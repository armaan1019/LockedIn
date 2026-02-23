import '../models/user.dart';
import '../../../core/local_db.dart';
import 'package:uuid/uuid.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  String? _currentUserId;
  String? get currentUserId => _currentUserId;
  Future<User?> login(String username, String password) async {
    final db = await LocalDb.instance.db;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
      limit: 1,
    );

    if (result.isEmpty) return null;
    final user = User.fromMap(result.first);
    _currentUserId = user.id;
    return user;
  }

  Future<User?> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    final db = await LocalDb.instance.db;

    final existing = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (existing.isNotEmpty) {
      return null; // username taken
    }

    const uuid = Uuid();
    final id = uuid.v6();

    final user = User(id: id, username: username, email: email, password: password);
    await db.insert('users', user.toMap());
    _currentUserId = id;
    return user;
  }

  void logout() {
    _currentUserId = null;
  }
}
