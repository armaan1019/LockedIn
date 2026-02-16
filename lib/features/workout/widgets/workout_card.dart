import 'package:flutter/material.dart';
import '../models/workout.dart';

class WorkoutCard extends StatelessWidget {
  final Workout workout;
  final VoidCallback onStart;
  final VoidCallback onPastWorkouts;
  final void Function(Workout)? onEdit; 
  final VoidCallback? onDelete; 

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