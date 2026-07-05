import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'habit_records.dart';

part 'app_database.g.dart';

@DataClassName('Habit')
class Habits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get question => text().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get frequency => text().nullable()();
  RealColumn get quantity => real().nullable()();
  TextColumn get unit => text().nullable()();
  TextColumn get goalType => text().nullable()();
  IntColumn get daysOfWeek => integer().withDefault(const Constant(0))();

  BoolColumn get reminder => boolean().withDefault(const Constant(false))();
  TextColumn get reminderDays => text().nullable()();
  DateTimeColumn get reminderTime => dateTime().nullable()();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

@DriftDatabase(tables: [Habits, HabitRecords])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 7;

  // ---- CRUD für Habits ----
  Future<int> insertHabit(HabitsCompanion habit) => into(habits).insert(habit);
  Future<List<Habit>> getAllHabits() => select(habits).get();
  Future<Habit?> getHabitById(int id) =>
      (select(habits)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  Future<void> updateHabit(int id, HabitsCompanion habit) =>
      (update(habits)..where((tbl) => tbl.id.equals(id))).write(habit);
  Future<int> deleteHabit(int id) =>
      (delete(habits)..where((tbl) => tbl.id.equals(id))).go();

  // ---- CRUD für HabitRecords ----
  Future<int> insertHabitRecord(HabitRecordsCompanion record) =>
      into(habitRecords).insert(record);
  Future<List<HabitRecord>> getRecordsByHabitId(int habitId) =>
      (select(habitRecords)..where((tbl) => tbl.habitId.equals(habitId))).get();
  Future<int> deleteRecordsByHabitId(int habitId) =>
      (delete(habitRecords)..where((tbl) => tbl.habitId.equals(habitId))).go();

  Future<List<HabitRecord>> getRecordsByHabitIdAndDate(
    int habitId,
    DateTime day,
  ) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    return (select(habitRecords)..where(
          (tbl) =>
              tbl.habitId.equals(habitId) &
              tbl.date.isBiggerOrEqualValue(start) &
              tbl.date.isSmallerThanValue(end),
        ))
        .get();
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 7) {
        await m.deleteTable(habits.actualTableName);

        await m.createTable(habits);
      }
    },
  );
}

// Verbindungsaufbau
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'habits.sqlite'));

    return NativeDatabase(file);
  });
}

Future<void> resetDatabase() async {
  final dbFolder = await getApplicationDocumentsDirectory();
  final file = File(p.join(dbFolder.path, 'habits.sqlite'));
  if (await file.exists()) {
    await file.delete();
  }
}

final AppDatabase db = AppDatabase();
