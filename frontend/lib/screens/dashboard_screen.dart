import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int) onNavigate;

  const DashboardScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          // Add logic to refresh financial data here
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 24),
              _buildSectionHeader('Financial Snapshot'),
              const SizedBox(height: 12),
              _buildStatRow(),
              const SizedBox(height: 24),
              _buildRiskAlert(),
              const SizedBox(height: 24),
              _buildSectionHeader('Smart Tools'),
              const SizedBox(height: 12),
              _buildFeatureGrid(),
              const SizedBox(height: 24),
              _buildSectionHeader('Recent Activity'),
              const SizedBox(height: 12),
              _buildActivityList(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.dark,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildHeaderCard() {
    return GradientCard(
      colors: const [
        AppColors.primary,
        Color(0xFF064E3B)
      ], // Darker forest green gradient
      radius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildProfileAvatar(),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Good morning,',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 11)),
                      Text('Amir 👋',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900)),
                    ],
                  ),
                ],
              ),
              _buildNotificationBadge(),
            ],
          ),
          const SizedBox(height: 28),
          _buildResilienceScoreUI(),
        ],
      ),
    );
  }

  Widget _buildResilienceScoreUI() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Resilience Score',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              Text('Level 6',
                  style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('6.2',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w900)),
              Text(' /10',
                  style: TextStyle(
                      color: Colors.white60,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 0.62,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation(AppColors.secondary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 10),
          const Text('You can survive ~3.1 months without income',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }

  Widget _buildStatRow() {
    return LayoutBuilder(builder: (context, constraints) {
      return Row(
        children: [
          _buildStatItem('💰', 'Income', '3.5k', AppColors.primary),
          const SizedBox(width: 8),
          _buildStatItem('💸', 'Spent', '2.8k', AppColors.danger),
          const SizedBox(width: 8),
          _buildStatItem('🏦', 'Saved', '700', AppColors.purple),
        ],
      );
    });
  }

  Widget _buildStatItem(String emoji, String label, String value, Color color) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.grey,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              'RM $value',
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w900, color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskAlert() {
    return InkWell(
      onTap: () => onNavigate(3), // Jump to BNPL Risk screen
      child: AppCard(
        color: const Color(0xFFFFF7ED), // Subtle orange
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('BNPL Alert',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF9A3412))),
                  Text('Commitments exceed 20% of income.',
                      style: TextStyle(fontSize: 12, color: Color(0xFFC2410C))),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF9A3412)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        FeatureButton(
          icon: '🔍',
          label: 'Spending\nAnalyzer',
          bgColor: const Color(0xFFEFF6FF),
          accentColor: const Color(0xFF3B82F6),
          onTap: () => onNavigate(1),
        ),
        FeatureButton(
          icon: '📈',
          label: 'Future\nSimulator',
          bgColor: const Color(0xFFF0FDF4),
          accentColor: AppColors.primary,
          onTap: () => onNavigate(2),
        ),
      ],
    );
  }

  Widget _buildActivityList() {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _activityTile(
              '🛍', 'Shopee BNPL', 'Mar 8', '-RM200', AppColors.danger),
          const Divider(height: 1, indent: 60),
          _activityTile('💼', 'Salary Credit', 'Mar 1', '+RM3,500',
              const Color(0xFF059669)),
          const Divider(height: 1, indent: 60),
          _activityTile(
              '🏦', 'Auto Savings', 'Mar 1', '-RM700', AppColors.primary),
        ],
      ),
    );
  }

  Widget _activityTile(
      String icon, String label, String date, String amt, Color color) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12)),
        child: Text(icon, style: const TextStyle(fontSize: 18)),
      ),
      title: Text(label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
      subtitle: Text(date,
          style: const TextStyle(fontSize: 12, color: AppColors.grey)),
      trailing: Text(amt,
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w800, color: color)),
    );
  }

  Widget _buildProfileAvatar() {
    return const CircleAvatar(
      radius: 18,
      backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=amir'),
    );
  }

  Widget _buildNotificationBadge() {
    return IconButton(
      onPressed: () {},
      icon: Badge(
        label: const Text('2'),
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.notifications_none_rounded,
            color: Colors.white, size: 26),
      ),
    );
  }
}
