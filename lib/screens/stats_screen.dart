import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/habit_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  String formatDate(DateTime d) {
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HabitProvider>(context);
    final habits = provider.habits;
    final score = _score(habits);

    return Scaffold(
      appBar: AppBar(title: const Text("Statistics")),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: Theme.of(context).brightness == Brightness.dark
                ? [Color(0xFF020617), Color(0xFF0F172A)]
                : [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ======================
              // CONSISTENCY CARD
              // ======================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).cardColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Consistency",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${score.toStringAsFixed(1)}%",
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ======================
              // WEEKLY OVERVIEW TABLE
              // ======================
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Theme.of(context).cardColor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Weekly Overview",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // DAY HEADER
                      Row(
                        children: [
                          const SizedBox(width: 80),
                          ...List.generate(7, (index) {
                            DateTime date = DateTime.now().subtract(
                              Duration(days: 6 - index),
                            );

                            return Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    [
                                      "M",
                                      "T",
                                      "W",
                                      "T",
                                      "F",
                                      "S",
                                      "S",
                                    ][date.weekday - 1],
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    "${date.day}",
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // HABIT DATA
                      Expanded(
                        child: ListView.builder(
                          itemCount: habits.length,
                          itemBuilder: (_, i) {
                            final h = habits[i];

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 80,
                                    child: Text(
                                      h.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  ...List.generate(7, (index) {
                                    DateTime date = DateTime.now().subtract(
                                      Duration(days: 6 - index),
                                    );

                                    String d = formatDate(date);
                                    bool done = h.completedDates.contains(d);

                                    return Expanded(
                                      child: Icon(
                                        done
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        color: done ? Colors.green : Colors.red,
                                        size: 18,
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ======================
              // WEEKLY CHART
              // ======================
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).cardColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Weekly Progress",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      height: 180,
                      child: BarChart(
                        BarChartData(
                          maxY: 100,
                          gridData: FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const days = [
                                    'M',
                                    'T',
                                    'W',
                                    'T',
                                    'F',
                                    'S',
                                    'S',
                                  ];
                                  return Text(days[value.toInt()]);
                                },
                              ),
                            ),
                          ),
                          barGroups: _bars(habits),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _score(List habits) {
    if (habits.isEmpty) return 0;

    int total = 0;

    for (int i = 0; i < 7; i++) {
      String d = formatDate(DateTime.now().subtract(Duration(days: i)));

      for (var h in habits) {
        if (h.completedDates.contains(d)) total++;
      }
    }

    return total / (7 * habits.length) * 100;
  }

  List<BarChartGroupData> _bars(List habits) {
    List<BarChartGroupData> bars = [];

    for (int i = 0; i < 7; i++) {
      String d = formatDate(DateTime.now().subtract(Duration(days: 6 - i)));

      int total = habits.length;
      int done = habits.where((h) => h.completedDates.contains(d)).length;

      double percent = total == 0 ? 0 : done / total * 100;

      bars.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: percent == 0 ? 2 : percent,
              width: 16,
              borderRadius: BorderRadius.circular(6),
            ),
          ],
        ),
      );
    }

    return bars;
  }
}
