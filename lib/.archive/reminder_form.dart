import 'package:flutter/material.dart';
import '../components/day_picker_field.dart';
import '../components/time_picker_field.dart';

class ReminderForm extends StatefulWidget {
  final TimeOfDay? initialTime;
  final List<String>? initialDays;
  final ValueChanged<TimeOfDay?> onTimeChanged;
  final ValueChanged<List<String>> onDaysChanged;

  const ReminderForm({
    super.key,
    this.initialTime,
    this.initialDays,
    required this.onTimeChanged,
    required this.onDaysChanged,
  });

  @override
  State<ReminderForm> createState() => _ReminderFormState();
}

class _ReminderFormState extends State<ReminderForm> {
  TimeOfDay? _selectedTime;
  final int selectedDaysMask;
  final ValueChanged<int> onMaskChanged;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
    _selectedDays = widget.initialDays ?? [];
  }

  void _handleTimeChanged(TimeOfDay? time) {
    setState(() => _selectedTime = time);
    widget.onTimeChanged(time);
  }

  void _handleDaysChanged(List<String> days) {
    setState(() => _selectedDays = days);
    widget.onDaysChanged(days);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            children: [
              TimePickerField(
                selectedTime: _selectedTime,
                onTimeChanged: _handleTimeChanged,
              ),
              const SizedBox(height: 8),
              DayPickerField(
                selectedDaysMask: _selectedDaysMask,
                onMaskChanged: (mask) =>
                    setState(() => _selectedDaysMask = mask),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            children: const [
              Icon(Icons.add_alert, color: Colors.white),
              SizedBox(height: 4),
              Text("Alarm", style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }
}
