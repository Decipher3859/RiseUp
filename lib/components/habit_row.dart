import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rise_up/components/check_habit_button.dart';
import 'package:rise_up/db/app_database.dart';
import 'package:rise_up/pages/habit_overview_page.dart';
import 'package:rise_up/db/habits_notifier.dart';

class HabitRow extends ConsumerWidget {
  final Habit habit;

  const HabitRow({super.key, required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);
    final currentHabit = habits.firstWhere(
      (h) => h.id == habit.id,
      orElse: () => habit,
    );

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        color: const Color.fromARGB(255, 100, 100, 100),
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          HabitOverviewPage(habit: currentHabit),
                    ),
                  );
                },
                child: Text(
                  currentHabit.title,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              CheckHabitButton(habitId: currentHabit.id),
            ],
          ),
        ),
      ),
    );
  }
}
