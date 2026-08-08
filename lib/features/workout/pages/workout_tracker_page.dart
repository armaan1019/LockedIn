import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'workout_summary_page.dart';
import '../models/workout.dart';
import '../models/workout_session.dart';
import '../models/set_entry.dart';
import '../models/exercise_session.dart';
import '../widgets/past_workout_sheet.dart';
import '../repositories/workout_session_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

    _loadWorkoutProgress();
  }

  @override
  void dispose() {
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _loadWorkoutProgress() async {
    final prefs = await SharedPreferences.getInstance();

    final json = prefs.getString('active_workout');

    if (json == null) return;

    final map = jsonDecode(json);

    if (map['workoutId'] != widget.workout.id) return;

    setState(() {
      currentExerciseIndex = map['currentExerciseIndex'];

      exerciseSessions = (map['exercises'] as List)
          .map((e) => ExerciseSession.fromMap(e))
          .toList();
    });
  }

  Future<void> _saveWorkoutProgress() async {
    final prefs = await SharedPreferences.getInstance();

    final map = {
      'workoutId': widget.workout.id,
      'workoutTitle': widget.workout.title,
      'currentExerciseIndex': currentExerciseIndex,
      'exercises': exerciseSessions.map((e) => e.toMap()).toList(),
    };

    await prefs.setString('active_workout', jsonEncode(map));
  }

  Future<void> _showPreviousWorkouts() async {
    final repo = context.read<WorkoutSessionRepository>();

    final sessions = await repo.getPastWorkoutsByWorkoutId(widget.workout.id);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.9,
        child: PastWorkoutsSheet(sessions: sessions),
      ),
    );
  }

  void _showWorkout() {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.9,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              widget.workout.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              '${widget.workout.exercises.length} exercises',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 24),

            ...widget.workout.exercises.map(
              (exercise) => Card(
                margin: const EdgeInsets.only(bottom: 14),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.fitness_center,
                        color: theme.colorScheme.primary,
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Text(
                          exercise.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      Text(
                        '${exercise.sets} × ${exercise.reps}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addSet() async {
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

    await _saveWorkoutProgress();
  }

  Future<void> _nextExercise() async {
    if (currentExerciseIndex < exerciseSessions.length - 1) {
      setState(() {
        currentExerciseIndex++;
      });
    }
  }

  void _deleteSet(int index) async {
    setState(() {
      exerciseSessions[currentExerciseIndex].sets.removeAt(index);
    });

    await _saveWorkoutProgress();
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
            onPressed: () async {
              setState(() {
                set.reps = int.tryParse(repsController.text) ?? set.reps;
                set.weight = double.tryParse(weightController.text);
              });
              Navigator.pop(context);

              await _saveWorkoutProgress();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _finishWorkout() async {
    final session = WorkoutSession(
      id: '',
      workoutId: widget.workout.id,
      date: DateTime.now(),
      exercises: exerciseSessions,
    );

    // Push summary page and wait for the user to tap "Done"
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WorkoutSummaryPage(session: session)),
    );

    // Only send session back to parent if user confirms
    if (!mounted) return;
    if (result != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('active_workout');
      if (!mounted) return;
      Navigator.pop(context, session); // Pass completed session back
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentExercise = exerciseSessions[currentExerciseIndex];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldLeave = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Leave Workout?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Your workout is still in progress. Are you sure you want to leave?',
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Continue'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Leave'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );

        if (shouldLeave == true && mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.workout.title),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'history':
                    _showPreviousWorkouts();
                    break;
                  case 'workout':
                    _showWorkout();
                    break;
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'history',
                  child: Text('Previous Workouts'),
                ),
                PopupMenuItem(value: 'workout', child: Text('View Workout')),
              ],
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                currentExercise.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
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
                        : FilledButton(
                            onPressed: _finishWorkout,
                            child: const Text('Finish'),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
