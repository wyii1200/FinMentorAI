import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class NotificationsScreen extends StatelessWidget {
  final VoidCallback onBack;

  const NotificationsScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: onBack,
        ),
        title: Text(
          'Notifications',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          _notificationCard(
            context,
            icon: '💳',
            title: 'BNPL Payment Due',
            subtitle: 'Shopee BNPL RM200 due in 2 days.',
            color: AppColors.warning,
          ),
          const SizedBox(height: 12),
          _notificationCard(
            context,
            icon: '🏦',
            title: 'Savings Goal Progress',
            subtitle: 'You saved RM700 this month. Keep going!',
            color: AppColors.success,
          ),
          const SizedBox(height: 12),
          _notificationCard(
            context,
            icon: '🛡️',
            title: 'Resilience Score Tip',
            subtitle:
                'Increasing your emergency fund could improve your resilience score.',
            color: AppColors.info,
          ),
        ],
      ),
    );
  }

  Widget _notificationCard(
    BuildContext context, {
    required String icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
