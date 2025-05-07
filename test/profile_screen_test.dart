import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitstacker/auth_singleton.dart';
import 'package:habitstacker/profile_screen.dart' as profile_screen;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

void main() {
  ///////////// TESTING MOCKS /////////////
  setUpAll(() {
    setFirebaseUiIsTestMode(true);
  });
  final mockAuth = MockFirebaseAuth(
    mockUser: MockUser(
      uid: 'someUid',
      email: 'someuser@test.com',
    ),
    signedIn: true,
  );
  final mockDB = FakeFirebaseFirestore();
  AuthSingleton.initialize(
    mockAuth: mockAuth,
    mockDb: mockDB,
  );
  ///////////// TESTING MOCKS /////////////

  testWidgets('ProfileScreen displays Profile text and SignOutButton',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: profile_screen.MyProfileScreen(),
    ));

    // Check for "Profile Screen" text
    expect(find.text('Profile Screen'), findsOneWidget);

    // Check for SignOutButton (from firebase_ui_auth).
    expect(find.byType(SignOutButton), findsOneWidget);
  });
}
