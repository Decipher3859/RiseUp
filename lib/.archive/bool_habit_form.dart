import 'package:flutter/material.dart';

class BoolHabitForm extends StatelessWidget {
  final String frequency;
  final void Function(String) onFrequencyChanged;

  const BoolHabitForm({
    super.key,
    required this.frequency,
    required this.onFrequencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: DropdownButtonFormField<String>(
        value: frequency,
        decoration: const InputDecoration(
          labelText: 'Frequency',
          filled: true,
          fillColor: Color.fromARGB(255, 50, 50, 50),
          border: OutlineInputBorder(),
        ),
        items: const [
          DropdownMenuItem(value: 'Daily', child: Text('Daily')),
          DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
          DropdownMenuItem(value: 'Monthly', child: Text('Monthly')),
          DropdownMenuItem(value: 'Define', child: Text('Define...')),
        ],
        onChanged: (value) {
          if (value != null) onFrequencyChanged(value);
        },
      ),
    );
  }
}
