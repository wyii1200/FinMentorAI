import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class SpentScreen extends StatelessWidget {
  final VoidCallback onBack;

  const SpentScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.background,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: onBack,
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              titlePadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              title: Text(
                'Spending Breakdown',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppCard(
                    color: AppColors.subtleDangerBg,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Spent This Month',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'RM 2,800.00',
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.danger,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Your largest expense category is Shopping, followed by Food & Drinks.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Category Breakdown',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    child: Column(
                      children: [
                        _buildCategoryItem(
                          context,
                          title: 'Shopping',
                          amount: 'RM 1,200',
                          share: '43%',
                          color: AppColors.warning,
                          progress: 0.43,
                          isLast: false,
                        ),
                        _buildCategoryItem(
                          context,
                          title: 'Food & Drinks',
                          amount: 'RM 800',
                          share: '29%',
                          color: AppColors.info,
                          progress: 0.29,
                          isLast: false,
                        ),
                        _buildCategoryItem(
                          context,
                          title: 'Transport',
                          amount: 'RM 400',
                          share: '14%',
                          color: AppColors.primary,
                          progress: 0.14,
                          isLast: false,
                        ),
                        _buildCategoryItem(
                          context,
                          title: 'Bills',
                          amount: 'RM 400',
                          share: '14%',
                          color: AppColors.success,
                          progress: 0.14,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppCard(
                    color: AppColors.subtleWarningBg,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.lightbulb_outline_rounded,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Reducing discretionary spending in Shopping by even 10% could improve your monthly savings noticeably.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textPrimary,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context, {
    required String title,
    required String amount,
    required String share,
    required Color color,
    required double progress,
    required bool isLast,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    share,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    amount,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  color: color,
                  backgroundColor: color.withValues(alpha: 0.14),
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, color: AppColors.border),
      ],
    );
  }
}
