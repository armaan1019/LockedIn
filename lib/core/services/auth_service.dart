import '../../features/social/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _currentUserId;
  String? get currentUserId => _currentUserId;

  Future<AppUser?> login(String username, String password) async {
    final query = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .where('password', isEqualTo: password)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    final doc = query.docs.first;
    final user = AppUser.fromMap(doc.id, doc.data());
    _currentUserId = user.id;
    return user;
  }

  Future<AppUser?> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    final existing = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      return null; // username taken
    }

    const uuid = Uuid();
    final id = uuid.v6();
    final user = AppUser(id: id, username: username, email: email);

    await _firestore.collection('users').doc(id).set({
      ...user.toMap(), 
      password: password,
    });
    _currentUserId = id;
    return user;
  }

  void logout() {
    _currentUserId = null;
  }
}
