import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'analyzer_screen.dart';
import 'simulator_screen.dart';
import 'bnpl_screen.dart';
import 'resilience_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final GlobalKey<CurvedNavigationBarState> _navKey = GlobalKey();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(onNavigate: _jumpToTab),
      const AnalyzerScreen(),
      const SimulatorScreen(),
      const BNPLScreen(),
      const ResilienceScreen(),
    ];
  }

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }

  void _jumpToTab(int index) {
    _navKey.currentState?.setPage(index);
  }

  String _getPageTitle() {
    const titles = [
      'Personal Dashboard',
      'Spending Analyzer',
      'Future Simulator',
      'BNPL Risk Shield',
      'Resilience Score'
    ];
    return titles[_currentIndex];
  }

  @override
  Widget build(BuildContext context) {
    // PopScope prevents accidental app exit on Android
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentIndex != 0) {
          _jumpToTab(0);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        extendBody: true, // Allows content to flow behind the curved bar
        appBar: _buildAppBar(),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          // Fixed: AnimatedSwitcher needs a unique key on the child to trigger
          child: Container(
            key: ValueKey<int>(_currentIndex),
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBottomNav() {
    return CurvedNavigationBar(
      key: _navKey,
      backgroundColor: Colors.transparent,
      color: AppColors.dark,
      buttonBackgroundColor: AppColors.primary,
      animationDuration: const Duration(milliseconds: 450),
      animationCurve: Curves.easeInOutBack, // Added a slight bounce
      height: 65,
      index: _currentIndex,
      onTap: _onTabTapped,
      items: const [
        Icon(Icons.grid_view_rounded, color: Colors.white, size: 24),
        Icon(Icons.analytics_rounded, color: Colors.white, size: 24),
        Icon(Icons.auto_graph_rounded, color: Colors.white, size: 24),
        Icon(Icons.credit_card_rounded, color: Colors.white, size: 24),
        Icon(Icons.shield_rounded, color: Colors.white, size: 24),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 2, // Slight shadow when scrolling
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'FinMentor',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.dark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'AI',
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Text(
            _getPageTitle(),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        _buildActionIcon(Icons.search_rounded),
        _buildNotificationIcon(),
        _buildUserAvatar(),
      ],
    );
  }

  Widget _buildActionIcon(IconData icon) {
    return IconButton(
      onPressed: () {},
      icon: Icon(icon, color: AppColors.dark, size: 22),
    );
  }

  Widget _buildNotificationIcon() {
    return Stack(
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded,
              color: AppColors.dark, size: 24),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.redAccent,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.background, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserAvatar() {
    return Padding(
      padding: const EdgeInsets.only(right: 16, left: 4),
      child: GestureDetector(
        onTap: () {},
        child: CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: const Text('👤', style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
