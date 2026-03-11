import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/user_provider.dart';
import 'theme/app_theme.dart';

// Screens
import 'screens/onboarding_screen.dart';
import 'screens/main_shell.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/financial_setup_screen.dart';
import 'screens/income_screen.dart';
import 'screens/spent_screen.dart';
import 'screens/saved_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFF1E8A5C),
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Color(0xFF1E8A5C),
    ),
  );

  runApp(const AppProviders());
}

class AppProviders extends StatelessWidget {
  const AppProviders({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider(),
        ),
      ],
      child: const FinMentorApp(),
    );
  }
}

class FinMentorApp extends StatelessWidget {
  const FinMentorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinMentor AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const AppEntry(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/main': (context) => const MainShell(),
        '/income': (context) => IncomeScreen(
              onBack: () => Navigator.of(context).maybePop(),
            ),
        '/spent': (context) => SpentScreen(
              onBack: () => Navigator.of(context).maybePop(),
            ),
        '/saved': (context) => SavedScreen(
              onBack: () => Navigator.of(context).maybePop(),
            ),
      },
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);

        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: mediaQuery.textScaler.clamp(
              minScaleFactor: 1.0,
              maxScaleFactor: 1.1,
            ),
          ),
          child: ScrollConfiguration(
            behavior: const _AppScrollBehavior(),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      onUnknownRoute: (_) => MaterialPageRoute(
        builder: (_) => const OnboardingScreen(),
      ),
    );
  }
}

class AppEntry extends StatelessWidget {
  const AppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProv, _) {
        if (!userProv.isLoggedIn) {
          return const OnboardingScreen();
        }

        final hasFinancialProfile = userProv.income > 0 ||
            userProv.expenses > 0 ||
            userProv.savingsGoal > 0 ||
            userProv.bnplCommitments > 0;

        if (!hasFinancialProfile) {
          return FinancialSetupScreen(
            userName: userProv.userName.isEmpty ? 'User' : userProv.userName,
          );
        }

        return const MainShell();
      },
    );
  }
}

class _AppScrollBehavior extends MaterialScrollBehavior {
  const _AppScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
