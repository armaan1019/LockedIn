import 'package:cloud_firestore/cloud_firestore.dart';
import '../../social/models/user.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore;
  String userId;

  ProfileRepository({required this.userId, FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get _userDoc =>
      _firestore.collection('users').doc(userId);

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
}
