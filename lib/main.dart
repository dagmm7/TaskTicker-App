import 'package:flutter/material.dart';

// Import Screens
import 'package:task_ticker_app/screens/welcome_screen.dart';
import 'package:task_ticker_app/screens/login_screen.dart';
import 'package:task_ticker_app/screens/signup_screen.dart';
import 'package:task_ticker_app/screens/home_screen.dart';

void main() {
  runApp(const TaskTickerApp());
}

class TaskTickerApp extends StatelessWidget {
  const TaskTickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskTicker',
      theme: ThemeData(primarySwatch: Colors.blue),

      // Initial screen when app opens
      initialRoute: '/welcome',

      routes: {
        '/welcome': (context) => WelcomeScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/home': (context) => const HomeScreen(),
      },

      debugShowCheckedModeBanner: false,
    );
  }
}
