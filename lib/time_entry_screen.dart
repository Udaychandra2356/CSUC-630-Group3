// lib/time_entry_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'add_habit_flow.dart';

class TimeEntryScreen extends StatefulWidget {
  final Habit habit;
  const TimeEntryScreen({Key? key, required this.habit}) : super(key: key);

  @override
  State<TimeEntryScreen> createState() => _TimeEntryScreenState();
}

class _TimeEntryScreenState extends State<TimeEntryScreen> {
  int? _minutes;
  final _formKey = GlobalKey<FormState>();
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
    int? saved = custom ?? _minutes;

    // if no prior or custom entry, log zero
    if (saved == null) {
      await HabitService().logSession(
        habitId: widget.habit.id,
        minutes: 0, //changed from null to zero
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
              title: const Text('Below minimum'),
              content: Text(
                  'You entered $saved min but the minimum for “${widget.habit.name}” is $min min.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Proceed'),
                ),
              ],
            ),
          ) ??
          false;
      if (!proceed) return;
    }

    if (saved > max) {
      proceed = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Above maximum'),
              content: Text(
                  'You entered $saved min but the maximum for “${widget.habit.name}” is $max min.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Proceed'),
                ),
              ],
            ),
          ) ??
          false;
      if (!proceed) return;
    }

    await HabitService().logSession(
      habitId: widget.habit.id,
      minutes: saved,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final greenDark = Colors.green.shade700;
    final greenLight = Colors.green.shade50;
    final greenAccent = Colors.green.shade200;

    final gradient = LinearGradient(
      colors: [greenLight, greenAccent],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    final min = widget.habit.minTime;
    final max = widget.habit.maxTime;
    final presets = [for (var i = min; i <= max; i += 5) i];

    return Scaffold(
      appBar: AppBar(
        title: Text('Log Time: ${widget.habit.name}'),
        backgroundColor: greenDark,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: CircleAvatar(
                              radius: 36,
                              backgroundColor: greenDark,
                              child: Text(
                                widget.habit.icon,
                                style: const TextStyle(
                                    fontSize: 36, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              widget.habit.name,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: greenDark,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Min',
                                          style: TextStyle(color: Colors.grey)),
                                      const SizedBox(height: 4),
                                      Text('$min min',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: greenDark)),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text('Max',
                                          style: TextStyle(color: Colors.grey)),
                                      const SizedBox(height: 4),
                                      Text('$max min',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: greenDark)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text('Preset Times',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: presets.map((v) {
                              final selected = _minutes == v;
                              return ChoiceChip(
                                label: Text('$v'),
                                selected: selected,
                                backgroundColor: greenAccent,
                                selectedColor: greenDark,
                                labelStyle: TextStyle(
                                    color: selected ? Colors.white : greenDark),
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
                          const Text('Or Custom Entry',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Form(
                            key: _formKey,
                            child: TextFormField(
                              controller: _controller,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                hintText: 'Enter minutes',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) return null;
                                final num = int.tryParse(val);
                                if (num == null) return 'Invalid number';
                                if (num < min) return 'At least $min';
                                if (num > max) return 'At most $max';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: greenDark,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                              shadowColor: Colors.green.shade900,
                            ),
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? true) {
                                _handleSave();
                              }
                            },
                            child: const Text('Save',
                                style: TextStyle(fontSize: 18)),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
