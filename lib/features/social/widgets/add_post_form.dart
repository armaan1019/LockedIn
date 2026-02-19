import 'package:flutter/material.dart';
import '../models/post.dart';

class AddPostForm extends StatefulWidget {
  final void Function(Post) onSave;

  const AddPostForm({super.key, required this.onSave});

  @override
  State<AddPostForm> createState() => _AddPostFormState();
}

class _AddPostFormState extends State<AddPostForm> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _userController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    _userController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final post = Post(
        user: _userController.text,
        message: _messageController.text,
        timestamp: DateTime.now(),
      );
      widget.onSave(post);
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
              controller: _userController,
              decoration: const InputDecoration(labelText: 'Your Name'),
              validator: (v) => v == null || v.isEmpty ? 'Enter your name' : null,
            ),
            TextFormField(
              controller: _messageController,
              decoration: const InputDecoration(labelText: 'Message'),
              maxLines: 3,
              validator: (v) => v == null || v.isEmpty ? 'Enter a message' : null,
            ),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Post'),
            ),
          ],
        ),
      ),
    );
  }
}