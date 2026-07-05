import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:rise_up/db/app_database.dart';
import 'package:rise_up/utils/weekday_mask.dart';

class HabitsNotifier extends StateNotifier<List<Habit>> {
  final AppDatabase db;

  HabitsNotifier(this.db) : super([]) {
    loadHabits();
  }

  Future<void> loadHabits() async {
    final allHabits = await db.getAllHabits();
    state = allHabits;
  }

  // ---- CRUD ----

  Future<int> addHabit(HabitsCompanion habit) async {
    final id = await db.insertHabit(habit);
    await loadHabits();

    return id;
  }

  Future<void> updateHabit(int id, HabitsCompanion habit) async {
    await db.updateHabit(id, habit);
    await loadHabits();
  }

  Future<void> deleteHabit(int id) async {
    await db.deleteRecordsByHabitId(id);
    await db.deleteHabit(id);
    await loadHabits();
  }

  Habit? getHabitById(int id) {
    try {
      return state.firstWhere((h) => h.id == id);
    } catch (e) {
      return null;
    }
  }

  // ---- Queries ----

  Future<int> getTotalProgress(int habitId) async {
    final records = await db.getRecordsByHabitId(habitId);
    return records.length;
  }

  Future<int> getPlannedDays(int id) async {
    final habit = getHabitById(id);
    if (habit == null || habit.daysOfWeek == 0) return 0;

    return WeekdayMask.countDays(habit.daysOfWeek);
  }

  Future<List<Habit>> getHabitsByDayOfWeek(DateTime day) async {
    final allHabits = await db.getAllHabits();
    final dayBit = WeekdayMask.fromDate(day);

    final filtered = allHabits.where((h) {
      if (h.daysOfWeek == 0) return false;
      return WeekdayMask.contains(h.daysOfWeek, dayBit);
    }).toList();

    return filtered;
  }

  Future<Map<Habit, List<HabitRecord>>> getHabitRecordsByDay(
    DateTime day,
  ) async {
    final habits = await getHabitsByDayOfWeek(day);

    final Map<Habit, List<HabitRecord>> result = {};

    for (final habit in habits) {
      final records = await db.getRecordsByHabitIdAndDate(habit.id, day);
      result[habit] = records;
    }

    return result;
  }

  Future<double> getTotalHabitProgress(int habitId) async {
    final plannedDays = await getPlannedDays(habitId);
    if (plannedDays == 0) return 0.0;

    final records = await db.getRecordsByHabitId(habitId);
    final completedDays = records.length;

    return (completedDays / plannedDays).clamp(0.0, 1.0);
  }

  Future<List<double>> getWeeklyHabitProgress(DateTime startDate) async {
    final List<double> weekProgress = [];

    for (int i = 0; i < 7; i++) {
      final day = startDate.add(Duration(days: i));

      final habits = await getHabitsByDayOfWeek(day);

      if (habits.isEmpty) {
        weekProgress.add(0.0);
        continue;
      }

      int completed = 0;
      for (final habit in habits) {
        final records = await db.getRecordsByHabitIdAndDate(habit.id, day);
        if (records.isNotEmpty) completed++;
      }

      final progress = completed / habits.length;
      weekProgress.add(progress.clamp(0.0, 1.0));
    }

    return weekProgress;
  }

  Future<double> getDailyHabitProgress(DateTime day) async {
    final plannedHabits = await getHabitsByDayOfWeek(day);
    final plannedCount = plannedHabits.length;
    if (plannedCount == 0) return 0.0;

    int doneCount = 0;
    for (final habit in plannedHabits) {
      final records = await db.getRecordsByHabitIdAndDate(habit.id, day);
      if (records.isNotEmpty) {
        doneCount++;
      }
    }

    return (doneCount / plannedCount).clamp(0.0, 1.0);
  }

  Future<bool> isHabitDoneOnDay(int habitId, DateTime date) async {
    final target = DateTime(date.year, date.month, date.day);

    final records = await db.getRecordsByHabitId(habitId);

    return records.any(
      (r) =>
          r.date.year == target.year &&
          r.date.month == target.month &&
          r.date.day == target.day,
    );
  }

  Future<void> toggleDay(int habitId, DateTime date) async {
    final targetDate = DateTime(date.year, date.month, date.day);
    final currentDate = DateTime.now();

    final records = await db.getRecordsByHabitId(habitId);
    final dayRecord = records.firstWhereOrNull(
      (r) =>
          r.date.year == targetDate.year &&
          r.date.month == targetDate.month &&
          r.date.day == targetDate.day,
    );

    if (dayRecord == null && targetDate.isBefore(currentDate)) {
      await db.insertHabitRecord(
        HabitRecordsCompanion(habitId: Value(habitId), date: Value(targetDate)),
      );
    } else {
      await (db.delete(
        db.habitRecords,
      )..where((r) => r.id.equals(dayRecord.id))).go();
    }

    state = [...state];
  }

  Future<void> toggleHabitActive(int habitId) async {
    final habit = getHabitById(habitId);
    if (habit == null) return;

    final updatedCompanion = HabitsCompanion(isActive: Value(!habit.isActive));

    await updateHabit(habitId, updatedCompanion);
  }
}
// -------------- Extensions ----------------

extension HabitByDay on HabitsNotifier {
  Future<List<Habit>> getHabitsForDay(DateTime day) async {
    final allHabits = await db.getAllHabits();
    final dayBit = WeekdayMask.fromDate(day);

    return allHabits.where((h) {
      return WeekdayMask.contains(h.daysOfWeek, dayBit);
    }).toList();
  }
}

extension HabitListExtensions on List<Habit> {
  List<Habit> getHabitsForDay(DateTime day) {
    return where(
      (h) => WeekdayMask.contains(h.daysOfWeek, WeekdayMask.fromDate(day)),
    ).toList();
  }
}

// -------------- Provider ----------------
final habitsProvider = StateNotifierProvider<HabitsNotifier, List<Habit>>((
  ref,
) {
  final db = ref.watch(databaseProvider);
  return HabitsNotifier(db);
});

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final selectedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());

final dailyProgressProvider = FutureProvider.family<double, DateTime>((
  ref,
  day,
) async {
  final notifier = ref.watch(habitsProvider.notifier);
  return notifier.getDailyHabitProgress(day);
});

final progressUpdateProvider = StateProvider<int>((ref) => 0);

enum HabitFilter { all, active, inactive }

final habitFilterProvider = StateProvider<HabitFilter>(
  (ref) => HabitFilter.active,
);
