import 'package:flutter/material.dart';
import 'workout_tracker_page.dart';
import '../models/workout.dart';
import '../widgets/add_workout_form.dart';
import '../widgets/workout_card.dart';
import '../../../core/database/local_db.dart';
import '../widgets/past_workout_sheet.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  final List<Workout> _workouts = [];

  final List<WorkoutSession> _history = [];

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    final rows = await LocalDb.instance.getWorkouts();
    final loaded = rows.map((map) => Workout.fromMap(map)).toList();
    setState(() {
      _workouts.clear();
      _workouts.addAll(loaded);
    });
  }

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
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddWorkoutForm(onSave: _addWorkout),
      ),
    );
  }

  void _showPastWorkouts(Workout workout) async {
    final pastSessions = await LocalDb.instance.getWorkoutSessionsByWorkoutId(workout.id!);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: PastWorkoutsSheet(sessions: pastSessions),
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
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
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
                            content: const Text(
                              'Are you sure you want to delete this workout?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
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
