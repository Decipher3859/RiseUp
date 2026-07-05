import 'package:drift/drift.dart';
import 'package:rise_up/db/app_database.dart';

class DebugHabitRecords {
  final AppDatabase db;

  DebugHabitRecords(this.db);

  /// Gibt alle HabitRecords in der Konsole aus
  Future<void> printAllRecords() async {
    final allRecords = await db.select(db.habitRecords).get();

    if (allRecords.isEmpty) {
      print("Keine HabitRecords gefunden.");
      return;
    }

    print("----- Alle HabitRecords -----");
    for (final record in allRecords) {
      print("ID: ${record.id}");
      print("HabitID: ${record.habitId}");
      print("Date: ${record.date}");
      print("Quantity: ${record.quantity}");
      print("----------------------------");
    }
  }

  /// Optional: Records für ein bestimmtes Habit ausgeben
  Future<void> printRecordsByHabit(int habitId) async {
    final records = await db.getRecordsByHabitId(habitId);

    if (records.isEmpty) {
      print("Keine Records für Habit ID $habitId gefunden.");
      return;
    }

    print("----- Records für Habit ID $habitId -----");
    for (final record in records) {
      print(
        "ID: ${record.id}, Date: ${record.date}, Quantity: ${record.quantity}",
      );
    }
    print("----------------------------");
  }

  /// Optional: Records für ein bestimmtes Datum
  Future<void> printRecordsByDate(DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    final records =
        await (db.select(db.habitRecords)..where(
              (tbl) =>
                  tbl.date.isBiggerOrEqualValue(start) &
                  tbl.date.isSmallerThanValue(end),
            ))
            .get();

    if (records.isEmpty) {
      print("Keine Records am ${day.toIso8601String()} gefunden.");
      return;
    }

    print("----- Records am ${day.toIso8601String()} -----");
    for (final record in records) {
      print(
        "ID: ${record.id}, HabitID: ${record.habitId}, Quantity: ${record.quantity}",
      );
    }
    print("----------------------------");
  }
}
