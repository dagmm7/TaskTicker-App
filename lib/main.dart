import 'package:flutter/material.dart';

// Import welcome screen
import 'package:task_ticker_app/screens/welcome_screen.dart';

// Import login & signup screens
import 'package:task_ticker_app/screens/login_screen.dart';
import 'package:task_ticker_app/screens/signup_screen.dart';

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
      home: WelcomeScreen(), // Starting page
      debugShowCheckedModeBanner: false,
    );
  }
}
