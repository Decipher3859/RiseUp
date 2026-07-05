import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rise_up/theme/colors.dart';
import 'package:rise_up/utils/weekday_mask.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:rise_up/db/app_database.dart';
import 'package:rise_up/db/habits_notifier.dart';
import 'package:rise_up/pages/habit_form_page.dart';

class HabitOverviewPage extends ConsumerStatefulWidget {
  final Habit habit;

  const HabitOverviewPage({super.key, required this.habit});

  @override
  ConsumerState<HabitOverviewPage> createState() => _HabitOverviewPageState();
}

class _HabitOverviewPageState extends ConsumerState<HabitOverviewPage> {
  late Habit habit;

  @override
  void initState() {
    super.initState();
    habit = widget.habit;
  }

  Future<void> _updateHabit() async {
    final notifier = ref.read(habitsProvider.notifier);
    final updated = notifier.getHabitById(habit.id);
    if (updated != null) {
      setState(() {
        habit = updated;
      });
    }
  }

  Future<void> _navigateToEditHabit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            HabitFormPage(habit: habit, buttonText: 'Submit Changes'),
      ),
    );

    if (result == true) {
      await _updateHabit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedDay = ref.watch(selectedDayProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(habit.title),
        actions: [
          IconButton(
            icon: Icon(habit.isActive ? Icons.check_circle : Icons.cancel),
            color: habit.isActive ? Colors.green : Colors.red,
            onPressed: () async {
              await ref
                  .read(habitsProvider.notifier)
                  .toggleHabitActive(habit.id);
              await _updateHabit();
            },
          ),
          IconButton(
            onPressed: _navigateToEditHabit,
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TableCalendar(
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(color: Colors.white),
                ),
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: selectedDay,
                calendarFormat: CalendarFormat.month,
                onDaySelected: (selected, focused) async {
                  ref.read(selectedDayProvider.notifier).state = selected;
                  await ref
                      .read(habitsProvider.notifier)
                      .toggleDay(habit.id, selected);
                },
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    return FutureBuilder<bool>(
                      future: ref
                          .read(habitsProvider.notifier)
                          .isHabitDoneOnDay(habit.id, day),
                      builder: (context, snapshot) {
                        final isDone = snapshot.data ?? false;
                        final isPlanned = WeekdayMask.contains(
                          habit.daysOfWeek,
                          WeekdayMask.fromDate(day),
                        );
                        Color bg = Colors.transparent;
                        if (isPlanned && isDone) {
                          bg = AppColors.green;
                        } else if (isPlanned) {
                          bg = AppColors.turquoise;
                        } else if (isDone) {
                          bg = Colors.blue;
                        }
                        return Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: bg,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
