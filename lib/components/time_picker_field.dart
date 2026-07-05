import 'package:flutter/material.dart';

class TimePickerField extends StatelessWidget {
  final TimeOfDay? selectedTime;
  final ValueChanged<TimeOfDay?> onTimeChanged;

  const TimePickerField({
    super.key,
    required this.selectedTime,
    required this.onTimeChanged,
  });

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      onTimeChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      onTap: () => _pickTime(context),
      controller: TextEditingController(
        text: selectedTime == null ? "Off" : selectedTime!.format(context),
      ),
      decoration: InputDecoration(
        labelText: "Reminder Time",
        filled: true,
        fillColor: const Color.fromARGB(255, 50, 50, 50),
        border: const OutlineInputBorder(),
        suffixIcon: selectedTime != null
            ? IconButton(
                icon: const Icon(Icons.delete, color: Colors.white),
                onPressed: () => onTimeChanged(null),
              )
            : null,
      ),
      style: const TextStyle(color: Colors.white),
    );
  }
}
