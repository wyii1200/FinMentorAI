import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _email = TextEditingController();

  final List<TextEditingController> _otpControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _otpFocus = List.generate(4, (_) => FocusNode());

  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _loading = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;

  int _step = 0;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeInOut,
    );
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _email.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();

    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocus) {
      f.dispose();
    }

    _animCtrl.dispose();
    super.dispose();
  }

  String get _otpCode => _otpControllers.map((c) => c.text).join();

  bool get _isEmailValid => _email.text.trim().contains('@');

  bool get _isOtpValid =>
      _otpCode.length == 4 &&
      !_otpControllers.any((c) => c.text.trim().isEmpty);

  bool get _isPasswordValid => _newPassword.text.trim().length >= 8;

  bool get _isConfirmValid => _newPassword.text == _confirmPassword.text;

  Future<void> _handleContinue() async {
    FocusScope.of(context).unfocus();

    if (_step == 0 && !_isEmailValid) {
      _showMessage('Please enter a valid email address.');
      return;
    }

    if (_step == 1 && !_isOtpValid) {
      _showMessage('Please enter the complete 4-digit OTP code.');
      return;
    }

    if (_step == 2) {
      if (!_isPasswordValid) {
        _showMessage('Password must be at least 8 characters.');
        return;
      }
      if (!_isConfirmValid) {
        _showMessage('Passwords do not match.');
        return;
      }
    }

    setState(() => _loading = true);

    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;

    setState(() {
      _loading = false;
      if (_step < 3) {
        _step++;
      }
    });

    _animCtrl
      ..reset()
      ..forward();
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleBack() {
    if (_step > 0) {
      setState(() => _step--);
      _animCtrl
        ..reset()
        ..forward();
    } else {
      Navigator.maybePop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF064E3B), Color(0xFF065F46)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildBackButton(),
                  const SizedBox(height: 40),
                  Text(
                    _getStepTitle(),
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _getStepSubtitle(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.72),
                    ),
                  ),
                  const SizedBox(height: 40),
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.10),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: _buildCurrentStep(theme),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return IconButton(
      onPressed: _handleBack,
      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(ThemeData theme) {
    switch (_step) {
      case 0:
        return _buildEmailStep(theme);
      case 1:
        return _buildOtpStep(theme);
      case 2:
        return _buildNewPasswordStep(theme);
      default:
        return _buildSuccessStep(theme);
    }
  }

  Widget _buildEmailStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(theme, 'Email Address'),
        const SizedBox(height: 8),
        _buildTextField(
          theme: theme,
          controller: _email,
          hint: 'you@email.com',
          icon: Icons.email_outlined,
          type: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        Text(
          'We will send a 4-digit reset code to your email.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        _buildSubmitButton(theme, 'Send Reset Code'),
      ],
    );
  }

  Widget _buildOtpStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(theme, 'Enter 4-digit code'),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(4, (i) {
            return SizedBox(
              width: 58,
              height: 62,
              child: TextFormField(
                controller: _otpControllers[i],
                focusNode: _otpFocus[i],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
                decoration: _otpInputDecoration(),
                onChanged: (value) {
                  if (value.isNotEmpty && i < 3) {
                    _otpFocus[i + 1].requestFocus();
                  } else if (value.isEmpty && i > 0) {
                    _otpFocus[i - 1].requestFocus();
                  }
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        Text(
          'Code sent to ${_email.text.trim()}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        _buildSubmitButton(theme, 'Verify Code'),
      ],
    );
  }

  Widget _buildNewPasswordStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(theme, 'New Password'),
        const SizedBox(height: 8),
        _buildTextField(
          theme: theme,
          controller: _newPassword,
          hint: '••••••••',
          icon: Icons.lock_outline,
          isPassword: true,
          obscure: _obscureNew,
          onToggle: () => setState(() => _obscureNew = !_obscureNew),
        ),
        const SizedBox(height: 16),
        _buildLabel(theme, 'Confirm Password'),
        const SizedBox(height: 8),
        _buildTextField(
          theme: theme,
          controller: _confirmPassword,
          hint: '••••••••',
          icon: Icons.lock_reset,
          isPassword: true,
          obscure: _obscureConfirm,
          onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
        ),
        const SizedBox(height: 12),
        Text(
          'Use at least 8 characters for better security.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        _buildSubmitButton(theme, 'Reset Password'),
      ],
    );
  }

  Widget _buildSuccessStep(ThemeData theme) {
    return Column(
      children: [
        const Icon(
          Icons.check_circle_rounded,
          color: AppColors.primary,
          size: 80,
        ),
        const SizedBox(height: 20),
        Text(
          'Success!',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'You can now log in with your new password.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Go to Login'),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(ThemeData theme, String text) {
    return Text(
      text,
      style: theme.textTheme.bodySmall?.copyWith(
        fontSize: 13,
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildTextField({
    required ThemeData theme,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggle,
    TextInputType type = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: type,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: const Color(0xFFD1D5DB),
        ),
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: onToggle,
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSubmitButton(ThemeData theme, String label) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _loading ? null : _handleContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  InputDecoration _otpInputDecoration() {
    return InputDecoration(
      counterText: '',
      filled: true,
      fillColor: const Color(0xFFF3F4F6),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

  String _getStepTitle() {
    if (_step == 0) return 'Forgot Password?';
    if (_step == 1) return 'Verify OTP';
    if (_step == 2) return 'New Password';
    return 'All Set!';
  }

  String _getStepSubtitle() {
    if (_step == 0) return 'Enter your email to reset your account';
    if (_step == 1) return 'Enter the 4-digit code sent to your mail';
    if (_step == 2) return 'Create a strong password for your security';
    return 'Your password has been reset successfully';
  }
}
