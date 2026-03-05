import '../../../core/database/local_db.dart';

class LikeRepository {
  final _db = LocalDb.instance;

  Future<void> toggleLike(int postId) async {
    final liked = await _db.isPostLiked(postId);

    if (liked) {
      await _db.deleteLike(postId);
    } else {
      await _db.insertLike(postId);
    }
  }

  Future<bool> isPostLiked(int postId) {
    return _db.isPostLiked(postId);
  }
}
