import 'package:flutter/material.dart';
import '../models/workout.dart';

class PastWorkoutsSheet extends StatelessWidget {
  final List<WorkoutSession> sessions;

  const PastWorkoutsSheet({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const Center(child: Text('No past workouts yet.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];

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
                const SizedBox(height: 8),
                ...session.exercises.map((e) => _buildExercise(e)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExercise(ExerciseSession exercise) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(exercise.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        ...exercise.sets.asMap().entries.map((entry) {
          final i = entry.key;
          final set = entry.value;
          return Text(
            'Set ${i + 1}: ${set.reps} reps${set.weight != null ? ' (${set.weight} lbs)' : ''}',
          );
        }),
        const SizedBox(height: 6),
      ],
    );
  }
}