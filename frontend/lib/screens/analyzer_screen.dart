import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class AnalyzerScreen extends StatefulWidget {
  const AnalyzerScreen({super.key});

  @override
  State<AnalyzerScreen> createState() => _AnalyzerScreenState();
}

class _AnalyzerScreenState extends State<AnalyzerScreen> {
  bool _analyzed = false;
  // Use numeric keyboards for better UX
  final _income = TextEditingController(text: '3500');
  final _expenses = TextEditingController(text: '2100');
  final _bnpl = TextEditingController(text: '700');
  final _savings = TextEditingController(text: '700');

  // Helper to parse values safely
  double get _valIncome => double.tryParse(_income.text) ?? 1.0;
  double get _valExp => double.tryParse(_expenses.text) ?? 0;
  double get _valBnpl => double.tryParse(_bnpl.text) ?? 0;
  double get _valSav => double.tryParse(_savings.text) ?? 0;

  List<PieChartSectionData> _getSections() {
    final double income = _valIncome;

    return [
      PieChartSectionData(
          value: _valExp,
          color: AppColors.primary,
          title: '${(_valExp / income * 100).toInt()}%',
          radius: 55, // Slightly larger radius
          titleStyle: _titleStyle),
      PieChartSectionData(
          value: _valBnpl,
          color: AppColors.danger,
          title: '${(_valBnpl / income * 100).toInt()}%',
          radius: 55,
          titleStyle: _titleStyle),
      PieChartSectionData(
          value: _valSav,
          color: AppColors.purple,
          title: '${(_valSav / income * 100).toInt()}%',
          radius: 55,
          titleStyle: _titleStyle),
    ];
  }

  static const _titleStyle =
      TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: '🔍 AI Spending Analyzer',
            subtitle: 'Get a clear picture of where your money goes',
          ),
          const SizedBox(height: 24),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Enter Your Monthly Figures',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark)),
                const SizedBox(height: 20),
                AppInputField(
                    label: '💰 Monthly Income (RM)',
                    controller: _income,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 14),
                AppInputField(
                    label: '💸 Essential Expenses (RM)',
                    controller: _expenses,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 14),
                AppInputField(
                    label: '💳 BNPL Commitments (RM)',
                    controller: _bnpl,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 14),
                AppInputField(
                    label: '🏦 Monthly Savings (RM)',
                    controller: _savings,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Analyze My Spending →',
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    // Small delay to make the AI feel like it's "thinking"
                    setState(() => _analyzed = true);
                  },
                ),
              ],
            ),
          ),
          if (_analyzed) ...[
            const SizedBox(height: 24),
            _buildResultsSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
    final bnplRatio = (_valBnpl / _valIncome) * 100;
    final isRisky = bnplRatio > 15;

    return Column(
      children: [
        AppCard(
          child: Column(
            children: [
              const Text('📊 Spending Breakdown',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 30),
              SizedBox(
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 4,
                        centerSpaceRadius: 70, // Room for text in the middle
                        sections: _getSections(),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('TOTAL',
                            style: TextStyle(
                                fontSize: 10,
                                color: AppColors.grey,
                                fontWeight: FontWeight.bold)),
                        Text('RM${(_valExp + _valBnpl + _valSav).toInt()}',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppColors.dark)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildLegend(),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Dynamic Dynamic Insight: BNPL Risk
        InsightCard(
          icon: isRisky ? '⚠️' : '🛡️',
          text: isRisky
              ? 'BNPL is ${bnplRatio.toInt()}% of income — above the safe 15% threshold!'
              : 'Your BNPL commitments are within a healthy range.',
          bgColor: isRisky ? const Color(0xFFFEF3C7) : const Color(0xFFF0FDF4),
          textColor: isRisky ? AppColors.amberText : const Color(0xFF166534),
        ),

        const SizedBox(height: 12),

        // Dynamic Insight: Savings/Emergency Fund
        InsightCard(
          icon: '💡',
          text:
              'At this rate, it takes ${(_valIncome / _valSav).toStringAsFixed(1)} months to save 1 month of income.',
          bgColor: const Color(0xFFEEF2FF),
          textColor: const Color(0xFF3730A3),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 20,
      runSpacing: 10,
      children: [
        _legendItem('Expenses', AppColors.primary),
        _legendItem('BNPL', AppColors.danger),
        _legendItem('Savings', AppColors.purple),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                color: AppColors.grey,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}
