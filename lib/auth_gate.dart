import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:habitstacker/auth_singleton.dart';
import 'home_screen.dart';

class AuthGate extends StatelessWidget {
  final FirebaseAuth? auth; // nullable firebase auth to have mocks work.
  const AuthGate({super.key, this.auth});

  @override
  Widget build(BuildContext context) {
    // if auth isnt passed, createa firebaseauth instance.
    final FirebaseAuth _auth = auth ?? FirebaseAuth.instance;
    // Set the auth singleton here!
    AuthSingleton().auth = _auth;
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(
            auth: _auth,
            providers: [
              EmailAuthProvider(),
              GoogleProvider(
                clientId:
                    "265607603336-2o35dimd24m7gr5c78s85dq5cl649fse.apps.googleusercontent.com",
              ),
            ],
            headerBuilder: (context, constraints, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                // Need to wrap with single child scroll view because render overflow
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: Image.asset('assets/g-logo.png'),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Habit Stacker',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            subtitleBuilder: (context, action) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: action == AuthAction.signIn
                    ? const Text('Welcome to Habit Stacker, please sign in!')
                    : const Text('Welcome to Habit Stacker, please sign up!'),
              );
            },
            footerBuilder: (context, action) {
              return const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'By signing in, you agree to our terms and conditions.',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            },
            sideBuilder: (context, shrinkOffset) {
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

        return const HomeScreen();
      },
    );
  }
}
