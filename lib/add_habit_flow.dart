import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habitstacker/auth_singleton.dart';

/// ====================== DATA MODEL ======================
class Habit {
  String id;
  String name;
  String icon; // emoji
  String category;
  String description;
  int minTime; // minutes
  int maxTime; // minutes
  DateTime startDate;
  TimeOfDay targetTime;
  List<int> days; // 0=Mon … 6=Sun

  Habit({
    required this.id,
    required this.name,
    required this.icon,
    required this.category,
    required this.description,
    required this.minTime,
    required this.maxTime,
    required this.startDate,
    required this.targetTime,
    required this.days,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'icon': icon,
        'category': category,
        'description': description,
        'minTime': minTime,
        'maxTime': maxTime,
        'startDate': Timestamp.fromDate(startDate),
        'targetTime':
            '${targetTime.hour.toString().padLeft(2, '0')}:${targetTime.minute.toString().padLeft(2, '0')}',
        'days': days,
      };

  factory Habit.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final parts = (d['targetTime'] as String).split(':');
    return Habit(
      id: doc.id,
      name: d['name'] ?? '',
      icon: d['icon'] ?? '',
      category: d['category'] ?? '',
      description: d['description'] ?? '',
      minTime: d['minTime'] ?? 0,
      maxTime: d['maxTime'] ?? 0,
      startDate: (d['startDate'] as Timestamp).toDate(),
      targetTime: TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      ),
      days: List<int>.from(d['days'] ?? []),
    );
  }
}

/// ====================== FIRESTORE SERVICE ======================
class HabitService {
  final FirebaseFirestore _db =
      AuthSingleton().db ?? FirebaseFirestore.instance;
  final String _uid =
      (AuthSingleton().auth ?? FirebaseAuth.instance).currentUser!.uid;

  Future<void> createHabit(Habit h) =>
      _db.collection('users').doc(_uid).collection('habits').add(h.toJson());

  Future<void> updateHabit(Habit h) => _db
      .collection('users')
      .doc(_uid)
      .collection('habits')
      .doc(h.id)
      .update(h.toJson());

  Future<void> deleteHabit(String habitId) => _db
      .collection('users')
      .doc(_uid)
      .collection('habits')
      .doc(habitId)
      .delete();

  Stream<List<Habit>> allHabits() => _db
      .collection('users')
      .doc(_uid)
      .collection('habits')
      .snapshots()
      .map((snap) => snap.docs.map(Habit.fromDoc).toList());

  Stream<List<Habit>> habitsForDay(int wd) => _db
      .collection('users')
      .doc(_uid)
      .collection('habits')
      .where('days', arrayContains: wd)
      .snapshots()
      .map((snap) => snap.docs.map(Habit.fromDoc).toList());

