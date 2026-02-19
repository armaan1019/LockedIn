import 'package:flutter/material.dart';
import '../models/post.dart';

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