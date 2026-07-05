import 'package:flutter/material.dart';
import 'package:rise_up/db/app_database.dart';
import 'package:drift/drift.dart';

class WeekdayCheckRow extends StatefulWidget {
  final int habitId;
  const WeekdayCheckRow({super.key, required this.habitId});

  @override
  State<WeekdayCheckRow> createState() => _WeekdayCheckRowState();
}

class _WeekdayCheckRowState extends State<WeekdayCheckRow> {
  final List<bool> _selected = List.generate(7, (_) => false);

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _loadRecords() async {
    final records = await db.getRecordsByHabitId(widget.habitId);

    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday));

    setState(() {
      for (int i = 0; i < 7; i++) {
        final day = weekStart.add(Duration(days: i));
        _selected[i] = records.any(
          (r) =>
              r.date.year == day.year &&
              r.date.month == day.month &&
              r.date.day == day.day,
        );
      }
    });
  }

  void _toggleDay(int index) async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday));
    final day = weekStart.add(Duration(days: index));

    DateTime onlyDate(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

    final exists =
        await (db.select(db.habitRecords)..where(
              (r) =>
                  r.habitId.equals(widget.habitId) &
                  r.date.equals(onlyDate(day)),
            ))
            .getSingleOrNull();

    if (exists == null) {
      await db.insertHabitRecord(
        HabitRecordsCompanion(
          habitId: Value(widget.habitId),
          date: Value(onlyDate(day)),
        ),
      );
      setState(() => _selected[index] = true);
    } else {
      await (db.delete(db.habitRecords)..where(
            (r) =>
                r.habitId.equals(widget.habitId) & r.date.equals(onlyDate(day)),
          ))
          .go();
      setState(() => _selected[index] = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        return GestureDetector(
          onTap: () => _toggleDay(index),
          child: Icon(
            Icons.check,
            color: _selected[index] ? Colors.blue : Colors.white,
            size: 24,
          ),
        );
      }),
    );
  }
}
