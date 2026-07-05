import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rise_up/components/progress_circle.dart';
import 'package:rise_up/db/habits_notifier.dart';

class WeekdayCircle extends ConsumerWidget {
  final DateTime day;
  final String labelDay;
  final String labelDate;

  const WeekdayCircle({
    super.key,
    required this.day,
    required this.labelDay,
    required this.labelDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(selectedDayProvider);

    final isSelected =
        day.day == selectedDay.day &&
        day.month == selectedDay.month &&
        day.year == selectedDay.year;

    final today = DateTime.now();
    final isToday =
        day.day == today.day &&
        day.month == today.month &&
        day.year == today.year;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: ProgressCircle(
            key: ValueKey(isSelected),
            date: day,
            isSelected: isSelected,
            labelDay: labelDay,
            labelDate: labelDate,
          ),
        ),
        const SizedBox(height: 4),
        if (isToday)
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }
}

class WeekdaysHorizontalList extends StatelessWidget {
  const WeekdaysHorizontalList({super.key});

  @override
  Widget build(BuildContext context) {
    final startDate = DateTime.now().subtract(const Duration(days: 3));

    final weekDays = List.generate(
      7,
      (i) => DateFormat.E('de_DE').format(startDate.add(Duration(days: i))),
    );

    final weekDates = List.generate(
      7,
      (i) => DateFormat('dd').format(startDate.add(Duration(days: i))),
    );

    return SizedBox(
      height: 90,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (i) {
          final day = startDate.add(Duration(days: i));

          return WeekdayCircle(
            key: ValueKey(day), // Key für Flutter, um Widgets zu unterscheiden
            day: day,
            labelDay: weekDays[i],
            labelDate: weekDates[i],
          );
        }),
      ),
    );
  }
}
