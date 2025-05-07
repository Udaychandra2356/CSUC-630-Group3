import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:habitstacker/planner_screen.dart';
import 'package:habitstacker/auth_singleton.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
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
  AuthSingleton.initialize(
    mockAuth: mockAuth,
    mockDb: mockDB,
  );
  ///////////// TESTING MOCKS /////////////

  testWidgets('Planner screen renders', (WidgetTester tester) async {
    // Pump the plannerscreen widget inside a MaterialApp to provide needed context.
    await tester.pumpWidget(const MaterialApp(
      home: PlannerScreen(),
    ));

    await tester.tap(find.text('2 weeks'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Week'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Month'));
    await tester.pumpAndSettle();

    final anyDay = find.text('${DateTime.now().day}');
    expect(anyDay, findsOneWidget);
    await tester.tap(anyDay);
    await tester.pumpAndSettle();
  });
}
