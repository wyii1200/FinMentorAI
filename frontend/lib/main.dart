import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart'; // Ensure this import is here
import 'providers/user_provider.dart';
import 'theme/app_theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_shell.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const FinMentorApp(),
    ),
  );
}

class FinMentorApp extends StatelessWidget {
  const FinMentorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinMentor AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,

      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling,
          ),
          child: ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(overscroll: false),
            child: child!,
          ),
        );
      },

      // Use 'home' instead of 'initialRoute' for dynamic auth checking
      home: Consumer<UserProvider>(
        builder: (context, userProv, _) {
          // If logged in, go to MainShell, otherwise Onboarding
          return userProv.isLoggedIn
              ? const MainShell()
              : const OnboardingScreen();
        },
      ),

      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/main': (context) => const MainShell(),
      },

      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const OnboardingScreen(),
      ),
    );
  }
}
