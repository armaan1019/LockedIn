import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment.dart';

class CommentRepository {
  final FirebaseFirestore _firestore;

  CommentRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<Comment>> getPostComments(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Comment.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> addComment({
    required String postId,
    required String content,
    required String userId,
    required String username,
  }) async {
    final comment = Comment(
      id: _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc()
          .id,
      userId: userId,
      username: username,
      postId: postId,
      content: content,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(comment.id)
        .set(comment.toMap());
  }
}
