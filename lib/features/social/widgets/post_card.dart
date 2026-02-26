import 'package:flutter/material.dart';
import '../models/post.dart';
import 'comments_sheet.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final String timestampString;
  final String authorName;

  const PostCard({
    super.key,
    required this.post,
    required this.timestampString,
    required this.authorName,
  });

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
              child: CommentsSheet(postId: post.id!),
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
                  authorName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  timestampString,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(post.content),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.thumb_up, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text('Like', style: TextStyle(color: Colors.grey)),
                SizedBox(width: 16),
                Icon(Icons.comment, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                TextButton(
                  onPressed: () => _openComments(context),
                  child: const Text(
                    'Comment',
                    style: TextStyle(color: Colors.grey),
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
