import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitstacker/profile_screen.dart' as profile_screen;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';


void main() {
  testWidgets('ProfileScreen displays Profile text and SignOutButton', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: profile_screen.MyProfileScreen(),
    ));

    // Check for "Profile Screen" text
    expect(find.text('Profile Screen'), findsOneWidget);

    // Check for SignOutButton (from firebase_ui_auth).
    expect(find.byType(SignOutButton), findsOneWidget);
  });
}
