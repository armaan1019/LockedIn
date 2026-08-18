import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/session_manager.dart';
import '../../social/repositories/user_repository.dart';
import '../../social/models/public_profile.dart';
import '../../social/pages/profile_page.dart';

class BlockedUsersPage extends StatefulWidget {
  const BlockedUsersPage({super.key});

  @override
  State<BlockedUsersPage> createState() => _BlockedUsersPageState();
}

class _BlockedUsersPageState extends State<BlockedUsersPage> {
  final _userRepo = UserRepository();

  Map<String, PublicProfile> _profiles = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final blockedUserIds =
        context.read<SessionManager>().blockedUserIds.toList();

    if (blockedUserIds.isEmpty) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      return;
    }

    try {
      final profiles = <String, PublicProfile>{};

      for (final userId in blockedUserIds) {
        final profile = await _userRepo.getPublicProfile(userId);

        if (profile != null) {
          profiles[userId] = profile;
        }
      }

      if (!mounted) return;

      setState(() {
        _profiles = profiles;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final blockedUserIds =
        context.watch<SessionManager>().blockedUserIds.toList();

    final profiles = blockedUserIds
        .map((id) => _profiles[id])
        .whereType<PublicProfile>()
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blocked Users'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : profiles.isEmpty
          ? const Center(
              child: Text('You have not blocked anyone.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: blockedUserIds.length,
              itemBuilder: (context, index) {
                final userId = blockedUserIds[index];
                final profile = _profiles[userId];

                if (profile == null) {
                  return const SizedBox.shrink();
                }

                return ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      profile.username.isNotEmpty
                          ? profile.username[0].toUpperCase()
                          : '?',
                    ),
                  ),
                  title: Text(profile.username),
                  subtitle: Text(
                    profile.bio.isEmpty ? 'No bio' : profile.bio,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfilePage(userId: userId),
                      ),
                    );
                  },
                );
              },
            )
    );
  }
}