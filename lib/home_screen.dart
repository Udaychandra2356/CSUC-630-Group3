import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'add_habit_flow.dart';
import 'time_entry_screen.dart';
import 'planner_screen.dart';
import 'package:intl/intl.dart';
import 'manage_habits_screen.dart';
import 'analytics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  static const List<Widget> _tabs = [
    DashboardScreen(),
    PlannerScreen(),
    AnalyticsScreen(),
    ProfileScreen(),
  ];

  void _onTapNav(int i) => setState(() => _selectedIndex = i);

  void _openCalendar() {
    final today = DateTime.now();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Calendar'),
        content: SizedBox(
          width: 320,
          height: 330,
          child: CalendarDatePicker(
            initialDate: today,
            firstDate: today.subtract(const Duration(days: 365)),
            lastDate: today.add(const Duration(days: 365)),
            onDateChanged: (_) {},
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext ctx) => Scaffold(
        appBar: AppBar(
          title: const Text('Today'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _onTapNav(3),
          ),
          actions: [
            IconButton(
                icon: const Icon(Icons.calendar_month),
                onPressed: _openCalendar),
            IconButton(
              icon: const Icon(Icons.list_alt),
              tooltip: 'Manage Habits',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageHabitsScreen()),
              ),
            ),
          ],
        ),
        body: _tabs[_selectedIndex],
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.push(
            ctx,
            MaterialPageRoute(builder: (_) => const AddHabitsScreen()),
          ),
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onTapNav,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today), label: 'Planner'),
            BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart), label: 'Analytics'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      );
}

/// ---------------- DASHBOARD TAB ----------------
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _weekOffset = 0; // weeks from current
  int _dayIdx = DateTime.now().weekday - 1;

  String _label(int i) => ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Calculate start of offset week (Monday)
    final monday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1))
        .add(Duration(days: _weekOffset * 7));
    final weekDates = List.generate(7, (i) => monday.add(Duration(days: i)));

    return Column(
      children: [
        // Week slider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Prev', style: TextStyle(color: Colors.grey[700])),
                Text(
                  // Display actual week range
                  '${DateFormat('MMM d').format(weekDates.first)} - '
                  '${DateFormat('MMM d').format(weekDates.last)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Next', style: TextStyle(color: Colors.grey[700])),
              ],
            ),
            Slider(
              value: _weekOffset.toDouble(),
              min: -4,
              max: 4,
              divisions: 8,
              label:
                  '${DateFormat('MMM d').format(weekDates.first)} - '
                  '${DateFormat('MMM d').format(weekDates.last)}',
              activeColor: Colors.teal,
              inactiveColor: Colors.teal.shade100,
              onChanged: (val) {
                setState(() {
                  _weekOffset = val.toInt();
                  _dayIdx = 0;
                });
              },
            ),
          ]),
        ),
        // Day labels row
        Container(
          color: Colors.teal[100],
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (i) {
              return GestureDetector(
                onTap: () => setState(() => _dayIdx = i),
                child: _DateColumn(
                  dayLabel: _label(i),
                  dayNumber: weekDates[i].day.toString(),
                  isSelected: i == _dayIdx,
                ),
              );
            }),
          ),
        ),
        // Habit list
        Expanded(
          child: StreamBuilder<List<Habit>>(
            stream: HabitService().habitsForDay(_dayIdx),
            builder: (_, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final habits = snap.data ?? [];
              habits.sort((a, b) {
                final aMin = a.targetTime.hour * 60 + a.targetTime.minute;
                final bMin = b.targetTime.hour * 60 + b.targetTime.minute;
                return aMin.compareTo(bMin);
              });
              final morning = habits.where((h) => h.targetTime.hour < 12).toList();
              final noon = habits
                  .where((h) => h.targetTime.hour >= 12 && h.targetTime.hour < 17)
                  .toList();
              final evening = habits.where((h) => h.targetTime.hour >= 17).toList();

              return SingleChildScrollView(
                child: Column(children: [
                  _TimeBlockCard(
                    blockTitle: 'Morning',
                    habits: morning,
                    date: weekDates[_dayIdx],
                    onSessionLogged: () => setState(() {}),
                  ),
                  _TimeBlockCard(
                    blockTitle: 'Noon',
                    habits: noon,
                    date: weekDates[_dayIdx],
                    onSessionLogged: () => setState(() {}),
                  ),
                  _TimeBlockCard(
                    blockTitle: 'Evening',
                    habits: evening,
                    date: weekDates[_dayIdx],
                    onSessionLogged: () => setState(() {}),
                  ),
                ]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DateColumn extends StatelessWidget {
  final String dayLabel, dayNumber;
  final bool isSelected;
  const _DateColumn({
    required this.dayLabel,
    required this.dayNumber,
    this.isSelected = false,
  });
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        decoration: isSelected
            ? BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.black26),
              )
            : null,
        child: Column(children: [
          Text(dayLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(dayNumber, style: const TextStyle(fontSize: 16)),
        ]),
      );
}

class _TimeBlockCard extends StatelessWidget {
  final String blockTitle;
  final List<Habit> habits;
  final DateTime date;
  final VoidCallback onSessionLogged;
  const _TimeBlockCard({required this.blockTitle, required this.habits,required this.onSessionLogged,required this.date,});

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(blockTitle,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (habits.isEmpty)
              Center(
                child: Text('No habits yet\ntap "+" to add',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.purple.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 16)),
              )
            else
              ...habits.map((h) => ListTile(
  leading: FutureBuilder<int?>(
  future: HabitService().lastSessionMinutes(h.id,  when: date),
  builder: (context, snap) {
    final minutes = snap.data;
    final txt = (minutes != null) ? '$minutes min ' : '';
    return Text(
      '$txt${h.icon}',
      style: const TextStyle(fontSize: 20),
    );
  },
),
                    title: Text(h.name),
trailing: IconButton(
  icon: const Icon(Icons.timer),
  onPressed: () async {
    // wait for the TimeEntryScreen to pop
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TimeEntryScreen(habit: h)),
    );
    // then rebuild so your FutureBuilder refetches the just-logged minutes
    onSessionLogged();
  },
),
onTap: () async {
  await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => TimeEntryScreen(habit: h)),
  );
  onSessionLogged();
},

                  )),
          ]),
        ),
      );
}

/// placeholders for the other tabs
class PlannerPlaceholder extends StatelessWidget {
  const PlannerPlaceholder({super.key});
  @override
  Widget build(BuildContext c) =>
      const Center(child: Text('Planner (coming soon)'));
}

class AnalyticsPlaceholder extends StatelessWidget {
  const AnalyticsPlaceholder({super.key});
  @override
  Widget build(BuildContext c) =>
      const Center(child: Text('Analytics (coming soon)'));
}
