import 'package:rise_up/db/app_database.dart';

class DebugHabits {
  final AppDatabase db;

  DebugHabits(this.db);

  /// Gibt alle Habits in der Konsole aus
  Future<void> printAllHabits() async {
    final allHabits = await db.getAllHabits();

    if (allHabits.isEmpty) {
      print("Keine Habits gefunden.");
      return;
    }

    print("----- Alle Habits -----");
    for (final habit in allHabits) {
      print("ID: ${habit.id}");
      print("Title: ${habit.title}");
      print("Question: ${habit.question}");
      print("Category: ${habit.category}");
      print("Frequency: ${habit.frequency}");
      print("DaysOfWeek: ${habit.daysOfWeek}");
      print("StartDate: ${habit.startDate}");
      print("EndDate: ${habit.endDate}");
      print("IsActive: ${habit.isActive}");
      print("----------------------");
    }
  }

  /// Optional: Debug-Methode für Habits + Records an einem Tag
  Future<void> printHabitsAndRecords(DateTime day) async {
    final allHabits = await db.getAllHabits();
    print("----- Habits & Records für $day -----");

    for (final habit in allHabits) {
      final records = await db.getRecordsByHabitIdAndDate(habit.id, day);
      print("Habit: ${habit.title}, Records: ${records.length}");
    }
    print("----------------------");
  }
}
