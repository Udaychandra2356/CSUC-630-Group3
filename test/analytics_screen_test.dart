import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitstacker/auth_singleton.dart';
import 'package:habitstacker/analytics_screen.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  ///////////// TESTING MOCKS /////////////
  setUpAll(() {
    setFirebaseUiIsTestMode(true);
  });
  final mockAuth = MockFirebaseAuth(
    mockUser: MockUser(
      uid: 'testUser',
      email: 'testuser@test.com',
    ),
    signedIn: true,
  );
  final mockDB = FakeFirebaseFirestore();
  AuthSingleton().auth = mockAuth;
  AuthSingleton().db = mockDB;

  // Mock an Firebase entry
  final uid = 'testUser';
  final habitId = 'habit1';
  final habitDoc =
      mockDB.collection('users').doc(uid).collection('habits').doc(habitId);
  // Define your date range
  final startUtc = DateTime.utc(2024, 1, 1);
  final endUtc = DateTime.utc(2024, 1, 31);
  habitDoc.collection('sessions').add({
    'timestamp': Timestamp.fromDate(DateTime.utc(2024, 1, 5)),
  });
  habitDoc.collection('sessions').add({
    'timestamp': Timestamp.fromDate(DateTime.utc(2024, 2, 1)), // outside range
  });
  ///////////// TESTING MOCKS /////////////

  testWidgets('analytics shows week', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: AnalyticsScreen(),
    ));

    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Weekly'), findsOneWidget);
    expect(find.text('Monthly'), findsOneWidget);
    expect(find.text('Yearly'), findsOneWidget);
  });

  ///////////// TESTING MOCKS /////////////

  testWidgets('analytics can switch betweent weekly monthly yearly',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: AnalyticsScreen(),
    ));

    await tester.pump(const Duration(seconds: 1));

    final weekly = find.text('Weekly');
    await tester.tap(weekly);
    await tester.pumpAndSettle();

    final monthly = find.text('Monthly');
    await tester.tap(monthly);
    await tester.pumpAndSettle();

    final yearly = find.text('Yearly');
    await tester.tap(yearly);
    await tester.pumpAndSettle();
  });
}
