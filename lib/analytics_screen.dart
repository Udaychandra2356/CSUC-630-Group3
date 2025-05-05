import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:habitstacker/auth_singleton.dart';
import 'package:habitstacker/add_habit_flow.dart';

class TrackedActivity {
  final String habitName;
  final int minutes;
  TrackedActivity(this.habitName, this.minutes);
}

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});
  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _viewIndex = 0; // 0 = weekly, 1 = monthly, 2 = yearly
  bool _loading = true;
  int _totalMinutes = 0;
  List<BarChartGroupData> _barGroups = [];
  List<String> _labels = [];
  List<TrackedActivity> _activities = [];

  Map<String, List<double>> _habitSeries = {};
  String? _selectedHabit;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _loading = true);
    final uid = AuthSingleton().auth!.currentUser!.uid;
    final firestore = AuthSingleton().db ?? FirebaseFirestore.instance;
    // final firestore = FirebaseFirestore.instance;
    final now = DateTime.now();

    final habitSnap =
        await firestore.collection('users').doc(uid).collection('habits').get();

    final totalPerHabit = <String, int>{};
    final periodTotals = <int>[];
    final periodLabels = <String>[];

    _habitSeries = {for (var d in habitSnap.docs) Habit.fromDoc(d).name: []};

    if (_viewIndex == 0) {
      final weekStart = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: now.weekday - 1));
      for (int i = 0; i < 7; i++) {
        final day = weekStart.add(Duration(days: i));
        periodLabels.add(DateFormat('E, d').format(day));
        final startUtc = DateTime(day.year, day.month, day.day).toUtc();
        final endUtc =
            DateTime(day.year, day.month, day.day, 23, 59, 59).toUtc();

        int daySum = 0;
        for (var doc in habitSnap.docs) {
          final habit = Habit.fromDoc(doc);
          final sessions = await firestore
              .collection('users')
              .doc(uid)
              .collection('habits')
              .doc(habit.id)
              .collection('sessions')
              .where('timestamp',
                  isGreaterThanOrEqualTo: Timestamp.fromDate(startUtc))
              .where('timestamp',
                  isLessThanOrEqualTo: Timestamp.fromDate(endUtc))
              .get();
          int sum = sessions.docs
              .fold<int>(0, (p, s) => p + ((s.data()['minutes'] as int) ?? 0));
          
          daySum += sum;
          totalPerHabit[habit.name] = (totalPerHabit[habit.name] ?? 0) + sum;
          _habitSeries[habit.name]!.add(sum.toDouble());
        }
        periodTotals.add(daySum);
      }
    } else if (_viewIndex == 1) {
      for (int i = 5; i >= 0; i--) {
        final m = now.month - i;
        final year = now.year + ((m - 1) ~/ 12);
        final mon = ((m - 1) % 12) + 1;
        final start = DateTime(year, mon, 1);
        if (start.isAfter(now)) continue;
        final end =
            (mon < 12) ? DateTime(year, mon + 1, 1) : DateTime(year + 1, 1, 1);
        periodLabels.add(DateFormat('MMM yyyy').format(start));

        final startUtc = start.toUtc();
        final endUtc = end.toUtc();
        int monthSum = 0;
        for (var doc in habitSnap.docs) {
          final habit = Habit.fromDoc(doc);
          final sessions = await firestore
              .collection('users')
              .doc(uid)
              .collection('habits')
              .doc(habit.id)
              .collection('sessions')
              .where('timestamp',
                  isGreaterThanOrEqualTo: Timestamp.fromDate(startUtc))
              .where('timestamp',
                  isLessThanOrEqualTo: Timestamp.fromDate(endUtc))
              .get();
          int sum = sessions.docs
              .fold<int>(0, (p, s) => p + ((s.data()['minutes'] as int) ?? 0));
          
          monthSum += sum;
          totalPerHabit[habit.name] = (totalPerHabit[habit.name] ?? 0) + sum;
          _habitSeries[habit.name]!.add(sum.toDouble());
        }
        periodTotals.add(monthSum);
      }
    } else {
      for (int i = 4; i >= 0; i--) {
        final yr = now.year - i;
        final start = DateTime(yr, 1, 1);
        if (start.isAfter(now)) continue;
        final end = DateTime(yr + 1, 1, 1);
        periodLabels.add(yr.toString());

        final startUtc = start.toUtc();
        final endUtc = end.toUtc();
        int yearSum = 0;
        for (var doc in habitSnap.docs) {
          final habit = Habit.fromDoc(doc);
          final sessions = await firestore
              .collection('users')
              .doc(uid)
              .collection('habits')
              .doc(habit.id)
              .collection('sessions')
              .where('timestamp',
                  isGreaterThanOrEqualTo: Timestamp.fromDate(startUtc))
              .where('timestamp',
                  isLessThanOrEqualTo: Timestamp.fromDate(endUtc))
              .get();
          int sum = sessions.docs
              .fold<int>(0, (p, s) => p + ((s.data()['minutes'] as int) ?? 0));
          
          yearSum += sum;
          totalPerHabit[habit.name] = (totalPerHabit[habit.name] ?? 0) + sum;
          _habitSeries[habit.name]!.add(sum.toDouble());
        }
        periodTotals.add(yearSum);
      }
    }

    _totalMinutes = totalPerHabit.values.fold(0, (a, b) => a + b);
    _barGroups = periodTotals.asMap().entries.map((e) {
      return BarChartGroupData(x: e.key, barRods: [
        BarChartRodData(
          toY: e.value.toDouble(),
          color: Theme.of(context).primaryColor,
        )
      ]);
    }).toList();
    _labels = periodLabels;
    _activities = totalPerHabit.entries
        .map((e) => TrackedActivity(e.key, e.value))
        .toList()
      ..sort((a, b) => b.minutes.compareTo(a.minutes));

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ToggleButtons(
                    isSelected: [
                      _viewIndex == 0,
                      _viewIndex == 1,
                      _viewIndex == 2
                    ],
                    onPressed: (i) {
                      setState(() {
                        _viewIndex = i;
                        _selectedHabit = null;
                      });
                      _loadAnalytics();
                    },
                    children: const [
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('Weekly')),
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('Monthly')),
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('Yearly')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_selectedHabit != null)
                    TextButton.icon(
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('All Activities'),
                      onPressed: () => setState(() => _selectedHabit = null),
                    ),
                  Text('Total: ${_totalMinutes}m',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  Expanded(
                    child: BarChart(BarChartData(
                      barGroups: (_selectedHabit == null)
                          ? _barGroups
                          : _habitSeries[_selectedHabit!]!
                              .asMap()
                              .entries
                              .map((e) => BarChartGroupData(x: e.key, barRods: [
                                    BarChartRodData(
                                      toY: e.value,
                                      color: Theme.of(context).primaryColor,
                                    )
                                  ]))
                              .toList(),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (v, _) {
                              final idx = v.toInt();
                              if (idx < 0 || idx >= _labels.length) {
                                return const SizedBox();
                              }
                              return Text(_labels[idx],
                                  style: const TextStyle(fontSize: 10));
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                            sideTitles:
                                SideTitles(showTitles: true, interval: 60)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: const FlGridData(show: true),
                      borderData: FlBorderData(show: false),
                    )),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: _activities.map((a) {
                        final isSelected = a.habitName == _selectedHabit;
                        return ListTile(
                          leading: Text(habitEmoji(a.habitName)),
                          title: Text(a.habitName),
                          trailing: Text('${a.minutes}m'),
                          selected: isSelected,
                          onTap: () => setState(() {
                            _selectedHabit = isSelected ? null : a.habitName;
                          }),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String habitEmoji(String name) {
    final habit = _habitSeries.containsKey(name) ? name : name;
    return '•';
  }
}
