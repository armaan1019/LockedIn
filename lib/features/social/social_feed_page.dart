import 'package:flutter/material.dart';

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

class Post {
  final String user;
  final String message;
  final DateTime timestamp;

  Post({required this.user, required this.message, required this.timestamp});
}

class PostCard extends StatelessWidget {
  final Post post;
  final String timestampString;

  const PostCard({super.key, required this.post, required this.timestampString});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(post.user,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(timestampString,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            Text(post.message),
            const SizedBox(height: 12),
            Row(
              children: const [
                Icon(Icons.thumb_up, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text('Like', style: TextStyle(color: Colors.grey)),
                SizedBox(width: 16),
                Icon(Icons.comment, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text('Comment', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AddPostForm extends StatefulWidget {
  final void Function(Post) onSave;

  const AddPostForm({super.key, required this.onSave});

  @override
  State<AddPostForm> createState() => _AddPostFormState();
}

class _AddPostFormState extends State<AddPostForm> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _userController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    _userController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final post = Post(
        user: _userController.text,
        message: _messageController.text,
        timestamp: DateTime.now(),
      );
      widget.onSave(post);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Wrap(
          runSpacing: 12,
          children: [
            const Text(
              'New Post',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextFormField(
              controller: _userController,
              decoration: const InputDecoration(labelText: 'Your Name'),
              validator: (v) => v == null || v.isEmpty ? 'Enter your name' : null,
            ),
            TextFormField(
              controller: _messageController,
              decoration: const InputDecoration(labelText: 'Message'),
              maxLines: 3,
              validator: (v) => v == null || v.isEmpty ? 'Enter a message' : null,
            ),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Post'),
            ),
          ],
        ),
      ),
    );
  }
}
