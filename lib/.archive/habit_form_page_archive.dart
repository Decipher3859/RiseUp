import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'package:rise_up/db/app_database.dart';
import 'package:rise_up/components/bool_habit_form.dart';
import 'package:rise_up/components/measurable_habit_form.dart';
import 'package:rise_up/components/reminder_form.dart';

class HabitFormPage extends StatefulWidget {
  final Habit? habit;
  final String buttonText;
  final Future<void> Function(HabitsCompanion habit) onSubmit;

  const HabitFormPage({
    super.key,
    this.habit,
    required this.buttonText,
    required this.onSubmit,
  });

  @override
  State<HabitFormPage> createState() => _HabitFormPageState();
}

class _HabitFormPageState extends State<HabitFormPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  late TextEditingController _titleController;
  late TextEditingController _questionController;
  late TextEditingController _quantityController;
  late TextEditingController _unitController;

  late String _frequency;
  late String _goalType;
  late bool _reminder;
  late List<String> _selectedDays;
  TimeOfDay? _reminderTime;
  DateTime? _startDate;
  DateTime? _endDate;
  late bool _isActive;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });

    _titleController = TextEditingController(text: widget.habit?.title ?? '');
    _questionController = TextEditingController(
      text: widget.habit?.question ?? '',
    );
    _quantityController = TextEditingController(
      text: widget.habit?.quantity?.toString() ?? '',
    );
    _unitController = TextEditingController(text: widget.habit?.unit ?? '');

    _frequency = widget.habit?.frequency ?? 'Daily';
    _goalType = widget.habit?.goalType ?? 'Minimum';
    _reminder = widget.habit?.reminder ?? false;
    _selectedDays = widget.habit?.reminderDays?.split(',') ?? [];
    if (widget.habit?.reminderTime != null) {
      _reminderTime = TimeOfDay(
        hour: widget.habit!.reminderTime!.hour,
        minute: widget.habit!.reminderTime!.minute,
      );
    }
    _startDate = widget.habit?.startDate;
    _endDate = widget.habit?.endDate;
    _isActive = widget.habit?.isActive ?? true;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _questionController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _onSubmitPressed() async {
    String category = _tabController.index == 0 ? 'bool' : 'measurable';

    final habitCompanion = HabitsCompanion(
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

    await widget.onSubmit(habitCompanion);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.buttonText == 'Create Habit'
              ? 'Habit created'
              : 'Habit updated',
        ),
      ),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit == null ? 'Add Habit' : 'Edit Habit'),
      ),
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
              onPressed: _onSubmitPressed,
              child: Text(widget.buttonText),
            ),
          ],
        ),
      ),
    );
  }
}
