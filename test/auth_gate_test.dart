import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitstacker/auth_gate.dart';
// adjust path as needed

import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

// // If using mockito, you can create a MockFirebaseAuth, etc.
// class MockUser extends Mock implements User {}
// class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() async {
  setUpAll(() {
    setFirebaseUiIsTestMode(true);
  });

  testWidgets('AuthGate shows SignInScreen when user is not signed in',
      (WidgetTester tester) async {
    // In a real test, you'd configure mock FirebaseAuth to return null for currentUser.

    final mockAuth = MockFirebaseAuth(
      mockUser: MockUser(
        uid: 'someUid',
        email: 'someuser@test.com',
      ),
      signedIn: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AuthGate(auth: mockAuth),
      ),
    );

    // We expect to see a SignInScreen from firebase_ui_auth by default:
    // It might contain sign-in form fields, "Habit Stacker" header, etc.
    expect(find.text('Habit Stacker'), findsOneWidget);
    expect(find.byType(TextFormField), findsWidgets); // Email + password fields
  });
}
