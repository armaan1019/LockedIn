import 'package:flutter/material.dart';
import 'widgets/post_card.dart';
import 'widgets/add_post_form.dart';
import 'models/post.dart';

class SocialPage extends StatefulWidget {
  const SocialPage({super.key});

  @override
  State<SocialPage> createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  final List<Post> _posts = [
    Post(
        user: 'Alice',
        message: 'Just finished a 5k run! 🏃‍♀️',
        timestamp: DateTime.now().subtract(const Duration(hours: 2))),
    Post(
        user: 'Bob',
        message: 'Tried the new protein smoothie recipe. Delicious!',
        timestamp: DateTime.now().subtract(const Duration(hours: 1))),
  ];

  void _addPost(Post post) {
    setState(() {
      _posts.insert(0, post); // newest on top
    });
    Navigator.pop(context);
  }

  void _showAddPostSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _posts.length,
          itemBuilder: (context, index) {
            final post = _posts[index];
            return PostCard(post: post, timestampString: _formatTimestamp(post.timestamp));
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
