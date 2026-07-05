import 'package:flutter/material.dart';
import 'package:rise_up/utils/weekday_mask.dart';

class DayPickerField extends StatefulWidget {
  final int selectedDaysMask;
  final ValueChanged<int> onMaskChanged;

  const DayPickerField({
    super.key,
    required this.selectedDaysMask,
    required this.onMaskChanged,
  });

  @override
  State<DayPickerField> createState() => _DayPickerFieldState();
}

class _DayPickerFieldState extends State<DayPickerField> {
  final List<int> dayBits = [
    WeekdayMask.monday,
    WeekdayMask.tuesday,
    WeekdayMask.wednesday,
    WeekdayMask.thursday,
    WeekdayMask.friday,
    WeekdayMask.saturday,
    WeekdayMask.sunday,
  ];

  final List<String> dayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final Map<String, String> abbreviations = {
    'Monday': 'Mon',
    'Tuesday': 'Tue',
    'Wednesday': 'Wed',
    'Thursday': 'Thu',
    'Friday': 'Fri',
    'Saturday': 'Sat',
    'Sunday': 'Sun',
  };

  late int tempMask;

  @override
  void initState() {
    super.initState();
    tempMask = widget.selectedDaysMask;
  }

  void _toggleDay(int dayBit) {
    setState(() {
      if (WeekdayMask.contains(tempMask, dayBit)) {
        tempMask = WeekdayMask.removeDay(tempMask, dayBit);
      } else {
        tempMask = WeekdayMask.addDay(tempMask, dayBit);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final result = await showDialog<int>(
          context: context,
          builder: (context) {
            tempMask = widget.selectedDaysMask;
            return AlertDialog(
              title: const Text("Choose days"),
              content: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(dayBits.length, (i) {
                      final dayBit = dayBits[i];
                      final dayName = dayNames[i];
                      return CheckboxListTile(
                        title: Text(dayName),
                        value: WeekdayMask.contains(tempMask, dayBit),
                        onChanged: (checked) {
                          setState(() => _toggleDay(dayBit));
                        },
                      );
                    }),
                  );
                },
              ),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () =>
                      Navigator.pop(context, widget.selectedDaysMask),
                ),
                ElevatedButton(
                  child: const Text("OK"),
                  onPressed: () => Navigator.pop(context, tempMask),
                ),
              ],
            );
          },
        );

        if (result != null) {
          widget.onMaskChanged(result);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color.fromARGB(255, 50, 50, 50),
          labelStyle: const TextStyle(color: Colors.white),
          border: const OutlineInputBorder(),
        ),
        child: Text(
          tempMask == 0
              ? "Choose days"
              : tempMask == 127
              ? "Every day"
              : List.generate(dayBits.length, (i) {
                  if (WeekdayMask.contains(tempMask, dayBits[i])) {
                    return abbreviations[dayNames[i]];
                  }
                  return null;
                }).whereType<String>().join(', '),
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
