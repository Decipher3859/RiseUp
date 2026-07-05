import 'package:flutter/material.dart';

class MeasurableHabitForm extends StatelessWidget {
  final TextEditingController quantityController;
  final TextEditingController unitController;
  final String frequency;
  final String goalType;
  final void Function(String) onFrequencyChanged;
  final void Function(String) onGoalTypeChanged;

  const MeasurableHabitForm({
    super.key,
    required this.quantityController,
    required this.unitController,
    required this.frequency,
    required this.goalType,
    required this.onFrequencyChanged,
    required this.onGoalTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  filled: true,
                  fillColor: Color.fromARGB(255, 50, 50, 50),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: TextField(
                controller: unitController,
                decoration: const InputDecoration(
                  labelText: 'Unit',
                  filled: true,
                  fillColor: Color.fromARGB(255, 50, 50, 50),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
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
                onChanged: (val) {
                  if (val != null) onFrequencyChanged(val);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: goalType,
                decoration: const InputDecoration(
                  labelText: 'Goal type',
                  filled: true,
                  fillColor: Color.fromARGB(255, 50, 50, 50),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Minimum', child: Text('Minimum')),
                  DropdownMenuItem(value: 'Maximum', child: Text('Maximum')),
                ],
                onChanged: (val) {
                  if (val != null) onGoalTypeChanged(val);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
