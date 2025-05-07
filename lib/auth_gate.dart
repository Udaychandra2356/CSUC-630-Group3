// lib/auth_gate.dart

import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:habitstacker/auth_singleton.dart';
import 'home_screen.dart';

class AuthGate extends StatelessWidget {
  /// If you pass in an [auth] (for testing/mocking), we'll use that;
  /// otherwise fall back to the real singleton.
  final FirebaseAuth? auth;

  const AuthGate({Key? key, this.auth}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = AuthSingleton().auth;

    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        // not signed in? show the FirebaseUI sign-in screen
        if (!snapshot.hasData) {
          return SignInScreen(
            auth: _auth,
            providers: [
              EmailAuthProvider(),
              GoogleProvider(
                clientId:
                    '265607603336-2o35dimd24m7gr5c78s85dq5cl649fse.apps.googleusercontent.com',
              ),
            ],
            footerBuilder: (context, _) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'By signing in, you agree to our terms and conditions.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              );
            },
            sideBuilder: (context, _) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset('assets/g-logo.png'),
                ),
              );
            },
          );
        }

        // already signed in? go to home
        return const HomeScreen();
      },
    );
  }
}
