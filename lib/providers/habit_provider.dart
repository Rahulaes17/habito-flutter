import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Habit {
  String name;
  List<String> completedDates;

  Habit({required this.name, required this.completedDates});

  Map<String, dynamic> toJson() => {
    'name': name,
    'completedDates': completedDates,
  };

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      name: json['name'],
      completedDates: List<String>.from(json['completedDates']),
    );
  }
}

class HabitProvider extends ChangeNotifier {
  List<Habit> habits = [];

  // LOAD DATA
  Future<void> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('habits');

    if (data != null) {
      final decoded = jsonDecode(data) as List;
      habits = decoded.map((e) => Habit.fromJson(e)).toList();
      notifyListeners();
    }
  }

  // SAVE DATA
  Future<void> saveHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(habits.map((h) => h.toJson()).toList());
    await prefs.setString('habits', encoded);
  }

  // ADD
  void addHabit(String name) {
    habits.add(Habit(name: name, completedDates: []));
    saveHabits();
    notifyListeners();
  }

  void editHabit(int index, String newName) {
    habits[index].name = newName;
    saveHabits();
    notifyListeners();
  }

  // DELETE
  void deleteHabit(int index) {
    habits.removeAt(index);
    saveHabits();
    notifyListeners();
  }

  // TOGGLE
  void toggleHabit(int index, String date) {
    final habit = habits[index];

    if (habit.completedDates.contains(date)) {
      habit.completedDates.remove(date);
    } else {
      habit.completedDates.add(date);
    }

    saveHabits();
    notifyListeners();
  }
}
