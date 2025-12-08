import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // IMAGE
            SizedBox(
              height: 180,
              child: Image.network(
                "https://cdn-icons-png.flaticon.com/512/5956/5956494.png",
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 30),

            