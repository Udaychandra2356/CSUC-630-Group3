import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitstacker/splash_screen.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
// adjust path as needed

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
    signedIn: false,
  );

  ///////////// TESTING MOCKS /////////////

  testWidgets('SplashScreen renders logo and text',
      (WidgetTester tester) async {
    // Pump the SplashScreen widget inside a MaterialApp to provide needed context.
    await tester.pumpWidget(MaterialApp(
      home: SplashScreen(auth: mockAuth),
    ));

    // Look for the app logo image.
    expect(find.byType(Image), findsOneWidget);

    // Look for the title text "Habit Stacker".
    expect(find.text('Habit Stacker'), findsOneWidget);

    // The SplashScreen navigates after 3 seconds, so we can simulate time passing:
    await tester.pump(const Duration(seconds: 3));

    // After 3 seconds, it should pushReplacement to AuthGate.
    // If you want to check the resulting widget, you could add a mock or check that
    // the new route was pushed. For now, we'll just confirm no errors are thrown.
  });
}
