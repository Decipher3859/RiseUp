import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'package:rise_up/db/app_database.dart';
import 'package:rise_up/components/bool_habit_form.dart';
import 'package:rise_up/components/measurable_habit_form.dart';
import 'package:rise_up/.archive/reminder_form.dart';

class AddHabitPage extends StatefulWidget {
  const AddHabitPage({super.key});

  @override
  State<AddHabitPage> createState() => _AddHabitPageState();
}

class _AddHabitPageState extends State<AddHabitPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Controller für TextFields
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();

  // State-Variablen
  String _frequency = 'Daily';
  String _goalType = 'Minimum';
  bool _reminder = false;
  List<String> _selectedDays = [];
  TimeOfDay? _reminderTime;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onCreatePressed() async {
    String category = _tabController.index == 0 ? 'bool' : 'measurable';

    final habit = HabitsCompanion(
      title: drift.Value(_titleController.text),
      question: drift.Value(
        _questionController.text.isEmpty ? null : _questionController.text,
      ),
      category: drift.Value(category),
      frequency: drift.Value(_frequency),
      quantity: drift.Value(double.tryParse(_quantityController.text)),
      unit: drift.Value(
        _unitController.text.isEmpty ? null : _unitController.text,
      ),
      goalType: drift.Value(_goalType),
      reminder: drift.Value(_reminder),
      reminderDays: drift.Value(
        _selectedDays.isEmpty ? null : _selectedDays.join(','),
      ),
      reminderTime: drift.Value(
        _reminderTime != null
            ? DateTime(0, 1, 1, _reminderTime!.hour, _reminderTime!.minute)
            : null,
      ),
      startDate: drift.Value(_startDate),
      endDate: drift.Value(_endDate),
      isActive: drift.Value(_isActive),
    );

    await db.insertHabit(habit);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Habit created')));
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add habit')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'New habit',
                filled: true,
                fillColor: const Color.fromARGB(255, 50, 50, 50),
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _questionController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Tracking question',
                filled: true,
                fillColor: const Color.fromARGB(255, 50, 50, 50),
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Yes/No'),
                Tab(text: 'Measurable'),
              ],
            ),
            Flexible(
              child: IndexedStack(
                index: _tabController.index,
                children: [
                  BoolHabitForm(
                    frequency: _frequency,
                    onFrequencyChanged: (val) =>
                        setState(() => _frequency = val),
                  ),
                  MeasurableHabitForm(
                    quantityController: _quantityController,
                    unitController: _unitController,
                    frequency: _frequency,
                    goalType: _goalType,
                    onFrequencyChanged: (val) =>
                        setState(() => _frequency = val),
                    onGoalTypeChanged: (val) => setState(() => _goalType = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ReminderForm(
              initialTime: _reminderTime,
              initialDays: _selectedDays,
              onTimeChanged: (time) => setState(() => _reminderTime = time),
              onDaysChanged: (days) => setState(() => _selectedDays = days),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _onCreatePressed,
              child: const Text('Create Habit'),
            ),
          ],
        ),
      ),
    );
  }
}
