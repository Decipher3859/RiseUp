import 'package:drift/drift.dart' as drift;
import 'package:rise_up/db/app_database.dart';

class ProvideSampleData {
  Future<void> insertSampleData(AppDatabase db) async {
    final habits = [
      HabitsCompanion.insert(
        title: "Mehr Wasser trinken",
        question: drift.Value("Hast du genug Wasser getrunken?"),
        category: drift.Value("bool"),
        frequency: drift.Value("Daily"),
        daysOfWeek: drift.Value(7),
      ),
      HabitsCompanion.insert(
        title: "Sport machen",
        question: drift.Value("Hast du heute Sport gemacht?"),
        category: drift.Value("bool"),
        frequency: drift.Value("Weekly"),
        daysOfWeek: drift.Value(127),
      ),
      HabitsCompanion.insert(
        title: "Lesen",
        question: drift.Value("Hast du gelesen?"),
        category: drift.Value("bool"),
        frequency: drift.Value("Daily"),
        daysOfWeek: drift.Value(59),
      ),
    ];

    for (final habit in habits) {
      await db.insertHabit(habit);
    }
  }
}
