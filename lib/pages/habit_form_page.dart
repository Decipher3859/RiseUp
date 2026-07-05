import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rise_up/components/day_picker_field.dart';
import 'package:rise_up/db/app_database.dart';
import 'package:rise_up/.archive/bool_habit_form.dart';
import 'package:rise_up/db/habits_notifier.dart';
import 'package:rise_up/utils/weekday_mask.dart';

class HabitFormPage extends ConsumerStatefulWidget {
  final Habit? habit;
  bool get isEditing => habit != null;
  final String buttonText;

  const HabitFormPage({super.key, this.habit, required this.buttonText});

  @override
  ConsumerState<HabitFormPage> createState() => _HabitFormPageState();
}

class _HabitFormPageState extends ConsumerState<HabitFormPage> {
  late TextEditingController _titleController;
  late TextEditingController _questionController;

  late String _frequency;
  late bool _reminder;
  int _selectedDaysMask = 127;
  TimeOfDay? _reminderTime;
  DateTime? _startDate;
  DateTime? _endDate;
  late bool _isActive;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.habit?.title ?? '');
    _questionController = TextEditingController(
      text: widget.habit?.question ?? '',
    );

    _frequency = widget.habit?.frequency ?? 'Daily';
    _reminder = widget.habit?.reminder ?? false;
    _selectedDaysMask =
        widget.habit?.daysOfWeek ??
        (WeekdayMask.monday |
            WeekdayMask.tuesday |
            WeekdayMask.wednesday |
            WeekdayMask.thursday |
            WeekdayMask.friday |
            WeekdayMask.saturday |
            WeekdayMask.sunday);

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
    _titleController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _onSubmitPressed() async {
    final habitCompanion = HabitsCompanion(
      title: drift.Value(_titleController.text),
      question: drift.Value(
        _questionController.text.isEmpty ? null : _questionController.text,
      ),
      category: drift.Value('bool'),
      frequency: drift.Value(_frequency),
      reminder: drift.Value(_reminder),
      daysOfWeek: drift.Value(_selectedDaysMask),
      reminderTime: drift.Value(
        _reminderTime == null
            ? null
            : DateTime(0, 1, 1, _reminderTime!.hour, _reminderTime!.minute),
      ),
      startDate: drift.Value(_startDate),
      endDate: drift.Value(_endDate),
      isActive: drift.Value(_isActive),
    );

    final habitsNotifier = ref.read(habitsProvider.notifier);

    if (widget.isEditing) {
      await habitsNotifier.updateHabit(widget.habit!.id, habitCompanion);
    } else {
      await habitsNotifier.addHabit(habitCompanion);
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Habit' : 'Add Habit'),
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Habit'),
                    content: const Text(
                      'Are you sure you want to delete this habit?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirm != true) return;

                await ref
                    .read(habitsProvider.notifier)
                    .deleteHabit(widget.habit!.id);

                if (!mounted) return;

                Navigator.of(
                  // ignore: use_build_context_synchronously
                  context,
                ).pushNamedAndRemoveUntil('/habitspage', (route) => false);
              },
            ),
        ],
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
            BoolHabitForm(
              frequency: _frequency,
              onFrequencyChanged: (val) => setState(() => _frequency = val),
            ),
            const SizedBox(height: 16),
            DayPickerField(
              selectedDaysMask: _selectedDaysMask,
              onMaskChanged: (mask) => setState(() => _selectedDaysMask = mask),
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
