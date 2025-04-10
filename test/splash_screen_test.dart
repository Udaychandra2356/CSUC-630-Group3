import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:habitstacker/splash_screen.dart';
import 'package:habitstacker/firebase_options.dart';  // adjust path as needed


void main() {

setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Initialize a FAKE app so the call to FirebaseAuth.instance won't crash
    await Firebase.initializeApp(
      name: 'test',
      options: const FirebaseOptions(
        appId: '1:1:1:1:1',
        apiKey: 'testKey',
        projectId: 'testProject',
        messagingSenderId: '12345',
      ),
    );
  });

  testWidgets('SplashScreen renders logo and text', (WidgetTester tester) async {
    // Pump the SplashScreen widget inside a MaterialApp to provide needed context.
    await tester.pumpWidget(const MaterialApp(
      home: SplashScreen(),
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
