import 'package:flutter/material.dart';
import 'home_screen.dart'; // Import the new dashboard screen

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Log In"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "log in",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // New Dashboard Navigation Button for Developers/Testers
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Use pushReplacement to clear the login screen from the stack
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Colors.teal, width: 2),
                ),
                child: const Text(
                  "SKIP TO DASHBOARD ",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                // Navigate back to the previous screen (WelcomeScreen)
                Navigator.pop(context);
              },
              child: const Text("Go back to Welcome Screen"),
            ),
          ],
        ),
      ),
    );
  }
}
