import 'package:flutter/material.dart';
import '../../workout/models/workout_session.dart';

class ActivityTile extends StatelessWidget {
  final WorkoutSession session;

  const ActivityTile({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final names = session.exercises.map((e) => e.name).toList();
    return Card(
      child: ListTile(
        leading: const Icon(Icons.fitness_center),
        title: Text(),
        subtitle: Text(names.length > 3
          ? '${names.take(3).join(' * ')} +${names.length - 3} more'
          : names.join(' * '),
        )
      ),
    );
  }
}
