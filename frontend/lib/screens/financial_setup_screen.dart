import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';

class FinancialSetupScreen extends StatefulWidget {
  final String userName;

  const FinancialSetupScreen({
    super.key,
    required this.userName,
  });

  @override
  State<FinancialSetupScreen> createState() => _FinancialSetupScreenState();
}

class _FinancialSetupScreenState extends State<FinancialSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _incomeController = TextEditingController();
  final _expensesController = TextEditingController();
  final _savingsGoalController = TextEditingController();
  final _bnplController = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _incomeController.dispose();
    _expensesController.dispose();
    _savingsGoalController.dispose();
    _bnplController.dispose();
    super.dispose();
  }

  String? _validateAmount(String? value, String fieldName) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return '$fieldName is required';

    final number = double.tryParse(text);
    if (number == null) return 'Enter a valid number';
    if (number < 0) return '$fieldName cannot be negative';

    return null;
  }

  Future<void> _continueToApp() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    final userProvider = context.read<UserProvider>();

    userProvider.setFinancialProfile(
      income: double.parse(_incomeController.text.trim()),
      expenses: double.parse(_expensesController.text.trim()),
      savingsGoal: double.parse(_savingsGoalController.text.trim()),
      bnplCommitments: double.parse(_bnplController.text.trim()),
    );

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/main',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF1E8A5C),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F2419),
              Color(0xFF1A6B4A),
              Color(0xFF1E8A5C),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 36,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.maybePop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.10),
                            padding: const EdgeInsets.all(12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Let’s personalize your plan',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                            height: 1.08,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Hi ${widget.userName.split(' ').first}, tell us a bit about your finances so FinMentor AI can generate smarter insights.',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white.withOpacity(0.76),
                            fontSize: 14.5,
                            height: 1.55,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 26),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.14),
                                blurRadius: 28,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Financial snapshot',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'You can update these values later inside the app.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  height: 1.5,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 22),
                              _buildAmountField(
                                label: 'MONTHLY INCOME',
                                hint: 'e.g. 3500',
                                icon: Icons.account_balance_wallet_outlined,
                                controller: _incomeController,
                                validator: (value) =>
                                    _validateAmount(value, 'Monthly income'),
                              ),
                              const SizedBox(height: 18),
                              _buildAmountField(
                                label: 'MONTHLY EXPENSES',
                                hint: 'e.g. 2200',
                                icon: Icons.receipt_long_outlined,
                                controller: _expensesController,
                                validator: (value) =>
                                    _validateAmount(value, 'Monthly expenses'),
                              ),
                              const SizedBox(height: 18),
                              _buildAmountField(
                                label: 'SAVINGS GOAL',
                                hint: 'e.g. 1000',
                                icon: Icons.savings_outlined,
                                controller: _savingsGoalController,
                                validator: (value) =>
                                    _validateAmount(value, 'Savings goal'),
                              ),
                              const SizedBox(height: 18),
                              _buildAmountField(
                                label: 'BNPL COMMITMENTS',
                                hint: 'e.g. 300',
                                icon: Icons.credit_card_outlined,
                                controller: _bnplController,
                                validator: (value) =>
                                    _validateAmount(value, 'BNPL commitments'),
                              ),
                              const SizedBox(height: 26),
                              SizedBox(
                                width: double.infinity,
                                height: 58,
                                child: ElevatedButton(
                                  onPressed: _loading ? null : _continueToApp,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        AppColors.primary.withOpacity(0.7),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  child: _loading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.2,
                                          ),
                                        )
                                      : Text(
                                          'Finish Setup',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAmountField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: validator,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              size: 20,
              color: AppColors.primary,
            ),
            prefixText: 'RM ',
            prefixStyle: GoogleFonts.plusJakartaSans(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            filled: true,
            fillColor: const Color(0xFFF7F9F8),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
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
            errorStyle: const TextStyle(fontSize: 10),
          ),
        ),
      ],
    );
  }
}
