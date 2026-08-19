import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment.dart';
import 'package:cloud_functions/cloud_functions.dart';

class CommentRepository {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  CommentRepository({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _functions = functions ?? FirebaseFunctions.instance;

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

  Stream<int> getTotalCommentsForPost(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<void> deleteUserComments(String userId) async {
    final posts = await _firestore.collection('posts').get();

    for (final post in posts.docs) {
      final comments = await post.reference
          .collection('comments')
          .where('userId', isEqualTo: userId)
          .get();

      for (final comment in comments.docs) {
        await comment.reference.delete();
      }
    }
  }

  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    final callable = _functions.httpsCallable('deleteComment');

    await callable.call({'postId': postId, 'commentId': commentId});
  }

  Future<bool> reportComment({
    required String postId,
    required String commentId,
    required String reporterId,
    required String reason,
  }) async {
    final reportRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .collection('reports')
        .doc(reporterId);

    final existingReport = await reportRef.get();

    if (existingReport.exists) {
      return false;
    }

    await reportRef.set({
      'commentId': commentId,
      'reporterId': reporterId,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });

    return true;
  }
}
