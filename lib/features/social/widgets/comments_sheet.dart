import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/comment.dart';
import '../repositories/comment_repository.dart';
import '../services/session_manager.dart';

class CommentsSheet extends StatefulWidget {
  final int postId;

  const CommentsSheet({super.key, required this.postId,});

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final TextEditingController _controller = TextEditingController();
  final _repo = CommentRepository();

  List<Comment> comments = [];

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
    final rows = await _repo.getPostComments(widget.postId);

    setState(() {
      comments = rows;
    });
  }

  Future<void> _addComment() async {
    final session = context.read<SessionManager>();
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    await _repo.addComment(widget.postId, text, session.currentUserId!);

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
                      title: Text(comment.username),
                      subtitle: Text(comment.content),
                      trailing: Text(
                        timeAgo(comment.createdAt.millisecondsSinceEpoch),
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
