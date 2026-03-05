import 'package:flutter/material.dart';
import '../widgets/post_card.dart';
import '../widgets/add_post_form.dart';
import '../models/post.dart';
import '../repositories/post_repository.dart';

class SocialPage extends StatefulWidget {
  const SocialPage({super.key});

  @override
  State<SocialPage> createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  List<Post> _posts = [];
  List<String> _usernames = [];
  final _postRepo = PostRepository();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _addPost(Post post) async {
    await _postRepo.addPost(
      userId: post.userId,
      username: post.username,
      content: post.content,
    );

    if (mounted) {
      Navigator.pop(context);
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
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final post = snapshot.data ?? [];

            if (post.isEmpty) {
              return const Center(child: Text('No posts yet'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                return PostCard(
                  post: post,
                  timestampString: _formatTimestamp(post.createdAt),
                  authorName: _usernames[index],
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
