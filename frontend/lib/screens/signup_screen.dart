import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/user_provider.dart'; // Adjust the path if your folder structure is different
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  // State Management
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  bool _agreeTerms = false;
  double _strength = 0;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInQuint);
    _animCtrl.forward();

    _password.addListener(_calculateStrength);
  }

  void _calculateStrength() {
    double s = 0;
    String p = _password.text;
    if (p.length >= 8) s += 0.25;
    if (p.contains(RegExp(r'[A-Z]'))) s += 0.25;
    if (p.contains(RegExp(r'[0-9]'))) s += 0.25;
    if (p.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) s += 0.25;
    setState(() => _strength = s);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    // 1. Validate Form
    if (!_formKey.currentState!.validate()) return;

    // 2. Validate Terms
    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms & Conditions to continue'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // 3. Simulate API Call / Registration
      await Future.delayed(const Duration(milliseconds: 2000));

      if (mounted) {
        // 4. Update Global State
        // We use listen: false because we are calling this inside a function
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.login(_name.text);

        // 5. Navigate to Dashboard
        // pushNamedAndRemoveUntil ensures the user can't "go back" to the signup page
        Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
      }
    } catch (e) {
      setState(() => _loading = false);
      // Handle potential errors here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBackButton(),
                    const SizedBox(height: 20),
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildFormCard(),
                    const SizedBox(height: 24),
                    _buildSocialSignup(),
                    const SizedBox(height: 24),
                    _buildLoginLink(),
                    const SizedBox(height: 20),
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
      onPressed: () => Navigator.pop(context),
      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.1),
        padding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Create Account 🚀',
            style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -1)),
        const SizedBox(height: 8),
        Text('Join the ASEAN youth financial revolution.',
            style:
                TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 15)),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          _buildTextField(
            label: 'FULL NAME',
            controller: _name,
            hint: 'e.g. Amir Abdullah',
            icon: Icons.person_outline_rounded,
            validator: (v) => v!.length < 3 ? 'Name is too short' : null,
          ),
          const SizedBox(height: 18),
          _buildTextField(
            label: 'EMAIL ADDRESS',
            controller: _email,
            hint: 'name@example.com',
            icon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: (v) => !v!.contains('@') ? 'Enter a valid email' : null,
          ),
          const SizedBox(height: 18),
          _buildTextField(
            label: 'PASSWORD',
            controller: _password,
            hint: 'At least 8 characters',
            icon: Icons.lock_outline_rounded,
            obscure: _obscure,
            hasToggle: true,
            onToggle: () => setState(() => _obscure = !_obscure),
          ),
          _buildStrengthIndicator(),
          const SizedBox(height: 18),
          _buildTextField(
            label: 'CONFIRM PASSWORD',
            controller: _confirm,
            hint: 'Repeat your password',
            icon: Icons.verified_user_outlined,
            obscure: _obscureConfirm,
            hasToggle: true,
            onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
            validator: (v) =>
                v != _password.text ? 'Passwords match fail' : null,
          ),
          const SizedBox(height: 20),
          _buildTermsCheckbox(),
          const SizedBox(height: 24),
          _buildSignupButton(),
        ],
      ),
    );
  }

  Widget _buildStrengthIndicator() {
    Color color = _strength <= 0.25
        ? Colors.red
        : _strength <= 0.75
            ? Colors.orange
            : AppColors.primary;
    return Column(
      children: [
        const SizedBox(height: 8),
        Row(
          children: List.generate(4, (index) {
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: index < 3 ? 4 : 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: (index < (_strength * 4)) ? color : Colors.grey[200],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    bool hasToggle = false,
    VoidCallback? onToggle,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.grey,
                letterSpacing: 1)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
            suffixIcon: hasToggle
                ? IconButton(
                    onPressed: onToggle,
                    icon: Icon(
                        obscure
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        size: 20))
                : null,
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1)),
            errorStyle: const TextStyle(fontSize: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: _agreeTerms,
            onChanged: (v) => setState(() => _agreeTerms = v!),
            activeColor: AppColors.primary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
            child: Text('I agree to the Terms of Service & AI Privacy Policy',
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.dark,
                    fontWeight: FontWeight.w500))),
      ],
    );
  }

  Widget _buildSignupButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _loading ? null : _signup,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : const Text('Create Account',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      ),
    );
  }

  Widget _buildSocialSignup() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.white.withOpacity(0.2))),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('OR CONTINUE WITH',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 10,
                        fontWeight: FontWeight.bold))),
            Expanded(child: Divider(color: Colors.white.withOpacity(0.2))),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _socialIcon(Icons.g_mobiledata_rounded, 'Google'),
            const SizedBox(width: 16),
            _socialIcon(Icons.apple_rounded, 'Apple'),
          ],
        ),
      ],
    );
  }

  Widget _socialIcon(IconData icon, String label) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: TextButton(
        onPressed: () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LoginScreen())),
        child: RichText(
          text: TextSpan(
            text: 'Already a member? ',
            style:
                TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
            children: const [
              TextSpan(
                  text: 'Log In',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      decoration: TextDecoration.underline))
            ],
          ),
        ),
      ),
    );
  }
}
