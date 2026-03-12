import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class IncomeScreen extends StatelessWidget {
  final VoidCallback onBack;

  const IncomeScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<UserProvider>();

    final income = user.income;
    final salaryPortion = income * 0.85;
    final sideIncomePortion = income * 0.10;
    final otherPortion = income * 0.05;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: onBack,
        ),
        title: Text(
          'Income Overview',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Track where your money comes from and how stable your monthly income is.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This Month',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatCurrency(income),
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AppTag(
                    label: _incomeStabilityLabel(income),
                    bgColor: _incomeStabilityBg(income),
                    textColor: _incomeStabilityColor(income),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Estimated Income Sources',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'These categories are a simple frontend estimate until connected income records are available.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _IncomeTile(
                    icon: '💼',
                    title: 'Primary Income',
                    subtitle: 'Main monthly income source',
                    amount: '+${_formatCurrencyCompact(salaryPortion)}',
                    isLast: false,
                  ),
                  _IncomeTile(
                    icon: '🎨',
                    title: 'Side Income',
                    subtitle: 'Freelance / extra earnings',
                    amount: '+${_formatCurrencyCompact(sideIncomePortion)}',
                    isLast: false,
                  ),
                  _IncomeTile(
                    icon: '🎁',
                    title: 'Other Sources',
                    subtitle: 'Allowance / miscellaneous',
                    amount: '+${_formatCurrencyCompact(otherPortion)}',
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildIncomeHealthCard(theme, user),
            const SizedBox(height: 20),
            AppCard(
              color: AppColors.subtleInfoBg,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Diversifying income sources can improve financial resilience, especially during unexpected disruptions.',
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
    );
  }

  Widget _buildIncomeHealthCard(ThemeData theme, UserProvider user) {
    final income = user.income;
    final expenses = user.expenses;
    final bnpl = user.bnplCommitments;
    final available = user.availableToSave;

    final healthy = available >= 0;

    return AppCard(
      color: healthy ? AppColors.subtleSuccessBg : AppColors.subtleWarningBg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            healthy ? Icons.trending_up_rounded : Icons.warning_amber_rounded,
            color: healthy ? AppColors.success : AppColors.warning,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              income <= 0
                  ? 'No monthly income has been added yet. Complete your financial setup to unlock better insights.'
                  : healthy
                      ? 'After expenses and BNPL commitments, your income still leaves ${_formatCurrency(available)} of monthly breathing room.'
                      : 'Your current expenses and BNPL commitments exceed your income by ${_formatCurrency((expenses + bnpl - income).abs())}.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _incomeStabilityLabel(double income) {
    if (income >= 3000) return 'Stable Income';
    if (income >= 1500) return 'Developing Income';
    if (income > 0) return 'Starter Income';
    return 'No Income Added';
  }

  Color _incomeStabilityColor(double income) {
    if (income >= 3000) return AppColors.success;
    if (income >= 1500) return AppColors.warning;
    if (income > 0) return AppColors.info;
    return AppColors.textSecondary;
  }

  Color _incomeStabilityBg(double income) {
    if (income >= 3000) return AppColors.subtleSuccessBg;
    if (income >= 1500) return AppColors.subtleWarningBg;
    if (income > 0) return AppColors.subtleInfoBg;
    return AppColors.background;
  }

  String _formatCurrency(double value) {
    return 'RM ${value.toStringAsFixed(0)}';
  }

  String _formatCurrencyCompact(double value) {
    if (value >= 1000) {
      return 'RM ${(value / 1000).toStringAsFixed(1)}k';
    }
    return 'RM ${value.toStringAsFixed(0)}';
  }
}

class _IncomeTile extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final String amount;
  final bool isLast;

  const _IncomeTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 6,
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 18)),
          ),
          title: Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          trailing: Text(
            amount,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.success,
            ),
          ),
        ),
        if (!isLast) const Divider(height: 1, indent: 72, endIndent: 16),
      ],
    );
  }
}