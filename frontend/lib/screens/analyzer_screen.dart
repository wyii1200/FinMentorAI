import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class AnalyzerScreen extends StatefulWidget {
  const AnalyzerScreen({super.key});

  @override
  State<AnalyzerScreen> createState() => _AnalyzerScreenState();
}

class _AnalyzerScreenState extends State<AnalyzerScreen> {
  String  _aiAdvice  = '';
  String  _riskLevel = '';
  bool    _analyzed  = false;
  bool    _loading   = false;
  String? _errorMsg;

  bool _initialized = false;

  late final TextEditingController _income;
  late final TextEditingController _expenses;
  late final TextEditingController _bnpl;
  late final TextEditingController _monthlySavingsPlan;

  static const _titleStyle = TextStyle(
    fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white,
  );

  @override
  void initState() {
    super.initState();
    _income             = TextEditingController();
    _expenses           = TextEditingController();
    _bnpl               = TextEditingController();
    _monthlySavingsPlan = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final user = context.read<UserProvider>();
    _income.text             = _fmt(user.income,          fallback: 3500);
    _expenses.text           = _fmt(user.expenses,        fallback: 2100);
    _bnpl.text               = _fmt(user.bnplCommitments, fallback: 700);
    _monthlySavingsPlan.text = _fmt(
      user.availableToSave > 0 ? user.availableToSave : 0,
      fallback: 700,
    );

    _initialized = true;
  }

  double get _valIncome => double.tryParse(_income.text.trim())             ?? 0;
  double get _valExp    => double.tryParse(_expenses.text.trim())           ?? 0;
  double get _valBnpl   => double.tryParse(_bnpl.text.trim())               ?? 0;
  double get _valSav    => double.tryParse(_monthlySavingsPlan.text.trim()) ?? 0;

  double get _safeIncome   => _valIncome <= 0 ? 1 : _valIncome;
  double get _totalTracked => _valExp + _valBnpl + _valSav;

  @override
  void dispose() {
    _income.dispose();
    _expenses.dispose();
    _bnpl.dispose();
    _monthlySavingsPlan.dispose();
    super.dispose();
  }

  Future<void> _analyzeSpending() async {
    FocusScope.of(context).unfocus();
    if (_valIncome <= 0) {
      _snack('Please enter a valid monthly income greater than 0.');
      return;
    }

    setState(() { _loading = true; _errorMsg = null; });

    try {
      final callable = FirebaseFunctions.instance.httpsCallable(
        'analyzeSpending',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 30)),
      );

      final result = await callable.call({
        'income':   _valIncome,
        'expenses': _valExp,
        'bnpl':     _valBnpl,
        'savings':  _valSav,
      });

      final data = result.data as Map<String, dynamic>;

      // ── Update UserProvider so Dashboard refreshes immediately ──────────
      final user = context.read<UserProvider>();
      user.updateIncome(_valIncome);
      user.updateExpenses(_valExp);
      user.updateBnplCommitments(_valBnpl);
      user.updateCurrentSavings(_valSav);
      if (user.savingsGoal <= 0) {
        user.updateSavingsGoal(_valSav > 0 ? _valSav * 6 : 1000);
      }

