import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'add_habit_flow.dart';
import 'time_entry_screen.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});
  @override
  _PlannerScreenState createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  final HabitService _svc = HabitService();
  DateTime _focused = DateTime.now();
  DateTime? _selected;
  CalendarFormat _format = CalendarFormat.month;
  final Map<DateTime, List<Habit>> _events = {};

  List<Habit> _getEventsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    if (_events.containsKey(key)) return _events[key]!;
    _svc.habitsOn(key).then((list) {
      if (mounted) setState(() => _events[key] = list);
    });
    return [];
  }

  void _onDaySelected(DateTime sel, DateTime foc) {
    setState(() {
      _selected = sel;
      _focused = foc;
    });

    final events = _getEventsForDay(sel);
    showModalBottomSheet(
      context: context,
      builder: (context) {
        // must return a widget here!
        if (events.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'No habits scheduled on ${DateFormat('MMM d').format(sel)}',
              style: const TextStyle(fontSize: 16),
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(8),
          children: events.map((h) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Text(h.icon, style: const TextStyle(fontSize: 24)),
                title: Text(h.name, style: const TextStyle(fontSize: 18)),
                subtitle: Text(h.targetTime.format(context)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TimeEntryScreen(habit: h),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Planner')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TableCalendar<Habit>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2040, 12, 31),
          focusedDay: _focused,
          calendarFormat: _format,
          onFormatChanged: (fmt) => setState(() => _format = fmt),
          availableCalendarFormats: const {
            CalendarFormat.month: 'Month',
            CalendarFormat.twoWeeks: '2 weeks',
            CalendarFormat.week: 'Week',
          },
          selectedDayPredicate: (d) =>
              _selected != null &&
              d.year == _selected!.year &&
              d.month == _selected!.month &&
              d.day == _selected!.day,
          onDaySelected: _onDaySelected,
          eventLoader: _getEventsForDay,
          calendarStyle: const CalendarStyle(markersMaxCount: 0),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isEmpty) return const SizedBox();
              return Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.tealAccent.shade700,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      )
                    ],
                  ),
                  child: Text(
                    '${events.length}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
