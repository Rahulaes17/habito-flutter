import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController habitController = TextEditingController();

  List<Map<String, dynamic>> habits = [];

  @override
  void initState() {
    super.initState();
    loadHabits();
  }

  void addHabit() {
    if (habitController.text.trim().isEmpty) return;

    setState(() {
      habits.add({
        'name': habitController.text.trim(),
        'completed': false,
      });
      habitController.clear();
    });

    saveHabits();
  }

  void toggleHabit(int index, bool value) {
    setState(() {
      habits[index]['completed'] = value;
    });
    saveHabits();
  }

  void deleteHabit(int index) {
    setState(() {
      habits.removeAt(index);
    });
    saveHabits();
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
      backgroundColor: Color(0xFF0B1120),
      appBar: AppBar(
        title: Text("Habit Tracker"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            // Input Card
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
                  GestureDetector(
                    onTap: addHabit,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(0xFF3B82F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.add, color: Colors.white),
                    ),
                  )
                ],
              ),
            ),

            SizedBox(height: 20),

            // Habit List
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
                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          padding: EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [

                              // Checkbox
                              Checkbox(
                                value: habits[index]['completed'],
                                onChanged: (value) {
                                  toggleHabit(index, value!);
                                },
                                activeColor: Color(0xFF3B82F6),
                              ),

                              SizedBox(width: 10),

                              // Text
                              Expanded(
                                child: Text(
                                  habits[index]['name'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    decoration: habits[index]['completed']
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),

                              // Delete Button
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteHabit(index),
                              )
                            ],
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}