      // ── Also persist currentSavings to Firestore ────────────────────────
      // analyzeSpending handler already saves income/expenses/bnpl.
      // We add currentSavings + savingsGoal here so dashboard shows them.
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'currentSavings': _valSav,
          'savingsGoal':    _valSav * 6,
        }, SetOptions(merge: true));
      }

      setState(() {
        _riskLevel = data['riskLevel'] as String? ?? '';
        _aiAdvice  = data['advice']    as String? ?? '';
        _analyzed  = true;
        _loading   = false;
      });

    } on FirebaseFunctionsException catch (e) {
      setState(() {
        _errorMsg = e.code == 'resource-exhausted'
            ? 'Daily limit reached (10/day). Try again tomorrow.'
            : 'Error: ${e.message}';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _errorMsg = 'Something went wrong. Please try again.';
        _loading  = false;
      });
    }
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));

  List<PieChartSectionData> _getSections() {
    final income = _safeIncome;
    return [
      PieChartSectionData(
        value: _valExp  <= 0 ? 0.01 : _valExp,
        color: AppColors.primary,
        title: '${((_valExp  / income) * 100).toInt()}%',
        radius: 56, titleStyle: _titleStyle,
      ),
      PieChartSectionData(
        value: _valBnpl <= 0 ? 0.01 : _valBnpl,
        color: AppColors.danger,
        title: '${((_valBnpl / income) * 100).toInt()}%',
        radius: 56, titleStyle: _titleStyle,
      ),
      PieChartSectionData(
        value: _valSav  <= 0 ? 0.01 : _valSav,
        color: AppColors.info,
        title: '${((_valSav  / income) * 100).toInt()}%',
        radius: 56, titleStyle: _titleStyle,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
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
                Text('Review Your Monthly Figures',
                    style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                Text('Pre-filled from your financial setup. Adjust anytime.',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary, height: 1.45)),
                const SizedBox(height: 20),
                AppInputField(
                  label: '💰 Monthly Income (RM)',
                  controller: _income,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 14),
                AppInputField(
                  label: '💸 Essential Expenses (RM)',
                  controller: _expenses,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 14),
                AppInputField(
                  label: '💳 BNPL Commitments (RM)',
                  controller: _bnpl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 14),
                AppInputField(
                  label: '🏦 Planned Monthly Savings (RM)',
                  controller: _monthlySavingsPlan,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Analyze My Spending',
                  isLoading: _loading,
                  onTap: _loading ? () {} : _analyzeSpending,
                ),
                if (_errorMsg != null) ...[
                  const SizedBox(height: 10),
                  AppCard(
                    color: AppColors.subtleDangerBg,
                    child: Text(_errorMsg!,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: AppColors.danger)),
                  ),
                ],
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
    final free    = _valIncome - (_valExp + _valBnpl + _valSav);
    final healthy = free >= 0;
    return AppCard(
      color: healthy ? AppColors.subtleSuccessBg : AppColors.subtleWarningBg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Text(healthy ? '✅' : '⚠️',
                style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              healthy
                  ? 'You still have RM ${free.toStringAsFixed(0)} unallocated after expenses, BNPL, and savings.'
                  : 'Your commitments exceed income by RM ${free.abs().toStringAsFixed(0)}.',
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection(ThemeData theme) {
    final bnplRatio    = (_valBnpl / _safeIncome) * 100;
    final expenseRatio = (_valExp  / _safeIncome) * 100;
    final savingsRatio = (_valSav  / _safeIncome) * 100;
    final isBnplRisky    = bnplRatio > 15;
    final isExpenseHeavy = expenseRatio > 60;
    final monthsToSave   = _valSav <= 0 ? double.infinity : _valIncome / _valSav;

    return Column(children: [
      AppCard(
        child: Column(children: [
          Text('📊 Spending Breakdown',
              style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 28),
          SizedBox(
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(PieChartData(
                  sectionsSpace: 4, centerSpaceRadius: 72,
                  sections: _getSections(),
                )),
                Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('TOTAL TRACKED',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('RM ${_totalTracked.toStringAsFixed(0)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary)),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildLegend(theme),
        ]),
      ),
      const SizedBox(height: 16),

      // AI Advice card
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1B4B),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.auto_awesome_rounded,
              color: Color(0xFFA5B4FC), size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text('FinMentor AI Analysis',
                    style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w800)),
                const SizedBox(width: 10),
                _riskBadge(_riskLevel),
              ]),
              const SizedBox(height: 10),
              Text(_aiAdvice,
                  style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9), height: 1.5)),
            ]),
          ),
        ]),
      ),

      const SizedBox(height: 16),
      InsightCard(
        icon: isBnplRisky ? '⚠️' : '🛡️',
        text: isBnplRisky
            ? 'BNPL is ${bnplRatio.toStringAsFixed(0)}% of income — above the safer 15% threshold.'
            : 'Your BNPL commitments are within a healthier range.',
        bgColor: isBnplRisky ? AppColors.subtleWarningBg : AppColors.subtleSuccessBg,
        textColor: isBnplRisky ? AppColors.warning : AppColors.success,
      ),
      const SizedBox(height: 12),
      InsightCard(
        icon: isExpenseHeavy ? '📉' : '💡',
        text: isExpenseHeavy
            ? 'Essential expenses use ${expenseRatio.toStringAsFixed(0)}% of income. Tightening could improve flexibility.'
            : 'Your core spending is at a manageable share of income.',
        bgColor: isExpenseHeavy ? AppColors.subtleWarningBg : AppColors.subtleInfoBg,
        textColor: isExpenseHeavy ? AppColors.warning : AppColors.info,
      ),
      const SizedBox(height: 12),
      InsightCard(
        icon: '🏦',
        text: monthsToSave == double.infinity
            ? 'You are not saving monthly yet. Even a small amount improves emergency readiness.'
            : 'Takes ${monthsToSave.toStringAsFixed(1)} months to save one month of income. Savings rate: ${savingsRatio.toStringAsFixed(0)}%.',
        bgColor: AppColors.subtleInfoBg,
        textColor: AppColors.info,
      ),
    ]);
  }

  Widget _riskBadge(String level) {
    final color = level == 'High'
        ? AppColors.danger
        : level == 'Medium'
            ? AppColors.warning
            : AppColors.success;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(8)),
      child: Text('$level Risk',
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w800)),
    );
  }

  Widget _buildLegend(ThemeData theme) {
    return Wrap(
      alignment: WrapAlignment.center, spacing: 20, runSpacing: 10,
      children: [
        _legendItem(theme, 'Expenses',     AppColors.primary),
        _legendItem(theme, 'BNPL',         AppColors.danger),
        _legendItem(theme, 'Savings Plan', AppColors.info),
      ],
    );
  }

  Widget _legendItem(ThemeData theme, String label, Color color) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 10, height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(label,
          style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
    ]);
  }

  String _fmt(double v, {required double fallback}) =>
      (v > 0 ? v : fallback).toStringAsFixed(0);
}
