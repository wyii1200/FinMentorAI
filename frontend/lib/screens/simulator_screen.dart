import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
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
  bool _initializedAmount = false;
  double _monthsSliderValue = 6;

  final List<String> _tabs = [
    'BNPL Purchase',
    'Save More',
    'Personal Loan',
  ];

  final TextEditingController _amountController = TextEditingController();

  int get _months => _monthsSliderValue.toInt();

  double get _enteredAmount =>
      double.tryParse(_amountController.text.trim()) ?? 0;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double _recommendedAmount(UserProvider user) {
    switch (_selectedTabIndex) {
      case 0:
        final suggestedBnpl = user.income > 0 ? user.income * 0.4 : 1500;
        return suggestedBnpl.clamp(800.0, 2500.0).toDouble();
      case 1:
        final extraSavings =
            user.availableToSave > 0 ? user.availableToSave * 0.4 : 400.0;
        return extraSavings.clamp(100.0, 1200.0).toDouble();
      case 2:
        final suggestedLoan = user.income > 0 ? user.income * 1.5 : 5000;
        return suggestedLoan.clamp(3000.0, 10000.0).toDouble();
      default:
        return 1500;
    }
  }

  double _conservativeAmount(UserProvider user) {
    return (_recommendedAmount(user) * 0.7).clamp(50.0, 999999.0).toDouble();
  }

  double _aggressiveAmount(UserProvider user) {
    return (_recommendedAmount(user) * 1.3).clamp(50.0, 999999.0).toDouble();
  }

  void _setScenarioAmount(double value) {
    _amountController.text = value.toStringAsFixed(0);
  }

  void _ensureInitialAmount(UserProvider user) {
    if (_initializedAmount) return;
    _setScenarioAmount(_recommendedAmount(user));
    _initializedAmount = true;
  }

  String get _scenarioLabel {
    switch (_selectedTabIndex) {
      case 0:
        return 'Purchase Amount';
      case 1:
        return 'Extra Monthly Savings';
      case 2:
        return 'Loan Amount';
      default:
        return 'Amount';
    }
  }

  String get _scenarioHint {
    switch (_selectedTabIndex) {
      case 0:
        return 'e.g. 1500';
      case 1:
        return 'e.g. 400';
      case 2:
        return 'e.g. 5000';
      default:
        return 'Enter amount';
    }
  }

  List<FlSpot> _getDebtSpots(UserProvider user) {
    if (_selectedTabIndex == 1) {
      return List.generate(_months + 1, (i) => FlSpot(i.toDouble(), 0));
    }

    final principal =
        _enteredAmount > 0 ? _enteredAmount : _recommendedAmount(user);

    if (_selectedTabIndex == 0) {
      final monthlyPayment = principal / (_months < 6 ? 6 : _months);

      return List.generate(_months + 1, (i) {
        final remaining = principal - (i * monthlyPayment);
        return FlSpot(i.toDouble(), remaining < 0 ? 0 : remaining);
      });
    }

    final monthlyPayment = principal / (_months < 12 ? 12 : _months);

    return List.generate(_months + 1, (i) {
      final remaining = principal - (i * monthlyPayment);
      return FlSpot(i.toDouble(), remaining < 0 ? 0 : remaining);
    });
  }

  List<FlSpot> _getSavingsSpots(UserProvider user) {
    final baseSavings = user.currentSavings;
    double monthlyContribution;
    double annualRate;

    switch (_selectedTabIndex) {
      case 0:
        monthlyContribution =
            user.availableToSave > 0 ? user.availableToSave * 0.2 : 150;
        annualRate = 0.025;
        break;
      case 1:
        monthlyContribution =
            _enteredAmount > 0 ? _enteredAmount : _recommendedAmount(user);
        annualRate = 0.035;
        break;
      case 2:
        monthlyContribution =
            user.availableToSave > 0 ? user.availableToSave * 0.15 : 100;
        annualRate = 0.02;
        break;
      default:
        monthlyContribution = 150;
        annualRate = 0.03;
    }

    final monthlyRate = annualRate / 12;

    return List.generate(_months + 1, (i) {
      if (i == 0) return FlSpot(0, baseSavings);

      final futureValue = baseSavings * MathUtils.pow(1 + monthlyRate, i) +
          monthlyContribution *
              ((MathUtils.pow(1 + monthlyRate, i) - 1) / monthlyRate);

      return FlSpot(i.toDouble(), futureValue);
    });
  }

  double _finalSavings(UserProvider user) {
    final spots = _getSavingsSpots(user);
    return spots.isNotEmpty ? spots.last.y : 0;
  }

  double _finalDebt(UserProvider user) {
    final spots = _getDebtSpots(user);
    return spots.isNotEmpty ? spots.last.y : 0;
  }

  double _netImpact(UserProvider user) {
    return _finalSavings(user) - _finalDebt(user);
  }

  double _projectedScoreDelta(UserProvider user) {
    final amount =
        _enteredAmount > 0 ? _enteredAmount : _recommendedAmount(user);
    final income = user.income <= 0 ? 1.0 : user.income;
    final amountRatio = amount / income;

    switch (_selectedTabIndex) {
      case 0:
        if (amountRatio >= 0.5) return -5.5;
        if (amountRatio >= 0.3) return -4.0;
        return -2.5;
      case 1:
        if (amountRatio >= 0.2) return 12.0;
        if (amountRatio >= 0.1) return 8.0;
        return 5.0;
      case 2:
        if (amountRatio >= 1.5) return -7.0;
        if (amountRatio >= 1.0) return -6.0;
        return -4.0;
      default:
        return 0;
    }
  }

  String _riskDeltaText(UserProvider user) {
    final delta = _projectedScoreDelta(user);
    final sign = delta >= 0 ? '+' : '';
    return '$sign${delta.toStringAsFixed(delta.abs() % 1 == 0 ? 0 : 1)} pts';
  }

  double _projectedResilienceScore(UserProvider user) {
    final projected = user.resilienceScore + _projectedScoreDelta(user);
    return projected.clamp(0.0, 100.0);
  }

  String _adviceText(UserProvider user) {
    final amount =
        (_enteredAmount > 0 ? _enteredAmount : _recommendedAmount(user))
            .toStringAsFixed(0);

    switch (_selectedTabIndex) {
      case 0:
        return 'A BNPL purchase of RM $amount adds short-term pressure to your cash flow. If the purchase is not urgent, saving first may protect your resilience better.';
      case 1:
        return 'Adding RM $amount more into savings each month can strengthen your emergency buffer faster and improve your future financial flexibility.';
      case 2:
        return 'A personal loan of RM $amount can solve short-term needs, but it reduces future breathing room. Keep repayments manageable relative to your income.';
      default:
        return 'This scenario shows how today’s decisions shape your future financial resilience.';
    }
  }

  double _getMaxY(UserProvider user) {
    final allY = [
      ..._getSavingsSpots(user).map((e) => e.y),
      ..._getDebtSpots(user).map((e) => e.y),
    ];

    final maxValue =
        allY.isEmpty ? 1000.0 : allY.reduce((a, b) => a > b ? a : b);

    if (maxValue <= 1000) return 1000;
    if (maxValue <= 3000) return 3000;
    if (maxValue <= 6000) return 6000;
    if (maxValue <= 10000) return 10000;
    return ((maxValue / 1000).ceil() * 1000).toDouble();
  }

  void _runSimulation(UserProvider user) async {
    FocusScope.of(context).unfocus();

    final amount = _enteredAmount;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount greater than 0.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSimulated = false;
    });

    await Future.delayed(const Duration(milliseconds: 350));

    setState(() {
      _isSimulated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<UserProvider>();

    _ensureInitialAmount(user);

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
            subtitle: 'Visualize the long-term impact of today’s choices',
          ),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_tabs.length, (index) {
                return _buildTab(theme, index, user);
              }),
            ),
          ),
          const SizedBox(height: 24),
          _buildScenarioInputCard(theme, user),
          if (_isSimulated) ...[
            const SizedBox(height: 24),
            _buildScoreComparisonCard(theme, user),
            const SizedBox(height: 20),
            _buildChartCard(theme, user),
            const SizedBox(height: 20),
            _buildImpactSummaryCard(theme, user),
            const SizedBox(height: 20),
            _buildFinMentorAdvice(theme, user),
          ],
        ],
      ),
    );
  }

  Widget _buildTab(ThemeData theme, int index, UserProvider user) {
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
            _setScenarioAmount(_recommendedAmount(user));
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

  Widget _buildScenarioInputCard(ThemeData theme, UserProvider user) {
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
          Text(
            _scenarioLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              prefixText: 'RM ',
              hintText: _scenarioHint,
              filled: true,
              fillColor: const Color(0xFFF7F9F8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.2,
                ),
              ),
            ),
            onChanged: (value) {
              final formatted = formatCurrencyInput(value);

              if (formatted != value) {
                _amountController.value = TextEditingValue(
                  text: formatted,
                  selection: TextSelection.collapsed(offset: formatted.length),
                );
              }

              if (_isSimulated) {
                setState(() {});
              }
            },
          ),
          const SizedBox(height: 14),
          Text(
            'Scenario Presets',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _presetChip(
                label: 'Recommended',
                amount: _recommendedAmount(user),
                onTap: () {
                  setState(() {
                    _setScenarioAmount(_recommendedAmount(user));
                    _isSimulated = false;
                  });
                },
              ),
              _presetChip(
                label: 'Conservative',
                amount: _conservativeAmount(user),
                onTap: () {
                  setState(() {
                    _setScenarioAmount(_conservativeAmount(user));
                    _isSimulated = false;
                  });
                },
              ),
              _presetChip(
                label: 'Aggressive',
                amount: _aggressiveAmount(user),
                onTap: () {
                  setState(() {
                    _setScenarioAmount(_aggressiveAmount(user));
                    _isSimulated = false;
                  });
                },
              ),
            ],
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
            onTap: () => _runSimulation(user),
          ),
        ],
      ),
    );
  }

  Widget _presetChip({
    required String label,
    required double amount,
    required VoidCallback onTap,
  }) {
    return ActionChip(
      label: Text(
        '$label · RM ${amount.toStringAsFixed(0)}',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      backgroundColor: AppColors.subtleSuccessBg,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      onPressed: onTap,
    );
  }

  Widget _buildScoreComparisonCard(ThemeData theme, UserProvider user) {
    final currentScore = (user.resilienceScore / 10).clamp(0.0, 10.0);
    final projectedScore =
        (_projectedResilienceScore(user) / 10).clamp(0.0, 10.0);
    final delta = projectedScore - currentScore;
    final deltaPositive = delta >= 0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Score Comparison',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _scoreBox(
                  theme,
                  label: 'Current',
                  value: currentScore.toStringAsFixed(1),
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _scoreBox(
                  theme,
                  label: 'Projected',
                  value: projectedScore.toStringAsFixed(1),
                  color: deltaPositive ? AppColors.success : AppColors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: deltaPositive
                  ? AppColors.subtleSuccessBg
                  : AppColors.subtleWarningBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Text(
                  deltaPositive ? '📈' : '⚠️',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    deltaPositive
                        ? 'This scenario may improve your resilience by ${delta.abs().toStringAsFixed(1)} points out of 10.'
                        : 'This scenario may reduce your resilience by ${delta.abs().toStringAsFixed(1)} points out of 10.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _scoreBox(
    ThemeData theme, {
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(ThemeData theme, UserProvider user) {
    final maxY = _getMaxY(user);

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
                  _lineData(_getSavingsSpots(user), AppColors.primary),
                  if (_selectedTabIndex != 1)
                    _lineData(_getDebtSpots(user), AppColors.danger),
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
            color.withOpacity(0.18),
            color.withOpacity(0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildImpactSummaryCard(ThemeData theme, UserProvider user) {
    final netImpact = _netImpact(user);
    final netPositive = netImpact >= 0;
    final riskDelta = _riskDeltaText(user);

    return AppCard(
      child: IntrinsicHeight(
        child: Row(
          children: [
            _impactMetric(
              theme,
              'NET IMPACT',
              '${netPositive ? '+' : '-'}RM ${netImpact.abs().toStringAsFixed(0)}',
              netPositive ? AppColors.success : AppColors.danger,
            ),
            const VerticalDivider(width: 32),
            _impactMetric(
              theme,
              'SCORE Δ',
              riskDelta,
              _projectedScoreDelta(user) >= 0
                  ? AppColors.info
                  : AppColors.danger,
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

  Widget _buildFinMentorAdvice(ThemeData theme, UserProvider user) {
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
                  _adviceText(user),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
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

String formatCurrencyInput(String value) {
  final number = int.tryParse(value.replaceAll(',', ''));
  if (number == null) return value;

  final text = number.toString();
  final buffer = StringBuffer();
  int count = 0;

  for (int i = text.length - 1; i >= 0; i--) {
    buffer.write(text[i]);
    count++;

    if (count % 3 == 0 && i != 0) {
      buffer.write(',');
    }
  }

  return buffer.toString().split('').reversed.join();
}
