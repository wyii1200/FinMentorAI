import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class ResilienceScreen extends StatefulWidget {
  const ResilienceScreen({super.key});

  @override
  State<ResilienceScreen> createState() => _ResilienceScreenState();
}

class _ResilienceScreenState extends State<ResilienceScreen> {
  bool _isStressTestActive = false;

  @override
  Widget build(BuildContext context) {
    // Score data structure using Records
    final metrics = [
      (
        '💰',
        'Emergency Fund',
        4.0,
        AppColors.danger,
        'Covers 1.5 months — target: 6 months'
      ),
      (
        '🛡️',
        'Insurance Coverage',
        5.0,
        AppColors.secondary,
        'Basic health only — no income protection'
      ),
      (
        '📉',
        'Debt-to-Income',
        7.0,
        AppColors.primary,
        '22% — within manageable range'
      ),
      (
        '💸',
        'Monthly Savings',
        8.0,
        AppColors.purple,
        '20% of income — great habit!'
      ),
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildMainScoreCard(),
          const SizedBox(height: 32),
          _buildBreakdownHeader(),
          const SizedBox(height: 16),
          _buildMetricsList(metrics),
          const SizedBox(height: 32),
          _buildAIAdviceCard(),
          const SizedBox(height: 40), // Extra space for BottomNav curve
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Expanded(
          child: SectionHeader(
            title: '🛡️ Resilience Score',
            subtitle: 'Financial health beyond your balance',
          ),
        ),
        // Stress Test Toggle
        Column(
          children: [
            Switch.adaptive(
              value: _isStressTestActive,
              activeColor: AppColors.danger,
              onChanged: (val) => setState(() => _isStressTestActive = val),
            ),
            const Text('STRESS TEST',
                style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildMainScoreCard() {
    double score = _isStressTestActive ? 4.8 : 6.2;
    Color scoreColor =
        _isStressTestActive ? AppColors.danger : AppColors.secondary;

    return AppCard(
      child: Column(
        children: [
          const SizedBox(height: 10),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: score / 10),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 170,
                    height: 170,
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 14,
                      backgroundColor: AppColors.lightGrey.withOpacity(0.5),
                      valueColor: AlwaysStoppedAnimation(scoreColor),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${(value * 10).toStringAsFixed(1)}',
                          style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: AppColors.dark)),
                      const Text('OUT OF 10',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.grey,
                              letterSpacing: 1.2)),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          AppTag(
            label: _isStressTestActive
                ? '⚠️ HIGH RISK IN RECESSION'
                : '⚡ MODERATE RESILIENCE',
            textColor: _isStressTestActive ? Colors.white : AppColors.amberText,
            bgColor: _isStressTestActive ? AppColors.danger : AppColors.amber,
          ),
          const SizedBox(height: 16),
          Text(
            _isStressTestActive
                ? 'In a job loss scenario, you have 45 days of safety.'
                : 'You can survive ~3.1 months without income.',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 13,
                color: AppColors.grey,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownHeader() {
    return const Row(
      children: [
        Text('Score Breakdown',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.dark)),
        SizedBox(width: 8),
        Icon(Icons.info_outline, size: 16, color: AppColors.grey),
      ],
    );
  }

  Widget _buildMetricsList(
      List<(String, String, double, Color, String)> metrics) {
    return AppCard(
      child: Column(
        children: metrics.asMap().entries.map((entry) {
          final m = entry.value;
          final isLast = entry.key == metrics.length - 1;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIconBox(m.$1),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(m.$2,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.dark)),
                              Text('${m.$3.toInt()}/10',
                                  style: TextStyle(
                                      color: m.$4,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          AppProgressBar(
                              value: m.$3 / 10, color: m.$4, height: 8),
                          const SizedBox(height: 10),
                          Text(m.$5,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.grey,
                                  height: 1.4)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(height: 32, color: AppColors.lightGrey),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildIconBox(String emoji) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: AppColors.lightGrey.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.lightGrey)),
      child: Text(emoji, style: const TextStyle(fontSize: 22)),
    );
  }

  Widget _buildAIAdviceCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF1E1B4B).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle),
                child: const Icon(Icons.auto_awesome,
                    color: Color(0xFFA5B4FC), size: 18),
              ),
              const SizedBox(width: 10),
              const Text('AI STRATEGY',
                  style: TextStyle(
                      color: Color(0xFFA5B4FC),
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Path to 8.5 (Robust)',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          _tipItem('Boost emergency fund to RM12,500'),
          _tipItem('Switch to a High-Yield Savings Account'),
          _tipItem('Consolidate 2 BNPL debts into 1'),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Generate Action Plan',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          const Icon(Icons.bolt_rounded, color: Color(0xFFFFD166), size: 20),
          const SizedBox(width: 12),
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
