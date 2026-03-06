import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import 'comments_sheet.dart';
import '../repositories/like_repository.dart';
import '../repositories/comment_repository.dart';
import '../../../core/services/session_manager.dart';

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
      setState(() => _liked = !_liked);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to like post. Please try again')),
      );
    }
  }

  void _openComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
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
                Text(
                  widget.authorName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.timestampString,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(widget.post.content),
            const SizedBox(height: 12),
            Row(
              children: [
                GestureDetector(
                  onTap: () => _toggleLike(),
                  child: Icon(
                    _liked ? Icons.favorite : Icons.favorite_border,
                    size: 16,
                    color: _liked ? Colors.red : Colors.grey,
                  ),
                ),
                const SizedBox(width: 4),
                StreamBuilder<int>(
                  stream: _likesRepo.getPostLikesCount(widget.post.id),
                  initialData: 0,
                  builder: (context, snapshot) {
                    final count = snapshot.data ?? 0;
                    return Text('$count');
                  },
                ),
                SizedBox(width: 16),
                GestureDetector(
                  onTap: () => _openComments(context),
                  child: const Icon(
                    Icons.comment,
                    size: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 4),
                StreamBuilder<int>(
                  stream: _commentsRepo.getTotalCommentsForPost(widget.post.id),
                  initialData: 0,
                  builder: (context, snapshot) {
                    final count = snapshot.data ?? 0;
                    return Text('$count');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
