import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rise_up/db/habits_notifier.dart';

final habitDoneProvider =
    FutureProvider.family<bool, (int habitId, DateTime day)>((ref, args) {
      final (habitId, day) = args;
      final notifier = ref.watch(habitsProvider.notifier);
      return notifier.isHabitDoneOnDay(habitId, day);
    });

final habitProgressProvider = FutureProvider.family<int, int>((ref, habitId) {
  final notifier = ref.watch(habitsProvider.notifier);
  return notifier.getTotalProgress(habitId);
});

class CheckHabitButton extends ConsumerStatefulWidget {
  final int habitId;

  const CheckHabitButton({super.key, required this.habitId});

  @override
  ConsumerState<CheckHabitButton> createState() => _CheckHabitButtonState();
}

class _CheckHabitButtonState extends ConsumerState<CheckHabitButton> {
  bool _lastDone = false;
  int _lastProgress = 0;

  @override
  Widget build(BuildContext context) {
    final selectedDay = ref.watch(selectedDayProvider);
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final normalizedSelectedDay = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
    );

    if (normalizedSelectedDay.isAfter(normalizedToday)) {
      return const SizedBox.shrink();
    }

    final doneAsync = ref.watch(
      habitDoneProvider((widget.habitId, selectedDay)),
    );
    final progressAsync = ref.watch(habitProgressProvider(widget.habitId));

    doneAsync.whenData((value) => _lastDone = value);
    progressAsync.whenData((value) => _lastProgress = value);

    final imageName = _lastProgress == 0
        ? 'lib/images/habit_plant/habit_plant_0.png'
        : 'lib/images/habit_plant/habit_plant_$_lastProgress.png';

    return GestureDetector(
      onTap: () async {
        await ref
            .read(habitsProvider.notifier)
            .toggleDay(widget.habitId, selectedDay);
        ref.invalidate(habitDoneProvider((widget.habitId, selectedDay)));
        ref.invalidate(habitProgressProvider(widget.habitId));
        ref.read(progressUpdateProvider.notifier).state++;
      },
      child: SizedBox(
        width: 120,
        height: 120,
        child: ClipOval(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: ColorFiltered(
              key: ValueKey('habit_${_lastProgress}_$_lastDone'),
              colorFilter: _lastDone
                  ? const ColorFilter.mode(
                      Colors.transparent,
                      BlendMode.multiply,
                    )
                  : const ColorFilter.matrix(<double>[
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0.2126,
                      0.7152,
                      0.0722,
                      0,
                      0,
                      0,
                      0,
                      0,
                      1,
                      0,
                    ]),
              child: Image.asset(imageName, fit: BoxFit.cover),
            ),
          ),
        ),
      ),
    );
  }
}
