import 'package:flutter/material.dart';
import 'widgets/post_card.dart';
import 'widgets/add_post_form.dart';
import 'models/post.dart';
import '../../core/local_db.dart';

class SocialPage extends StatefulWidget {
  const SocialPage({super.key});

  @override
  State<SocialPage> createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  List<Post> _posts = [];
  List<String> _usernames = [];
  final _db = LocalDb.instance;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    final rows = await _db.getAllPosts(null);

    setState(() {
      _posts = rows.map((r) => Post.fromMap(r)).toList();
      _usernames = rows.map((r) => r['username'] as String).toList();
    });
  }

  Future<void> _addPost(Post post) async {
    await _db.insertPost(post.toMap());
    await _loadPosts();

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
        child: ListView.builder(
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
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPostSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}
