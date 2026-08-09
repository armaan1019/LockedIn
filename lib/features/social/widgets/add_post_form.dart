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
      final user = session.currentUser;
      if (user == null) {
        return;
      }

      final post = Post(
        id: '',
        userId: user.id,
        username: user.username,
        content: _messageController.text.trim(),
        createdAt: DateTime.now(),
      );
      widget.onSave(post);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
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
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Enter a message';
                  }

                  if (v.trim().length > 500) {
                    return 'Post must be 500 characters or less';
                  }

                  return null;
                },
              ),
              ElevatedButton(onPressed: _save, child: const Text('Post')),
            ],
          ),
        ),
      ),
    );
  }
}
