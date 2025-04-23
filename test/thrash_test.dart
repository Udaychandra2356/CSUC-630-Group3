import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitstacker/auth_singleton.dart';
import 'package:habitstacker/planner_screen.dart';
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
    signedIn: true,
  );
  final mockDB = FakeFirebaseFirestore();
  AuthSingleton().auth = mockAuth;
  AuthSingleton().db = mockDB;
  ///////////// TESTING MOCKS /////////////

  testWidgets('planner thrash', (WidgetTester tester) async {
    // Pump the SplashScreen widget inside a MaterialApp to provide needed context.
    await tester.pumpWidget(const MaterialApp(
      home: PlannerScreen(),
    ));

    final tappables = find.byWidgetPredicate(
      (widget) =>
          widget is ElevatedButton ||
          widget is TextButton ||
          widget is IconButton,
    );
    final count = tester.widgetList(tappables).length;
    print('Found $count tappables in planner thrash test');
    for (var i = 0; i < tester.widgetList(tappables).length; i++) {
      final button = tester.widgetList(tappables).elementAt(i);
      final finder = find.byWidget(button);
      await tester.tap(finder);
      await tester.pump(); // pump to reflect UI changes
    }
  });
}
