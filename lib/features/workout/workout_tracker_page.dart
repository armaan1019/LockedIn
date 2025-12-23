import 'package:flutter/material.dart';
import 'workout_summary_page.dart';

class WorkoutSession {
  final String id;
  final String title;
  final List<ExerciseSession> exercises;
  final DateTime date;

  WorkoutSession({
    required this.id,
    required this.title,
    required this.exercises,
    required this.date,
  });
}

class ExerciseSession {
  final String name;
  final List<SetEntry> sets;

  ExerciseSession({required this.name, required this.sets});
}

class SetEntry {
  int reps;
  double? weight; // optional

  SetEntry({required this.reps, this.weight});
}

class Workout {
  final String title;
  final List<Exercise> exercises;
  final int duration;
  final int calories;

  Workout({
    required this.title,
    required this.exercises,
    required this.duration,
    required this.calories,
  });
}

class Exercise {
  final String name;
  final int sets;
  final int reps;

  Exercise({required this.name, required this.sets, required this.reps});
}

class WorkoutTrackerPage extends StatefulWidget {
  final Workout workout;
  final WorkoutSession? existingSession;

  const WorkoutTrackerPage({
    super.key,
    required this.workout,
    this.existingSession,
  });

  @override
  State<WorkoutTrackerPage> createState() => _WorkoutTrackerPageState();
}

class _WorkoutTrackerPageState extends State<WorkoutTrackerPage> {
  int currentExerciseIndex = 0;
  List<ExerciseSession> exerciseSessions = [];

  final _repsController = TextEditingController();
  final _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.existingSession != null) {
      // Editing an existing workout
      exerciseSessions = widget.existingSession!.exercises;
    } else {
      // New workout
      exerciseSessions = widget.workout.exercises
          .map((e) => ExerciseSession(name: e.name, sets: []))
          .toList();
    }
  }

  void _addSet() {
    final reps = int.tryParse(_repsController.text);
    final weight = double.tryParse(_weightController.text);

    if (reps != null) {
      setState(() {
        exerciseSessions[currentExerciseIndex].sets.add(
          SetEntry(reps: reps, weight: weight),
        );
        _repsController.clear();
        _weightController.clear();
      });
    }
  }

  Future<void> _nextExercise() async {
    if (currentExerciseIndex < exerciseSessions.length - 1) {
      setState(() {
        currentExerciseIndex++;
      });
    }
  }

  void _deleteSet(int index) {
    setState(() {
      exerciseSessions[currentExerciseIndex].sets.removeAt(index);
    });
  }

  void _editSet(SetEntry set) {
    final repsController = TextEditingController(text: set.reps.toString());
    final weightController = TextEditingController(
      text: set.weight?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Set'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: repsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Reps'),
            ),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Weight (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                set.reps = int.tryParse(repsController.text) ?? set.reps;
                set.weight = double.tryParse(weightController.text);
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _finishWorkout() async {
    final session = WorkoutSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: widget.workout.title,
      date: DateTime.now(),
      exercises: exerciseSessions,
    );

    // Push summary page and wait for the user to tap "Done"
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WorkoutSummaryPage(session: session)),
    );

    // Only send session back to parent if user confirms
    if (result != null) {
      Navigator.pop(context, result); // Pass completed session back
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentExercise = exerciseSessions[currentExerciseIndex];

    return Scaffold(
      appBar: AppBar(title: Text(widget.workout.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              currentExercise.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: currentExercise.sets.length,
                itemBuilder: (context, index) {
                  final set = currentExercise.sets[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: Text('Set ${index + 1}'),
                      title: Text('${set.reps} reps'),
                      subtitle: set.weight != null
                          ? Text('${set.weight} lbs')
                          : const Text('No weight'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editSet(set),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteSet(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            TextField(
              controller: _repsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Reps',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Weight (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // PREVIOUS (left)
                Expanded(
                  child: currentExerciseIndex > 0
                      ? OutlinedButton(
                          onPressed: () {
                            setState(() {
                              currentExerciseIndex--;
                            });
                          },
                          child: const Text('Previous'),
                        )
                      : const SizedBox(),
                ),

                const SizedBox(width: 12),

                // ADD SET (center)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _addSet,
                    child: const Text('Add Set'),
                  ),
                ),

                const SizedBox(width: 12),

                // NEXT / FINISH (right)
                Expanded(
                  child: currentExerciseIndex < exerciseSessions.length - 1
                      ? OutlinedButton(
                          onPressed: _nextExercise,
                          child: const Text('Next'),
                        )
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, // visually different
                          ),
                          onPressed: _finishWorkout,
                          child: const Text('Finish Workout'),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
