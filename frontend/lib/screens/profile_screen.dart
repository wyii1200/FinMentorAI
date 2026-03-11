import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'onboarding_screen.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback onBack;

  const ProfileScreen({super.key, required this.onBack});

  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);

        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Log out?',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          content: Text(
            'You will need to log in again to access your financial dashboard.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                minimumSize: const Size(100, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !context.mounted) return;

    context.read<UserProvider>().logout();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      (route) => false,
    );
  }

  void _showComingSoon(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title will be available soon.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<UserProvider>();

    final displayName =
        user.userName.trim().isEmpty ? 'FinMentor User' : user.userName.trim();
    final firstName = displayName.split(' ').first;
    final initial = firstName.isNotEmpty ? firstName[0].toUpperCase() : 'F';

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
          'Profile Settings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(theme, user, displayName, initial),
            const SizedBox(height: 20),
            _buildFinancialProfileCard(theme, user),
            const SizedBox(height: 24),
            Text(
              'Account',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _ProfileTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Personal Information',
                    subtitle: 'Name, account identity, preferences',
                    isLast: false,
                    onTap: () =>
                        _showComingSoon(context, 'Personal Information'),
                  ),
                  _ProfileTile(
                    icon: Icons.security_rounded,
                    title: 'Security Settings',
                    subtitle: 'Password, privacy, login protection',
                    isLast: false,
                    onTap: () => _showComingSoon(context, 'Security Settings'),
                  ),
                  _ProfileTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notification Preferences',
                    subtitle: 'Alerts, reminders, financial tips',
                    isLast: true,
                    onTap: () =>
                        _showComingSoon(context, 'Notification Preferences'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Support',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _ProfileTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Help Center',
                    subtitle: 'Learn how to use FinMentor AI',
                    isLast: false,
                    onTap: () => _showComingSoon(context, 'Help Center'),
                  ),
                  _ProfileTile(
                    icon: Icons.info_outline_rounded,
                    title: 'About FinMentor AI',
                    subtitle: 'Version, mission, transparency',
                    isLast: true,
                    onTap: () => _showAboutDialog(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppCard(
              color: AppColors.subtleDangerBg,
              child: InkWell(
                onTap: () => _handleLogout(context),
                borderRadius: BorderRadius.circular(24),
                child: Row(
                  children: [
                    const Icon(
                      Icons.logout_rounded,
                      color: AppColors.danger,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Log Out',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: AppColors.danger,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    ThemeData theme,
    UserProvider user,
    String displayName,
    String initial,
  ) {
    final scoreOutOfTen = (user.resilienceScore / 10).clamp(0.0, 10.0);

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary.withOpacity(0.14),
            child: Text(
              initial,
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Resilience Score: ${scoreOutOfTen.toStringAsFixed(1)} / 10',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    AppTag(
                      label: 'ASEAN Youth',
                      bgColor: AppColors.subtleInfoBg,
                      textColor: AppColors.info,
                    ),
                    AppTag(
                      label: user.currentSavings > 0
                          ? 'Active Saver'
                          : 'Starter Profile',
                      bgColor: AppColors.subtleSuccessBg,
                      textColor: AppColors.success,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialProfileCard(ThemeData theme, UserProvider user) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Financial Profile',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _miniStat(
                  theme,
                  label: 'Income',
                  value: _formatCompact(user.income),
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _miniStat(
                  theme,
                  label: 'BNPL',
                  value: _formatCompact(user.bnplCommitments),
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _miniStat(
                  theme,
                  label: 'Savings',
                  value: _formatCompact(user.currentSavings),
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _miniStat(
                  theme,
                  label: 'Goal',
                  value: _formatCompact(user.savingsGoal),
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(
    ThemeData theme, {
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'About FinMentor AI',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          content: Text(
            'FinMentor AI helps ASEAN youth build stronger financial resilience through savings guidance, BNPL risk awareness, and future scenario planning.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  String _formatCompact(double value) {
    if (value >= 1000) {
      return 'RM ${(value / 1000).toStringAsFixed(1)}k';
    }
    return 'RM ${value.toStringAsFixed(0)}';
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isLast;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: AppColors.textSecondary,
          ),
          onTap: onTap,
        ),
        if (!isLast) const Divider(height: 1, indent: 72, endIndent: 16),
      ],
    );
  }
}
