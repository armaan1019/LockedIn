import 'package:flutter/material.dart';
import 'activity_tile.dart';
import '../repositories/dashboard_repository.dart';
import 'package:provider/provider.dart';
import '../../workout/models/workout_session.dart';

class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({super.key});

  Future<Map<String, dynamic>> _loadData(BuildContext context) async {
    final dashboardRepo = context.read<DashboardRepository?>();

    final sessions = await dashboardRepo!.getRecentWorkouts();

    final titles = await Future.wait(
      sessions.map((s) => dashboardRepo.getWorkoutTitle(s.workoutId)),
    );

    return {'sessions': sessions, 'titles': titles};
  }

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

        FutureBuilder(
          future: _loadData(context),
          builder: (context, snapshot) {
            if(!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!;
            final List<WorkoutSession> sessions = data['sessions'];
            final List<String> titles = data['titles'];

            return Column(
              children: List.generate(sessions.length, (i) {
                return ActivityTile(
                  session: sessions[i],
                  title: titles[i],
                );
              })
            );
          },
        )
      ],
    );
  }
}
