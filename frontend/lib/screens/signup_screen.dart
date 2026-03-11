import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import 'financial_setup_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  bool _agreeTerms = false;
  double _strength = 0;

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeInOut,
    );
    _animCtrl.forward();

    _password.addListener(_calculateStrength);
  }

  void _calculateStrength() {
    double s = 0;
    final p = _password.text.trim();

    if (p.length >= 8) s += 0.25;
    if (p.contains(RegExp(r'[A-Z]'))) s += 0.25;
    if (p.contains(RegExp(r'[0-9]'))) s += 0.25;
    if (p.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]'))) s += 0.25;

    if (mounted) {
      setState(() => _strength = s);
    }
  }

  @override
  void dispose() {
    _password.removeListener(_calculateStrength);

    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();

    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();

    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms & Conditions to continue.'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await Future.delayed(const Duration(milliseconds: 1200));

      if (!mounted) return;

      final userProvider = context.read<UserProvider>();
      await userProvider.login(_name.text.trim());

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => FinancialSetupScreen(
            userName: _name.text.trim(),
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signup failed. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String? _validateName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Full name is required';
    if (text.length < 3) return 'Name is too short';
    return null;
  }

  String? _validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(text)) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Password is required';
    if (text.length < 8) return 'Use at least 8 characters';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Please confirm your password';
    if (text != _password.text) return 'Passwords do not match';
    return null;
  }

  String get _strengthLabel {
    if (_strength <= 0.25) return 'Weak password';
    if (_strength <= 0.75) return 'Moderate password';
    return 'Strong password';
  }

  Color get _strengthColor {
    if (_strength <= 0.25) return AppColors.danger;
    if (_strength <= 0.75) return AppColors.warning;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
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
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBackButton(),
                    const SizedBox(height: 20),
                    _buildHeader(theme),
                    const SizedBox(height: 24),
                    _buildFormCard(theme),
                    const SizedBox(height: 20),
                    _buildLoginLink(theme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return IconButton(
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
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create your account',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 31,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Start building smarter savings habits with AI-powered financial guidance.',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white.withOpacity(0.74),
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard(ThemeData theme) {
    return Container(
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
            'Set up your profile',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'We’ll use this to personalize your financial insights and recommendations.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              height: 1.5,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 22),
          _buildTextField(
            theme: theme,
            label: 'FULL NAME',
            controller: _name,
            focusNode: _nameFocus,
            hint: 'e.g. Amir Abdullah',
            icon: Icons.person_outline_rounded,
            validator: _validateName,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_emailFocus);
            },
          ),
          const SizedBox(height: 18),
          _buildTextField(
            theme: theme,
            label: 'EMAIL ADDRESS',
            controller: _email,
            focusNode: _emailFocus,
            hint: 'name@example.com',
            icon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_passwordFocus);
            },
          ),
          const SizedBox(height: 18),
          _buildTextField(
            theme: theme,
            label: 'PASSWORD',
            controller: _password,
            focusNode: _passwordFocus,
            hint: 'At least 8 characters',
            icon: Icons.lock_outline_rounded,
            obscure: _obscure,
            hasToggle: true,
            onToggle: () => setState(() => _obscure = !_obscure),
            validator: _validatePassword,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_confirmFocus);
            },
          ),
          _buildStrengthIndicator(theme),
          const SizedBox(height: 18),
          _buildTextField(
            theme: theme,
            label: 'CONFIRM PASSWORD',
            controller: _confirm,
            focusNode: _confirmFocus,
            hint: 'Repeat your password',
            icon: Icons.verified_user_outlined,
            obscure: _obscureConfirm,
            hasToggle: true,
            onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
            validator: _validateConfirmPassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _signup(),
          ),
          const SizedBox(height: 20),
          _buildTermsCheckbox(theme),
          const SizedBox(height: 24),
          _buildSignupButton(theme),
        ],
      ),
    );
  }

  Widget _buildStrengthIndicator(ThemeData theme) {
    final filledBars = (_strength * 4).round();

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(4, (index) {
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 6,
                  margin: EdgeInsets.only(right: index < 3 ? 5 : 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: index < filledBars
                        ? _strengthColor
                        : Colors.grey.shade200,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            _strengthLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: _strengthColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required ThemeData theme,
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData icon,
    bool obscure = false,
    bool hasToggle = false,
    VoidCallback? onToggle,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
    void Function(String)? onFieldSubmitted,
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
          focusNode: focusNode,
          obscureText: obscure,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          onFieldSubmitted: onFieldSubmitted,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
            suffixIcon: hasToggle
                ? IconButton(
                    onPressed: onToggle,
                    icon: Icon(
                      obscure
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  )
                : null,
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            filled: true,
            fillColor: const Color(0xFFF7F9F8),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
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

  Widget _buildTermsCheckbox(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: _agreeTerms,
            onChanged: (v) => setState(() => _agreeTerms = v ?? false),
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              'I agree to the Terms of Service and AI Privacy Policy.',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                height: 1.45,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignupButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: _loading ? null : _signup,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.7),
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
                'Continue',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }

  Widget _buildLoginLink(ThemeData theme) {
    return Center(
      child: TextButton(
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        ),
        child: RichText(
          text: TextSpan(
            text: 'Already a member? ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.78),
            ),
            children: const [
              TextSpan(
                text: 'Log In',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