  Future<List<Habit>> habitsOn(DateTime date) async {
    final key = DateTime(date.year, date.month, date.day);
    final snap = await _db
        .collection('users')
        .doc(_uid)
        .collection('habits')
        .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(key))
        .get();
    final all = snap.docs.map(Habit.fromDoc).toList();
    final wd = date.weekday - 1;
    return all.where((h) => h.days.contains(wd)).toList();
  }

  Future<void> logSession({
    required String habitId,
    int? minutes,
    DateTime? when,
  }) {
    final ts = when ?? DateTime.now();
    return _db
        .collection('users')
        .doc(_uid)
        .collection('habits')
        .doc(habitId)
        .collection('sessions')
        .add({'minutes': minutes, 'timestamp': Timestamp.fromDate(ts)});
  }

  Future<int?> lastSessionMinutes(String habitId, {DateTime? when}) async {
    final dt = when ?? DateTime.now();
    final startOfDay = DateTime(dt.year, dt.month, dt.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snap = await _db
        .collection('users')
        .doc(_uid)
        .collection('habits')
        .doc(habitId)
        .collection('sessions')
        .where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('timestamp',
            isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;
    return snap.docs.first.data()['minutes'] as int?;
  }
}

/// ====================== PRESET DATA (5×10+) ============================
const presetHabits = {
  'Sports': [
    {'name': 'Walk', 'icon': '🚶‍♂️'},
    {'name': 'Run', 'icon': '🏃‍♂️'},
    {'name': 'Cycling', 'icon': '🚴‍♂️'},
    {'name': 'Swim', 'icon': '🏊‍♂️'},
    {'name': 'Yoga', 'icon': '🧘‍♀️'},
    {'name': 'Stretch', 'icon': '🤸‍♂️'},
    {'name': 'Hike', 'icon': '🥾'},
    {'name': 'Dance', 'icon': '💃'},
    {'name': 'Basketball', 'icon': '🏀'},
    {'name': 'Soccer', 'icon': '⚽'},
  ],
  'Health': [
    {'name': 'Drink Water', 'icon': '💧'},
    {'name': 'Healthy Meal', 'icon': '🥗'},
    {'name': 'Sleep Early', 'icon': '😴'},
    {'name': 'Take Vitamins', 'icon': '💊'},
    {'name': 'Floss Teeth', 'icon': '🦷'},
    {'name': 'Hand Wash', 'icon': '🧼'},
    {'name': 'Fresh Air', 'icon': '🌬️'},
    {'name': 'Posture Check', 'icon': '🧍‍♀️'},
    {'name': 'Meditate', 'icon': '🧘‍♂️'},
    {'name': 'Sunlight Break', 'icon': '☀️'},
  ],
  'Thoughts': [
    {'name': 'Journal', 'icon': '📓'},
    {'name': 'Read Book', 'icon': '📚'},
    {'name': 'Gratitude', 'icon': '🙏'},
    {'name': 'Affirmations', 'icon': '💬'},
    {'name': 'Mind Dump', 'icon': '📝'},
    {'name': 'Reflection', 'icon': '🤔'},
    {'name': 'Brainstorm', 'icon': '💡'},
    {'name': 'Positive Talk', 'icon': '🗣️'},
    {'name': 'Vision Board', 'icon': '🖼️'},
    {'name': 'Mood Check', 'icon': '😊'},
  ],
  'Productivity': [
    {'name': 'Plan Day', 'icon': '🗓️'},
    {'name': 'Prioritize', 'icon': '✅'},
    {'name': 'Email Zero', 'icon': '✉️'},
    {'name': 'Pomodoro', 'icon': '🍅'},
    {'name': 'Break Reminder', 'icon': '⏳'},
    {'name': 'Goal Review', 'icon': '🎯'},
    {'name': 'Project Work', 'icon': '💼'},
    {'name': 'Note Taking', 'icon': '📝'},
    {'name': 'Deep Work', 'icon': '🔒'},
    {'name': 'Inbox Cleanup', 'icon': '🗑️'},
  ],
  'Learning': [
    {'name': 'Coding Practice', 'icon': '💻'},
    {'name': 'Language Study', 'icon': '🈳'},
    {'name': 'TED Talk', 'icon': '🎤'},
    {'name': 'Podcast', 'icon': '🎧'},
    {'name': 'Online Course', 'icon': '🎓'},
    {'name': 'Skill Drill', 'icon': '🛠️'},
    {'name': 'Vocabulary', 'icon': '📖'},
    {'name': 'Science Fact', 'icon': '🔬'},
    {'name': 'History Nugget', 'icon': '🏺'},
    {'name': 'Art Appreciation', 'icon': '🖼️'},
  ],
};

/// ====================== ADD / EDIT FLOW ========================
class AddHabitsScreen extends StatelessWidget {
  const AddHabitsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Add Habits')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _CategoryTile(
              title: 'Custom Habits',
              trailing: const Icon(Icons.add),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HabitFormScreen(
                    original: null,
                    presetName: '',
                    presetIcon: '✅',
                    category: 'Custom',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ...presetHabits.entries
                .map((e) => _ExpandableCategory(title: e.key, habits: e.value)),
          ],
        ),
      );
}

class _CategoryTile extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;
  const _CategoryTile({
    required this.title,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext ctx) => Card(
        color: Colors.green.shade200,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          title: Center(child: Text(title, style: const TextStyle(fontSize: 18))),
          trailing: trailing,
          onTap: onTap,
        ),
      );
}

class _ExpandableCategory extends StatefulWidget {
  final String title;
  final List<Map<String, String>> habits;
  const _ExpandableCategory({
    required this.title,
    required this.habits,
  });

  @override
  State<_ExpandableCategory> createState() => _ExpandableCategoryState();
}

class _ExpandableCategoryState extends State<_ExpandableCategory> {
  bool _open = false;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          _CategoryTile(
            title: widget.title,
            trailing:
                Icon(_open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
            onTap: () => setState(() => _open = !_open),
          ),
          if (_open)
            ...widget.habits.map((h) => ListTile(
                  leading: Text(h['icon']!, style: const TextStyle(fontSize: 20)),
                  title: Text(h['name']!),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HabitFormScreen(
                        original: null,
                        presetName: h['name']!,
                        presetIcon: h['icon']!,
                        category: widget.title,
                      ),
                    ),
                  ),
                )),
        ],
      );
}

