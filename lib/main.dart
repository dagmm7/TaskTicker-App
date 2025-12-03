import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // Import your new home screen

void main() {
  runApp(const TaskTickerApp());
}

class TaskTickerApp extends StatelessWidget {
  const TaskTickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskTicker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Set HomeScreen as the main entry point
      home: const HomeScreen(),
    );
  }
}