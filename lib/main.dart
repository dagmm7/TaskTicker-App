import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Import Services
import 'package:task_ticker_app/services/hive_service.dart';

// Import Screens
import 'package:task_ticker_app/screens/welcome_screen.dart';
import 'package:task_ticker_app/screens/login_screen.dart';
import 'package:task_ticker_app/screens/signup_screen.dart';
import 'package:task_ticker_app/screens/home_screen.dart';
import 'package:task_ticker_app/screens/onboarding_screen.dart';
import 'package:task_ticker_app/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(const TaskTickerApp());
}

class TaskTickerApp extends StatefulWidget {
  const TaskTickerApp({super.key});

  @override
  State<TaskTickerApp> createState() => _TaskTickerAppState();
}

class _TaskTickerAppState extends State<TaskTickerApp> {
  @override
  void initState() {
    super.initState();
    // Initialize notifier from saved value
    HiveService.themeNotifier.value = HiveService.getThemeMode();
    HiveService.themeNotifier.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    HiveService.themeNotifier.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = HiveService.themeNotifier.value == 'dark';
    return MaterialApp(
      title: 'TaskTicker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF4A90E2),
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A90E2),
          primary: const Color(0xFF4A90E2),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4A90E2),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4A90E2),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 2),
          ),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF4A90E2),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF4A90E2)),
      ),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

      initialRoute: '/welcome',

      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const HomeScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },

      debugShowCheckedModeBanner: false,
    );
  }
}
