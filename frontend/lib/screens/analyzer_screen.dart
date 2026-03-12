import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class AnalyzerScreen extends StatefulWidget {
  const AnalyzerScreen({super.key});

  @override
  State<AnalyzerScreen> createState() => _AnalyzerScreenState();
}

class _AnalyzerScreenState extends State<AnalyzerScreen> {
  bool _analyzed = false;
  bool _initialized = false;

  late final TextEditingController _income;
  late final TextEditingController _expenses;
  late final TextEditingController _bnpl;
  late final TextEditingController _monthlySavingsPlan;

  static const _titleStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  @override
  void initState() {
    super.initState();
    _income = TextEditingController();
    _expenses = TextEditingController();
    _bnpl = TextEditingController();
    _monthlySavingsPlan = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;

    final user = context.read<UserProvider>();

    _income.text = _formatInitial(user.income, fallback: 3500);
    _expenses.text = _formatInitial(user.expenses, fallback: 2100);
    _bnpl.text = _formatInitial(user.bnplCommitments, fallback: 700);

    final suggestedMonthlySavings =
        user.availableToSave > 0 ? user.availableToSave : 700.0;
    _monthlySavingsPlan.text =
        _formatInitial(suggestedMonthlySavings, fallback: 700);

    _initialized = true;
  }

  double get _valIncome => double.tryParse(_income.text.trim()) ?? 0;
  double get _valExp => double.tryParse(_expenses.text.trim()) ?? 0;
  double get _valBnpl => double.tryParse(_bnpl.text.trim()) ?? 0;
  double get _valSav => double.tryParse(_monthlySavingsPlan.text.trim()) ?? 0;

  double get _safeIncome => _valIncome <= 0 ? 1 : _valIncome;

  double get _totalTracked => _valExp + _valBnpl + _valSav;

  @override
  void dispose() {
    _income.dispose();
    _expenses.dispose();
    _bnpl.dispose();
    _monthlySavingsPlan.dispose();
    super.dispose();
  }

