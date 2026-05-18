import 'package:flutter/material.dart';
import '../../../core/services/session_manager.dart';
import 'package:provider/provider.dart';
import '../widgets/settings_tile.dart';
import '../widgets/settings_section_title.dart';
import '../widgets/settings_switch_tile.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/notification_provider.dart';
import '../../profile/edit_profile_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<void> _showLogoutDialog() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),

            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      context.read<SessionManager>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const SettingsSectionTitle(title: 'Account'),

            SettingsTile(
              icon: Icons.person,
              title: 'Edit Profile',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfilePage()),
                );
              },
            ),

            SettingsTile(
              icon: Icons.lock,
              title: "Change Password",
              onTap: () {},
            ),

            SettingsTile(
              icon: Icons.logout,
              title: "Logout",
              onTap: _showLogoutDialog,
            ),

            const SettingsSectionTitle(title: 'Preferences'),

            SettingsSwitchTile(
              icon: Icons.notifications,
              title: "Notifications",
              value: context.watch<NotificationProvider>().notificationsEnabled,
              onChanged: (value) {
                context.read<NotificationProvider>().toggleNotifications(value);
              },
            ),

            SettingsSwitchTile(
              icon: Icons.dark_mode,
              title: "Dark Mode",
              value: context.watch<ThemeProvider>().isDarkMode,
              onChanged: (value) {
                context.read<ThemeProvider>().toggleTheme(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
