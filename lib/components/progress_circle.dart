import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rise_up/db/habits_notifier.dart';
import 'package:rise_up/theme/colors.dart';

class ProgressCircle extends ConsumerWidget {
  final DateTime date;
  final bool isSelected;
  final String labelDay;
  final String labelDate;

  const ProgressCircle({
    super.key,
    required this.date,
    required this.isSelected,
    required this.labelDay,
    required this.labelDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(progressUpdateProvider);

    return FutureBuilder<double>(
      future: ref.read(habitsProvider.notifier).getDailyHabitProgress(date),
      builder: (context, snapshot) {
        final progress = snapshot.data ?? 0.0;

        return GestureDetector(
          onTap: () => ref.read(selectedDayProvider.notifier).state = date,
          child: SizedBox(
            width: isSelected ? 65 : 50,
            height: isSelected ? 65 : 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: isSelected ? 75 : 60,
                  height: isSelected ? 75 : 60,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 4,
                    color: AppColors.eggshell,
                  ),
                ),
                Container(
                  width: isSelected ? 65 : 50,
                  height: isSelected ? 65 : 50,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.lightBlue
                        : AppColors.turquoise,
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        labelDay,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      Text(
                        labelDate,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
