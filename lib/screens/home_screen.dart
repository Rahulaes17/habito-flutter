import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  const HomeScreen({super.key, required this.toggleTheme});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final controller = TextEditingController();
  DateTime selectedDate = DateTime.now();

  String formatDate(DateTime d) {
    return "${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}";
  }

  int streak(List<String> dates) {
    int s = 0;
    DateTime now = DateTime.now();
    for (int i = 0; i < 365; i++) {
      String d = formatDate(now.subtract(Duration(days: i)));
      if (dates.contains(d)) s++;
      else break;
    }
    return s;
  }

  void showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HabitProvider>(context);

    int total = provider.habits.length;
    int done = provider.habits.where((h) =>
      h.completedDates.contains(formatDate(selectedDate))
    ).length;

    double progress = total == 0 ? 0 : done / total;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habito'),
        actions: [
          IconButton(
            onPressed: widget.toggleTheme,
            icon: const Icon(Icons.dark_mode),
          )
        ],
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: Theme.of(context).brightness == Brightness.dark
                ? [const Color(0xFF020617), const Color(0xFF0F172A)]
                : [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              // INPUT
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: "Add a habit...",
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () {
                        if (controller.text.trim().isEmpty) return;
                        provider.addHabit(controller.text.trim());
                        controller.clear();
                        showSnack("Habit added");
                      },
                    ),
                  )
                ],
              ),

              const SizedBox(height: 20),

              // DATE SELECTOR
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    DateTime date = DateTime.now().subtract(Duration(days: 6 - index));
                    bool isSelected = formatDate(date) == formatDate(selectedDate);

                    return GestureDetector(
                      onTap: () => setState(() => selectedDate = date),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 60,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("${date.day}"),
                            Text(
                              ["S","M","T","W","T","F","S"][date.weekday % 7],
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              // PROGRESS
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Progress ${(progress * 100).toStringAsFixed(0)}%"),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      color: Theme.of(context).colorScheme.primary,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // LIST
              Expanded(
                child: provider.habits.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.track_changes, size: 50, color: Colors.grey),
                          SizedBox(height: 10),
                          Text("Start building your habits"),
                        ],
                      )
                    : ListView.builder(
                        itemCount: provider.habits.length,
                        itemBuilder: (_, i) {
                          final h = provider.habits[i];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Theme.of(context).cardColor,
                            ),
                            child: ListTile(
                              title: Text(h.name),
                              subtitle: Text("🔥 Streak: ${streak(h.completedDates)}"),

                              leading: Checkbox(
                                value: h.completedDates.contains(formatDate(selectedDate)),
                                onChanged: (_) {
                                  provider.toggleHabit(i, formatDate(selectedDate));
                                  showSnack("Updated");
                                },
                              ),

                              // EDIT + DELETE
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [

                                  // EDIT BUTTON
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      TextEditingController editController =
                                          TextEditingController(text: h.name);

                                      showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: const Text("Edit Habit"),
                                          content: TextField(
                                            controller: editController,
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text("Cancel"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                if (editController.text.trim().isEmpty) return;
                                                provider.editHabit(i, editController.text.trim());
                                                Navigator.pop(context);
                                                showSnack("Habit updated");
                                              },
                                              child: const Text("Save"),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),

                                  // DELETE BUTTON
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: const Text("Delete Habit"),
                                          content: const Text("Are you sure?"),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text("No"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                provider.deleteHabit(i);
                                                Navigator.pop(context);
                                                showSnack("Habit deleted");
                                              },
                                              child: const Text("Yes"),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StatsScreen()),
                  );
                },
                child: const Text("View Stats"),
              )
            ],
          ),
        ),
      ),
    );
  }
}