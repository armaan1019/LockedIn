import 'package:flutter/material.dart';

class WorkoutSession {
  final String title;
  final List<ExerciseSession> exercises;
  final DateTime date;

  WorkoutSession({required this.title, required this.exercises, required this.date});
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

  const WorkoutTrackerPage({super.key, required this.workout});

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
    exerciseSessions = widget.workout.exercises
        .map((e) => ExerciseSession(name: e.name, sets: []))
        .toList();
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

  void _nextExercise() {
    if (currentExerciseIndex < exerciseSessions.length - 1) {
      setState(() {
        currentExerciseIndex++;
      });
    } else {
      // Workout finished, maybe save or show summary
      Navigator.pop(context, exerciseSessions);
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
                  return ListTile(
                    leading: Text('Set ${index + 1}'),
                    title: Text('${set.reps} reps'),
                    subtitle: set.weight != null
                        ? Text('${set.weight} lbs')
                        : null,
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
                          onPressed: _nextExercise,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('Finish'),
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
