import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

import 'package:cloud_functions/cloud_functions.dart';

class ResilienceScreen extends StatefulWidget {
  const ResilienceScreen({super.key});

  @override
  State<ResilienceScreen> createState() => _ResilienceScreenState();
}

class _ResilienceScreenState extends State<ResilienceScreen> {
  bool _isStressTestActive = false;

  Map<String, dynamic>? backendData;
  bool loading = true;
  String? errorMsg;

  Future<Map<String, dynamic>> _fetchResilience(UserProvider user) async {
    final callable = FirebaseFunctions.instance.httpsCallable('calcResilience');

    final result = await callable.call({
      "savings":    user.currentSavings,
      "fixedExp":   user.expenses,
      "income":     user.income,
      "varExp":     0,
      "insurance":  0,
      "bnplDebt":   user.bnplCommitments,
      "dependents": 0,
    });

    return Map<String, dynamic>.from(result.data);
  }

  @override
  void initState() {
    super.initState();
    _loadResilience();
  }

  Future<void> _loadResilience() async {
    setState(() { loading = true; errorMsg = null; });

    try {
      final user = context.read<UserProvider>();
      final data = await _fetchResilience(user);

      setState(() {
        backendData = data;
        loading     = false;
      });

      // ── Update dashboard score immediately ──────────────────────────────
      // Backend returns scoreOut10 (0–10). UserProvider stores 0–100,
      // so updateResilienceScore() multiplies ×10 internally.
      if (mounted) {
        final scoreOut10 = (data['scoreOut10'] as num).toDouble();
        context.read<UserProvider>().updateResilienceScore(scoreOut10);
      }

    } catch (e) {
      setState(() {
        loading  = false;
        errorMsg = 'Could not load resilience data. Pull down to retry.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMsg != null || backendData == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 16),
              Text(
                errorMsg ?? 'Something went wrong.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadResilience,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final user  = context.watch<UserProvider>();
    final metrics = _buildMetrics(user);

    return RefreshIndicator(
      onRefresh: _loadResilience,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 24),
            _buildMainScoreCard(theme),
            const SizedBox(height: 28),
            _buildBreakdownHeader(theme),
            const SizedBox(height: 16),
            _buildMetricsList(theme, metrics),
            const SizedBox(height: 28),
            _buildAIAdviceCard(theme, user),
          ],
        ),
      ),
    );
  }

