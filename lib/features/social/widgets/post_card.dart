import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/session_manager.dart';
import '../models/post.dart';
import '../repositories/comment_repository.dart';
import '../repositories/like_repository.dart';
import 'comments_sheet.dart';
import '../repositories/post_repository.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final String timestampString;
  final String authorName;
  final VoidCallback onDeleted;

  const PostCard({
    super.key,
    required this.post,
    required this.timestampString,
    required this.authorName,
    required this.onDeleted,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _liked = false;

  final _likesRepo = LikeRepository();
  final _commentsRepo = CommentRepository();

  @override
  void initState() {
    super.initState();
    _loadLikeState();
  }

  bool get _isOwner {
    final session = context.read<SessionManager>();
    return session.currentUserId == widget.post.userId;
  }

  Future<void> _loadLikeState() async {
    final session = context.read<SessionManager>();
    final userId = session.currentUserId;

    if (userId == null) return;

    final liked = await _likesRepo.isPostLiked(
      postId: widget.post.id,
      userId: userId,
    );

    if (!mounted) return;

    setState(() {
      _liked = liked;
    });
  }

  Future<void> _toggleLike() async {
    final session = context.read<SessionManager>();
    final userId = session.currentUserId;

    if (userId == null) return;

    try {
      await _likesRepo.toggleLike(postId: widget.post.id, userId: userId);

      setState(() {
        _liked = !_liked;
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to like post. Please try again.')),
      );
    }
  }

  void _openComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.35,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: CommentsSheet(postId: widget.post.id),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete() async {
    final postRepo = context.read<PostRepository>();

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete post?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('This post will be permanently deleted.'),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.pop(dialogContext, true);
                      },
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      await postRepo.deletePost(widget.post.id);

      if (!mounted) return;

      widget.onDeleted();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete post. Please try again.'),
        ),
      );
    }
  }

  Future<void> _showReportDialog() async {
    final postRepo = context.read<PostRepository>();
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
                title: const Text('Report Post'),
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
                                final wasReported = await postRepo.reportPost(
                                  postId: widget.post.id,
                                  reporterId: reporterId,
                                  reason: reason,
                                );

                                if (!dialogContext.mounted) return;

                                Navigator.pop(dialogContext, wasReported);
                              } catch (e) {
                                if (!dialogContext.mounted) return;

                                setDialogState(() {
                                  isSubmitting = false;
                                });

                                ScaffoldMessenger.of(
                                  dialogContext,
                                ).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Failed to report post. Please try again.',
                                    ),
                                  ),
                                );
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
              ? 'Post reported successfully'
              : 'You have already reported this post.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: theme.colorScheme.primary.withOpacity(.12),
                  child: Text(
                    widget.authorName.isNotEmpty
                        ? widget.authorName[0].toUpperCase()
                        : "?",
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.authorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.timestampString,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'delete') {
                      _confirmDelete();
                    } else if (value == 'report') {
                      _showReportDialog();
                    }
                  },
                  itemBuilder: (context) {
                    if (_isOwner) {
                      return const [
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline),
                              SizedBox(width: 12),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ];
                    }

                    return const [
                      PopupMenuItem(
                        value: 'report',
                        child: Row(
                          children: [
                            Icon(Icons.flag_outlined),
                            SizedBox(width: 12),
                            Text('Report'),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// POST CONTENT
            Text(
              widget.post.content,
              style: const TextStyle(fontSize: 15, height: 1.45),
            ),

            const SizedBox(height: 16),

            Divider(color: Colors.grey.shade300, height: 1),

            const SizedBox(height: 4),

            /// ACTIONS
            Row(
              children: [
                Expanded(
                  child: StreamBuilder<int>(
                    stream: _likesRepo.getPostLikesCount(widget.post.id),
                    initialData: 0,
                    builder: (context, snapshot) {
                      return _PostActionButton(
                        icon: _liked ? Icons.favorite : Icons.favorite_border,
                        color: _liked ? Colors.red : Colors.grey.shade700,
                        label: "${snapshot.data ?? 0}",
                        onTap: _toggleLike,
                      );
                    },
                  ),
                ),

                Expanded(
                  child: StreamBuilder<int>(
                    stream: _commentsRepo.getTotalCommentsForPost(
                      widget.post.id,
                    ),
                    initialData: 0,
                    builder: (context, snapshot) {
                      return _PostActionButton(
                        icon: Icons.mode_comment_outlined,
                        color: Colors.grey.shade700,
                        label: "${snapshot.data ?? 0}",
                        onTap: () => _openComments(context),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PostActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _PostActionButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
