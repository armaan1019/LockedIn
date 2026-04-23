import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'stat_card.dart';
import '../repositories/stats_repository.dart';

class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  Future<Map<String, int>> _loadStats(BuildContext context) async {
    final statsRepo = context.read<StatsRepository?>();

    final workouts = await statsRepo!.getWorkoutsThisWeek();
    final calories = await statsRepo.getCaloriesToday();

    return {'workouts': workouts, 'calories': calories};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadStats(context),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;

        return Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Workouts',
                value: data['workouts'].toString(),
                subtitle: 'This week',
                icon: Icons.fitness_center,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: StatCard(
                title: 'Calories',
                value: data['calories'].toString(),
                subtitle: 'Today',
                icon: Icons.local_fire_department,
              ),
            ),
          ],
        );
      },
    );
  }
}
