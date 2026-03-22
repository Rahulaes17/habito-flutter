import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/habit_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
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
    return ChangeNotifierProvider(
      create: (_) => HabitProvider()..loadHabits(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Habito',

        theme: ThemeData(
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF3B82F6),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: Colors.transparent,
          cardColor: Colors.white,
        ),

        darkTheme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF3B82F6),
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: Colors.transparent,
          cardColor: const Color(0xFF111827),
        ),

        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

        home: HomeScreen(toggleTheme: toggleTheme),
      ),
    );
  }
}