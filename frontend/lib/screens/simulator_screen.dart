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

  final List<String> _tabs = [
    'BNPL Purchase',
    'Save More',
    'Personal Loan',
  ];

  int get _months => _monthsSliderValue.toInt();

  double get _scenarioAmount {
    switch (_selectedTabIndex) {
      case 0:
        return 1500; // BNPL purchase amount
      case 1:
        return 400; // extra monthly savings
      case 2:
        return 5000; // personal loan amount
      default:
        return 1500;
    }
  }

  String get _scenarioLabel {
    switch (_selectedTabIndex) {
      case 0:
        return 'Purchase Amount';
      case 1:
        return 'Monthly Savings';
      case 2:
        return 'Loan Amount';
      default:
        return 'Amount';
    }
  }

  String get _scenarioAmountText {
    return 'RM ${_scenarioAmount.toStringAsFixed(0)}';
  }

  List<FlSpot> _getDebtSpots() {
    if (_selectedTabIndex == 1) {
      return List.generate(_months + 1, (i) => FlSpot(i.toDouble(), 0));
    }

    if (_selectedTabIndex == 0) {
      const principal = 1500.0;
      const monthlyPayment = 250.0;

      return List.generate(_months + 1, (i) {
        final remaining = principal - (i * monthlyPayment);
        return FlSpot(i.toDouble(), remaining < 0 ? 0 : remaining);
      });
    }

    // Personal loan scenario
    const principal = 5000.0;
    const monthlyPayment = 320.0;

    return List.generate(_months + 1, (i) {
      final remaining = principal - (i * monthlyPayment);
      return FlSpot(i.toDouble(), remaining < 0 ? 0 : remaining);
    });
  }

  List<FlSpot> _getSavingsSpots() {
    double monthlyContribution;
    double annualRate;

    switch (_selectedTabIndex) {
      case 0:
        monthlyContribution = 150;
        annualRate = 0.025;
        break;
      case 1:
        monthlyContribution = 400;
        annualRate = 0.035;
        break;
      case 2:
        monthlyContribution = 100;
        annualRate = 0.02;
        break;
      default:
        monthlyContribution = 150;
        annualRate = 0.03;
    }

    final monthlyRate = annualRate / 12;

    return List.generate(_months + 1, (i) {
      if (i == 0) return const FlSpot(0, 0);

      final value = monthlyContribution *
          ((MathUtils.pow(1 + monthlyRate, i) - 1) / monthlyRate);

      return FlSpot(i.toDouble(), value);
    });
  }

  double get _finalSavings {
    final spots = _getSavingsSpots();
    return spots.isNotEmpty ? spots.last.y : 0;
  }

  double get _finalDebt {
    final spots = _getDebtSpots();
    return spots.isNotEmpty ? spots.last.y : 0;
  }

  double get _netImpact {
    return _finalSavings - _finalDebt;
  }

  String get _riskDeltaText {
    switch (_selectedTabIndex) {
      case 0:
        return '+4 pts';
      case 1:
        return '+12 pts';
      case 2:
        return '-6 pts';
      default:
        return '+0 pts';
    }
  }

  String get _adviceText {
    switch (_selectedTabIndex) {
      case 0:
        return 'Buying this with BNPL adds short-term pressure. Waiting a few months and saving first would reduce debt stress and improve your resilience.';
      case 1:
        return 'Increasing savings monthly builds your emergency fund faster and improves your ability to survive income shocks.';
      case 2:
        return 'A personal loan can solve immediate needs, but it reduces future flexibility. Keep repayments low enough to protect your monthly cash flow.';
      default:
        return 'This scenario shows how today’s decisions shape your future financial resilience.';
    }
  }

  double _getMaxY() {
    final allY = [
      ..._getSavingsSpots().map((e) => e.y),
      ..._getDebtSpots().map((e) => e.y),
    ];

    final maxValue =
        allY.isEmpty ? 1000.0 : allY.reduce((a, b) => a > b ? a : b);

    if (maxValue <= 1000) return 1000;
    if (maxValue <= 3000) return 3000;
    if (maxValue <= 6000) return 6000;
    return ((maxValue / 1000).ceil() * 1000).toDouble();
  }

  void _runSimulation() {
    FocusScope.of(context).unfocus();
    setState(() {
      _isSimulated = true;
    });
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
            title: '✨ Future You',
            subtitle: 'Visualize the long-term impact of today\'s choices',
          ),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_tabs.length, (index) {
                return _buildTab(theme, index);
              }),
            ),
          ),
          const SizedBox(height: 24),
          _buildScenarioInputCard(theme),
          if (_isSimulated) ...[
            const SizedBox(height: 24),
            _buildChartCard(theme),
            const SizedBox(height: 20),
            _buildImpactSummaryCard(theme),
            const SizedBox(height: 20),
            _buildFinMentorAdvice(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildTab(ThemeData theme, int index) {
    final isSelected = _selectedTabIndex == index;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(_tabs[index]),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            _selectedTabIndex = index;
            _isSimulated = false;
          });
        },
        selectedColor: AppColors.primaryLight,
        backgroundColor: AppColors.surface,
        labelStyle: theme.textTheme.bodySmall?.copyWith(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  Widget _buildScenarioInputCard(ThemeData theme) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scenario Setup',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _scenarioLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _scenarioAmountText,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Simulation Period',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Slider.adaptive(
            value: _monthsSliderValue,
            min: 3,
            max: 24,
            divisions: 7,
            label: '$_months months',
            onChanged: (val) {
              setState(() {
                _monthsSliderValue = val;
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '3m',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '24m',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 20),
          const SizedBox(height: 4),
          PrimaryButton(
            label:
                _isSimulated ? 'Update Simulation' : 'Simulate Future Impact',
            onTap: _runSimulation,
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(ThemeData theme) {
    final maxY = _getMaxY();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Wealth Projection',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              _legendItem(theme, AppColors.primary, 'Growth'),
              const SizedBox(width: 12),
              _legendItem(theme, AppColors.danger, 'Debt'),
            ],
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: _months.toDouble(),
                minY: 0,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.border,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 44,
                      interval: maxY / 4,
                      getTitlesWidget: (v, _) => Text(
                        '${v.toInt()}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: _months >= 12 ? 3 : 1,
                      getTitlesWidget: (val, _) => Text(
                        'M${val.toInt()}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppColors.textPrimary,
                  ),
                ),
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
      dotData: FlDotData(show: spots.length <= 10),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.18),
            color.withValues(alpha: 0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildImpactSummaryCard(ThemeData theme) {
    final netPositive = _netImpact >= 0;

    return AppCard(
      child: IntrinsicHeight(
        child: Row(
          children: [
            _impactMetric(
              theme,
              'NET IMPACT',
              '${netPositive ? '+' : '-'}RM ${_netImpact.abs().toStringAsFixed(0)}',
              netPositive ? AppColors.success : AppColors.danger,
            ),
            const VerticalDivider(width: 32),
            _impactMetric(
              theme,
              'SCORE Δ',
              _riskDeltaText,
              _selectedTabIndex == 2 ? AppColors.danger : AppColors.info,
            ),
          ],
        ),
      ),
    );
  }

  Widget _impactMetric(
    ThemeData theme,
    String label,
    String value,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinMentorAdvice(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
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
                  _adviceText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(ThemeData theme, Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class MathUtils {
  static double pow(double x, int n) {
    double result = 1;
    for (int i = 0; i < n; i++) {
      result *= x;
    }
    return result;
  }
}
