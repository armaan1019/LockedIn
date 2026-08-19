import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/comment.dart';
import '../repositories/comment_repository.dart';
import '../../../core/services/session_manager.dart';
import '../pages/profile_page.dart';

class CommentsSheet extends StatefulWidget {
  final String postId;

  const CommentsSheet({super.key, required this.postId});

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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _deleteComment(Comment comment) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete comment?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('This comment will be permanently deleted.'),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (shouldDelete != true || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Deleting...'),
          ],
        ),
      ),
    );

    try {
      await _repo.deleteComment(postId: widget.postId, commentId: comment.id);

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      Navigator.pop(context); // loading dialog
      Navigator.pop(context); // comments sheet

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete comment. Please try again.'),
        ),
      );
    }
  }

  Future<void> _showReportDialog(Comment comment) async {
    final reporterId = context.read<SessionManager>().currentUserId;

    if (reporterId == null) return;

    final reasons = [
      'Spam',
      'Harassment or bullying',
      'Hateful or abusive content',
      'Sexual or explicit content',
      'Violence',
      'Other',
    ];

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        bool isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return PopScope(
              canPop: !isSubmitting,
              child: AlertDialog(
                title: const Text('Report Comment'),
                content: isSubmitting
                    ? const SizedBox(
                        height: 80,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: reasons.map((reason) {
                          return ListTile(
                            title: Text(reason),
                            onTap: () async {
                              setDialogState(() {
                                isSubmitting = true;
                              });

                              try {
                                final wasReported = await _repo.reportComment(
                                  postId: widget.postId,
                                  commentId: comment.id,
                                  reporterId: reporterId,
                                  reason: reason,
                                );

                                if (!dialogContext.mounted) return;

                                Navigator.pop(dialogContext, wasReported);

                                if (mounted) {
                                  Navigator.pop(context);
                                }
                              } catch (e) {
                                if (!dialogContext.mounted) return;

                                Navigator.pop(dialogContext);

                                if (mounted) {
                                  Navigator.pop(context);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Failed to report comment. Please try again.',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                          );
                        }).toList(),
                      ),
              ),
            );
          },
        );
      },
    );

    if (!mounted || result == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result
              ? 'Comment reported successfully'
              : 'You have already reported this comment.',
        ),
      ),
    );
  }

  String timeAgo(DateTime createdAt) {
    final diff = DateTime.now().difference(createdAt);

    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${createdAt.month}/${createdAt.day}/${createdAt.year}';
  }

  Future<void> _addComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Commenting...'),
          ],
        ),
      ),
    );

    try {
      await _repo.addComment(postId: widget.postId, content: text);

      if (!mounted) return;

      Navigator.pop(context);

      _controller.clear();
    } catch (e) {
      if (!mounted) return;

      Navigator.pop(context); // loading dialog
      Navigator.pop(context); // comments sheet

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Comment rejected')));
    }
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
          child: StreamBuilder<List<Comment>>(
            stream: _repo.getPostComments(widget.postId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                debugPrint('Comments error: ${snapshot.error}');
              }

              final session = context.watch<SessionManager>();

              final comments = (snapshot.data ?? [])
                  .where(
                    (comment) =>
                        !session.blockedUserIds.contains(comment.userId),
                  )
                  .toList();

              if (comments.isEmpty) {
                return const Center(child: Text('No Comments yet'));
              } else {
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];

                    return ListTile(
                      title: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProfilePage(userId: comment.userId),
                            ),
                          );
                        },
                        child: Text(
                          comment.username,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      subtitle: Text(comment.content),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            timeAgo(comment.createdAt),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'delete') {
                                await _deleteComment(comment);
                              } else if (value == 'report') {
                                await _showReportDialog(comment);
                              }
                            },
                            itemBuilder: (context) {
                              final isOwnComment =
                                  comment.userId == session.currentUserId;

                              return [
                                if (isOwnComment)
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete'),
                                  )
                                else
                                  const PopupMenuItem(
                                    value: 'report',
                                    child: Text('Report'),
                                  ),
                              ];
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),

        /// add comment input
        SafeArea(
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
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
