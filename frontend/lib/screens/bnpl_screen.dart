import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class BNPLScreen extends StatefulWidget {
  const BNPLScreen({super.key});

  @override
  State<BNPLScreen> createState() => _BNPLScreenState();
}

class _BNPLScreenState extends State<BNPLScreen> {
  bool _explained = false;
  bool _initialized = false;

  late final TextEditingController _amountController;
  late final TextEditingController _durationController;
  late final TextEditingController _interestController;

  double get _amount => double.tryParse(_amountController.text.trim()) ?? 0;
  double get _duration => double.tryParse(_durationController.text.trim()) ?? 0;
  double get _interest => double.tryParse(_interestController.text.trim()) ?? 0;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _durationController = TextEditingController();
    _interestController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;

    final user = context.read<UserProvider>();

    final suggestedAmount =
        user.bnplCommitments > 0 ? user.bnplCommitments : 1200.0;
    final suggestedDuration = user.bnplCommitments > 0 ? 6.0 : 6.0;
    final suggestedInterest = 1.5;

    _amountController.text = suggestedAmount.toStringAsFixed(0);
    _durationController.text = suggestedDuration.toStringAsFixed(0);
    _interestController.text = suggestedInterest.toStringAsFixed(1);

    _initialized = true;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _durationController.dispose();
    _interestController.dispose();
    super.dispose();
  }

  void _explainRisk() {
    FocusScope.of(context).unfocus();

    if (_amount <= 0) {
      _showMessage('Please enter a valid purchase amount.');
      return;
    }

    if (_duration <= 0) {
      _showMessage('Please enter a valid duration greater than 0.');
      return;
    }

    if (_interest < 0) {
      _showMessage('Interest rate cannot be negative.');
      return;
    }

    setState(() {
      _explained = true;
    });
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Map<String, double> _calculateData() {
    final principal = _amount;
    final monthlyRate = _interest / 100;
    final months = _duration <= 0 ? 1 : _duration;

    final totalInterest = principal * monthlyRate * months;
    final totalRepayment = principal + totalInterest;
    final monthlyInstallment = totalRepayment / months;
    final overpaymentPercent =
        principal == 0 ? 0 : ((totalRepayment - principal) / principal) * 100;

    return {
      'principal': principal,
      'interest': totalInterest,
      'total': totalRepayment,
      'monthly': monthlyInstallment,
      'months': months.toDouble(),
      'rate': monthlyRate,
      'overpaymentPercent': overpaymentPercent.toDouble(),
    };
  }

  bool get _isHighRisk {
    final data = _calculateData();
    return data['overpaymentPercent']! >= 10 || data['months']! >= 12;
  }

  bool get _isMediumRisk {
    final data = _calculateData();
    return !_isHighRisk &&
        (data['overpaymentPercent']! >= 5 || data['months']! >= 6);
  }

  String get _riskLabel {
    if (_isHighRisk) return 'High Risk';
    if (_isMediumRisk) return 'Medium Risk';
    return 'Lower Risk';
  }

  Color get _riskColor {
    if (_isHighRisk) return AppColors.danger;
    if (_isMediumRisk) return AppColors.warning;
    return AppColors.success;
  }

  Color get _riskBgColor {
    if (_isHighRisk) return AppColors.subtleDangerBg;
    if (_isMediumRisk) return AppColors.subtleWarningBg;
    return AppColors.subtleSuccessBg;
  }

  String _riskExplanation(UserProvider user) {
    final data = _calculateData();
    final overpay = data['overpaymentPercent']!.toStringAsFixed(1);
    final monthly = data['monthly']!;
    final income = user.income;
    final monthlyShare =
        income > 0 ? ((monthly / income) * 100).toStringAsFixed(0) : null;

    if (_isHighRisk) {
      return income > 0
          ? 'This plan is costly. You may repay about $overpay% more than the original price, and the monthly installment takes about $monthlyShare% of your income.'
          : 'This plan is costly. You may repay about $overpay% more than the original price, and longer repayment increases late-payment stress.';
    }

    if (_isMediumRisk) {
      return income > 0
          ? 'This plan is manageable, but still adds pressure. The monthly installment uses about $monthlyShare% of your income.'
          : 'This plan is manageable, but still adds repayment pressure. Make sure the monthly installment fits comfortably into your budget.';
    }

    return 'This plan is relatively safer, but it is still debt. Late payments can still trigger penalties and reduce future flexibility.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<UserProvider>();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: '💳 BNPL Risk Calculator',
            subtitle: 'Understand the true cost before you commit',
          ),
          const SizedBox(height: 24),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Review Your BNPL Plan',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Estimate the repayment burden and understand how this plan may affect your monthly financial flexibility.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),
                AppInputField(
                  label: 'Total Purchase Amount (RM)',
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: AppInputField(
                        label: 'Duration (Months)',
                        controller: _durationController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: AppInputField(
                        label: 'Interest (% / month)',
                        controller: _interestController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Explain My Risk',
                  bgColor: AppColors.warning,
                  onTap: _explainRisk,
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 1),
                        child: Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This is an educational estimate, not official financial advice.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_explained) ...[
            const SizedBox(height: 20),
            _buildRiskSummaryCard(theme, user),
            const SizedBox(height: 14),
            _buildRepaymentCard(theme),
            const SizedBox(height: 14),
            _buildMonthlyBreakdownCard(theme, user),
            const SizedBox(height: 14),
            _buildPenaltyRiskCard(theme),
            const SizedBox(height: 14),
            _buildCashFlowImpactCard(theme, user),
            const SizedBox(height: 14),
            _buildFinMentorAdviceCard(theme, user),
          ],
        ],
      ),
    );
  }

  Widget _buildRiskSummaryCard(ThemeData theme, UserProvider user) {
    return AppCard(
      color: _riskBgColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              _isHighRisk
                  ? '🚨'
                  : _isMediumRisk
                      ? '⚠️'
                      : '🛡️',
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _riskLabel,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: _riskColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _riskExplanation(user),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepaymentCard(ThemeData theme) {
    final data = _calculateData();

    return _riskCard(
      theme,
      '💸',
      'Total Repayment',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RM ${data['total']!.toStringAsFixed(2)}',
            style: theme.textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              Text(
                'Original: RM ${data['principal']!.toStringAsFixed(0)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '+ Interest: RM ${data['interest']!.toStringAsFixed(2)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyBreakdownCard(ThemeData theme, UserProvider user) {
    final data = _calculateData();
    final monthly = data['monthly']!;
    final income = user.income;
    final monthlyShare = income > 0 ? (monthly / income) * 100 : 0.0;

    return _riskCard(
      theme,
      '📅',
      'Monthly Installment',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RM ${monthly.toStringAsFixed(2)} / month',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${data['months']!.toInt()} monthly payments required.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (income > 0) ...[
            const SizedBox(height: 8),
            Text(
              'That is about ${monthlyShare.toStringAsFixed(1)}% of your monthly income.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPenaltyRiskCard(ThemeData theme) {
    final data = _calculateData();
    final monthly = data['monthly']!;
    final penalty = monthly < 100 ? 15.0 : 30.0;

    return _riskCard(
      theme,
      '⚠️',
      'Late Penalty Risk',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Missing 1 payment may trigger an estimated RM ${penalty.toStringAsFixed(0)} penalty.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Repeated missed payments may increase stress, reduce repayment flexibility, and hurt future borrowing confidence.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.danger,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashFlowImpactCard(ThemeData theme, UserProvider user) {
    final data = _calculateData();
    final monthly = data['monthly']!;
    final available = user.availableToSave;
    final afterBnpl = available - monthly;
    final healthy = afterBnpl >= 0;

    return _riskCard(
      theme,
      '📊',
      'Cash Flow Impact',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            healthy
                ? 'After this BNPL payment, you may still keep about RM ${afterBnpl.toStringAsFixed(0)} available each month.'
                : 'This BNPL plan may push your monthly budget negative by about RM ${afterBnpl.abs().toStringAsFixed(0)}.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          AppProgressBar(
            value:
                user.income > 0 ? (monthly / user.income).clamp(0.0, 1.0) : 0,
            color: healthy ? AppColors.warning : AppColors.danger,
            height: 10,
          ),
          const SizedBox(height: 10),
          Text(
            'This bar shows how much of your income the BNPL installment may consume each month.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinMentorAdviceCard(ThemeData theme, UserProvider user) {
    final data = _calculateData();
    final total = data['total']!;
    final principal = data['principal']!;
    final monthly = data['monthly']!;
    final extraCost = total - principal;

    String advice;

    if (user.availableToSave - monthly < 0) {
      advice =
          'This BNPL plan could strain your monthly cash flow. Delaying the purchase or choosing a smaller amount may protect your resilience better.';
    } else if (_isHighRisk) {
      advice =
          'If you delay this purchase and save first, you may avoid about RM ${extraCost.toStringAsFixed(2)} in extra repayment cost. The plan looks expensive relative to its repayment period.';
    } else {
      advice =
          'This plan is more manageable, but saving first would still help you avoid about RM ${extraCost.toStringAsFixed(2)} in extra repayment cost and reduce future debt pressure.';
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B4B),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            color: Color(0xFFA5B4FC),
            size: 24,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FinMentor Advice',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  advice,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.92),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _riskCard(
    ThemeData theme,
    String icon,
    String title,
    Widget content,
  ) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }
}