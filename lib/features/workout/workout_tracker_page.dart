import 'package:flutter/material.dart';

class WorkoutSession {
  final String title;
  final List<ExerciseSession> exercises;

  WorkoutSession({required this.title, required this.exercises});
}

class ExerciseSession {
  final String name;
  final List<SetEntry> sets;

  ExerciseSession({required this.name, required this.sets});
}

class SetEntry {
  final int reps;
  final double? weight; // optional

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

  Exercise({
    required this.name, 
    required this.sets, 
    required this.reps});
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
            Text(currentExercise.name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: currentExercise.sets.length,
                itemBuilder: (context, index) {
                  final set = currentExercise.sets[index];
                  return ListTile(
                    leading: Text('Set ${index + 1}'),
                    title: Text('${set.reps} reps'),
                    subtitle:
                        set.weight != null ? Text('${set.weight} kg') : null,
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _repsController,
                    decoration: const InputDecoration(labelText: 'Reps'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    decoration: const InputDecoration(labelText: 'Weight'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addSet,
                )
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _nextExercise,
              child: Text(currentExerciseIndex < exerciseSessions.length - 1
                  ? 'Next Exercise'
                  : 'Finish Workout'),
            )
          ],
        ),
      ),
    );
  }
}
