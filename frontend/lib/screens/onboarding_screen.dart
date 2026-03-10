import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart'; // Import for navigation
import 'main_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _mainCtrl;

  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _chartAnim;

  @override
  void initState() {
    super.initState();
    _mainCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _mainCtrl,
          curve: const Interval(0.0, 0.4, curve: Curves.easeIn)),
    );

    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
      CurvedAnimation(
          parent: _mainCtrl,
          curve: const Interval(0.1, 0.6, curve: Curves.easeOutCubic)),
    );

    _chartAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _mainCtrl,
          curve: const Interval(0.4, 1.0, curve: Curves.elasticOut)),
    );

    _mainCtrl.forward();
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<double> bars = [40.0, 55.0, 45.0, 70.0, 60.0, 85.0, 75.0, 95.0];

    return Scaffold(
      extendBodyBehindAppBar: true,
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
            child: SlideTransition(
              position: _slideAnim,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    _buildHeader(),
                    const Spacer(),
                    _buildHeadline(),
                    const SizedBox(height: 44),
                    _buildAnimatedChart(bars),
                    const SizedBox(height: 44),
                    _buildFeatureChips(),
                    const Spacer(flex: 2),
                    _buildActionButtons(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: const Text('💚', style: TextStyle(fontSize: 22)),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('FOR ASEAN YOUTH',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                )),
            Text('FinMentor AI',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                )),
          ],
        ),
      ],
    );
  }

  Widget _buildHeadline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Beat debt.\nBuild wealth.\nStay resilient.',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.w800,
              height: 1.1,
              letterSpacing: -1,
            )),
        const SizedBox(height: 20),
        Text(
          'Smart AI guidance for navigating BNPL, automated savings, and financial freedom.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.75),
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedChart(List<double> bars) {
    return AnimatedBuilder(
      animation: _chartAnim,
      builder: (context, child) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 120,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: bars.asMap().entries.map((e) {
                  final isLast = e.key == bars.length - 1;
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: e.value * _chartAnim.value,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: isLast
                              ? [Colors.white, Colors.white]
                              : [
                                  Colors.white.withOpacity(0.1),
                                  Colors.white.withOpacity(0.3)
                                ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Positioned(
              top: -20,
              right: -10,
              child: Transform.scale(
                scale: _chartAnim.value,
                child: _buildBadge('📈 +32% avg savings'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD166), // Warmer gold for better accessibility
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      child: Text(text,
          style: const TextStyle(
              color: Color(0xFF0F2419),
              fontSize: 11,
              fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildFeatureChips() {
    final chips = ['BNPL Alerts', 'Risk Analysis', 'AI Coaching'];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: chips
          .map((f) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt, color: Color(0xFFFFD166), size: 16),
                    const SizedBox(width: 8),
                    Text(f,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 62,
          child: ElevatedButton(
            onPressed: () => Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const MainShell())),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1A6B4A),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Get Started →',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const LoginScreen())),
          child: RichText(
            text: TextSpan(
              style:
                  TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
              children: const [
                TextSpan(text: 'Already a member? '),
                TextSpan(
                  text: 'Log in',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      decoration: TextDecoration.underline),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
