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
  AuthSingleton.initialize(
    mockAuth: mockAuth,
    mockDb: mockDB,
  );
  ///////////// TESTING MOCKS /////////////

  testWidgets('HomeScreen shows 4 bottom navigation items',
      (WidgetTester tester) async {
    // Pump HomeScreen in a MaterialApp.
    await tester.pumpWidget(const MaterialApp(
      home: HomeScreen(),
    ));

    // Verify bottom navigation bar is present.
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // Check for labels: Dashboard, Planner, Analytics, Profile
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Planner'), findsOneWidget);
    expect(find.text('Analytics'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // Not implemented yet.
    // // Optionally tap on an item and confirm the UI changes. E.g.:
    // await tester.tap(find.text('Planner'));
    // await tester.pump();
    // expect(find.text('Planner Screen'), findsOneWidget);
  });

  testWidgets('premade habits present', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: HomeScreen(),
    ));

    // Check for FloatingActionButton.
    final FABfinder = find.byType(FloatingActionButton);
    expect(FABfinder, findsOneWidget);

    await tester.tap(FABfinder);
    await tester.pumpAndSettle();

    final sportsfinder = find.text('Sports');
    expect(sportsfinder, findsOneWidget);

    await tester.tap(sportsfinder);
    await tester.pumpAndSettle();
    expect(find.text('Cycling'), findsOneWidget);
  });

  testWidgets('homescreen buttons', (WidgetTester tester) async {
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

    await tester.pumpWidget(const MaterialApp(
      home: MediaQuery(
          data: MediaQueryData(size: Size(360, 800)), child: HomeScreen()),
    ));
    await tester.pump(const Duration(seconds: 3));

    final timericon = find.byIcon(Icons.timer);
    expect(timericon, findsOneWidget); // find the timer of the fake habit
    await tester.tap(timericon);
    await tester.pumpAndSettle();

    final savebutton = find.text("Save");
    expect(savebutton, findsOneWidget);
    await tester.tap(savebutton, warnIfMissed: false);
    await tester.pumpAndSettle();
  });
}
