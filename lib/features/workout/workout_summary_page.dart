import 'package:flutter/material.dart';
import 'workout_tracker_page.dart';

class WorkoutSummaryPage extends StatelessWidget {
  final WorkoutSession session;

  const WorkoutSummaryPage({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Summary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              session.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Date: ${session.date.toLocal().toString().split(' ')[0]}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),

            ...session.exercises.map((exercise) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...exercise.sets.asMap().entries.map((entry) {
                          final i = entry.key;
                          final set = entry.value;
                          return Text(
                            'Set ${i + 1}: ${set.reps} reps'
                            '${set.weight != null ? ' @ ${set.weight} lbs' : ''}',
                          );
                        }),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  // Edit workout
                  final updatedSession = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WorkoutTrackerPage(
                        workout: Workout(
                          title: session.title,
                          exercises: session.exercises
                              .map((e) => Exercise(name: e.name, sets: 0, reps: 0))
                              .toList(),
                          duration: 0,
                          calories: 0,
                        ),
                        existingSession: session,
                      ),
                    ),
                  );

                  // If the user finishes after editing, update session in summary
                  if (updatedSession != null && updatedSession is WorkoutSession) {
                    Navigator.pop(context, updatedSession);
                  }
                },
                child: const Text('Edit Workout'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, session); // 🔑 return session
                },
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
