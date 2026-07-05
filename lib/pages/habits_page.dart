import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rise_up/components/habit_row.dart';
import 'package:rise_up/components/weekdays_horizontal_list.dart';
import 'package:rise_up/pages/habit_form_page.dart';
import 'package:rise_up/db/habits_notifier.dart';
import 'package:rise_up/managers/app_controller.dart';

class HabitsPage extends ConsumerWidget {
  const HabitsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allHabits = ref.watch(habitsProvider);
    final selectedDay = ref.watch(selectedDayProvider);

    final selectedFilter = ref.watch(habitFilterProvider);

    final habitsForSelectedDay = allHabits.getHabitsForDay(selectedDay).where((
      h,
    ) {
      switch (selectedFilter) {
        case HabitFilter.active:
          return h.isActive;
        case HabitFilter.inactive:
          return !h.isActive;
        case HabitFilter.all:
          return true;
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habits'),
        actions: [
          IconButton(
            onPressed: () => _navigateToAddHabit(context),
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<HabitFilter>(
            icon: const Icon(Icons.filter_list),
            onSelected: (filter) {
              ref.read(habitFilterProvider.notifier).state = filter;
            },
            itemBuilder: (context) => HabitFilter.values.map((filter) {
              return PopupMenuItem(value: filter, child: Text(filter.name));
            }).toList(),
          ),

          IconButton(
            onPressed: () async {
              await AppController.instance.notifications
                  .showSimpleNotification();
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [WeekdaysHorizontalList()],
              ),
            ),
            Expanded(
              flex: 7,
              child: habitsForSelectedDay.isEmpty
                  ? const Center(child: Text('No habits found.'))
                  : ListView.builder(
                      itemCount: habitsForSelectedDay.length,
                      itemBuilder: (context, index) {
                        return HabitRow(habit: habitsForSelectedDay[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddHabit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HabitFormPage(buttonText: 'Create Habit'),
      ),
    );
  }
}
