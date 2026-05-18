import 'package:flutter/material.dart';
import '../../../core/services/session_manager.dart';
import 'package:provider/provider.dart';
import '../widgets/settings_tile.dart';
import '../widgets/settings_section_title.dart';
import '../widgets/settings_switch_tile.dart';
import '../../../core/providers/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;

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
              onTap: () {},
            ),

            SettingsTile(
              icon: Icons.lock,
              title: "Change Password",
              onTap: () {},
            ),

            SettingsTile(
              icon: Icons.logout,
              title: "Logout",
              onTap: () {
                context.read<SessionManager>().logout();
                Navigator.pop(context);
              },
            ),

            const SettingsSectionTitle(title: 'Preferences'),

            SettingsSwitchTile(
              icon: Icons.notifications,
              title: "Notifications",
              value: notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  notificationsEnabled = value;
                });
              },
            ),

            SettingsSwitchTile(
              icon: Icons.dark_mode,
              title: "Dark Mode",
              value: context.watch<ThemeProvider>().isDarkMode,
              onChanged: (value) {
                setState(() {
                  context.read<ThemeProvider>().toggleTheme(value);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
