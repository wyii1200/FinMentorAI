import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../providers/user_provider.dart';

// Main tab screens
import 'dashboard_screen.dart';
import 'analyzer_screen.dart';
import 'simulator_screen.dart';
import 'bnpl_screen.dart';
import 'resilience_screen.dart';

// Sub screens
import 'income_screen.dart';
import 'spent_screen.dart';
import 'saved_screen.dart';
import 'search_screen.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final GlobalKey<CurvedNavigationBarState> _navKey =
      GlobalKey<CurvedNavigationBarState>();

  int _currentIndex = ShellTab.dashboard.tabIndex;
  int _lastMainTabIndex = ShellTab.dashboard.tabIndex;

  bool _isMainTab(int index) => index >= 0 && index <= 4;

  void _resetToDashboard() {
    setState(() {
      _currentIndex = ShellTab.dashboard.tabIndex;
      _lastMainTabIndex = ShellTab.dashboard.tabIndex;
    });
    _navKey.currentState?.setPage(ShellTab.dashboard.tabIndex);
  }

  void _goBackToPreviousMainTab() {
    setState(() {
      _currentIndex = _lastMainTabIndex;
    });
    _navKey.currentState?.setPage(_lastMainTabIndex);
  }

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;

    setState(() {
      _currentIndex = index;
      _lastMainTabIndex = index;
    });
  }

  void _jumpToTab(int index) {
    if (_currentIndex == index) return;

    setState(() {
      if (_isMainTab(index)) {
        _currentIndex = index;
        _lastMainTabIndex = index;
      } else {
        _currentIndex = index;
      }
    });

    if (_isMainTab(index)) {
      _navKey.currentState?.setPage(index);
    }
  }

  bool _showBottomNav() => _isMainTab(_currentIndex);

  bool _showAppBar() => _isMainTab(_currentIndex);

  Widget _getActiveScreen() {
    switch (_currentIndex) {
      case 0:
        return DashboardScreen(onNavigate: _jumpToTab);
      case 1:
        return const AnalyzerScreen();
      case 2:
        return const SimulatorScreen();
      case 3:
        return const BNPLScreen();
      case 4:
        return const ResilienceScreen();
      case 6:
        return IncomeScreen(onBack: _goBackToPreviousMainTab);
      case 7:
        return SpentScreen(onBack: _goBackToPreviousMainTab);
      case 8:
        return SavedScreen(onBack: _goBackToPreviousMainTab);
      case 9:
        return NotificationsScreen(onBack: _goBackToPreviousMainTab);
      case 10:
        return ProfileScreen(onBack: _goBackToPreviousMainTab);
      case 11:
        return SearchScreen(
          onBack: _goBackToPreviousMainTab,
          onNavigate: _jumpToTab,
        );
      default:
        return DashboardScreen(onNavigate: _jumpToTab);
    }
  }

  String _getPageTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Personal Dashboard';
      case 1:
        return 'Spending Analyzer';
      case 2:
        return 'Future Simulator';
      case 3:
        return 'BNPL Risk Shield';
      case 4:
        return 'Resilience Score';
      case 6:
        return 'Income Details';
      case 7:
        return 'Spending Breakdown';
      case 8:
        return 'Savings Goals';
      case 9:
        return 'Notifications';
      case 10:
        return 'My Profile';
      case 11:
        return 'Search';
      default:
        return 'FinMentor AI';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentIndex == ShellTab.dashboard.tabIndex,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentIndex != ShellTab.dashboard.tabIndex) {
          if (_isMainTab(_currentIndex)) {
            _resetToDashboard();
          } else {
            _goBackToPreviousMainTab();
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        extendBody: true,
        appBar: _showAppBar() ? _buildAppBar(context) : null,
        body: SafeArea(
          top: false,
          bottom: false,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: KeyedSubtree(
              key: ValueKey(_currentIndex),
              child: _getActiveScreen(),
            ),
          ),
        ),
        bottomNavigationBar: _showBottomNav() ? _buildBottomNav() : null,
      ),
    );
  }

  Widget _buildBottomNav() {
    return CurvedNavigationBar(
      key: _navKey,
      index: _currentIndex.clamp(0, 4).toInt(),
      backgroundColor: Colors.transparent,
      color: AppColors.textPrimary,
      buttonBackgroundColor: AppColors.primary,
      animationDuration: const Duration(milliseconds: 350),
      animationCurve: Curves.easeOutCubic,
      height: 64,
      onTap: _onTabTapped,
      items: const [
        Icon(Icons.grid_view_rounded, color: Colors.white, size: 22),
        Icon(Icons.analytics_rounded, color: Colors.white, size: 22),
        Icon(Icons.auto_graph_rounded, color: Colors.white, size: 22),
        Icon(Icons.credit_card_rounded, color: Colors.white, size: 22),
        Icon(Icons.shield_rounded, color: Colors.white, size: 22),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<UserProvider>();

    final firstName = user.userName.trim().isEmpty
        ? 'User'
        : user.userName.trim().split(' ').first;

    final initial = firstName[0].toUpperCase();

    return AppBar(
      backgroundColor: AppColors.background,
      automaticallyImplyLeading: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 16,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FinMentor',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _getPageTitle(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Search',
          icon: const Icon(Icons.search_rounded, color: AppColors.textPrimary),
          onPressed: () => _jumpToTab(11),
        ),
        IconButton(
          tooltip: 'Notifications',
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => _jumpToTab(9),
        ),
        GestureDetector(
          onTap: () => _jumpToTab(10),
          child: Padding(
            padding: const EdgeInsets.only(right: 16, left: 8),
            child: CircleAvatar(
              radius: 17,
              backgroundColor: AppColors.primary.withOpacity(0.14),
              child: Text(
                initial,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

enum ShellTab {
  dashboard(0),
  analyzer(1),
  simulator(2),
  bnpl(3),
  resilience(4);

  const ShellTab(this.tabIndex);
  final int tabIndex;
}