import 'package:drift/drift.dart';

class HabitRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get habitId =>
      integer().customConstraint('REFERENCES habits(id)')();
  DateTimeColumn get date => dateTime()();
  RealColumn get quantity => real().nullable()();
}
