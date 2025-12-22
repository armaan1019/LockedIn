import 'package:flutter/material.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  final List<Workout> _workouts = [
    Workout(
        title: 'Upper Body Strength',
        exercises: 'Chest, Shoulders, Triceps',
        duration: 45,
        calories: 300),
    Workout(
        title: 'Morning Run',
        exercises: 'Legs & Cardio',
        duration: 30,
        calories: 250),
  ];

  void _addWorkout(Workout workout) {
    setState(() {
      _workouts.add(workout);
    });
    Navigator.pop(context);
  }

  void _showAddWorkoutSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: AddWorkoutForm(onSave: _addWorkout),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Workouts',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _workouts.length,
                  itemBuilder: (context, index) {
                    final w = _workouts[index];
                    return WorkoutCard(
                        title: w.title,
                        exercises: w.exercises,
                        duration: w.duration,
                        calories: w.calories);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddWorkoutSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Workout {
  final String title;
  final String exercises;
  final int duration;
  final int calories;

  Workout({
    required this.title,
    required this.exercises,
    required this.duration,
    required this.calories,
  });
}

class AddWorkoutForm extends StatefulWidget {
  final void Function(Workout) onSave;

  const AddWorkoutForm({super.key, required this.onSave});

  @override
  State<AddWorkoutForm> createState() => _AddWorkoutFormState();
}

class _AddWorkoutFormState extends State<AddWorkoutForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _exercisesController = TextEditingController();
  final _durationController = TextEditingController();
  final _caloriesController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _exercisesController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final workout = Workout(
        title: _titleController.text,
        exercises: _exercisesController.text,
        duration: int.parse(_durationController.text),
        calories: int.parse(_caloriesController.text),
      );
      widget.onSave(workout);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Wrap(
          runSpacing: 12,
          children: [
            Text(
              'Add New Workout',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Workout Title'),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Enter a title' : null,
            ),
            TextFormField(
              controller: _exercisesController,
              decoration: const InputDecoration(labelText: 'Exercises'),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Enter exercises' : null,
            ),
            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(labelText: 'Duration (min)'),
              keyboardType: TextInputType.number,
              validator: (v) =>
                  v == null || int.tryParse(v) == null ? 'Enter a number' : null,
            ),
            TextFormField(
              controller: _caloriesController,
              decoration: const InputDecoration(labelText: 'Calories'),
              keyboardType: TextInputType.number,
              validator: (v) =>
                  v == null || int.tryParse(v) == null ? 'Enter a number' : null,
            ),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Save Workout'),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkoutCard extends StatelessWidget {
  final String title;
  final String exercises;
  final int duration; // in minutes
  final int calories;

  const WorkoutCard({
    super.key,
    required this.title,
    required this.exercises,
    required this.duration,
    required this.calories,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(exercises, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.timer, size: 16),
                    const SizedBox(width: 4),
                    Text('$duration min'),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.local_fire_department, size: 16),
                    const SizedBox(width: 4),
                    Text('$calories cal'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

