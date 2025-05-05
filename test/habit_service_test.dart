import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitstacker/add_habit_flow.dart';
import 'package:habitstacker/auth_singleton.dart';
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
      email: 'testUser@test.com',
    ),
    signedIn: true,
  );
  final mockDB = FakeFirebaseFirestore();
  AuthSingleton().auth = mockAuth;
  AuthSingleton().db = mockDB;
  ///////////// TESTING MOCKS /////////////

  testWidgets('HabitService() testing', (WidgetTester tester) async {
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
      days: [0, 1, 2],
    );

    // Create habit
    await HabitService().createHabit(fakehabit);

    // Get all habits
    final habits = await HabitService().allHabits().first;
    late Habit habupdated;
    for (final hab in habits) {
      habupdated = hab;
    }

    // Update habit
    habupdated.name = "newname";
    await HabitService().updateHabit(habupdated);

    // Habit for a given weekday
    await HabitService().habitsForDay(0).first;

    // Habit on a specific date
    await HabitService().habitsOn(DateTime(2017));

    // Delete habit
    await HabitService().deleteHabit(habupdated.id);
  });

  testWidgets('Session logging and retrieval works correctly', (WidgetTester tester) async {
    final service = HabitService();
    final fakehabit2 = Habit(
      id: "FakeSessionID",
      name: "SessionHabit",
      icon: "⏱",
      category: "Category",
      description: '',
      minTime: 0,
      maxTime: 60,
      startDate: DateTime(2025, 4, 1),
      targetTime: const TimeOfDay(hour: 12, minute: 0),
      days: [0],
    );

    // Create habit
    await service.createHabit(fakehabit2);

    // 1) No sessions yet → should be null
    final minutesNoSession = await service.lastSessionMinutes(
      fakehabit2.id,
      when: DateTime(2025, 4, 23),
    );
    expect(minutesNoSession, isNull);

    // 2) Log a null session → still null
    await service.logSession(
      habitId: fakehabit2.id,
      minutes: null,
      when: DateTime(2025, 4, 23),
    );
    final minutesAfterNull = await service.lastSessionMinutes(
      fakehabit2.id,
      when: DateTime(2025, 4, 23),
    );
    expect(minutesAfterNull, isNull);

    // 3) Log a 30-minute session
    await service.logSession(
      habitId: fakehabit2.id,
      minutes: 30,
      when: DateTime(2025, 4, 23),
    );
    final minutes30 = await service.lastSessionMinutes(
      fakehabit2.id,
      when: DateTime(2025, 4, 23),
    );
    expect(minutes30, equals(30));

    // 4) Log a 45-minute session later same day → should pick the latest
    await service.logSession(
      habitId: fakehabit2.id,
      minutes: 45,
      when: DateTime(2025, 4, 23, 15, 0),
    );
    final minutes45 = await service.lastSessionMinutes(
      fakehabit2.id,
      when: DateTime(2025, 4, 23),
    );
    expect(minutes45, equals(45));

    // 5) Log 20 minutes on next day → should be separate
    await service.logSession(
      habitId: fakehabit2.id,
      minutes: 20,
      when: DateTime(2025, 4, 24),
    );
    final minutesNextDay = await service.lastSessionMinutes(
      fakehabit2.id,
      when: DateTime(2025, 4, 24),
    );
    expect(minutesNextDay, equals(20));
  });
}
