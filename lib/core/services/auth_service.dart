import '../../features/social/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Future<AppUser?> login(String username, String password) async {
    final usernameDoc = await _firestore
        .collection('usernames')
        .doc(username)
        .get();

    if (!usernameDoc.exists) return null;

    final email = usernameDoc.data()!['email'];

    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = cred.user!.uid;

    final userDoc = await _firestore.collection('users').doc(uid).get();

    return AppUser.fromMap(uid, userDoc.data()!);
  }

  Future<AppUser?> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final usernameDoc = await _firestore
          .collection('usernames')
          .doc(username)
          .get();

      if (usernameDoc.exists) {
        throw Exception("Username already taken");
      }

      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = cred.user!.uid;

      final user = AppUser(id: uid, username: username, email: email);

      final batch = _firestore.batch();

      batch.set(_firestore.collection('users').doc(uid), user.toMap());
      batch.set(_firestore.collection('usernames').doc(username), {
        'uid': uid,
        'email': email,
      });

      await batch.commit();
      return user;
    } catch (e) {
      print("SIGN UP ERROR: $e");
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Stream<AppUser?> get authStateChanges {
    return FirebaseAuth.instance.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) return null;

      return AppUser(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        username: firebaseUser.displayName ?? '',
      );
    });
  }
}
