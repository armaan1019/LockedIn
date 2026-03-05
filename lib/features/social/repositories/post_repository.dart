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
}
