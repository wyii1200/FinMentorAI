import 'package:flutter/material.dart';
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
    final metrics = _buildMetrics();

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
          _buildMainScoreCard(theme),
          const SizedBox(height: 28),
          _buildBreakdownHeader(theme),
          const SizedBox(height: 16),
          _buildMetricsList(theme, metrics),
          const SizedBox(height: 28),
          _buildAIAdviceCard(theme),
        ],
      ),
    );
  }

  List<ResilienceMetric> _buildMetrics() {
    if (_isStressTestActive) {
      return const [
        ResilienceMetric(
          emoji: '💰',
          title: 'Emergency Fund',
          score: 3.0,
          color: AppColors.danger,
          description: 'Covers only 45 days in a job loss scenario.',
        ),
        ResilienceMetric(
          emoji: '🛡️',
          title: 'Insurance Coverage',
          score: 4.0,
          color: AppColors.warning,
          description: 'Basic protection only — no income replacement buffer.',
        ),
        ResilienceMetric(
          emoji: '📉',
          title: 'Debt-to-Income',
          score: 5.0,
          color: AppColors.warning,
          description: 'Debt becomes harder to manage when income drops.',
        ),
        ResilienceMetric(
          emoji: '💸',
          title: 'Monthly Savings',
          score: 6.0,
          color: AppColors.info,
          description: 'Savings habit helps, but not enough for a major shock.',
        ),
      ];
    }

    return const [
      ResilienceMetric(
        emoji: '💰',
        title: 'Emergency Fund',
        score: 4.0,
        color: AppColors.danger,
        description: 'Covers 1.5 months — target: 6 months.',
      ),
      ResilienceMetric(
        emoji: '🛡️',
        title: 'Insurance Coverage',
        score: 5.0,
        color: AppColors.warning,
        description: 'Basic health only — no income protection.',
      ),
      ResilienceMetric(
        emoji: '📉',
        title: 'Debt-to-Income',
        score: 7.0,
        color: AppColors.primary,
        description: '22% — still within a manageable range.',
      ),
      ResilienceMetric(
        emoji: '💸',
        title: 'Monthly Savings',
        score: 8.0,
        color: AppColors.info,
        description: '20% of income — a strong savings habit.',
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
            subtitle: 'Financial health beyond your balance',
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

  Widget _buildMainScoreCard(ThemeData theme) {
    final score = _isStressTestActive ? 4.8 : 6.2;
    final scoreColor =
        _isStressTestActive ? AppColors.danger : AppColors.warning;

    final label = _isStressTestActive
        ? '⚠️ HIGH RISK IN RECESSION'
        : '⚡ MODERATE RESILIENCE';

    final labelBg =
        _isStressTestActive ? AppColors.danger : AppColors.subtleWarningBg;

    final labelTextColor =
        _isStressTestActive ? Colors.white : AppColors.warning;

    final description = _isStressTestActive
        ? 'In a job loss scenario, you may only have about 45 days of financial safety.'
        : 'You can survive about 3.1 months without income based on your current profile.';

    return AppCard(
      child: Column(
        children: [
          const SizedBox(height: 6),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: score / 10),
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
                                '${metric.score.toInt()}/10',
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

  Widget _buildAIAdviceCard(ThemeData theme) {
    final title =
        _isStressTestActive ? 'Path to Safer Recovery' : 'Path to 8.5 (Robust)';

    final adviceItems = _isStressTestActive
        ? const [
            'Build a 3-month emergency fund as the first priority.',
            'Reduce fixed monthly commitments before taking new debt.',
            'Add income protection or a basic backup coverage plan.',
          ]
        : const [
            'Boost emergency fund to RM 12,500.',
            'Move savings into a higher-yield savings option.',
            'Consolidate short-term BNPL commitments into a simpler plan.',
          ];

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
            color: const Color(0xFF1E1B4B).withValues(alpha: 0.35),
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
                  color: Colors.white.withValues(alpha: 0.10),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Your action plan would be generated here.',
                    ),
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
