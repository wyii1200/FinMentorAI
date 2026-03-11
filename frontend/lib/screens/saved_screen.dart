import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class SavedScreen extends StatelessWidget {
  final VoidCallback onBack;

  const SavedScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<UserProvider>();

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
          'My Savings',
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
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
            _buildSavingsOverview(context, theme, user),
            const SizedBox(height: 24),
            _buildSectionTitle(theme, 'Savings Goal'),
            const SizedBox(height: 12),
            _buildGoalCard(context, theme, user),
            const SizedBox(height: 16),
            _buildAvailableToSaveCard(theme, user),
            const SizedBox(height: 20),
            AppCard(
              color: AppColors.subtleSuccessBg,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.savings_outlined,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Keeping consistent monthly savings can improve both your resilience score and your long-term financial flexibility.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsOverview(
    BuildContext context,
    ThemeData theme,
    UserProvider user,
  ) {
    return AppCard(
      color: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Savings',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatCurrency(user.currentSavings),
            style: theme.textTheme.displayMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _buildSavingsMessage(user),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.88),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _showAddSavingsDialog(context),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: Colors.white),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                '+ Add Savings',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildGoalCard(
    BuildContext context,
    ThemeData theme,
    UserProvider user,
  ) {
    final progress = user.savingsProgress;
    final goal = user.savingsGoal;
    final saved = user.currentSavings;
    final remaining = (goal - saved).clamp(0.0, double.infinity);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Emergency Fund Goal',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_formatCurrency(saved)} / ${_formatCurrency(goal)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              color: AppColors.primary,
              backgroundColor: AppColors.primary.withOpacity(0.14),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% completed',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.subtleInfoBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.flag_outlined,
                  color: AppColors.info,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    remaining > 0
                        ? '${_formatCurrency(remaining)} left to reach your goal.'
                        : 'Goal achieved. You can now grow your next savings milestone.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
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

  Widget _buildAvailableToSaveCard(ThemeData theme, UserProvider user) {
    final available = user.availableToSave;

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.subtleWarningBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: Color(0xFFD97706),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available to Save This Month',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatCurrency(available),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: available >= 0
                        ? AppColors.textPrimary
                        : AppColors.danger,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  available >= 0
                      ? 'This is your remaining balance after expenses and BNPL commitments.'
                      : 'Your current commitments exceed your monthly financial capacity.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddSavingsDialog(BuildContext context) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final quickAmounts = [50.0, 100.0, 200.0, 500.0];

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Add Savings'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: controller,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  autofocus: true,
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) return 'Please enter an amount';
                    final amount = double.tryParse(text);
                    if (amount == null) return 'Enter a valid number';
                    if (amount <= 0) return 'Amount must be more than 0';
                    return null;
                  },
                  decoration: InputDecoration(
                    prefixText: 'RM ',
                    hintText: 'e.g. 200',
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
                ),
                const SizedBox(height: 16),
                Text(
                  'Quick add',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: quickAmounts.map((amount) {
                    return ActionChip(
                      label: Text(
                        '+ RM ${amount.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      backgroundColor: AppColors.subtleSuccessBg,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      onPressed: () {
                        controller.text = amount.toStringAsFixed(0);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;

                final amount = double.parse(controller.text.trim());
                context.read<UserProvider>().addSavings(amount);

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'RM ${amount.toStringAsFixed(0)} added to savings.',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  String _buildSavingsMessage(UserProvider user) {
    if (user.currentSavings >= user.savingsGoal && user.savingsGoal > 0) {
      return 'Excellent work. You have already reached your current savings goal.';
    }

    if (user.currentSavings > 0) {
      return 'You are building a stronger safety net for future emergencies and goals.';
    }

    return 'Start building your savings habit today to strengthen your financial resilience.';
  }

  String _formatCurrency(double value) {
    return 'RM ${value.toStringAsFixed(2)}';
  }
}
