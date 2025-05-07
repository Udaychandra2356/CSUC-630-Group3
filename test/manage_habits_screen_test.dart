import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:habitstacker/add_habit_flow.dart';
import 'package:habitstacker/auth_singleton.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:habitstacker/manage_habits_screen.dart';

void main() {
  ///////////// TESTING MOCKS /////////////
  setUpAll(() {
    setFirebaseUiIsTestMode(true);
  });
  final mockAuth = MockFirebaseAuth(
    mockUser: MockUser(
      uid: 'testUser',
      email: 'testUser@test.com',
    ),
    signedIn: true,
  );
  final mockDB = FakeFirebaseFirestore();
  AuthSingleton.initialize(
    mockAuth: mockAuth,
    mockDb: mockDB,
  );
  // Mock an Firebase entry

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

  const uid = 'testUser';
  const habitId = 'FakeID';

  ///////////// TESTING MOCKS /////////////

  testWidgets('Manage Habits screen renders and can remove',
      (WidgetTester tester) async {
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

    const uid = 'testUser';
    await HabitService().createHabit(fakehabit);

    final habits = await HabitService().allHabits().first;
    for (final hab in habits) {
      print(hab);
    }

    // Pump the plannerscreen widget inside a MaterialApp to provide needed context.
    await tester.pumpWidget(const MaterialApp(
      home: ManageHabitsScreen(),
    ));

    await tester.pump(const Duration(seconds: 1));

    final deletebutton = find.byIcon(Icons.delete);
    expect(deletebutton, findsOneWidget); // found delete
    await tester.tap(deletebutton);
    await tester.pumpAndSettle();
  });
}
