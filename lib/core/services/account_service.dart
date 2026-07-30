import '../../features/social/models/user.dart';
import '../../features/workout/repositories/workout_repository.dart';
import '../../features/diet/repositories/diet_repository.dart';
import '../../features/social/repositories/post_repository.dart';
import '../../features/social/repositories/comment_repository.dart';
import '../../features/social/repositories/like_repository.dart';
import 'auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountService {
  Future<void> deleteAccount({
    required AppUser user,
    required String password,
    required WorkoutRepository workoutRepository,
    required DietRepository dietRepository,
    required PostRepository postRepository,
    required CommentRepository commentRepository,
    required LikeRepository likeRepository,
  }) async {
    await AuthService.instance.reauthenticate(
      email: user.email,
      password: password,
    );

    await workoutRepository.deleteAll();
    await dietRepository.deleteAll();
    await likeRepository.deleteUserLikes(user.id);
    await commentRepository.deleteUserComments(user.id);
    await postRepository.deleteUserPosts(user.id);

    final firestore = FirebaseFirestore.instance;

    await firestore.collection('users').doc(user.id).delete();

    await firestore.collection('usernames').doc(user.username).delete();

    await AuthService.instance.deleteFirebaseUser();
  }
}
