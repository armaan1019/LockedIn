import 'package:flutter/material.dart';
import '../models/workout.dart';
import 'exercise_input.dart';

class AddWorkoutForm extends StatefulWidget {
  final void Function(Workout) onSave;
  final Workout? existingWorkout; 

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
        id: widget.existingWorkout?.id,
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