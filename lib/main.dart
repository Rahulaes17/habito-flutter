import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDark = true;

  void toggleTheme() {
    setState(() {
      isDark = !isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDark ? ThemeData.dark() : ThemeData.light(),
      home: MainScreen(toggleTheme: toggleTheme),
    );
  }
}


class HomeScreen extends StatefulWidget {
    final VoidCallback toggleTheme;

  HomeScreen({required this.toggleTheme});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDate = DateTime.now();
  TextEditingController habitController = TextEditingController();
  List<Map<String, dynamic>> habits = [];

  @override
  void initState() {
    super.initState();
    loadHabits();
    initNotifications();
    showNotification();
  }

void initNotifications() async {
  const AndroidInitializationSettings android =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings settings =
      InitializationSettings(android: android);

  await notificationsPlugin.initialize(settings);
}

Future<void> showNotification() async {
  const AndroidNotificationDetails androidDetails =
      AndroidNotificationDetails(
    'habit_channel',
    'Habit Reminder',
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails details =
      NotificationDetails(android: androidDetails);

  await notificationsPlugin.show(
    0,
    "Level UP",
    "Complete your habits today 🔥",
    details,
  );
}

  String formatDate(DateTime date) {
    return "${date.year}-${date.month}-${date.day}";
  }

  void addHabit() {
    if (habitController.text.trim().isEmpty) return;

    setState(() {
      habits.add({'name': habitController.text.trim(), 'completedDates': []});
      habitController.clear();
    });

    FocusScope.of(context).unfocus();
    saveHabits();
  }

  void toggleHabit(int index) {
    String date = formatDate(selectedDate);

    setState(() {
      if (habits[index]['completedDates'].contains(date)) {
        habits[index]['completedDates'].remove(date);
      } else {
        habits[index]['completedDates'].add(date);
      }
    });

    saveHabits();
  }

  void deleteHabit(int index) {
    setState(() {
      habits.removeAt(index);
    });
    saveHabits();
  }

int calculateStreak(List dates) {
  int streak = 0;
  DateTime today = DateTime.now();

  while (true) {
    String d = formatDate(today.subtract(Duration(days: streak)));

    if (dates.contains(d)) {
      streak++;
    } else {
      break;
    }
  }

  return streak;
}

  double getProgress() {
    if (habits.isEmpty) return 0;

    int completed = habits
        .where((h) => h['completedDates'].contains(formatDate(selectedDate)))
        .length;

    return completed / habits.length;
  }

  Future<void> saveHabits() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('habits', jsonEncode(habits));
  }

  Future<void> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('habits');

    if (data != null) {
      setState(() {
        habits = List<Map<String, dynamic>>.from(jsonDecode(data));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
  IconButton(
    icon: Icon(Icons.brightness_6),
    onPressed: widget.toggleTheme,
  ),
],
        title: Text("Habit Tracker"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF020617)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // INPUT
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: habitController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Add a new habit...",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: addHabit,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Color(0xFF3B82F6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // CALENDAR + PROGRESS
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 7,
                      itemBuilder: (context, index) {
                        DateTime date = DateTime.now().subtract(
                          Duration(days: 6 - index),
                        );

                        bool isSelected =
                            formatDate(date) == formatDate(selectedDate);

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDate = date;
                            });
                          },
                          child: Container(
                            width: 60,
                            margin: EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Color(0xFF3B82F6)
                                  : Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${date.day}",
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text(
                                  [
                                    "S",
                                    "M",
                                    "T",
                                    "W",
                                    "T",
                                    "F",
                                    "S",
                                  ][date.weekday % 7],
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 10),

                  Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text("Progress", style: TextStyle(color: Colors.white70)),
    Text(
      "${(getProgress() * 100).toStringAsFixed(0)}%",
      style: TextStyle(color: Colors.white),
    ),
  ],
),

                  SizedBox(height: 8),

                  LinearProgressIndicator(
                    value: getProgress(),
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation(Color(0xFF3B82F6)),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // LIST
              Expanded(
                child: habits.isEmpty
                    ? Center(
                        child: Text(
                          "No habits yet",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: habits.length,
                        itemBuilder: (context, index) {
                          return AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            margin: EdgeInsets.only(bottom: 12),
                            padding: EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Color(0xFF1E293B).withOpacity(0.85),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: habits[index]['completedDates']
                                      .contains(formatDate(selectedDate)),
                                  onChanged: (value) {
                                    toggleHabit(index);
                                  },
                                  activeColor: Color(0xFF3B82F6),
                                ),

                                SizedBox(width: 10),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        habits[index]['name'],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          decoration:
                                              habits[index]['completedDates']
                                                  .contains(
                                                    formatDate(selectedDate),
                                                  )
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "🔥 Streak: ${calculateStreak(habits[index]['completedDates'])}",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => deleteHabit(index),
                                ),
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
    );
  }
}

