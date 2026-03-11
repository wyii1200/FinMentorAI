import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class BNPLScreen extends StatefulWidget {
  const BNPLScreen({super.key});

  @override
  State<BNPLScreen> createState() => _BNPLScreenState();
}

class _BNPLScreenState extends State<BNPLScreen> {
  bool _explained = false;

  final _amountController = TextEditingController(text: '1200');
  final _durationController = TextEditingController(text: '6');
  final _interestController = TextEditingController(text: '1.5');

  double get _amount => double.tryParse(_amountController.text.trim()) ?? 0;
  double get _duration => double.tryParse(_durationController.text.trim()) ?? 0;
  double get _interest => double.tryParse(_interestController.text.trim()) ?? 0;

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
      SnackBar(content: Text(text)),
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
      'principal': principal.toDouble(),
      'interest': totalInterest.toDouble(),
      'total': totalRepayment.toDouble(),
      'monthly': monthlyInstallment.toDouble(),
      'months': months.toDouble(),
      'rate': monthlyRate.toDouble(),
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

  String get _riskExplanation {
    final data = _calculateData();
    final overpay = data['overpaymentPercent']!.toStringAsFixed(1);

    if (_isHighRisk) {
      return 'This plan is costly. You may repay about $overpay% more than the original price, and longer repayment increases the chance of late-payment stress.';
    }
    if (_isMediumRisk) {
      return 'This plan is manageable, but still adds repayment pressure. Make sure the monthly installment fits comfortably into your budget.';
    }
    return 'This plan is relatively safer, but it is still debt. Late payments can still trigger penalties and affect future borrowing confidence.';
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
            title: '💳 BNPL Risk Calculator',
            subtitle: 'Understand the true cost before you commit',
          ),
          const SizedBox(height: 24),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter Your BNPL Plan',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
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
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
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
            _buildRiskSummaryCard(theme),
            const SizedBox(height: 14),
            _buildRepaymentCard(theme),
            const SizedBox(height: 14),
            _buildMonthlyBreakdownCard(theme),
            const SizedBox(height: 14),
            _buildPenaltyRiskCard(theme),
            const SizedBox(height: 14),
            _buildCreditScoreCard(theme),
            const SizedBox(height: 14),
            _buildFinMentorAdviceCard(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildRiskSummaryCard(ThemeData theme) {
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
                  _riskExplanation,
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

  Widget _buildMonthlyBreakdownCard(ThemeData theme) {
    final data = _calculateData();

    return _riskCard(
      theme,
      '📅',
      'Monthly Installment',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RM ${data['monthly']!.toStringAsFixed(2)} / month',
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
            'Repeated missed payments may increase stress, reduce repayment flexibility, and hurt future creditworthiness.',
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

  Widget _buildCreditScoreCard(ThemeData theme) {
    final scoreDrop = _isHighRisk
        ? 60
        : _isMediumRisk
            ? 35
            : 15;
    const currentScore = 680;
    final riskScore = currentScore - scoreDrop;
    final progressValue = riskScore / 1000;

    return _riskCard(
      theme,
      '📊',
      'Credit Score Impact',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current: $currentScore',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                'Risk: $riskScore',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AppProgressBar(
            value: progressValue.clamp(0.0, 1.0),
            color: _riskColor,
            height: 10,
          ),
          const SizedBox(height: 10),
          Text(
            'Your score could drop about $scoreDrop points if payments are missed repeatedly.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinMentorAdviceCard(ThemeData theme) {
    final data = _calculateData();
    final total = data['total']!;
    final principal = data['principal']!;

    final saveFirstDifference = total - principal;

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
                  'If you delay this purchase and save first, you may avoid about RM ${saveFirstDifference.toStringAsFixed(2)} in extra repayment cost. BNPL may feel small monthly, but the long-term burden is still real.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
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
