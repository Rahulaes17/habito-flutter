import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';

class StorageService {
  static const String key = 'habits';
  static const String themeKey = 'theme';

  static Future<void> saveHabits(List<Habit> habits) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        key, jsonEncode(habits.map((e) => e.toJson()).toList()));
  }

  static Future<List<Habit>> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(key);

    if (data == null) return [];

    final decoded = jsonDecode(data);
    return decoded.map<Habit>((e) => Habit.fromJson(e)).toList();
  }

  static Future<void> saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(themeKey, isDark);
  }

  static Future<bool> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(themeKey) ?? true;
  }
}