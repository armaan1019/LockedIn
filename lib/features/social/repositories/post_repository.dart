import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';
import 'package:cloud_functions/cloud_functions.dart';

class PostRepository {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  PostRepository({FirebaseFirestore? firestore, FirebaseFunctions? functions})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _functions = functions ?? FirebaseFunctions.instance;

  Stream<List<Post>> getPosts() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Post.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> deleteUserPosts(String userId) async {
    final callable = _functions.httpsCallable('deleteUserPosts');

    await callable.call();
  }

  Future<void> deletePost(String postId) async {
    final callable = _functions.httpsCallable('deletePost');

    await callable.call({'postId': postId});
  }

  Future<String> createPost({required String content}) async {
    final callable = _functions.httpsCallable('createPost');

    final result = await callable.call({'content': content});

    return result.data['postId'] as String;
  }

  Future<bool> reportPost({
    required String postId,
    required String reporterId,
    required String reason,
  }) async {
    final reportRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection('reports')
        .doc(reporterId);

    final existingReport = await reportRef.get();

    if (existingReport.exists) {
      return false;
    }

    await reportRef.set({
      'postId': postId,
      'reporterId': reporterId,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });

    return true;
  }
}
