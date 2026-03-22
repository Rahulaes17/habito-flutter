class Habit {
  String name;
  List<String> completedDates;

  Habit({required this.name, required this.completedDates});

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      name: json['name'],
      completedDates: List<String>.from(json['completedDates']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'completedDates': completedDates,
    };
  }
}