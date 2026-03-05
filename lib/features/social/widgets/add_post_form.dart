import 'package:flutter/material.dart';
import '../models/post.dart';
import '../../../core/services/session_manager.dart';
import 'package:provider/provider.dart';

class AddPostForm extends StatefulWidget {
  final void Function(Post) onSave;

  const AddPostForm({super.key, required this.onSave});

  @override
  State<AddPostForm> createState() => _AddPostFormState();
}

class _AddPostFormState extends State<AddPostForm> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _save() {
    final session = context.read<SessionManager>();
    if (_formKey.currentState!.validate()) {
      final userId = session.currentUserId;
      if (userId == null) {
        return;
      }

      final post = Post(
        content: _messageController.text,
        createdAt: DateTime.now(),
      );
      widget.onSave(post);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Wrap(
          runSpacing: 12,
          children: [
            const Text(
              'New Post',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextFormField(
              controller: _messageController,
              decoration: const InputDecoration(labelText: 'Message'),
              maxLines: 3,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Enter a message' : null,
            ),
            ElevatedButton(onPressed: _save, child: const Text('Post')),
          ],
        ),
      ),
    );
  }
}
