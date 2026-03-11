import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class ResilienceScreen extends StatefulWidget {
  const ResilienceScreen({super.key});

  @override
  State<ResilienceScreen> createState() => _ResilienceScreenState();
}

class _ResilienceScreenState extends State<ResilienceScreen> {
  bool _isStressTestActive = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<UserProvider>();
    final metrics = _buildMetrics(user);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme),
          const SizedBox(height: 24),
          _buildMainScoreCard(theme, user),
          const SizedBox(height: 28),
          _buildBreakdownHeader(theme),
          const SizedBox(height: 16),
          _buildMetricsList(theme, metrics),
          const SizedBox(height: 28),
          _buildAIAdviceCard(theme, user),
        ],
      ),
    );
  }

  List<ResilienceMetric> _buildMetrics(UserProvider user) {
    final income = user.income;
    final expenses = user.expenses;
    final bnpl = user.bnplCommitments;
    final savings = user.currentSavings;
    final goal = user.savingsGoal;

    final testedIncome = _isStressTestActive ? income * 0.6 : income;
    final testedAvailable = testedIncome - expenses - bnpl;

    final emergencyMonths = expenses > 0 ? savings / expenses : 0.0;
    final bnplRatio = testedIncome > 0 ? bnpl / testedIncome : 0.0;
    final savingsRate =
        testedIncome > 0 ? (testedAvailable / testedIncome) : 0.0;
    final goalProgress = goal > 0 ? (savings / goal).clamp(0.0, 1.0) : 0.0;

    final emergencyScore = _scoreFromMonths(emergencyMonths);
    final debtScore = _scoreFromBnplRatio(bnplRatio);
    final monthlySavingsScore = _scoreFromSavingsRate(savingsRate);
    final goalScore = _scoreFromGoalProgress(goalProgress);

    return [
      ResilienceMetric(
        emoji: '🛟',
        title: 'Emergency Buffer',
        score: emergencyScore,
        color: _scoreColor(emergencyScore),
        description: emergencyMonths <= 0
            ? 'You do not yet have a usable emergency buffer.'
            : 'Your current savings can cover about ${emergencyMonths.toStringAsFixed(1)} months of expenses.',
      ),
      ResilienceMetric(
        emoji: '💳',
        title: 'Debt Pressure',
        score: debtScore,
        color: _scoreColor(debtScore),
        description: bnpl <= 0
            ? 'You currently have no BNPL debt pressure.'
            : 'BNPL commitments use ${(bnplRatio * 100).toStringAsFixed(0)}% of your tested income.',
      ),
      ResilienceMetric(
        emoji: '💸',
        title: 'Monthly Saving Capacity',
        score: monthlySavingsScore,
        color: _scoreColor(monthlySavingsScore),
        description: testedAvailable >= 0
            ? 'You still have ${_formatCurrency(testedAvailable)} left after expenses and BNPL.'
            : 'You are overspending by ${_formatCurrency(testedAvailable.abs())} under this scenario.',
      ),
      ResilienceMetric(
        emoji: '🎯',
        title: 'Goal Progress',
        score: goalScore,
        color: _scoreColor(goalScore),
        description: goal > 0
            ? 'You have completed ${(goalProgress * 100).toStringAsFixed(0)}% of your current savings goal.'
            : 'Set a savings goal to track your resilience progress more clearly.',
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
              onChanged: (val) {
                setState(() {
                  _isStressTestActive = val;
                });
              },
            ),
            Text(
              'STRESS TEST',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainScoreCard(ThemeData theme, UserProvider user) {
    final baseScore = user.resilienceScore / 10;
    final stressAdjustedScore =
        (baseScore - _stressPenalty(user)).clamp(0.0, 10.0);
    final displayedScore =
        _isStressTestActive ? stressAdjustedScore : baseScore;

    final scoreColor = displayedScore >= 7.5
        ? AppColors.success
        : displayedScore >= 5
            ? AppColors.warning
            : AppColors.danger;

    final label = _isStressTestActive
        ? _stressLabel(displayedScore)
        : _normalLabel(displayedScore);

    final labelBg = displayedScore >= 7.5
        ? AppColors.subtleSuccessBg
        : displayedScore >= 5
            ? AppColors.subtleWarningBg
            : const Color(0xFFFEE2E2);

    final labelTextColor = displayedScore >= 7.5
        ? AppColors.success
        : displayedScore >= 5
            ? AppColors.warning
            : AppColors.danger;

    final description = _isStressTestActive
        ? _stressDescription(user)
        : _normalDescription(user);

    return AppCard(
      child: Column(
        children: [
          const SizedBox(height: 6),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: displayedScore / 10),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 170,
                    height: 170,
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
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'OUT OF 10',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textSecondary,
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
          AppTag(
            label: label,
            textColor: labelTextColor,
            bgColor: labelBg,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
              height: 1.45,
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
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        const Icon(
          Icons.info_outline_rounded,
          size: 16,
          color: AppColors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildMetricsList(
    ThemeData theme,
    List<ResilienceMetric> metrics,
  ) {
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
                    _buildIconBox(metric.emoji),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  metric.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Text(
                                '${metric.score.toStringAsFixed(1)}/10',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: metric.color,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          AppProgressBar(
                            value: metric.score / 10,
                            color: metric.color,
                            height: 8,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            metric.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.45,
                            ),
                          ),
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

  Widget _buildIconBox(String emoji) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        emoji,
        style: const TextStyle(fontSize: 22),
      ),
    );
  }

  Widget _buildAIAdviceCard(ThemeData theme, UserProvider user) {
    final adviceItems = _generateAdvice(user);
    final title = _isStressTestActive
        ? 'Safer Recovery Plan'
        : 'How to Strengthen Your Score';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E1B4B).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                  color: Colors.white.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFFA5B4FC),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'AI STRATEGY',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFFA5B4FC),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          ...adviceItems.map((tip) => _tipItem(theme, tip)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final message = _isStressTestActive
                    ? 'Stress-test action plan generated from your current financial profile.'
                    : 'Personalized action plan generated from your current resilience profile.';

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Generate Action Plan'),
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
            child: Icon(
              Icons.bolt_rounded,
              color: Color(0xFFFFD166),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _generateAdvice(UserProvider user) {
    final tips = <String>[];

    final availableToSave = user.availableToSave;
    final bnplRatio =
        user.income > 0 ? user.bnplCommitments / user.income : 0.0;
    final emergencyMonths =
        user.expenses > 0 ? user.currentSavings / user.expenses : 0.0;

    if (emergencyMonths < 3) {
      tips.add(
          'Build your emergency fund toward at least 3 months of expenses first.');
    }

    if (bnplRatio >= 0.2) {
      tips.add(
          'Reduce BNPL commitments below 20% of your income to lower debt pressure.');
    }

    if (availableToSave <= 0) {
      tips.add(
          'Cut non-essential monthly spending to create positive saving capacity.');
    } else if (availableToSave < user.savingsGoal * 0.2) {
      tips.add(
          'Increase your monthly transfer into savings to reach your goal faster.');
    }

    if (user.currentSavings < user.savingsGoal && user.savingsGoal > 0) {
      tips.add(
          'Stay consistent with savings contributions so your goal progress keeps moving.');
    }

    if (tips.isEmpty) {
      tips.add(
          'Your financial profile looks healthy. Keep maintaining your current saving discipline.');
      tips.add(
          'Review your savings goal regularly so your resilience grows with your income.');
      tips.add(
          'Consider growing idle savings into a higher-yield but low-risk account.');
    }

    return tips.take(3).toList();
  }

  double _stressPenalty(UserProvider user) {
    double penalty = 0.8;

    final expenseRatio = user.income > 0 ? user.expenses / user.income : 1.0;
    final bnplRatio =
        user.income > 0 ? user.bnplCommitments / user.income : 0.0;
    final emergencyMonths =
        user.expenses > 0 ? user.currentSavings / user.expenses : 0.0;

    if (expenseRatio > 0.7) penalty += 1.0;
    if (bnplRatio > 0.2) penalty += 0.8;
    if (emergencyMonths < 1) penalty += 0.9;
    if (emergencyMonths < 0.5) penalty += 0.5;

    return penalty;
  }

  String _normalLabel(double score) {
    if (score >= 8) return '✅ ROBUST RESILIENCE';
    if (score >= 5) return '⚡ MODERATE RESILIENCE';
    return '⚠️ FRAGILE RESILIENCE';
  }

  String _stressLabel(double score) {
    if (score >= 7) return '✅ STABLE UNDER STRESS';
    if (score >= 4.5) return '⚠️ VULNERABLE IN STRESS';
    return '🚨 HIGH RISK IN STRESS';
  }

  String _normalDescription(UserProvider user) {
    final months =
        user.expenses > 0 ? user.currentSavings / user.expenses : 0.0;

    if (months <= 0) {
      return 'You do not yet have an emergency buffer. Building savings will improve your resilience quickly.';
    }

    return 'Based on your current profile, your savings can cover about ${months.toStringAsFixed(1)} months of expenses.';
  }

  String _stressDescription(UserProvider user) {
    final stressedIncome = user.income * 0.6;
    final remaining = stressedIncome - user.expenses - user.bnplCommitments;

    if (remaining < 0) {
      return 'In a stress scenario with reduced income, your monthly finances would turn negative by ${_formatCurrency(remaining.abs())}.';
    }

    return 'Even under a lower-income scenario, you would still keep about ${_formatCurrency(remaining)} of monthly breathing room.';
  }

  double _scoreFromMonths(double months) {
    if (months >= 6) return 10.0;
    if (months >= 4) return 8.0;
    if (months >= 3) return 7.0;
    if (months >= 2) return 5.5;
    if (months >= 1) return 4.0;
    if (months > 0) return 2.5;
    return 1.0;
  }

  double _scoreFromBnplRatio(double ratio) {
    if (ratio <= 0) return 10.0;
    if (ratio <= 0.1) return 8.5;
    if (ratio <= 0.2) return 6.5;
    if (ratio <= 0.3) return 4.0;
    return 2.0;
  }

  double _scoreFromSavingsRate(double rate) {
    if (rate >= 0.3) return 10.0;
    if (rate >= 0.2) return 8.0;
    if (rate >= 0.1) return 6.0;
    if (rate >= 0.05) return 4.0;
    if (rate >= 0) return 2.5;
    return 1.0;
  }

  double _scoreFromGoalProgress(double progress) {
    if (progress >= 1) return 10.0;
    if (progress >= 0.75) return 8.0;
    if (progress >= 0.5) return 6.5;
    if (progress >= 0.25) return 4.5;
    if (progress > 0) return 3.0;
    return 1.5;
  }

  Color _scoreColor(double score) {
    if (score >= 7.5) return AppColors.success;
    if (score >= 5) return AppColors.warning;
    return AppColors.danger;
  }

  String _formatCurrency(double value) {
    return 'RM ${value.toStringAsFixed(0)}';
  }
}

class ResilienceMetric {
  final String emoji;
  final String title;
  final double score;
  final Color color;
  final String description;

  const ResilienceMetric({
    required this.emoji,
    required this.title,
    required this.score,
    required this.color,
    required this.description,
  });
}
