import 'package:flutter/material.dart';
import '../../../core/services/session_manager.dart';
import 'package:provider/provider.dart';
import '../widgets/settings_tile.dart';
import '../widgets/settings_section_title.dart';
import '../widgets/settings_switch_tile.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/notification_provider.dart';
import '../../profile/pages/edit_profile_page.dart';
import '../../profile/pages/change_password_page.dart';
import '../../../core/services/account_service.dart';
import '../../workout/repositories/workout_repository.dart';
import '../../diet/repositories/diet_repository.dart';
import '../../social/repositories/post_repository.dart';
import '../../social/repositories/comment_repository.dart';
import '../../social/repositories/like_repository.dart';
import 'blocked_users_page.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../social/repositories/user_repository.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDeleting = false;

  Future<void> _openWebsite(String url) async {
    final uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open this page.')),
      );
    }
  }

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
      if (!mounted) return;
      await context.read<SessionManager>().logout();

      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  Future<void> _showDeleteAccountDialog() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This action cannot be undone. Are you sure you want to permanenetly delete your account',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    if (!mounted) return;

    final password = await _showPasswordDialog();

    if (password == null) return;

    if (!mounted) return;

    final session = context.read<SessionManager>();

    final user = session.currentUser;

    if (user == null) return;

    if (!mounted) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      await context.read<AccountService>().deleteAccount(
        user: user,
        password: password,
        workoutRepository: context.read<WorkoutRepository>(),
        dietRepository: context.read<DietRepository>(),
        postRepository: context.read<PostRepository>(),
        commentRepository: context.read<CommentRepository>(),
        likeRepository: context.read<LikeRepository>(),
        userRepository: context.read<UserRepository>(),
      );

      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      context.read<SessionManager>().clearUser();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Delete failed: $e")));
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  Future<String?> _showPasswordDialog() async {
    final controller = TextEditingController();

    try {
      final password = await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Confirm Password'),
            content: TextField(
              controller: controller,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context, controller.text);
                },
                child: const Text('Delete'),
              ),
            ],
          );
        },
      );

      await Future.delayed(Duration.zero);
      return password;
    } finally {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
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
                      MaterialPageRoute(
                        builder: (_) => const EditProfilePage(),
                      ),
                    );
                  },
                ),

                SettingsTile(
                  icon: Icons.lock,
                  title: "Change Password",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChangePasswordPage(),
                      ),
                    );
                  },
                ),

                SettingsTile(
                  icon: Icons.logout,
                  title: "Logout",
                  onTap: _showLogoutDialog,
                ),

                SettingsTile(
                  icon: Icons.block,
                  title: 'Blocked Users',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BlockedUsersPage(),
                      ),
                    );
                  },
                ),

                SettingsTile(
                  icon: Icons.delete_forever,
                  title: "Delete Account",
                  onTap: _showDeleteAccountDialog,
                ),

                const SettingsSectionTitle(title: 'Preferences'),

                SettingsSwitchTile(
                  icon: Icons.notifications,
                  title: "Notifications",
                  value: context
                      .watch<NotificationProvider>()
                      .notificationsEnabled,
                  onChanged: (value) {
                    context.read<NotificationProvider>().toggleNotifications(
                      value,
                    );
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

                const SettingsSectionTitle(title: 'Support and Privacy'),

                SettingsTile(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () {
                    _openWebsite('https://lockedinfitness.app/support');
                  },
                ),

                SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () {
                    _openWebsite('https://lockedinfitness.app/privacy');
                  },
                ),
              ],
            ),
          ),
        ),

        if (_isDeleting)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black45,
              child: Center(
                child: Container(
                  width: 280,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 28,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Deleting Account',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Deleting your account...\nThis may take a few seconds.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
