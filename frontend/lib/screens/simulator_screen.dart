import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class SimulatorScreen extends StatefulWidget {
  const SimulatorScreen({super.key});

  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorScreen> {
  int _selectedTabIndex = 0;
  bool _isSimulated = false;
  double _monthsSliderValue = 6;
  final List<String> _tabs = ['BNPL Purchase', 'Save More', 'Personal Loan'];

  // Logic to generate spots based on selected scenario and duration
  List<FlSpot> _getDebtSpots() {
    if (_selectedTabIndex == 1)
      return [const FlSpot(0, 0)]; // No debt for "Save More"

    // Simple BNPL Amortization simulation
    double principal = 1500;
    double monthlyPayment = 250;
    return List.generate(_monthsSliderValue.toInt() + 1, (i) {
      double remaining = principal - (i * monthlyPayment);
      return FlSpot(i.toDouble(), remaining < 0 ? 0 : remaining);
    });
  }

  List<FlSpot> _getSavingsSpots() {
    double monthlyContribution = _selectedTabIndex == 1 ? 400 : 150;
    double rate = 0.035 / 12; // 3.5% annual

    return List.generate(_monthsSliderValue.toInt() + 1, (i) {
      // Future Value of Annuity formula: P * [((1 + r)^n - 1) / r]
      if (i == 0) return const FlSpot(0, 0);
      double val = monthlyContribution *
          (num.parse(MathUtils.pow(1 + rate, i).toString()) - 1) /
          rate;
      return FlSpot(i.toDouble(), val);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: '✨ Future You',
            subtitle: 'Visualize the long-term impact of today\'s choices',
          ),
          const SizedBox(height: 24),

          // Tab Selection
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  List.generate(_tabs.length, (index) => _buildTab(index)),
            ),
          ),
          const SizedBox(height: 24),

          _buildScenarioInputCard(),

          if (_isSimulated) ...[
            const SizedBox(height: 24),
            _buildChartCard(),
            const SizedBox(height: 20),
            _buildImpactSummaryCard(),
            const SizedBox(height: 20),
            _buildFinMentorAdvice(),
            const SizedBox(height: 40),
          ],
        ],
      ),
    );
  }

  Widget _buildTab(int index) {
    bool isSelected = _selectedTabIndex == index;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(_tabs[index]),
        selected: isSelected,
        onSelected: (val) => setState(() {
          _selectedTabIndex = index;
          _isSimulated = false;
        }),
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.lightGrey,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildScenarioInputCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  _selectedTabIndex == 1
                      ? 'Monthly Savings'
                      : 'Purchase Amount',
                  style: const TextStyle(
                      color: AppColors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
              Text(_selectedTabIndex == 1 ? 'RM 400' : 'RM 1,500',
                  style: const TextStyle(
                      color: AppColors.dark,
                      fontWeight: FontWeight.w900,
                      fontSize: 16)),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Simulation Period',
              style: TextStyle(
                  color: AppColors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
          Slider.adaptive(
            value: _monthsSliderValue,
            min: 3,
            max: 24,
            divisions: 7,
            label: '${_monthsSliderValue.toInt()} Months',
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() {
              _monthsSliderValue = val;
              if (_isSimulated) _isSimulated = true; // Refresh simulation
            }),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('3m', style: TextStyle(fontSize: 10, color: AppColors.grey)),
              Text('24m',
                  style: TextStyle(fontSize: 10, color: AppColors.grey)),
            ],
          ),
          const Divider(height: 32),
          PrimaryButton(
            label:
                _isSimulated ? 'Update Simulation' : 'Simulate Future Impact',
            onTap: () => setState(() => _isSimulated = true),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Wealth Projection',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              const Spacer(),
              _legendItem(AppColors.primary, 'Growth'),
              const SizedBox(width: 12),
              _legendItem(AppColors.danger, 'Debt'),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1000),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (v, _) => Text('${v.toInt()}',
                              style: const TextStyle(
                                  fontSize: 10, color: AppColors.grey)))),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 3,
                      getTitlesWidget: (val, _) => Text('M${val.toInt()}',
                          style: const TextStyle(
                              fontSize: 10, color: AppColors.grey)),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  _lineData(_getSavingsSpots(), AppColors.primary),
                  if (_selectedTabIndex != 1)
                    _lineData(_getDebtSpots(), AppColors.danger),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartBarData _lineData(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 4,
      isStrokeCapRound: true,
      dotData: FlDotData(show: spots.length < 10),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [color.withOpacity(0.2), color.withOpacity(0.0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildImpactSummaryCard() {
    return AppCard(
      child: IntrinsicHeight(
        child: Row(
          children: [
            _impactMetric('NET IMPACT', '+RM 2,450', AppColors.primary),
            const VerticalDivider(width: 32),
            _impactMetric('SCORE Δ', '+12 pts', Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _impactMetric(String label, String val, Color col) {
    return Expanded(
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey)),
          const SizedBox(height: 4),
          Text(val,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w900, color: col)),
        ],
      ),
    );
  }

  Widget _buildFinMentorAdvice() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B4B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: Color(0xFFA5B4FC), size: 24),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Waiting 3 months to buy this "In Cash" instead of BNPL would increase your Resilience Score by 0.4 points and save you RM120 in fees.',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  height: 1.5,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color col, String lab) => Row(
        children: [
          Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: col, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(lab,
              style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.grey,
                  fontWeight: FontWeight.bold)),
        ],
      );
}

// Simple internal helper for math
class MathUtils {
  static double pow(double x, int n) {
    double res = 1;
    for (int i = 0; i < n; i++) {
      res *= x;
    }
    return res;
  }
}
