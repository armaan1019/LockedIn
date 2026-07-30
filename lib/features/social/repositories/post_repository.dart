import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';

class PostRepository {
  final FirebaseFirestore _firestore;

  PostRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> addPost({
    required String userId,
    required String username,
    required String content,
  }) async {
    final postRef = _firestore.collection('posts').doc();

    final post = Post(
      id: postRef.id,
      userId: userId,
      username: username,
      content: content,
      createdAt: DateTime.now(),
    );

    await postRef.set(post.toMap());
  }

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
    final posts = await _firestore
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .get();

    for (final post in posts.docs) {
      await _deletePost(post.reference);
    }
  }

  Future<void> _deletePost(
    DocumentReference<Map<String, dynamic>> postRef,
  ) async {
    final comments = await postRef.collection('comments').get();

    for (final doc in comments.docs) {
      await doc.reference.delete();
    }

    final likes = await postRef.collection('likes').get();

    for (final doc in likes.docs) {
      await doc.reference.delete();
    }

    await postRef.delete();
  }
}
