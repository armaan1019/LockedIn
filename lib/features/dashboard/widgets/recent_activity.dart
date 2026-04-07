import 'package:flutter/material.dart';
import 'activity_tile.dart';
import '../../workout/models/workout.dart';

class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    Workout workout = Workout(
      id: '',
      title: 'Chest Day',
      calories: 50,
      duration: 60,
      exercises: [],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ActivityTile(workout: workout),
        ActivityTile(
          title: 'Morning Run',
          subtitle: '3.2 miles',
          icon: Icons.directions_run,
        ),
      ],
    );
  }
}
