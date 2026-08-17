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

    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = cred.user!.uid;

      final userDoc = await _firestore.collection('users').doc(uid).get();

      return AppUser.fromMap(uid, userDoc.data()!);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        return null;
      }

      rethrow;
    }
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

      batch.set(_firestore.collection('publicProfile').doc(uid), {
        'username': user.username,
        'bio': '',
        'profileImageUrl': null,
      });

      await batch.commit();
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Stream<AppUser?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      final userDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!userDoc.exists) return null;

      return AppUser.fromMap(firebaseUser.uid, userDoc.data()!);
    });
  }

  Future<void> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No user logged in');
    }

    await reauthenticate(email: email, password: currentPassword);

    await user.updatePassword(newPassword);
  }

  Future<void> deleteFirebaseUser() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No user logged in.');
    }

    await user.delete();
  }

  Future<void> reauthenticate({
    required String email,
    required String password,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No user logged in.');
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );

    await user.reauthenticateWithCredential(credential);
  }
}
