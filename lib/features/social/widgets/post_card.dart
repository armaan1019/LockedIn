import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/session_manager.dart';
import '../models/post.dart';
import '../repositories/comment_repository.dart';
import '../repositories/like_repository.dart';
import 'comments_sheet.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final String timestampString;
  final String authorName;

  const PostCard({
    super.key,
    required this.post,
    required this.timestampString,
    required this.authorName,
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
