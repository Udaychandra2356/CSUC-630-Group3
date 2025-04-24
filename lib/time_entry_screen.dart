import 'package:flutter/material.dart';
import 'add_habit_flow.dart';

class TimeEntryScreen extends StatefulWidget {
  final Habit habit;
  const TimeEntryScreen({Key? key, required this.habit}) : super(key: key);

  @override
  _TimeEntryScreenState createState() => _TimeEntryScreenState();
}

class _TimeEntryScreenState extends State<TimeEntryScreen>
    with SingleTickerProviderStateMixin {
  int? _minutes;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _loadPrevious();
  }

  Future<void> _loadPrevious() async {
    final prev = await HabitService()
        .lastSessionMinutes(widget.habit.id, when: DateTime.now());
    setState(() {
      _minutes = prev;
      if (prev != null) _controller.text = prev.toString();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final input = _controller.text.trim();
    final custom = int.tryParse(input);
    final saved = custom != null ? custom : _minutes;

    if (saved == null) {
      await HabitService().logSession(
        habitId: widget.habit.id,
        minutes: null,
      );
      Navigator.pop(context);
      return;
    }

    final min = widget.habit.minTime;
    final max = widget.habit.maxTime;
    bool proceed = true;

    if (saved < min) {
      proceed = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Too little time spent"),
              content: Text(
                "You entered $saved min but the minimum for “${widget.habit.name}” is $min min.",
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Cancel")),
                ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Proceed")),
              ],
            ),
          ) ??
          false;
    }
    if (proceed && saved > max) {
      proceed = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Great enthusiasm, but..."),
              content: Text(
                "You entered $saved min but the recommended max for “${widget.habit.name}” is $max min.",
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Cancel")),
                ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Proceed")),
              ],
            ),
          ) ??
          false;
    }

    if (!proceed) return;

    await HabitService().logSession(
      habitId: widget.habit.id,
      minutes: saved,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final min = widget.habit.minTime;
    final max = widget.habit.maxTime;
    final allowed = [for (var i = min; i <= max; i += 5) i];

    return Scaffold(
      appBar: AppBar(
        title: Text('⏱️ Log Time: ${widget.habit.name}'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade50, Colors.deepPurple.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 30.0,
                    backgroundColor: Colors.deepPurple,
                    child: Text(widget.habit.icon,
                        style: const TextStyle(fontSize: 30.0)),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    widget.habit.name,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Min',
                                style: TextStyle(color: Colors.grey)),
                            Text('$min min',
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Max',
                                style: TextStyle(color: Colors.grey)),
                            Text('$max min',
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Presets', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: allowed.map((v) {
                    final selected = _minutes == v;
                    return ChoiceChip(
                      label: Text('$v min'),
                      selected: selected,
                      backgroundColor: Colors.deepPurple.shade50,
                      selectedColor: Colors.deepPurple,
                      labelStyle: TextStyle(
                          color: selected ? Colors.white : Colors.deepPurple),
                      onSelected: (_) {
                        setState(() {
                          _minutes = v;
                          _controller.text = v.toString();
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                const Text('Or enter custom minutes',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.edit),
                    hintText: 'e.g. 47',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return null;
                    final num = int.tryParse(val.trim());
                    if (num == null) return 'Enter a valid number';
                    if (num < min) return 'At least $min min';
                    if (num > max) return 'At most $max min';
                    return null;
                  },
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? true) {
                        await _handleSave();
                      }
                    },
                    child: const Text('Save',
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}