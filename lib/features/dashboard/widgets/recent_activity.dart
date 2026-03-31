import 'package:flutter/material.dart';
import 'activity_tile.dart';

class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ActivityTile(
          title: 'Upper Body Workout',
          subtitle: '45 min · Chest & Triceps',
          icon: Icons.fitness_center,
        ),
        ActivityTile(
          title: 'Morning Run',
          subtitle: '3.2 miles',
          icon: Icons.directions_run,
        ),
      ],
    );
  }
}
