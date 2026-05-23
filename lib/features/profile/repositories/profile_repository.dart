import 'package:cloud_firestore/cloud_firestore.dart';
import '../../social/models/user.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore;
  String userId;

  ProfileRepository({required this.userId, FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get _userDoc =>
      _firestore.collection('users').doc(userId);

  CollectionReference<Map<String, dynamic>> get _usernames =>
      _firestore.collection('usernames');

  Future<void> updateProfile(AppUser user) async {
    await _userDoc.set(user.toMap(), SetOptions(merge: true));
  }

  Future<AppUser?> getProfile() async {
    final doc = await _userDoc.get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return AppUser.fromMap(doc.id, doc.data()!);
  }

  Future<void> updateUsername({
    required String oldUsername,
    required String newUsername,
    required String email,
  }) async {
    if (newUsername == oldUsername) {
      return;
    }

    final trimmedNew = newUsername.trim();
    final trimmedOld = oldUsername.trim();

    final newUsernameDoc = _usernames.doc(trimmedNew);

    final existing = await newUsernameDoc.get();

    if (existing.exists) {
      throw Exception('Username already Taken');
    }

    final batch = _firestore.batch();

    batch.delete(_usernames.doc(trimmedOld));

    batch.set(newUsernameDoc, {'uid': userId, 'email': email});

    batch.update(_userDoc, {'username': trimmedNew});

    await batch.commit();
  }
}
