import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class NotificationsScreen extends StatelessWidget {
  final VoidCallback onBack;

  const NotificationsScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<UserProvider>();
    final notifications = _buildNotifications(user);

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
      body: notifications.isEmpty
          ? _buildEmptyState(context)
          : ListView.separated(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = notifications[index];
                return _notificationCard(
                  context,
                  icon: item.icon,
                  title: item.title,
                  subtitle: item.subtitle,
                  color: item.color,
                );
              },
            ),
    );
  }

  List<_NotificationItem> _buildNotifications(UserProvider user) {
    final items = <_NotificationItem>[];

    if (user.bnplCommitments > 0) {
      final ratio = user.income > 0 ? user.bnplCommitments / user.income : 0.0;

      items.add(
        _NotificationItem(
          icon: '💳',
          title: ratio >= 0.2 ? 'BNPL Pressure Alert' : 'BNPL Reminder',
          subtitle: ratio >= 0.2
              ? 'Your BNPL commitments are taking a high share of your income this month.'
              : 'Your BNPL commitments are still active. Keep tracking repayments carefully.',
          color: ratio >= 0.2 ? AppColors.warning : AppColors.info,
        ),
      );
    }

    if (user.currentSavings > 0) {
      items.add(
        _NotificationItem(
          icon: '🏦',
          title: 'Savings Progress Update',
          subtitle:
              'You currently have RM ${user.currentSavings.toStringAsFixed(0)} saved. Keep the momentum going.',
          color: AppColors.success,
        ),
      );
    }

    if (user.savingsGoal > 0 && user.currentSavings < user.savingsGoal) {
      final remaining = user.savingsGoal - user.currentSavings;
      items.add(
        _NotificationItem(
          icon: '🎯',
          title: 'Savings Goal Reminder',
          subtitle:
              'You still need RM ${remaining.toStringAsFixed(0)} to reach your current savings goal.',
          color: AppColors.info,
        ),
      );
    }

    if (user.availableToSave < 0) {
      items.add(
        _NotificationItem(
          icon: '⚠️',
          title: 'Budget Warning',
          subtitle:
              'Your expenses and debt commitments are exceeding your monthly income capacity.',
          color: AppColors.danger,
        ),
      );
    } else if (user.availableToSave > 0) {
      items.add(
        _NotificationItem(
          icon: '💡',
          title: 'Smart Tip',
          subtitle:
              'You still have RM ${user.availableToSave.toStringAsFixed(0)} available this month. Consider moving part of it into savings.',
          color: AppColors.info,
        ),
      );
    }

    if (user.resilienceScore < 50) {
      items.add(
        _NotificationItem(
          icon: '🛡️',
          title: 'Resilience Score Tip',
          subtitle:
              'Improving savings and reducing short-term debt could strengthen your resilience score.',
          color: AppColors.warning,
        ),
      );
    } else {
      items.add(
        _NotificationItem(
          icon: '✅',
          title: 'Resilience Check-In',
          subtitle:
              'Your current profile is relatively stable. Staying consistent can strengthen it further.',
          color: AppColors.success,
        ),
      );
    }

    return items;
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: AppCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.subtleInfoBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.info,
                size: 34,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'No notifications yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Once your financial activity grows, FinMentor AI will surface reminders, tips, and alerts here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
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
            margin: const EdgeInsets.only(top: 6),
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

class _NotificationItem {
  final String icon;
  final String title;
  final String subtitle;
  final Color color;

  const _NotificationItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}