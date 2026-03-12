import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

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
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.1, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _chartAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
      ),
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
    final List<double> bars = [32, 48, 40, 62, 55, 78, 72, 90];

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0B1D14),
              Color(0xFF155238),
              Color(0xFF1E8A5C),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final h = constraints.maxHeight;
              final isCompact = h < 760;

              final topGap = isCompact ? 16.0 : 24.0;
              final sectionGap = isCompact ? 16.0 : 22.0;
              final featureGap = isCompact ? 14.0 : 20.0;
              final bottomGap = isCompact ? 18.0 : 26.0;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    topGap,
                    24,
                    bottomGap,
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: h - bottomGap,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(),
                            SizedBox(height: sectionGap),
                            _buildHeadline(),
                            SizedBox(height: sectionGap),
                            _buildAnimatedChart(bars),
                            SizedBox(height: featureGap),
                            _buildFeatureList(),
                            SizedBox(height: isCompact ? 20 : 28),
                            _buildActionButtons(context),
                          ],
                        ),
                      ),
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

  Widget _buildHeader() {
    return Row(
      children: [
        _glassBox(
          width: 52,
          height: 52,
          borderRadius: 16,
          child: const Icon(
            Icons.account_balance_wallet_rounded,
            color: Color(0xFFA7F36B),
            size: 28,
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FOR ASEAN YOUTH',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white.withOpacity(0.58),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              'FinMentor AI',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeadline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Beat debt.\nBuild wealth.\nStay resilient.',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            height: 1.08,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Smart AI guidance for BNPL awareness, savings habits, and stronger financial resilience.',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white.withOpacity(0.78),
            fontSize: 14,
            height: 1.55,
            fontWeight: FontWeight.w500,
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
            _glassCard(
              borderRadius: 24,
              padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
              child: SizedBox(
                height: 82,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: bars.asMap().entries.map((e) {
                    final isLast = e.key == bars.length - 1;

                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        height: e.value * _chartAnim.value,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: isLast
                                ? [
                                    const Color(0xFFA7F36B),
                                    Colors.white,
                                  ]
                                : [
                                    Colors.white.withOpacity(0.10),
                                    Colors.white.withOpacity(0.30),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            Positioned(
              top: -14,
              right: 8,
              child: Transform.scale(
                scale: _chartAnim.value.clamp(0.0, 1.0),
                child: _buildBadge('+32% avg savings'),
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
        color: const Color(0xFFFFD166),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          color: const Color(0xFF0F2419),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildFeatureList() {
    final features = [
      {
        'title': 'BNPL Alerts',
        'subtitle': 'Spot risky debt patterns before they grow.',
        'icon': Icons.notifications_active_rounded,
        'accent': const Color(0xFFFFD166),
      },
      {
        'title': 'Risk Analysis',
        'subtitle': 'See your financial resilience instantly.',
        'icon': Icons.shield_rounded,
        'accent': const Color(0xFFA7F36B),
      },
      {
        'title': 'AI Coaching',
        'subtitle': 'Get smart daily savings guidance.',
        'icon': Icons.auto_awesome_rounded,
        'accent': const Color(0xFF8FD3FF),
      },
    ];

    return Column(
      children: features.map((item) {
        final accent = item['accent'] as Color;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _glassCard(
            borderRadius: 20,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: accent.withOpacity(0.20),
                    ),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: accent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['subtitle'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white.withOpacity(0.72),
                          fontSize: 13,
                          height: 1.38,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignupScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF155238),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              shadowColor: Colors.transparent,
            ),
            child: Text(
              'Get Started →',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          ),
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white.withOpacity(0.65),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              children: const [
                TextSpan(text: 'Already a member? '),
                TextSpan(
                  text: 'Log in',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _glassCard({
    required Widget child,
    required double borderRadius,
    EdgeInsetsGeometry? padding,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _glassBox({
    required double width,
    required double height,
    required double borderRadius,
    required Widget child,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
