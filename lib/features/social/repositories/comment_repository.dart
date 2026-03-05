import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment.dart';

class CommentRepository {
  final _db = LocalDb.instance;

  Future<List<Comment>> getPostComments(int postId) async {
    return _db.getCommentsByPostId(postId);
  }

  Future<void> addComment(int postId, String content, String userId) async {
    await _db.insertComment(
      Comment(
        postId: postId,
        content: content,
        userId: userId,
        username: await _db.getCurrentUsername(),
        createdAt: DateTime.now(),
      ).toMap(),
    );
  }
}
