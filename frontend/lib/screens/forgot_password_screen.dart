import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>(); // Added for validation
  final _email = TextEditingController();
  bool _loading = false;

  // OTP state
  final List<TextEditingController> _otpControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _otpFocus = List.generate(4, (_) => FocusNode());

  // New password state
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  int _step = 0;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _email.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var f in _otpFocus) {
      f.dispose();
    }
    _animCtrl.dispose();
    super.dispose();
  }

  // --- Logic ---

  void _handleContinue() async {
    // Validate current step before proceeding
    if (_step == 0 && !_email.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    if (_step == 2) {
      if (_newPassword.text.length < 8) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Password must be at least 8 characters')),
        );
        return;
      }
      if (_newPassword.text != _confirmPassword.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
        );
        return;
      }
    }

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1200));

    if (mounted) {
      setState(() {
        _loading = false;
        _step++;
        _animCtrl.reset();
        _animCtrl.forward();
      });
    }
  }

  // --- Step Widgets ---

  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Email Address'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _email,
          hint: 'you@email.com',
          icon: Icons.email_outlined,
          type: TextInputType.emailAddress,
        ),
        const SizedBox(height: 24),
        _buildSubmitButton('Send Reset Code'),
      ],
    );
  }

  Widget _buildOtpStep() {
    return Column(
      children: [
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
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
        const SizedBox(height: 24),
        _buildSubmitButton('Verify Code'),
      ],
    );
  }

  Widget _buildNewPasswordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('New Password'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _newPassword,
          hint: '••••••••',
          icon: Icons.lock_outline,
          isPassword: true,
          obscure: _obscureNew,
          onToggle: () => setState(() => _obscureNew = !_obscureNew),
        ),
        const SizedBox(height: 16),
        _buildLabel('Confirm Password'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _confirmPassword,
          hint: '••••••••',
          icon: Icons.lock_reset,
          isPassword: true,
          obscure: _obscureConfirm,
          onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
        ),
        const SizedBox(height: 24),
        _buildSubmitButton('Reset Password'),
      ],
    );
  }

  // --- Shared UI Components ---

  Widget _buildLabel(String text) {
    return Text(text,
        style: const TextStyle(
            fontSize: 13, color: AppColors.grey, fontWeight: FontWeight.w700));
  }

  Widget _buildTextField({
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
      style: const TextStyle(color: AppColors.dark, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.grey, size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(obscure ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.grey, size: 20),
                onPressed: onToggle,
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildSubmitButton(String label) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _loading ? null : _handleContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white)),
      ),
    );
  }

  InputDecoration _otpInputDecoration() {
    return InputDecoration(
      counterText: '',
      filled: true,
      fillColor: const Color(0xFFF3F4F6),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
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
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildBackButton(),
                  const SizedBox(height: 40),
                  Text(_getStepTitle(),
                      style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  Text(_getStepSubtitle(),
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.7), fontSize: 15)),
                  const SizedBox(height: 40),

                  // Main Content Card
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10))
                        ],
                      ),
                      child: _buildCurrentStep(),
                    ),
                  ),
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
      onPressed: () =>
          _step > 0 ? setState(() => _step--) : Navigator.pop(context),
      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case 0:
        return _buildEmailStep();
      case 1:
        return _buildOtpStep();
      case 2:
        return _buildNewPasswordStep();
      default:
        return _buildSuccessStep();
    }
  }

  String _getStepTitle() {
    if (_step == 0) return "Forgot Password?";
    if (_step == 1) return "Verify OTP";
    if (_step == 2) return "New Password";
    return "All Set!";
  }

  String _getStepSubtitle() {
    if (_step == 0) return "Enter your email to reset your account";
    if (_step == 1) return "Enter the 4-digit code sent to your mail";
    if (_step == 2) return "Create a strong password for your security";
    return "Your password has been reset successfully";
  }

  Widget _buildSuccessStep() {
    return Column(
      children: [
        const Icon(Icons.check_circle_rounded,
            color: AppColors.primary, size: 80),
        const SizedBox(height: 20),
        const Text("Success!",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        const Text("You can now login with your new password",
            textAlign: TextAlign.center),
        const SizedBox(height: 30),
        _buildSubmitButton("Go to Login"),
      ],
    );
  }
}
