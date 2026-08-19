import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'workout_tracker_page.dart';
import '../models/workout.dart';
import '../widgets/add_workout_form.dart';
import '../widgets/workout_card.dart';
import '../widgets/past_workout_sheet.dart';
import '../models/workout_session.dart';
import '../repositories/workout_repository.dart';
import '../repositories/workout_session_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  final List<Workout> _workouts = [];
  String? _activeWorkoutId;

  bool _isLoading = true;
  bool _isShowingPastWorkouts = false;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _updateWorkout(Workout workout) async {
    final workoutRepo = context.read<WorkoutRepository?>();

    if (workoutRepo == null) return;

    await workoutRepo.updateWorkout(workout);
    await _loadWorkouts();

    if (!mounted) return;

    Navigator.pop(context);
  }

  Future<void> _deleteWorkout(String id) async {
    final workoutRepo = context.read<WorkoutRepository?>();

    if (workoutRepo == null) return;

    await workoutRepo.deleteWorkout(id);
    await _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    final workoutRepo = context.read<WorkoutRepository?>();

    if (workoutRepo == null) return;

    setState(() => _isLoading = true);

    final loaded = await workoutRepo.getWorkouts();
    final prefs = await SharedPreferences.getInstance();

    final json = prefs.getString('active_workout');

    String? activeWorkoutId;

    if (json != null) {
      final map = jsonDecode(json);

      activeWorkoutId = map['workoutId'];
    }

    setState(() {
      _workouts.clear();
      _workouts.addAll(loaded);
      _activeWorkoutId = activeWorkoutId;
      _isLoading = false;
    });
  }

  Future<void> _startWorkout(Workout workout) async {
    final workoutSessionsRepo = context.read<WorkoutSessionRepository?>();

    if (workoutSessionsRepo == null) return;

    final prefs = await SharedPreferences.getInstance();

    final json = prefs.getString('active_workout');

    if (json != null) {
      final map = jsonDecode(json);
      if (map['workoutId'] == workout.id) {
        if (!mounted) return;

        await _openWorkoutTracker(workout);

        return;
      }

      if (!mounted) return;

      final shouldContinue = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Workout in Progress'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${map['workoutTitle']} is already in progress.\n\n'
                'Would you like to continue it or discard it?',
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Discard'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Continue'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

      if (shouldContinue == true) {
        final activeWorkout = _workouts
            .where((w) => w.id == map['workoutId'])
            .firstOrNull;

        if (!mounted) return;

        if (activeWorkout == null) {
          await prefs.remove('active_workout');

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'The workout that was in progress has been deleted',
              ),
            ),
          );

          return;
        }

        await _openWorkoutTracker(activeWorkout);

        return;
      }

      if (shouldContinue == null) return;

      if (shouldContinue == false) {
        await prefs.remove('active_workout');

        if (!mounted) return;

        await _openWorkoutTracker(workout);

        return;
      }
    }

    if (!mounted) return;

    await _openWorkoutTracker(workout);
  }

  Future<void> _openWorkoutTracker(Workout workout) async {
    final workoutSessionsRepo = context.read<WorkoutSessionRepository>();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutTrackerPage(workout: workout),
      ),
    );

    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('active_workout');

    if (!mounted) return;

    setState(() {
      if (json == null) {
        _activeWorkoutId = null;
      } else {
        final map = jsonDecode(json);
        _activeWorkoutId = map['workoutId'];
      }
    });

    if (result is WorkoutSession) {
      await workoutSessionsRepo.addWorkoutSession(result);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Congrats! You completed ${workout.title}')),
      );
    }
  }

  Future<void> _addWorkout(Workout workout) async {
    final workoutRepo = context.read<WorkoutRepository?>();

    if (workoutRepo == null) return;

    await workoutRepo.addWorkout(workout);
    await _loadWorkouts();

    if (!mounted) return;
    Navigator.pop(context);
  }

  void _showAddWorkoutSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddWorkoutForm(onSave: _addWorkout),
      ),
    );
  }

  Future<void> _showPastWorkouts(Workout workout) async {
    if (_isShowingPastWorkouts) return;

    _isShowingPastWorkouts = true;

    try {
      final workoutSessionsRepo = context.read<WorkoutSessionRepository?>();

      if (workoutSessionsRepo == null) return;

      final pastSessions = await workoutSessionsRepo.getPastWorkoutsByWorkoutId(
        workout.id,
      );

      if (!mounted) return;

      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: PastWorkoutsSheet(sessions: pastSessions),
        ),
      );
    } finally {
      _isShowingPastWorkouts = false;
    }
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
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _workouts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.fitness_center,
                              size: 72,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No workouts yet',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the + button below to create your first workout.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 96),
                        itemCount: _workouts.length,
                        itemBuilder: (context, index) {
                          final w = _workouts[index];
                          return WorkoutCard(
                            workout: w,
                            activeWorkout: w.id == _activeWorkoutId,
                            onStart: () => _startWorkout(w),
                            onPastWorkouts: () => _showPastWorkouts(w),
                            onEdit: (workoutToEdit) {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) => Padding(
                                  padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(
                                      context,
                                    ).viewInsets.bottom,
                                  ),
                                  child: AddWorkoutForm(
                                    existingWorkout: workoutToEdit,
                                    onSave: (updatedWorkout) {
                                      _updateWorkout(updatedWorkout);
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
                                  content: const Text(
                                    'Are you sure you want to delete this workout?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        await _deleteWorkout(w.id);
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
