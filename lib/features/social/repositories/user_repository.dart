import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/public_profile.dart';

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<PublicProfile?> getPublicProfile(String userId) async {
    final doc = await _firestore.collection('publicProfiles').doc(userId).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return PublicProfile.fromMap(doc.id, doc.data()!);
  }

  Future<void> blockUser({
    required String userId,
    required String blockedUserId,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('blockedUsers')
        .doc(blockedUserId)
        .set({'blockedAt': FieldValue.serverTimestamp()});
  }
}
