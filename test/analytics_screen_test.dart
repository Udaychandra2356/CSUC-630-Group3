import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitstacker/add_habit_flow.dart';
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

  testWidgets('analytics can display habits', (WidgetTester tester) async {
    final fakehabit = Habit(
        id: "FakeID",
        name: "TestHabit",
        icon: "TestIcon",
        category: "Category",
        description: '',
        minTime: 30,
        maxTime: 120,
        startDate: DateTime(2017),
        targetTime: const TimeOfDay(hour: 13, minute: 30),
        days: [0, 1, 2]);

    // Create habit
    await HabitService().createHabit(fakehabit);

    await tester.pumpWidget(const MaterialApp(
      home: AnalyticsScreen(),
    ));

    await tester.pump(const Duration(seconds: 1));

    final thabitbutton = find.text('TestHabit');
    await tester.tap(thabitbutton);
    await tester.pumpAndSettle();
  });
}
