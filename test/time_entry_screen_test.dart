import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitstacker/add_habit_flow.dart';
import 'package:habitstacker/auth_singleton.dart';
import 'package:habitstacker/time_entry_screen.dart';
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
  AuthSingleton.initialize(
    mockAuth: mockAuth,
    mockDb: mockDB,
  );

  ///////////// TESTING MOCKS /////////////

  testWidgets('Time entry screen rendering test', (WidgetTester tester) async {
    final fakehabit = Habit(
        id: "FakeID",
        name: "TestHabit",
        icon: "TestIcon",
        category: "Category",
        description: '',
        minTime: 0,
        maxTime: 0,
        startDate: DateTime(2017),
        targetTime: const TimeOfDay(hour: 13, minute: 30),
        days: [0, 1, 2]);
    // Pump the SplashScreen widget inside a MaterialApp to provide needed context.
    await tester.pumpWidget(MaterialApp(
      home: TimeEntryScreen(
        habit: fakehabit,
      ),
    ));

    // expect(find.byType(Image), findsOneWidget);
  });
}
