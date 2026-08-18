import 'package:flutter/material.dart';
import '../../features/social/models/user.dart';
import 'auth_service.dart';
import '../../features/social/repositories/user_repository.dart';

class SessionManager extends ChangeNotifier {
  AppUser? _currentUser;
  bool _initialized = false;
  Set<String> _blockedUserIds = {};
  final _userRepo = UserRepository();
  bool _blockedUsersLoaded = false;

  bool get blockedUsersLoaded => _blockedUsersLoaded;
  bool get initialized => _initialized;
  AppUser? get currentUser => _currentUser;
  String? get currentUserId => _currentUser?.id;
  bool get isLoggedIn => _currentUser != null;
  Set<String> get blockedUserIds => _blockedUserIds;

  SessionManager() {
    AuthService.instance.authStateChanges.listen((user) async {
      _currentUser = user;

      if (user != null) {
        await loadBlockedUsers();
      } else {
        _blockedUserIds = {};
      }

      _blockedUsersLoaded = true;
      _initialized = true;
      notifyListeners();
    });
  }

  Future<bool> login(String username, String password) async {
    return await AuthService.instance.login(username, password) != null;
  }

  Future<bool> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    final user = await AuthService.instance.signUp(
      username: username,
      email: email,
      password: password,
    );

    if (user != null) {
      _currentUser = user;
      notifyListeners();
      return true;
    }

    return false;
  }

  Future<void> logout() async {
    await AuthService.instance.logout();
  }

  Future<void> setCurrentUser(AppUser user) async {
    _currentUser = user;
    notifyListeners();
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _currentUser;

    if (user == null) {
      throw Exception('No user logged in');
    }

    await AuthService.instance.changePassword(
      email: user.email,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  void clearUser() {
    _currentUser = null;
    _blockedUserIds = {};
    _blockedUsersLoaded = false;
    notifyListeners();
  }

  Future<void> loadBlockedUsers() async {
    final user = currentUser;

    if (user == null) {
      _blockedUserIds = {};
      return;
    }

    try {
      _blockedUserIds = await _userRepo.getBlockedUsers(user.id);
    } catch (e) {
      _blockedUserIds = {};
    }
  }

  void addBlockedUser(String userId) {
    _blockedUserIds = {..._blockedUserIds, userId};

    notifyListeners();
  }

  void removeBlockedUser(String userId) {
    _blockedUserIds = {..._blockedUserIds}..remove(userId);

    notifyListeners();
  }
}
