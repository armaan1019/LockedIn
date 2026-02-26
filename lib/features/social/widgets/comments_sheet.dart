import 'package:flutter/material.dart';

class CommentsSheet extends StatelessWidget {
  final int postId;
  final VoidCallback? onAddPressed;

  const CommentsSheet({super.key, required this.postId, this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    final comments = [];
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
                      subtitle: Text(comment.text),
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
                  onPressed: onAddPressed,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
