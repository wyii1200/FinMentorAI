import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int) onNavigate;

  const DashboardScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<UserProvider>();

    return RefreshIndicator(
      onRefresh: () async => Future.delayed(const Duration(seconds: 1)),
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(theme, user),
            const SizedBox(height: 24),
            _buildSectionHeader(theme, 'Financial Snapshot'),
            const SizedBox(height: 12),
            _buildStatRow(theme, user),
            const SizedBox(height: 20),
            _buildRiskAlert(theme, user),
            const SizedBox(height: 24),
            _buildSectionHeader(theme, 'Smart Tools'),
            const SizedBox(height: 12),
            _buildFeatureGrid(),
            const SizedBox(height: 24),
            _buildSectionHeader(theme, 'Quick Insights'),
            const SizedBox(height: 12),
            _buildInsightCards(theme, user),
            const SizedBox(height: 24),
            _buildSectionHeader(theme, 'Recent Activity'),
            const SizedBox(height: 12),
            _buildActivityList(theme, user),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildHeaderCard(ThemeData theme, UserProvider user) {
    final firstName = user.userName.trim().isEmpty
        ? 'there'
        : user.userName.trim().split(' ').first;

    final scoreOutOfTen = (user.resilienceScore / 10).clamp(0.0, 10.0);
    final level = _getLevel(user.resilienceScore);
    final scoreMessage = _getResilienceMessage(user);

    return GradientCard(
      colors: const [AppColors.primary, Color(0xFF064E3B)],
      radius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => onNavigate(10),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      firstName.isNotEmpty ? firstName[0].toUpperCase() : 'F',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good to see you,',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      '$firstName 👋',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onNavigate(4),
              borderRadius: BorderRadius.circular(20),
              child: Ink(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.10)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Resilience Score',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            level,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: scoreOutOfTen.toStringAsFixed(1),
                            style: theme.textTheme.displayMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          TextSpan(
                            text: ' /10',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white60,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: (user.resilienceScore / 100).clamp(0.0, 1.0),
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.secondary,
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            scoreMessage,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: Colors.white70,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(ThemeData theme, UserProvider user) {
    final savedAmount = user.currentSavings;

    return Row(
      children: [
        _buildStatItem(
          theme,
          emoji: '💰',
          label: 'Income',
          value: _formatCurrencyCompact(user.income),
          color: AppColors.primary,
          onTap: () => onNavigate(6),
        ),
        const SizedBox(width: 10),
        _buildStatItem(
          theme,
          emoji: '💸',
          label: 'Spent',
          value: _formatCurrencyCompact(user.expenses),
          color: AppColors.danger,
          onTap: () => onNavigate(7),
        ),
        const SizedBox(width: 10),
        _buildStatItem(
          theme,
          emoji: '🏦',
          label: 'Saved',
          value: _formatCurrencyCompact(savedAmount),
          color: AppColors.info,
          onTap: () => onNavigate(8),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    ThemeData theme, {
    required String emoji,
    required String label,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: AppCard(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
            child: Column(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 10),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.18,
      children: [
        FeatureButton(
          icon: '🔍',
          label: 'Spending\nAnalyzer',
          bgColor: AppColors.subtleInfoBg,
          accentColor: AppColors.info,
          onTap: () => onNavigate(1),
        ),
        FeatureButton(
          icon: '📈',
          label: 'Future\nSimulator',
          bgColor: AppColors.subtleSuccessBg,
          accentColor: AppColors.primary,
          onTap: () => onNavigate(2),
        ),
      ],
    );
  }

  Widget _buildRiskAlert(ThemeData theme, UserProvider user) {
    final bnplRatio =
        user.income > 0 ? user.bnplCommitments / user.income : 0.0;

    String title;
    String message;
    Color titleColor;
    Color subtitleColor;
    Color cardColor;
    String emoji;

    if (bnplRatio >= 0.2) {
      title = 'BNPL Alert';
      message =
          'Commitments exceed 20% of your income. Consider reducing short-term debt.';
      titleColor = const Color(0xFF9A3412);
      subtitleColor = const Color(0xFFC2410C);
      cardColor = AppColors.subtleWarningBg;
      emoji = '⚠️';
    } else if (user.bnplCommitments > 0) {
      title = 'BNPL Under Control';
      message =
          'Your BNPL usage is still manageable, but keep monitoring it monthly.';
      titleColor = const Color(0xFF166534);
      subtitleColor = const Color(0xFF15803D);
      cardColor = AppColors.subtleSuccessBg;
      emoji = '✅';
    } else {
      title = 'No BNPL Commitments';
      message = 'Great job keeping your short-term debt at zero.';
      titleColor = const Color(0xFF166534);
      subtitleColor = const Color(0xFF15803D);
      cardColor = AppColors.subtleSuccessBg;
      emoji = '🌟';
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onNavigate(3),
        borderRadius: BorderRadius.circular(24),
        child: AppCard(
          color: cardColor,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: titleColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightCards(ThemeData theme, UserProvider user) {
    final disposable = user.availableToSave;
    final savingsRate = user.savingsRate;

    return Column(
      children: [
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.subtleInfoBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.pie_chart_outline_rounded,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available to Save',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(disposable),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: disposable >= 0
                            ? AppColors.textPrimary
                            : AppColors.danger,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      disposable >= 0
                          ? 'This is what remains after expenses and BNPL commitments.'
                          : 'You are overspending beyond your monthly capacity.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.subtleSuccessBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.savings_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Savings Rate',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${savingsRate.toStringAsFixed(1)}%',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'A higher rate gives you stronger financial resilience.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityList(ThemeData theme, UserProvider user) {
    final disposable = user.availableToSave > 0 ? user.availableToSave : 0.0;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _activityTile(
            theme,
            '💼',
            'Monthly Income Added',
            'This month',
            _formatSignedCurrency(user.income, positive: true),
            AppColors.success,
          ),
          const Divider(height: 1, indent: 60),
          _activityTile(
            theme,
            '💳',
            'BNPL Commitments Logged',
            'This month',
            _formatSignedCurrency(user.bnplCommitments, positive: false),
            AppColors.danger,
          ),
          const Divider(height: 1, indent: 60),
          _activityTile(
            theme,
            '🏦',
            'Available to Save',
            'This month',
            _formatSignedCurrency(disposable, positive: false),
            AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _activityTile(
    ThemeData theme,
    String icon,
    String label,
    String date,
    String amt,
    Color color,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(icon, style: const TextStyle(fontSize: 18)),
      ),
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        date,
        style: theme.textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Text(
        amt,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  String _formatCurrency(double value) {
    final absValue = value.abs().toStringAsFixed(0);
    return 'RM $absValue';
  }

  String _formatSignedCurrency(double value, {required bool positive}) {
    final sign = positive ? '+' : '-';
    return '$sign${_formatCurrency(value)}';
  }

  String _formatCurrencyCompact(double value) {
    if (value >= 1000) {
      return 'RM ${(value / 1000).toStringAsFixed(1)}k';
    }
    return 'RM ${value.toStringAsFixed(0)}';
  }

  String _getLevel(double score) {
    if (score >= 80) return 'Level 8';
    if (score >= 70) return 'Level 7';
    if (score >= 60) return 'Level 6';
    if (score >= 50) return 'Level 5';
    if (score >= 40) return 'Level 4';
    if (score >= 30) return 'Level 3';
    if (score >= 20) return 'Level 2';
    if (score >= 10) return 'Level 1';
    return 'Level 0';
  }

  String _getResilienceMessage(UserProvider user) {
    final disposable = user.availableToSave;
    final savingsRate = user.savingsRate;

    if (disposable < 0) {
      return 'Your current spending is above your monthly income. Immediate adjustment is needed.';
    }

    if (savingsRate >= 25) {
      return 'You have strong monthly breathing room and a healthier resilience base.';
    }

    if (savingsRate >= 10) {
      return 'Your finances are stable, but there is still room to strengthen your safety net.';
    }

    return 'Your resilience is still fragile. Increasing savings can improve your stability.';
  }
}
