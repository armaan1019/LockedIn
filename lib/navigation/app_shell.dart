import 'package:flutter/material.dart';
import '../core/widgets/bottom_nav.dart';
import '../features/dashboard/pages/dashboard_page.dart';
import '../features/workout/pages/workout_page.dart';
import '../features/diet/pages/diet_page.dart';
import '../features/social/pages/social_feed_page.dart';
import '../features/settings/pages/settings_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    WorkoutPage(),
    DietPage(),
    SocialPage(),
  ];

  final List<String> _titles = ['Dashboard', 'Workout', 'Diet', 'Social Feed'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          if (_currentIndex == 0) // Show settings only on Dashboard
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _pages[_currentIndex],
        ),
      ),
      bottomNavigationBar: AppNavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
