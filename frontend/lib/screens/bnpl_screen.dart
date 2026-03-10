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

  @override
  void dispose() {
    _amountController.dispose();
    _durationController.dispose();
    _interestController.dispose();
    super.dispose();
  }

  // Calculation logic to keep the build method clean
  Map<String, double> _calculateData() {
    double p = double.tryParse(_amountController.text) ?? 0;
    double r = (double.tryParse(_interestController.text) ?? 0) / 100;
    double t =
        double.tryParse(_durationController.text) ?? 1; // Avoid divide by zero

    double totalInterest = p * r * t;
    double totalRepayment = p + totalInterest;
    double monthlyInstallment = totalRepayment / t;

    return {
      'principal': p,
      'interest': totalInterest,
      'total': totalRepayment,
      'monthly': monthlyInstallment,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
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
                const Text('Enter Your BNPL Plan',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark)),
                const SizedBox(height: 20),
                AppInputField(
                  label: 'Total Purchase Amount (RM)',
                  controller: _amountController,
                  keyboardType: TextInputType.number,
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
                        label: 'Interest (%/mo)',
                        controller: _interestController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Explain My Risk →',
                  // Using our custom orange color for warning/caution vibes
                  bgColor: const Color(0xFFF59E0B),
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    setState(() => _explained = true);
                  },
                ),
              ],
            ),
          ),
          if (_explained) ...[
            const SizedBox(height: 24),
            _buildRepaymentCard(),
            const SizedBox(height: 14),
            _buildMonthlyBreakdownCard(),
            const SizedBox(height: 14),
            _buildPenaltyRiskCard(),
            const SizedBox(height: 14),
            _buildCreditScoreCard(),
            const SizedBox(height: 30),
          ],
        ],
      ),
    );
  }

  Widget _buildRepaymentCard() {
    final data = _calculateData();
    return _riskCard(
      '💸',
      'Total Repayment',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('RM ${data['total']!.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.dark)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('Original: RM${data['principal']!.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.grey)),
              const SizedBox(width: 16),
              Text('+ Interest: RM${data['interest']!.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.danger,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyBreakdownCard() {
    final data = _calculateData();
    return _riskCard(
      '📅',
      'Monthly Installment',
      Text(
        'RM ${data['monthly']!.toStringAsFixed(2)} / month',
        style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primary),
      ),
    );
  }

  Widget _buildPenaltyRiskCard() {
    return _riskCard(
      '⚠️',
      'Late Penalty Risk',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Missing 1 payment = RM30 penalty',
              style: TextStyle(fontSize: 13, color: AppColors.dark)),
          SizedBox(height: 6),
          Text('2 missed payments may affect your credit score',
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.danger,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildCreditScoreCard() {
    return _riskCard(
      '📊',
      'Credit Score Impact',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Current: 680',
                  style: TextStyle(fontSize: 12, color: AppColors.grey)),
              Text('Risk: 620',
                  style: TextStyle(fontSize: 12, color: AppColors.grey)),
            ],
          ),
          const SizedBox(height: 10),
          const AppProgressBar(
              value: 0.68, color: AppColors.secondary, height: 10),
          const SizedBox(height: 10),
          const Text('Score could drop ~60 points if payments are missed.',
              style: TextStyle(
                  fontSize: 12,
                  color: AppColors.grey,
                  fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _riskCard(String icon, String title, Widget content) => AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Text(title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dark)),
              ],
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      );
}
