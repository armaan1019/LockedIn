import 'package:flutter/material.dart';
import 'workout_tracker_page.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  final List<Workout> _workouts = [];

  final List<WorkoutSession> _history = [];

  void _startWorkout(Workout workout) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutTrackerPage(workout: workout),
      ),
    );

    if (result != null && result is WorkoutSession) {
      setState(() {
        _history.insert(0, result);
      });
    }
  }

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

  void _showPastWorkouts(Workout workout) {
  final pastSessions = _history
      .where((s) => s.title == workout.title)
      .toList();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: pastSessions.isEmpty
            ? const Center(child: Text('No past workouts yet.'))
            : ListView.builder(
                itemCount: pastSessions.length,
                itemBuilder: (context, index) {
                  final session = pastSessions[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date: ${session.date.toLocal().toString().split(' ')[0]}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ...session.exercises.map((e) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(e.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  ...e.sets.asMap().entries.map((entry) {
                                    final i = entry.key;
                                    final set = entry.value;
                                    return Text(
                                        'Set ${i + 1}: ${set.reps} reps${set.weight != null ? ' (${set.weight} lbs)' : ''}');
                                  }),
                                  const SizedBox(height: 6),
                                ],
                              )),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
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
                      workout: w,
                      onStart: () => _startWorkout(w),
                      onPastWorkouts: () => _showPastWorkouts(w),
                      onEdit: (workoutToEdit) {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => Padding(
                            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                            child: AddWorkoutForm(
                              existingWorkout: workoutToEdit,
                              onSave: (updatedWorkout) {
                                setState(() {
                                  _workouts[index] = updatedWorkout;
                                });
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        );
                      },
                      onDelete: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Delete Workout'),
                            content: const Text('Are you sure you want to delete this workout?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _workouts.removeAt(index);
                                  });
                                  Navigator.pop(context);
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              )
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

class AddWorkoutForm extends StatefulWidget {
  final void Function(Workout) onSave;
  final Workout? existingWorkout; // 🔹 new

  const AddWorkoutForm({super.key, required this.onSave, this.existingWorkout});

  @override
  State<AddWorkoutForm> createState() => _AddWorkoutFormState();
}

class _AddWorkoutFormState extends State<AddWorkoutForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late List<ExerciseInput> _exerciseInputs;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingWorkout?.title ?? '',
    );

    if (widget.existingWorkout != null) {
      _exerciseInputs = widget.existingWorkout!.exercises
          .map((e) => ExerciseInput(
                name: e.name,
                sets: e.sets,
                reps: e.reps,
              ))
          .toList();
    } else {
      _exerciseInputs = [ExerciseInput()];
    }
  }

  void _addExerciseField() => setState(() => _exerciseInputs.add(ExerciseInput()));
  void _removeExerciseField(int index) => setState(() => _exerciseInputs.removeAt(index));

  void _save() {
    if (_formKey.currentState!.validate()) {
      final exercises = _exerciseInputs
          .map((input) => Exercise(
                name: input.nameController.text,
                sets: int.parse(input.setsController.text),
                reps: int.parse(input.repsController.text),
              ))
          .toList();

      final workout = Workout(
        title: _titleController.text,
        exercises: exercises,
        duration: exercises.length * 10,
        calories: exercises.length * 50,
      );

      widget.onSave(workout);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (var input in _exerciseInputs) input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.existingWorkout != null ? 'Edit Workout' : 'Add New Workout',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Workout Title'),
                validator: (v) => v == null || v.isEmpty ? 'Enter a title' : null,
              ),
              const SizedBox(height: 12),
              const Text('Exercises', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ..._exerciseInputs.asMap().entries.map((entry) {
                final index = entry.key;
                final input = entry.value;
                return Column(
                  children: [
                    input,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (_exerciseInputs.length > 1)
                          IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () => _removeExerciseField(index),
                          ),
                      ],
                    ),
                  ],
                );
              }).toList(),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _addExerciseField,
                child: const Text('Add Exercise'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Save Workout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WorkoutCard extends StatelessWidget {
  final Workout workout;
  final VoidCallback onStart;
  final VoidCallback onPastWorkouts;
  final void Function(Workout)? onEdit; // 🔹 new
  final VoidCallback? onDelete; // 🔹 new

  const WorkoutCard({
    super.key,
    required this.workout,
    required this.onStart,
    required this.onPastWorkouts,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(workout.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...workout.exercises
                .map((e) => Text('${e.name}: ${e.sets} x ${e.reps}',
                    style: const TextStyle(color: Colors.grey)))
                .toList(),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                ElevatedButton(onPressed: onStart, child: const Text('Start Workout')),
                ElevatedButton(onPressed: onPastWorkouts, child: const Text('Past Workouts')),
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => onEdit!(workout),
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class ExerciseInput extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController setsController;
  final TextEditingController repsController;

  ExerciseInput({
    super.key,
    String? name,
    int? sets,
    int? reps,
  })  : nameController = TextEditingController(text: name ?? ''),
        setsController = TextEditingController(text: sets?.toString() ?? ''),
        repsController = TextEditingController(text: reps?.toString() ?? '');

  void dispose() {
    nameController.dispose();
    setsController.dispose();
    repsController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Exercise'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: setsController,
              decoration: const InputDecoration(labelText: 'Sets'),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || int.tryParse(v) == null ? 'Num' : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: repsController,
              decoration: const InputDecoration(labelText: 'Reps'),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || int.tryParse(v) == null ? 'Num' : null,
            ),
          ),
        ],
      ),
    );
  }
}


