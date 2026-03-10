import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'main_shell.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isObscured = true;
  bool _isLoading = false;
  bool _rememberMe = false; // Added standard fintech feature

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainShell()),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Using a more dynamic gradient to match your FinMentor branding
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2419), Color(0xFF1A6B4A), Color(0xFF1E8A5C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBackButton(),
                  const SizedBox(height: 32),
                  _buildHeader(),
                  const SizedBox(height: 36),
                  _buildLoginForm(),
                  const SizedBox(height: 28),
                  _buildSignUpLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child:
            const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text('💚', style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 14),
            Text('FinMentor AI',
                style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 32),
        Text('Welcome back 👋',
            style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                height: 1.2)),
        const SizedBox(height: 8),
        Text('Log in to continue your financial journey',
            style:
                TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 15)),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFieldLabel('Email Address'),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              style: const TextStyle(color: AppColors.dark, fontSize: 15),
              decoration:
                  _inputDecoration('you@email.com', Icons.email_outlined),
              validator: (value) => (value == null || !value.contains('@'))
                  ? 'Enter a valid email'
                  : null,
            ),
            const SizedBox(height: 20),
            _buildFieldLabel('Password'),
            TextFormField(
              controller: _passwordController,
              obscureText: _isObscured,
              style: const TextStyle(color: AppColors.dark, fontSize: 15),
              decoration:
                  _inputDecoration('••••••••', Icons.lock_outline).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(_isObscured
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _isObscured = !_isObscured),
                  color: AppColors.grey,
                  iconSize: 20,
                ),
              ),
              validator: (value) => (value == null || value.length < 6)
                  ? 'Min 6 characters'
                  : null,
            ),

            // New: Remember Me & Forgot Password Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      child: Checkbox(
                        value: _rememberMe,
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                        onChanged: (v) => setState(() => _rememberMe = v!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Remember',
                        style: TextStyle(fontSize: 13, color: AppColors.grey)),
                  ],
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen())),
                  child: const Text('Forgot Password?',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildLoginButton(),
            const SizedBox(height: 20),
            _buildDivider(),
            const SizedBox(height: 20),
            _buildGoogleButton(),
          ],
        ),
      ),
    );
  }

  // --- UI Helpers ---

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(label,
          style: const TextStyle(
              fontSize: 13,
              color: AppColors.grey,
              fontWeight: FontWeight.w700)),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFD1D5DB)),
      prefixIcon: Icon(icon, color: AppColors.grey, size: 20),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF3F4F6))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : const Text('Log In',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(children: [
      const Expanded(child: Divider(color: Color(0xFFF3F4F6))),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text('or continue with',
            style: TextStyle(fontSize: 12, color: Colors.grey[400])),
      ),
      const Expanded(child: Divider(color: Color(0xFFF3F4F6))),
    ]);
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _isLoading ? null : () {},
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: Color(0xFFE5E7EB)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Replaced text 'G' with a generic colored icon placeholder
            const Icon(Icons.g_mobiledata, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            const Text('Google',
                style: TextStyle(
                    color: AppColors.dark,
                    fontWeight: FontWeight.w700,
                    fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Don't have an account? ",
              style: TextStyle(color: Colors.white.withOpacity(0.7))),
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SignupScreen())),
            child: const Text('Sign Up',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