  void _analyze() {
    FocusScope.of(context).unfocus();

    if (_valIncome <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid monthly income greater than 0.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_valExp < 0 || _valBnpl < 0 || _valSav < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Values cannot be negative.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final user = context.read<UserProvider>();

    user.updateIncome(_valIncome);
    user.updateExpenses(_valExp);
    user.updateBnplCommitments(_valBnpl);

    if (user.savingsGoal <= 0) {
      user.updateSavingsGoal(_valSav > 0 ? _valSav * 6 : 1000);
    }

    setState(() {
      _analyzed = true;
    });
  }

  List<PieChartSectionData> _getSections() {
    final income = _safeIncome;

    return [
      PieChartSectionData(
        value: _valExp <= 0 ? 0.01 : _valExp,
        color: AppColors.primary,
        title: '${((_valExp / income) * 100).toInt()}%',
        radius: 56,
        titleStyle: _titleStyle,
      ),
      PieChartSectionData(
        value: _valBnpl <= 0 ? 0.01 : _valBnpl,
        color: AppColors.danger,
        title: '${((_valBnpl / income) * 100).toInt()}%',
        radius: 56,
        titleStyle: _titleStyle,
      ),
      PieChartSectionData(
        value: _valSav <= 0 ? 0.01 : _valSav,
        color: AppColors.info,
        title: '${((_valSav / income) * 100).toInt()}%',
        radius: 56,
        titleStyle: _titleStyle,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: '🔍 AI Spending Analyzer',
            subtitle: 'Get a clearer picture of where your money goes',
          ),
          const SizedBox(height: 24),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Review Your Monthly Figures',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'These values are prefilled from your financial setup, and you can adjust them anytime.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),
                AppInputField(
                  label: '💰 Monthly Income (RM)',
                  controller: _income,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 14),
                AppInputField(
                  label: '💸 Essential Expenses (RM)',
                  controller: _expenses,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 14),
                AppInputField(
                  label: '💳 BNPL Commitments (RM)',
                  controller: _bnpl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 14),
                AppInputField(
                  label: '🏦 Planned Monthly Savings (RM)',
                  controller: _monthlySavingsPlan,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Analyze My Spending',
                  onTap: _analyze,
                ),
              ],
            ),
          ),
          if (_analyzed) ...[
            const SizedBox(height: 24),
            _buildSummaryCard(theme),
            const SizedBox(height: 16),
            _buildResultsSection(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCard(ThemeData theme) {
    final freeCash = _valIncome - (_valExp + _valBnpl + _valSav);
    final healthy = freeCash >= 0;

    return AppCard(
      color: healthy ? AppColors.subtleSuccessBg : AppColors.subtleWarningBg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              healthy ? '✅' : '⚠️',
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              healthy
                  ? 'You still have RM ${freeCash.toStringAsFixed(0)} unallocated after expenses, BNPL, and planned savings.'
                  : 'Your monthly commitments exceed your income by RM ${freeCash.abs().toStringAsFixed(0)}.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection(ThemeData theme) {
    final bnplRatio = (_valBnpl / _safeIncome) * 100;
    final expenseRatio = (_valExp / _safeIncome) * 100;
    final savingsRatio = (_valSav / _safeIncome) * 100;

    final isBnplRisky = bnplRatio > 15;
    final isExpenseHeavy = expenseRatio > 60;
    final monthsToSaveOneIncome =
        _valSav <= 0 ? double.infinity : (_valIncome / _valSav);

    return Column(
      children: [
        AppCard(
          child: Column(
            children: [
              Text(
                '📊 Spending Breakdown',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 4,
                        centerSpaceRadius: 72,
                        sections: _getSections(),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'TOTAL TRACKED',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'RM ${_totalTracked.toStringAsFixed(0)}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildLegend(theme),
            ],
          ),
        ),
        const SizedBox(height: 20),
        InsightCard(
          icon: isBnplRisky ? '⚠️' : '🛡️',
          text: isBnplRisky
              ? 'BNPL is ${bnplRatio.toStringAsFixed(0)}% of income — above the safer 15% threshold.'
              : 'Your BNPL commitments are still within a healthier range.',
          bgColor: isBnplRisky
              ? AppColors.subtleWarningBg
              : AppColors.subtleSuccessBg,
          textColor: isBnplRisky ? AppColors.warning : AppColors.success,
        ),
        const SizedBox(height: 12),
        InsightCard(
          icon: isExpenseHeavy ? '📉' : '💡',
          text: isExpenseHeavy
              ? 'Essential expenses already use ${expenseRatio.toStringAsFixed(0)}% of your income. Tightening spending could improve flexibility.'
              : 'Your core spending is still at a more manageable share of income.',
          bgColor: isExpenseHeavy
              ? AppColors.subtleWarningBg
              : AppColors.subtleInfoBg,
          textColor: isExpenseHeavy ? AppColors.warning : AppColors.info,
        ),
        const SizedBox(height: 12),
        InsightCard(
          icon: '🏦',
          text: monthsToSaveOneIncome == double.infinity
              ? 'You are not saving monthly yet. Even a small planned amount can improve your emergency readiness.'
              : 'At this rate, it takes about ${monthsToSaveOneIncome.toStringAsFixed(1)} months to save one month of income. Your planned savings rate is ${savingsRatio.toStringAsFixed(0)}%.',
          bgColor: AppColors.subtleInfoBg,
          textColor: AppColors.info,
        ),
      ],
    );
  }

  Widget _buildLegend(ThemeData theme) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 20,
      runSpacing: 10,
      children: [
        _legendItem(theme, 'Expenses', AppColors.primary),
        _legendItem(theme, 'BNPL', AppColors.danger),
        _legendItem(theme, 'Savings Plan', AppColors.info),
      ],
    );
  }

  Widget _legendItem(ThemeData theme, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatInitial(double value, {required double fallback}) {
    final target = value > 0 ? value : fallback;
    return target.toStringAsFixed(0);
  }
}