import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/user_repository.dart';
import '../models/public_profile.dart';
import '../../../core/services/session_manager.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _userRepo = UserRepository();
  PublicProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final profile = await _userRepo.getPublicProfile(widget.userId);

      if (!mounted) return;

      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _blockUser() async {
    final currentUser = context.read<SessionManager>().currentUser;

    if (currentUser == null) return;

    final shouldBlock = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Block User?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Are you sure you want to block @${_profile!.username}?'),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      child: const Text('Block'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (shouldBlock != true) return;

    try {
      await _userRepo.blockUser(
        userId: currentUser.id,
        blockedUserId: widget.userId,
      );

      if (!mounted) return;

      context.read<SessionManager>().addBlockedUser(widget.userId);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User blocked')));

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to block user')));
    }
  }

  Future<void> _unblockUser() async {
    final currentUser = context.read<SessionManager>().currentUser;

    if (currentUser == null) return;

    try {
      await _userRepo.unblockUser(
        userId: currentUser.id,
        blockedUserId: widget.userId,
      );

      if (!mounted) return;

      context.read<SessionManager>().removeBlockedUser(widget.userId);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User unblocked')));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to unblock user')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isBlocked = context.watch<SessionManager>().blockedUserIds.contains(
      widget.userId,
    );

    if (_profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("No User Found")),
        body: Center(child: Text('User not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 45,
                child: Text(
                  _profile!.username.isNotEmpty
                      ? _profile!.username[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                _profile!.username,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                _profile!.bio.isEmpty ? 'No bio' : _profile!.bio,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 32),
              if(widget.userId != context.read<SessionManager>().currentUserId) ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: isBlocked ? _unblockUser : _blockUser,
                    child: Text(isBlocked ? 'Unblock' : 'Block'),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
