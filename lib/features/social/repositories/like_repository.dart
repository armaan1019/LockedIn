import 'package:cloud_firestore/cloud_firestore.dart';

class LikeRepository {
  final FirebaseFirestore _firestore;

  LikeRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> toggleLike({
    required String postId,
    required String userId,
  }) async {
    final likeDocRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(userId);

    final liked = await isPostLiked(postId: postId, userId: userId);

    if (liked) {
      await likeDocRef.delete();
    } else {
      await likeDocRef.set({
        'userId': userId,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  Future<bool> isPostLiked({
    required String postId,
    required String userId,
  }) async {
    final likeDocRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(userId);

    final snapshot = await likeDocRef.get();
    return snapshot.exists;
  }

  Stream<int> getPostLikesCount(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
