import 'package:flutter/material.dart';
import '../../../core/local_db.dart';

class CommentsSheet extends StatefulWidget {
  final int postId;
  final VoidCallback? onAddPressed;

  const CommentsSheet({super.key, required this.postId, this.onAddPressed});

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final TextEditingController _controller = TextEditingController();

  List<Map<String, Object?>> comments = [];

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  String timeAgo(int timestamp) {
    final commentTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final diff = DateTime.now().difference(commentTime);

    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${commentTime.month}/${commentTime.day}/${commentTime.year}';
  }

  Future<void> _loadComments() async {
    final rows = await LocalDb.instance.getCommentsForPost(widget.postId);

    setState(() {
      comments = rows;
    });
  }

  Future<void> _addComment() async {
    final text = _controller.text.trim();
    final username = await LocalDb.instance.getCurrentUsername();
    if (text.isEmpty) return;

    await LocalDb.instance.insertComment({
      'post_id': widget.postId,
      'username': username,
      'content': text,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });

    _controller.clear();

    await _loadComments();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// drag handle
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            borderRadius: BorderRadius.circular(10),
          ),
        ),

        /// comments list
        Expanded(
          child: comments.isEmpty
              ? const Center(child: Text("No comments yet"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];

                    return ListTile(
                      title: Text(comment['username'] as String),
                      subtitle: Text(comment['content'] as String),
                      trailing: Text(
                        timeAgo(comment['created_at'] as int),
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    );
                  },
                ),
        ),

        /// add comment input
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Add a comment...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _addComment,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
