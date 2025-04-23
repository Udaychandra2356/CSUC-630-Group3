import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'add_habit_flow.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});
  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
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

  @override
  Widget build(BuildContext context) {
    final day = _selected ?? _focused;
    final habitsToday = _getEventsForDay(day)
      ..sort((a, b) {
        final aMin = a.targetTime.hour * 60 + a.targetTime.minute;
        final bMin = b.targetTime.hour * 60 + b.targetTime.minute;
        return aMin.compareTo(bMin);
      });

    return Column(
      children: [
        TableCalendar<Habit>(
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
          onDaySelected: (sel, foc) =>
              setState(() {_selected = sel; _focused = foc;}),
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
        const Divider(height: 1),
        Expanded(
          child: habitsToday.isEmpty
              ? Center(
                  child: Text(
                    'No habits scheduled',
                    style: TextStyle(
                        fontSize: 16, color: Colors.grey.shade600),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: habitsToday.length,
                  itemBuilder: (context, i) {
                    final h = habitsToday[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.indigo.shade200,
                                    Colors.indigo.shade500
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                h.icon,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                h.name,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            const Icon(Icons.chevron_right,
                                color: Colors.grey),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
