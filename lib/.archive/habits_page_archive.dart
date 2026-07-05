import 'package:flutter/material.dart';
import 'package:rise_up/components/habit_row.dart';
import 'package:rise_up/components/weekdays_horizontal_list.dart';
import 'package:rise_up/db/app_database.dart';
import 'package:rise_up/pages/habit_form_page.dart';

class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});

  @override
  State<HabitsPage> createState() => HabitsPageState();
}

class HabitsPageState extends State<HabitsPage> {
  late Future<List<Habit>> _habitsFuture;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  void _loadHabits() {
    _habitsFuture = db.getAllHabits();
  }

  void reloadHabits() {
    setState(() {
      _loadHabits();
    });
  }

  Future<void> _navigateToAddHabit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HabitFormPage(
          buttonText: 'Create Habit',
          onSubmit: (habitCompanion) async {
            final db = AppDatabase();
            await db.insertHabit(habitCompanion);
          },
        ),
      ),
    );
    if (result == true) {
      setState(() {
        _loadHabits();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habits'),
        actions: [
          IconButton(
            onPressed: _navigateToAddHabit,
            icon: const Icon(Icons.add),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [WeekdaysHorizontalList()],
            ),
            Expanded(
              child: FutureBuilder<List<Habit>>(
                future: _habitsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No habits found.'));
                  }

                  final habits = snapshot.data!;
                  return ListView.builder(
                    itemCount: habits.length,
                    itemBuilder: (context, index) {
                      return HabitRow(habit: habits[index]);
                    },
                  );
                },
              ),
            ),
            FutureBuilder(
              future: db.getRecordsByHabitId(1),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No records found.'));
                }

                final records = snapshot.data!;
                return Text(
                  'Records for Habit ID 1: ${records.length}',
                  style: const TextStyle(color: Colors.white),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
