import 'package:flutter/material.dart';
import 'add_habit_flow.dart';

class ManageHabitsScreen extends StatelessWidget {
  const ManageHabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Habits')),
      body: StreamBuilder<List<Habit>>(
        stream: HabitService().allHabits(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final habits = List<Habit>.from(snap.data!);
          // sort ascending by targetTime
          habits.sort((a, b) {
            final aMin = a.targetTime.hour * 60 + a.targetTime.minute;
            final bMin = b.targetTime.hour * 60 + b.targetTime.minute;
            return aMin.compareTo(bMin);
          });
          return ListView.builder(
            itemCount: habits.length,
            itemBuilder: (_, i) {
              final h = habits[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // first line: emoji + name
                      Row(
                        children: [
                          Text(h.icon, style: const TextStyle(fontSize: 28)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              h.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.indigo),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => HabitFormScreen(
                                  original: h,
                                  presetName: h.name,
                                  presetIcon: h.icon,
                                  category: h.category,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Delete habit?'),
                                  content: Text('Delete "${h.name}" forever?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await HabitService().deleteHabit(h.id);
                              }
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // second line: time/min/max + day chips
                      Row(
                        children: [
                          Chip(
                            backgroundColor: Colors.indigo.shade50,
                            label: Text(
                              '⏰ ${h.targetTime.format(context)}',
                              style: const TextStyle(color: Colors.indigo),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            backgroundColor: Colors.green.shade50,
                            label: Text(
                              'Min ${h.minTime}m',
                              style: const TextStyle(color: Colors.green),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            backgroundColor: Colors.orange.shade50,
                            label: Text(
                              'Max ${h.maxTime}m',
                              style: const TextStyle(color: Colors.orange),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // third line: days of week
                      Wrap(
                        spacing: 6,
                        children: List.generate(7, (idx) {
                          const labels = ['M','T','W','T','F','S','S'];
                          final selected = h.days.contains(idx);
                          return Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: selected ? Colors.indigo : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              labels[idx],
                              style: TextStyle(
                                color: selected ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
