import 'package:flutter/material.dart';
import '../widgets/greetings_widget.dart';
import '../widgets/stats_section.dart';
import '../widgets/progress_section.dart';
import '../widgets/recent_activity.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GreetingSection(),
          const SizedBox(height: 24),
          StatsSection(),
          const SizedBox(height: 24),
          ProgressSection(),
          const SizedBox(height: 24),
          RecentActivitySection(),
        ],
      ),
    );
  }
}
