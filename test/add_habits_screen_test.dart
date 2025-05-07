import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitstacker/auth_singleton.dart';
import 'package:habitstacker/add_habit_flow.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

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
  AuthSingleton.initialize(
    mockAuth: mockAuth,
    mockDb: mockDB,
  );
  ///////////// TESTING MOCKS /////////////

  testWidgets('add habit screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: AddHabitsScreen(),
    ));

    await tester.pump(const Duration(seconds: 1));
  });

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

  testWidgets('HabitFormScreen renders', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: HabitFormScreen(
        original: fakehabit,
        presetName: "sports",
        presetIcon: "icon",
        category: "category",
      ),
    ));

    await tester.pump(const Duration(seconds: 1));
  });
}
