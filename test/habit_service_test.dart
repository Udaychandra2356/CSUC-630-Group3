import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitstacker/add_habit_flow.dart';
import 'package:habitstacker/auth_singleton.dart';
import 'package:habitstacker/home_screen.dart';
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
        days: [0, 1, 2]);

    final uid = 'testUser';

    // Create habit
    await HabitService().createHabit(fakehabit);

    // Get all habits
    final habits = await HabitService().allHabits().first;
    late Habit habupdated;
    for (final hab in habits) {
      print(hab);
      habupdated = hab;
    }

    // update habit
    habupdated.name = "newname";
    await HabitService().updateHabit(habupdated);

    // habit for day
    await HabitService().habitsForDay(0).first;

    // habit on date
    await HabitService().habitsOn(DateTime(2017));

    // delete habit
    await HabitService().deleteHabit(habupdated.id);
  });
}
