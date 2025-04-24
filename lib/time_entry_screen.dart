import 'package:flutter/material.dart';
import 'add_habit_flow.dart';

class TimeEntryScreen extends StatefulWidget {
  final Habit habit;
  const TimeEntryScreen({super.key, required this.habit});

  @override
  State<TimeEntryScreen> createState() => _TimeEntryScreenState();
}

class _TimeEntryScreenState extends State<TimeEntryScreen> {
  int? _minutes;
  @override
  void initState() {
    super.initState();
    _loadPrevious();
  }
  Future<void> _loadPrevious() async {
    final prev = await HabitService()
        .lastSessionMinutes(widget.habit.id, when: DateTime.now());
    setState(() => _minutes = prev); // remains null if no prior entry
  }
Future<void> _handleSave() async {
    // Record null if the user never picked anything
    if (_minutes == null) {
      await HabitService().logSession(
        habitId: widget.habit.id,
        minutes: null,
      );
      Navigator.pop(context);
      return;
    }

    final min = widget.habit.minTime;
    final max = widget.habit.maxTime;

    // Under minimum?
    if (_minutes! < min) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Too little time spent"),
          content: Text(
            "You logged $_minutes min but the minimum for “${widget.habit.name}” is $min min.\n"
            "Every minute counts—keep building the habit! Save anyway?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Proceed"),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }

    // Above maximum?
    if (_minutes! > max) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Great enthusiasm, but..."),
          content: Text(
            "You logged $_minutes min but the recommended max for “${widget.habit.name}” is $max min.\n"
            "That’s fantastic—just remember balance, and avoid burnout! Save anyway?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Proceed"),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }

    // All good (or user chose to proceed)
    await HabitService().logSession(
      habitId: widget.habit.id,
      minutes: _minutes,
    );
    Navigator.pop(context);
  }


@override
  Widget build(BuildContext context) {
    final min = widget.habit.minTime;
    final max = widget.habit.maxTime;

    // Build the list of allowed minute values in 5-min increments
    final allowedMinutes = <int>[
      for (int m = min; m <= max; m += 5) m
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Log Time: ${widget.habit.name}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Minutes spent',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButton<int>(
              value: _minutes,
              hint: const Text('Select minutes'),
              items: allowedMinutes
                  .map((m) => DropdownMenuItem(
                        value: m,
                        child: Text('$m minutes'),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _minutes = v),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleSave,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Save', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
