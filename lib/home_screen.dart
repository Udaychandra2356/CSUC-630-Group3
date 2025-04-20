import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'add_habit_flow.dart';          
import 'time_entry_screen.dart';      
import 'planner_screen.dart';
import 'profile_screen.dart';

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
    AnalyticsPlaceholder(),
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))
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
            IconButton(icon: const Icon(Icons.calendar_month), onPressed: _openCalendar),
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
            BottomNavigationBarItem(icon: Icon(Icons.home),    label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Planner'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Analytics'),
            BottomNavigationBarItem(icon: Icon(Icons.person),  label: 'Profile'),
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
  final List<DateTime> _week = List.generate(7, (i) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return monday.add(Duration(days: i));
  });
  int _dayIdx = DateTime.now().weekday - 1;

  String _label(int i) => ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][i];

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        color: Colors.teal[100],
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(7, (i) => GestureDetector(
                onTap: () => setState(() => _dayIdx = i),
                child: _DateColumn(
                  dayLabel: _label(i),
                  dayNumber: _week[i].day.toString(),
                  isSelected: i == _dayIdx,
                ),
              )),
        ),
      ),
      Expanded(
        child: StreamBuilder<List<Habit>>(
          stream: HabitService().habitsForDay(_dayIdx),
          builder: (_, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final habits = snap.data ?? [];
            // **SORT ASCENDING BY targetTime**
            habits.sort((a, b) {
              final aMin = a.targetTime.hour * 60 + a.targetTime.minute;
              final bMin = b.targetTime.hour * 60 + b.targetTime.minute;
              return aMin.compareTo(bMin);
            });

            final morning = habits.where((h) => h.targetTime.hour < 12).toList();
            final noon    = habits.where((h) => h.targetTime.hour >= 12 && h.targetTime.hour < 17).toList();
            final evening = habits.where((h) => h.targetTime.hour >= 17).toList();

            return SingleChildScrollView(
              child: Column(children: [
                _TimeBlockCard(blockTitle: 'Morning', habits: morning),
                _TimeBlockCard(blockTitle: 'Noon',    habits: noon),
                _TimeBlockCard(blockTitle: 'Evening', habits: evening),
              ]),
            );
          },
        ),
      ),
    ]);
  }
}

class _DateColumn extends StatelessWidget {
  final String dayLabel, dayNumber;
  final bool isSelected;
  const _DateColumn({
    required this.dayLabel,
    required this.dayNumber,
    this.isSelected = false,
    super.key,
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
          Text(dayLabel,  style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(dayNumber, style: const TextStyle(fontSize: 16)),
        ]),
      );
}
class _TimeBlockCard extends StatelessWidget {
  final String blockTitle;
  final List<Habit> habits;
  const _TimeBlockCard({required this.blockTitle, required this.habits, super.key});

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(blockTitle,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                    leading: Text(
                      '${h.targetTime.format(context)}  ${h.icon}',
                      style: const TextStyle(fontSize: 20),
                    ),
                    title: Text(h.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.timer),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => TimeEntryScreen(habit: h)),
                      ),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => TimeEntryScreen(habit: h)),
                    ),
                  )),
          ]),
        ),
      );
}

/// placeholders for the other tabs
class PlannerPlaceholder extends StatelessWidget {
  const PlannerPlaceholder({super.key});
  @override Widget build(BuildContext c) => const Center(child: Text('Planner (coming soon)'));
}
class AnalyticsPlaceholder extends StatelessWidget {
  const AnalyticsPlaceholder({super.key});
  @override Widget build(BuildContext c) => const Center(child: Text('Analytics (coming soon)'));
}