class HabitFormScreen extends StatefulWidget {
  final Habit? original;
  final String presetName;
  final String presetIcon;
  final String category;

  const HabitFormScreen({
    this.original,
    required this.presetName,
    required this.presetIcon,
    required this.category,
    super.key,
  });
  @override
  State<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends State<HabitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameC, _descC;
  int _minTime = 10, _maxTime = 30;
  DateTime _startDate = DateTime.now();
  TimeOfDay _target = const TimeOfDay(hour: 5, minute: 0);
  List<int> _daysSel = [];

  @override
  void initState() {
    super.initState();
    final h = widget.original;
    _nameC = TextEditingController(
      text: h != null
          ? h.name
          : (widget.presetName.isEmpty
              ? ''
              : '${widget.presetIcon} ${widget.presetName}'),
    );
    _descC = TextEditingController(text: h?.description ?? '');
    _minTime = h?.minTime ?? 10;
    _maxTime = h?.maxTime ?? 30;
    _startDate = h?.startDate ?? DateTime.now();
    _target = h?.targetTime ?? const TimeOfDay(hour: 5, minute: 0);
    _daysSel = h?.days ?? [];
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title: Text(widget.original == null ? 'New Habit' : 'Edit Habit')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(children: [
              const Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _nameC,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              const Text('Description',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(controller: _descC, maxLines: 2),
              const SizedBox(height: 24),

              // - - - NEW QUICK-SELECT BUTTONS - - -
              const Text('Repeat on',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () =>
                        setState(() => _daysSel = List.generate(5, (i) => i)),
                    child: const Text('Weekdays'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () =>
                        setState(() => _daysSel = List.generate(7, (i) => i)),
                    child: const Text('Everyday'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: List.generate(7, (i) {
                  const lbl = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  final sel = _daysSel.contains(i);
                  return ChoiceChip(
                    label: Text(lbl[i]),
                    selected: sel,
                    onSelected: (v) => setState(
                      () => v ? _daysSel.add(i) : _daysSel.remove(i),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              _pickerRow('Minimum time', _minTime, (int? v) {
                if (v != null) setState(() => _minTime = v);
              }),
              const SizedBox(height: 16),
              _pickerRow('Maximum time', _maxTime, (int? v) {
                if (v != null) setState(() => _maxTime = v);
              }),
              const SizedBox(height: 16),
              _dateRow('Start date', _startDate, () async {
                final p = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate:
                      DateTime.now().subtract(const Duration(days: 365)),
                  lastDate:
                      DateTime.now().add(const Duration(days: 365)),
                );
                if (p != null) setState(() => _startDate = p);
              }),
              const SizedBox(height: 16),
              _timeRow('Target time', _target, () async {
                final p =
                    await showTimePicker(context: context, initialTime: _target);
                if (p != null) setState(() => _target = p);
              }),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.indigoAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: _save,
                child: Text(widget.original == null ? 'Save' : 'Update',
                    style: const TextStyle(fontSize: 18)),
              ),
            ]),
          ),
        ),
      );

  Widget _pickerRow(String label, int value, ValueChanged<int?> onChanged) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label)),
          DropdownButton<int>(
            value: value,
            items: List.generate(120, (i) => (i + 1) * 5)
                .map((e) =>
                    DropdownMenuItem(value: e, child: Text(e.toString())))
                .toList(),
            onChanged: onChanged,
          ),
        ],
      );

  Widget _dateRow(String label, DateTime d, VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(label),
            Text(
                '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}',
                style: const TextStyle(
                    color: Colors.purple, fontWeight: FontWeight.bold)),
          ]),
        ),
      );

  Widget _timeRow(String label, TimeOfDay t, VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(label),
            Text(t.format(context),
                style: const TextStyle(
                    color: Colors.purple, fontWeight: FontWeight.bold)),
          ]),
        ),
      );

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final h = Habit(
      id: widget.original?.id ?? '',
      name: _nameC.text.trim(),
      icon: widget.original?.icon ?? widget.presetIcon,
      category: widget.category,
      description: _descC.text.trim(),
      minTime: _minTime,
      maxTime: _maxTime,
      startDate: _startDate,
      targetTime: _target,
      days: _daysSel,
    );
    final svc = HabitService();
    if (widget.original == null) {
      await svc.createHabit(h);
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    } else {
      await svc.updateHabit(h);
      if (mounted) Navigator.pop(context);
    }
  }
}
