import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/post_card.dart';
import '../widgets/add_post_form.dart';
import '../models/post.dart';
import '../repositories/post_repository.dart';
import '../../../core/services/session_manager.dart';

class SocialPage extends StatefulWidget {
  const SocialPage({super.key});

  @override
  State<SocialPage> createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  final _postRepo = PostRepository();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _addPost(Post post) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Posting...'),
          ],
        ),
      ),
    );

    try {
      await _postRepo.createPost(content: post.content);

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post created'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your post could not be submitted.'),
        ),
      );
    }
  }

  void _showAddPostSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddPostForm(onSave: _addPost),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<List<Post>>(
          stream: _postRepo.getPosts(),
          builder: (context, snapshot) {
            final session = context.watch<SessionManager>();

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final posts = (snapshot.data ?? [])
                .where((post) => !session.blockedUserIds.contains(post.userId))
                .toList();

            if (posts.isEmpty) {
              return const Center(child: Text('No posts yet'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return PostCard(
                  key: ValueKey(post.id),
                  post: post,
                  timestampString: _formatTimestamp(post.createdAt),
                  authorName: post.username,
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPostSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}
