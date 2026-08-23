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

  Future<void> deletePublicProfile(String userId) async {
    await _firestore.collection('publicProfiles').doc(userId).delete();
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

  Future<Set<String>> getBlockedUsers(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('blockedUsers')
        .get();

    return snapshot.docs.map((doc) => doc.id).toSet();
  }

  Future<void> unblockUser({
    required String userId,
    required String blockedUserId,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('blockedUsers')
        .doc(blockedUserId)
        .delete();
  }

  Future<void> deleteUserBlockedUsers(String userId) async {
    final blockedRef = await _firestore
        .collection('users')
        .doc(userId)
        .collection('blockedUsers')
        .get();

    final batch = _firestore.batch();

    for (final doc in blockedRef.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
