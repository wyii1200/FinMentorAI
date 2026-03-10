import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int) onNavigate;

  const DashboardScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            _buildHeaderCard(theme),
            const SizedBox(height: 24),
            _buildSectionHeader(theme, 'Financial Snapshot'),
            const SizedBox(height: 12),
            _buildStatRow(theme),
            const SizedBox(height: 20),
            _buildRiskAlert(theme),
            const SizedBox(height: 24),
            _buildSectionHeader(theme, 'Smart Tools'),
            const SizedBox(height: 12),
            _buildFeatureGrid(),
            const SizedBox(height: 24),
            _buildSectionHeader(theme, 'Recent Activity'),
            const SizedBox(height: 12),
            _buildActivityList(theme),
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

  Widget _buildHeaderCard(ThemeData theme) {
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
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/150?u=amir',
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good morning,',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      'Amir 👋',
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
          _buildResilienceScoreUI(theme),
        ],
      ),
    );
  }

  Widget _buildResilienceScoreUI(ThemeData theme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onNavigate(4),
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
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
                      color: AppColors.secondary.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Level 6',
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
                      text: '6.2',
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
                child: const LinearProgressIndicator(
                  value: 0.62,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation(AppColors.secondary),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'You can survive about 3.1 months without income.',
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
    );
  }

  Widget _buildStatRow(ThemeData theme) {
    return Row(
      children: [
        _buildStatItem(
          theme,
          emoji: '💰',
          label: 'Income',
          value: 'RM 3.5k',
          color: AppColors.primary,
          onTap: () => onNavigate(6),
        ),
        const SizedBox(width: 10),
        _buildStatItem(
          theme,
          emoji: '💸',
          label: 'Spent',
          value: 'RM 2.8k',
          color: AppColors.danger,
          onTap: () => onNavigate(7),
        ),
        const SizedBox(width: 10),
        _buildStatItem(
          theme,
          emoji: '🏦',
          label: 'Saved',
          value: 'RM 700',
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

  Widget _buildRiskAlert(ThemeData theme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onNavigate(3),
        borderRadius: BorderRadius.circular(24),
        child: AppCard(
          color: AppColors.subtleWarningBg,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text('⚠️', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BNPL Alert',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF9A3412),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Commitments exceed 20% of income.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFC2410C),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF9A3412),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityList(ThemeData theme) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _activityTile(
            theme,
            '🛍',
            'Shopee BNPL',
            'Mar 8',
            '-RM200',
            AppColors.danger,
          ),
          const Divider(height: 1, indent: 60),
          _activityTile(
            theme,
            '💼',
            'Salary Credit',
            'Mar 1',
            '+RM3,500',
            AppColors.success,
          ),
          const Divider(height: 1, indent: 60),
          _activityTile(
            theme,
            '🏦',
            'Auto Savings',
            'Mar 1',
            '-RM700',
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
}
