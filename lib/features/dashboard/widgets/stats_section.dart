import 'package:flutter/material.dart';
import 'stat_card.dart';

class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: StatCard(
            title: 'Workouts',
            value: '4',
            subtitle: 'This week',
            icon: Icons.fitness_center,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Calories',
            value: '1,820',
            subtitle: 'Burned',
            icon: Icons.local_fire_department,
          ),
        ),
      ],
    );
  }
}