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
  CalendarFormat _format = CalendarFormat.month;      // ← track current format
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
    final habitsToday = _getEventsForDay(day);

    return Column(
      children: [
        TableCalendar<Habit>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2040, 12, 31),
          focusedDay: _focused,

          // ← add these two lines:
          calendarFormat: _format,
          onFormatChanged: (fmt) => setState(() => _format = fmt),

          // optional: customize the labels shown in the header button
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
          eventLoader: _getEventsForDay,
          calendarStyle: const CalendarStyle(
            markerDecoration:
                BoxDecoration(color: Colors.indigoAccent, shape: BoxShape.circle),
          ),
          onDaySelected: (sel, foc) => setState(() {
            _selected = sel;
            _focused = foc;
          }),
        ),
        const Divider(height: 1),
        Expanded(
          child: habitsToday.isEmpty
              ? const Center(child: Text('No habits this day'))
              : ListView.builder(
                  itemCount: habitsToday.length,
                  itemBuilder: (_, i) {
                    final h = habitsToday[i];
                    return ListTile(
                      leading: Text(h.icon, style: const TextStyle(fontSize: 20)),
                      title: Text(h.name),
                      subtitle:
                          Text('${h.targetTime.format(context)}  •  ${h.category}'),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
