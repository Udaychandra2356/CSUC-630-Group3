// lib/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_gate.dart';

/// Updated splash screen with larger illustration, gradient,
/// and navigation into AuthGate.
class SplashScreen extends StatelessWidget {
  /// If you pass in an [auth] (for testing/mocking), we'll use that;
  /// otherwise fall back to the real FirebaseAuth.instance.
  final FirebaseAuth? auth;
  const SplashScreen({Key? key, this.auth}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create a non-nullable _auth local so we never shadow the field.
    final FirebaseAuth _auth = auth ?? FirebaseAuth.instance;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6A11CB), // Purple
              Color(0xFF2575FC), // Blue
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Central illustration
            Image.asset(
              'assets/Splash_screem_image.png',
              width: 500,
              height: 500,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 32),
            const Text(
              'Habit Stacker',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Build better habits, one stack at a time',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => AuthGate(auth: _auth),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Get Started',
                style: TextStyle(
                  color: Color(0xFF2575FC),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
