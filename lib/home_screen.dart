import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    PlannerScreen(),
    AnalyticsScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Stacker'),
        centerTitle: true,
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Planner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// Dashboard screen with a date row and time-block cards.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.teal[100],
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _DateColumn(dayLabel: 'SAT', dayNumber: '15'),
              _DateColumn(dayLabel: 'SUN', dayNumber: '16'),
              _DateColumn(dayLabel: 'MON', dayNumber: '17'),
            ],
          ),
        ),
        const Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _TimeBlockCard(
                  blockTitle: 'Morning',
                  subtitle: 'No Habits yet\nTap "+" to add',
                ),
                _TimeBlockCard(
                  blockTitle: 'Noon',
                  subtitle: 'No Habits yet\nTap "+" to add',
                ),
                _TimeBlockCard(
                  blockTitle: 'Evening',
                  subtitle: 'No Habits yet\nTap "+" to add',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A widget to display a day label and number.
class _DateColumn extends StatelessWidget {
  final String dayLabel;
  final String dayNumber;

  const _DateColumn({
    required this.dayLabel,
    required this.dayNumber,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          dayLabel,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          dayNumber,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}

/// A card widget for each time block (e.g., Morning, Noon, Evening).
class _TimeBlockCard extends StatelessWidget {
  final String blockTitle;
  final String subtitle;

  const _TimeBlockCard({
    required this.blockTitle,
    required this.subtitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        title: Text(
          blockTitle,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
      ),
    );
  }
}

/// Placeholder for the Planner screen.
class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Planner Screen',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}

/// Placeholder for the Analytics screen.
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Analytics Screen',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}

/// Placeholder for the Profile screen.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Profile Screen",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            SignOutButton(),
          ],
        ),
      ),
    );
  }
}
