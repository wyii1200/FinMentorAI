import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class SpentScreen extends StatelessWidget {
  final VoidCallback onBack;

  const SpentScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<UserProvider>();

    final totalSpent = user.expenses;

    final shopping = totalSpent * 0.35;
    final food = totalSpent * 0.27;
    final transport = totalSpent * 0.18;
    final bills = totalSpent * 0.20;

    final categories = [
      _SpendingCategory(
        title: 'Shopping',
        amount: shopping,
        color: AppColors.warning,
      ),
      _SpendingCategory(
        title: 'Food & Drinks',
        amount: food,
        color: AppColors.info,
      ),
      _SpendingCategory(
        title: 'Transport',
        amount: transport,
        color: AppColors.primary,
      ),
      _SpendingCategory(
        title: 'Bills',
        amount: bills,
        color: AppColors.success,
      ),
    ];

    final topCategory = categories.reduce(
      (a, b) => a.amount >= b.amount ? a : b,
    );

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
                          _formatCurrency(totalSpent),
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.danger,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          totalSpent > 0
                              ? 'Your largest estimated expense category is ${topCategory.title}.'
                              : 'No spending data has been added yet. Complete your financial setup to unlock more useful insights.',
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
                    'Estimated Category Breakdown',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'These categories are a simple frontend estimate until detailed spending records are connected.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    child: Column(
                      children: [
                        _buildCategoryItem(
                          context,
                          title: 'Shopping',
                          amount: _formatCurrencyCompact(shopping),
                          share: _shareText(shopping, totalSpent),
                          color: AppColors.warning,
                          progress: _progress(shopping, totalSpent),
                          isLast: false,
                        ),
                        _buildCategoryItem(
                          context,
                          title: 'Food & Drinks',
                          amount: _formatCurrencyCompact(food),
                          share: _shareText(food, totalSpent),
                          color: AppColors.info,
                          progress: _progress(food, totalSpent),
                          isLast: false,
                        ),
                        _buildCategoryItem(
                          context,
                          title: 'Transport',
                          amount: _formatCurrencyCompact(transport),
                          share: _shareText(transport, totalSpent),
                          color: AppColors.primary,
                          progress: _progress(transport, totalSpent),
                          isLast: false,
                        ),
                        _buildCategoryItem(
                          context,
                          title: 'Bills',
                          amount: _formatCurrencyCompact(bills),
                          share: _shareText(bills, totalSpent),
                          color: AppColors.success,
                          progress: _progress(bills, totalSpent),
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
                            _spendingInsight(user, topCategory.title),
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
                  backgroundColor: color.withOpacity(0.14),
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, color: AppColors.border),
      ],
    );
  }

  String _spendingInsight(UserProvider user, String topCategory) {
    if (user.expenses <= 0) {
      return 'Once your monthly expenses are added, FinMentor AI can highlight which categories may be limiting your savings potential.';
    }

    if (user.availableToSave < 0) {
      return 'Your current spending is above your monthly financial capacity. Start by reviewing $topCategory and any non-essential expenses.';
    }

    if (user.expenses > user.income * 0.6) {
      return 'Your spending is taking a large share of income. Reducing $topCategory even slightly could improve monthly breathing room.';
    }

    return 'Your spending is still within a more manageable range, but trimming $topCategory could strengthen your savings rate further.';
  }

  String _formatCurrency(double value) {
    return 'RM ${value.toStringAsFixed(2)}';
  }

  String _formatCurrencyCompact(double value) {
    if (value >= 1000) {
      return 'RM ${(value / 1000).toStringAsFixed(1)}k';
    }
    return 'RM ${value.toStringAsFixed(0)}';
  }

  String _shareText(double amount, double total) {
    if (total <= 0) return '0%';
    return '${((amount / total) * 100).round()}%';
  }

  double _progress(double amount, double total) {
    if (total <= 0) return 0;
    return (amount / total).clamp(0.0, 1.0);
  }
}

class _SpendingCategory {
  final String title;
  final double amount;
  final Color color;

  const _SpendingCategory({
    required this.title,
    required this.amount,
    required this.color,
  });
}