  List<ResilienceMetric> _buildMetrics(UserProvider user) {
    final income   = user.income;
    final expenses = user.expenses;
    final bnpl     = user.bnplCommitments;
    final savings  = user.currentSavings;
    final goal     = user.savingsGoal;

    final testedIncome    = _isStressTestActive ? income * 0.6 : income;
    final testedAvailable = testedIncome - expenses - bnpl;

    final emergencyMonths = expenses > 0 ? savings / expenses : 0.0;
    final bnplRatio       = testedIncome > 0 ? bnpl / testedIncome : 0.0;
    final savingsRate     = testedIncome > 0 ? testedAvailable / testedIncome : 0.0;
    final goalProgress    = goal > 0 ? (savings / goal).clamp(0.0, 1.0) : 0.0;

    final emergencyScore      = _scoreFromMonths(emergencyMonths);
    final debtScore           = _scoreFromBnplRatio(bnplRatio);
    final monthlySavingsScore = _scoreFromSavingsRate(savingsRate);
    final goalScore           = _scoreFromGoalProgress(goalProgress);

    return [
      ResilienceMetric(
        emoji: '🛟',
        title: 'Emergency Buffer',
        score: emergencyScore,
        color: _scoreColor(emergencyScore),
        description: emergencyMonths <= 0
            ? 'You do not yet have a usable emergency buffer.'
            : 'Your savings cover about ${emergencyMonths.toStringAsFixed(1)} months of expenses.',
      ),
      ResilienceMetric(
        emoji: '💳',
        title: 'Debt Pressure',
        score: debtScore,
        color: _scoreColor(debtScore),
        description: bnpl <= 0
            ? 'You currently have no BNPL debt pressure.'
            : 'BNPL uses ${(bnplRatio * 100).toStringAsFixed(0)}% of your${_isStressTestActive ? ' tested' : ''} income.',
      ),
      ResilienceMetric(
        emoji: '💸',
        title: 'Monthly Saving Capacity',
        score: monthlySavingsScore,
        color: _scoreColor(monthlySavingsScore),
        description: testedAvailable >= 0
            ? 'You have ${_formatCurrency(testedAvailable)} left after expenses and BNPL.'
            : 'You are overspending by ${_formatCurrency(testedAvailable.abs())} under this scenario.',
      ),
      ResilienceMetric(
        emoji: '🎯',
        title: 'Goal Progress',
        score: goalScore,
        color: _scoreColor(goalScore),
        description: goal > 0
            ? 'You have completed ${(goalProgress * 100).toStringAsFixed(0)}% of your savings goal.'
            : 'Set a savings goal to track your resilience progress.',
      ),
    ];
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: SectionHeader(
            title: '🛡️ Resilience Score',
            subtitle: 'Financial strength beyond your account balance',
          ),
        ),
        const SizedBox(width: 12),
        Column(
          children: [
            Switch.adaptive(
              value: _isStressTestActive,
              activeColor: AppColors.danger,
              onChanged: (val) => setState(() => _isStressTestActive = val),
            ),
            Text(
              'STRESS TEST',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 10, fontWeight: FontWeight.w800,
                color: AppColors.textSecondary, letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainScoreCard(ThemeData theme) {
    final baseScore     = (backendData!['scoreOut10']      as num).toDouble();
    final stressScore   = (backendData!['stressTestScore'] as num).toDouble();
    final displayScore  = _isStressTestActive ? stressScore : baseScore;

    final scoreColor = displayScore >= 7.5 ? AppColors.success
        : displayScore >= 5 ? AppColors.warning : AppColors.danger;

    final label = _isStressTestActive
        ? _stressLabel(displayScore)
        : backendData!['tagLabel'] as String;

    final labelBg = displayScore >= 7.5 ? AppColors.subtleSuccessBg
        : displayScore >= 5 ? AppColors.subtleWarningBg : const Color(0xFFFEE2E2);

    final description = _isStressTestActive
        ? '${backendData!['stressDays']} days of safety under a 60% income scenario'
        : '~${backendData!['survivalMonths']} months without income (emergency fund only)';

    return AppCard(
      child: Column(
        children: [
          const SizedBox(height: 6),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: displayScore / 10),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 170, height: 170,
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 14,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation(scoreColor),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        (value * 10).toStringAsFixed(1),
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w900, color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'OUT OF 10',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w800, color: AppColors.textSecondary,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          AppTag(label: label, textColor: scoreColor, bgColor: labelBg),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary, fontWeight: FontWeight.w500, height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownHeader(ThemeData theme) {
    return Row(
      children: [
        Text(
          'Score Breakdown',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800, color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.textSecondary),
      ],
    );
  }

  Widget _buildMetricsList(ThemeData theme, List<ResilienceMetric> metrics) {
    return AppCard(
      child: Column(
        children: metrics.asMap().entries.map((entry) {
          final metric = entry.value;
          final isLast = entry.key == metrics.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _iconBox(metric.emoji),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(metric.title,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary)),
                              ),
                              Text('${metric.score.toStringAsFixed(1)}/10',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                      color: metric.color,
                                      fontWeight: FontWeight.w900)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          AppProgressBar(value: metric.score / 10, color: metric.color, height: 8),
                          const SizedBox(height: 10),
                          Text(metric.description,
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary, height: 1.45)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast) const Divider(height: 32, color: AppColors.border),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _iconBox(String emoji) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 22)),
    );
  }

  Widget _buildAIAdviceCard(ThemeData theme, UserProvider user) {
    final tips  = List<String>.from(backendData!['tips'] as List? ?? []);
    final title = _isStressTestActive ? 'Safer Recovery Plan' : 'How to Strengthen Your Score';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E1B4B).withValues(alpha: 0.35),
            blurRadius: 20, offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10), shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: Color(0xFFA5B4FC), size: 18),
              ),
              const SizedBox(width: 10),
              Text('AI STRATEGY',
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFFA5B4FC),
                      fontWeight: FontWeight.w900, letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 20),
          Text(title,
              style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          ...tips.map((tip) => _tipItem(theme, tip)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showActionPlanSheet(context, user),
              child: const Text('View Full Action Plan'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tipItem(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(Icons.bolt_rounded, color: Color(0xFFFFD166), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w500, height: 1.45)),
          ),
        ],
      ),
    );
  }

  void _showActionPlanSheet(BuildContext context, UserProvider user) {
    final theme        = Theme.of(context);
    final displayScore = _isStressTestActive
        ? (backendData!['stressTestScore'] as num).toDouble()
        : (backendData!['scoreOut10'] as num).toDouble();
    final statusLabel  = _isStressTestActive
        ? _stressLabel(displayScore)
        : backendData!['tagLabel'] as String;

    final actionItems     = _generateDetailedActionPlan(user);
    final weeklyFocus     = _generateWeeklyFocus(user);
    final estimatedImpact = _estimateImprovement(user);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.82, minChildSize: 0.60, maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 44, height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isStressTestActive
                              ? 'Your Stress-Test Action Plan'
                              : 'Your Full Action Plan',
                          style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'A detailed AI-guided plan based on your current financial profile.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary, height: 1.45),
                        ),
                        const SizedBox(height: 20),
                        _buildPlanSummaryCard(theme, displayScore, statusLabel, estimatedImpact),
                        const SizedBox(height: 20),
                        _sheetTitle(theme, 'Top Priorities'),
                        const SizedBox(height: 12),
                        ...actionItems.asMap().entries.map((e) => _actionPlanItem(
                            theme, index: e.key + 1,
                            title: e.value.title, description: e.value.description)),
                        const SizedBox(height: 20),
                        _sheetTitle(theme, 'This Week\'s Focus'),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(weeklyFocus,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600, height: 1.5)),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Got It'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlanSummaryCard(ThemeData theme, double score, String label, String impact) {
    final scoreColor = score >= 7.5 ? AppColors.success
        : score >= 5 ? AppColors.warning : AppColors.danger;
    final labelBg = score >= 7.5 ? AppColors.subtleSuccessBg
        : score >= 5 ? AppColors.subtleWarningBg : const Color(0xFFFEE2E2);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scoreColor.withValues(alpha: 0.12), Colors.white],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scoreColor.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Current Score',
              style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('${score.toStringAsFixed(1)}/10',
                  style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900, color: scoreColor)),
              const SizedBox(width: 12),
              AppTag(label: label, textColor: scoreColor, bgColor: labelBg),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.trending_up_rounded, size: 18, color: AppColors.success),
              const SizedBox(width: 8),
              Expanded(
                child: Text(impact,
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600, height: 1.45)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sheetTitle(ThemeData theme, String title) {
    return Text(title,
        style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800, color: AppColors.textPrimary));
  }

  Widget _actionPlanItem(ThemeData theme,
      {required int index, required String title, required String description}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34, height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.textPrimary, borderRadius: BorderRadius.circular(12),
            ),
            child: Text('$index',
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                Text(description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary, height: 1.45)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Action plan generation ────────────────────────────────────────────────
  List<ActionPlanItem> _generateDetailedActionPlan(UserProvider user) {
    final items = <ActionPlanItem>[];
    final emergencyMonths = user.expenses > 0 ? user.currentSavings / user.expenses : 0.0;
    final bnplRatio       = user.income > 0 ? user.bnplCommitments / user.income : 0.0;
    final available       = user.availableToSave;
    final goalProgress    = user.savingsGoal > 0
        ? (user.currentSavings / user.savingsGoal).clamp(0.0, 1.0) : 0.0;

    if (emergencyMonths < 3) {
      items.add(const ActionPlanItem(
        title: 'Strengthen your emergency buffer',
        description: 'Prioritize building savings until you reach at least 3 months of essential expenses.',
      ));
    }
    if (bnplRatio >= 0.2) {
      items.add(const ActionPlanItem(
        title: 'Reduce BNPL pressure',
        description: 'BNPL is taking a large share of income. Avoid new installment commitments for now.',
      ));
    }
    if (available <= 0) {
      items.add(const ActionPlanItem(
        title: 'Create positive monthly cash flow',
        description: 'Review non-essential spending and trim at least one recurring expense.',
      ));
    } else if (available < 300) {
      items.add(const ActionPlanItem(
        title: 'Increase monthly savings consistency',
        description: 'Set a fixed monthly auto-transfer so saving happens before extra spending.',
      ));
    }
    if (user.savingsGoal > 0 && goalProgress < 0.5) {
      items.add(const ActionPlanItem(
        title: 'Accelerate progress toward your goal',
        description: 'Break your savings goal into smaller milestones to stay motivated.',
      ));
    }
    if (_isStressTestActive) {
      items.add(const ActionPlanItem(
        title: 'Prepare for lower-income scenarios',
        description: 'Focus on housing, food, and transport. Delay non-urgent purchases.',
      ));
    }
    if (items.isEmpty) {
      items.addAll(const [
        ActionPlanItem(title: 'Maintain your healthy financial routine',
            description: 'Keep savings consistent and review expenses regularly.'),
        ActionPlanItem(title: 'Optimize where idle cash sits',
            description: 'Consider a low-risk account with better returns for excess savings.'),
        ActionPlanItem(title: 'Keep improving long-term resilience',
            description: 'As income grows, revise your savings target upward.'),
      ]);
    }
    return items.take(4).toList();
  }

  String _generateWeeklyFocus(UserProvider user) {
    final emergencyMonths = user.expenses > 0 ? user.currentSavings / user.expenses : 0.0;
    final bnplRatio       = user.income > 0 ? user.bnplCommitments / user.income : 0.0;
    final available       = user.availableToSave;

    if (_isStressTestActive) return 'This week, protect essentials and identify one expense you can temporarily reduce if income drops.';
    if (emergencyMonths < 1)  return 'This week, set aside your first emergency-fund amount, even a small one. Building the habit matters first.';
    if (bnplRatio >= 0.2)     return 'This week, avoid new BNPL purchases and review which commitments can be cleared earlier.';
    if (available > 0)        return 'This week, transfer a fixed amount into savings right after income arrives.';
    return 'This week, review recent spending and cut one non-essential category.';
  }

  String _estimateImprovement(UserProvider user) {
    final emergencyMonths = user.expenses > 0 ? user.currentSavings / user.expenses : 0.0;
    final bnplRatio       = user.income > 0 ? user.bnplCommitments / user.income : 0.0;
    double impact = 0.8;
    if (emergencyMonths < 1) impact += 0.8;
    if (bnplRatio >= 0.2)    impact += 0.6;
    if (user.availableToSave > 0) impact += 0.4;
    if (_isStressTestActive) impact += 0.3;
    return 'Following these steps consistently could improve your score by about +${impact.toStringAsFixed(1)} points.';
  }

  // ── Scoring helpers ───────────────────────────────────────────────────────
  double _scoreFromMonths(double m) {
    if (m >= 6) return 10; if (m >= 4) return 8; if (m >= 3) return 7;
    if (m >= 2) return 5.5; if (m >= 1) return 4; if (m > 0) return 2.5;
    return 1;
  }

  double _scoreFromBnplRatio(double r) {
    if (r <= 0) return 10; if (r <= 0.10) return 8.5;
    if (r <= 0.20) return 6.5; if (r <= 0.30) return 4; return 2;
  }

  double _scoreFromSavingsRate(double r) {
    if (r >= 0.30) return 10; if (r >= 0.20) return 8;
    if (r >= 0.10) return 6; if (r >= 0.05) return 4;
    if (r >= 0) return 2.5; return 1;
  }

  double _scoreFromGoalProgress(double p) {
    if (p >= 1) return 10; if (p >= 0.75) return 8;
    if (p >= 0.50) return 6.5; if (p >= 0.25) return 4.5;
    if (p > 0) return 3; return 1.5;
  }

  Color _scoreColor(double s) {
    if (s >= 7.5) return AppColors.success;
    if (s >= 5)   return AppColors.warning;
    return AppColors.danger;
  }

  String _stressLabel(double s) {
    if (s >= 7)   return '✅ STABLE UNDER STRESS';
    if (s >= 4.5) return '⚠️ VULNERABLE IN STRESS';
    return '🚨 HIGH RISK IN STRESS';
  }

  String _formatCurrency(double v) => 'RM ${v.toStringAsFixed(0)}';
}

// ── Data classes ──────────────────────────────────────────────────────────────
class ResilienceMetric {
  final String emoji, title, description;
  final double score;
  final Color  color;
  const ResilienceMetric({
    required this.emoji, required this.title, required this.score,
    required this.color, required this.description,
  });
}

class ActionPlanItem {
  final String title, description;
  const ActionPlanItem({required this.title, required this.description});
}
