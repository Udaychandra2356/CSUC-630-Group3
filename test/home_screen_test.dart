import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitstacker/home_screen.dart';

void main() {
  testWidgets('HomeScreen shows 4 bottom navigation items', (WidgetTester tester) async {
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

    // Optionally tap on an item and confirm the UI changes. E.g.:
    await tester.tap(find.text('Planner'));
    await tester.pump();
    expect(find.text('Planner Screen'), findsOneWidget);
  });

  testWidgets('HomeScreen FAB is present', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: HomeScreen(),
    ));

    // Check for FloatingActionButton.
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