class MainScreen extends StatefulWidget {
   final VoidCallback toggleTheme;

  MainScreen({required this.toggleTheme});
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

late List<Widget> screens;

  @override
   void initState() {
    super.initState();

    screens = [
      HomeScreen(toggleTheme: widget.toggleTheme),
      StatsScreen(),
    ];
  }
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF020617),
        selectedItemColor: Color(0xFF3B82F6),
        unselectedItemColor: Colors.grey,
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Stats"),
        ],
      ),
    );
  }
}

class StatsScreen extends StatelessWidget {
  List<BarChartGroupData> getWeeklyData(List habits) {
  List<BarChartGroupData> bars = [];

  for (int i = 0; i < 7; i++) {
    DateTime date = DateTime.now().subtract(Duration(days: 6 - i));
    String formatted =
        "${date.year}-${date.month}-${date.day}";

    int total = habits.length;

int completed = habits.where((h) =>
  h['completedDates'].contains(formatted)).length;

double percent = total == 0 ? 0 : completed / total * 100;

    bars.add(
      BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
  toY: percent,
  width: 18,
  borderRadius: BorderRadius.circular(6),
  gradient: LinearGradient(
    colors: [
      Color(0xFF3B82F6),
      Color(0xFF06B6D4),
    ],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  ),
),
        ],
      ),
    );
  }

  return bars;
}

  Future<List<Map<String, dynamic>>> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('habits');

    if (data != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(data));
    }
    return [];
  }

  String getToday() {
    final now = DateTime.now();
    return "${now.year}-${now.month}-${now.day}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0B1120),
      appBar: AppBar(
        title: Text("Statistics"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: loadHabits(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          List habits = snapshot.data as List;
          return Padding(
  padding: const EdgeInsets.all(16.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
  SizedBox(height: 20),
  Expanded(
  child: ListView.builder(
    itemCount: habits.length,
    itemBuilder: (context, index) {
      var habit = habits[index];

      return Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              habit['name'],
              style: TextStyle(color: Colors.white),
            ),

            SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                DateTime date =
                    DateTime.now().subtract(Duration(days: 6 - i));

                String formatted =
                    "${date.year}-${date.month}-${date.day}";

                bool done =
                    habit['completedDates'].contains(formatted);

                return Column(
                  children: [
                    Icon(
                      done ? Icons.check_circle : Icons.cancel,
                      color: done ? Colors.green : Colors.red,
                      size: 18,
                    ),
                    Text(
                      ["S","M","T","W","T","F","S"]
                          [date.weekday % 7],
                      style: TextStyle(
                          color: Colors.white70, fontSize: 10),
                    ),
                  ],
                );
              }),
            )
          ],
        ),
      );
    },
  ),
),

      Text(
        "Weekly Progress",
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),

      SizedBox(height: 20),

      SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            maxY: 100, 
            barTouchData: BarTouchData(
  enabled: true,
  touchTooltipData: BarTouchTooltipData(
    getTooltipColor: (group) => Colors.black87,
    getTooltipItem: (group, groupIndex, rod, rodIndex) {
      return BarTooltipItem(
        "${rod.toY.toInt()}%",
        TextStyle(color: Colors.white),
      );
    },
  ),
),
            // maxY: habits.length.toDouble(),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                   DateTime date =
    DateTime.now().subtract(Duration(days: 6 - value.toInt()));

List days = ["S","M","T","W","T","F","S"];

return Text(
  days[date.weekday % 7],
  style: TextStyle(color: Colors.white),
);
                  },
                ),
              ),
            ),
            barGroups: getWeeklyData(habits),
          ),
        ),
      ),

      SizedBox(height: 20),
    ],
  ),
);
        },
      ),
    );
  }
}