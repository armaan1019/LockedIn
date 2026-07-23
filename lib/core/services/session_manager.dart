import 'package:flutter/material.dart';
import '../../features/social/models/user.dart';
import 'auth_service.dart';

class SessionManager extends ChangeNotifier {
  AppUser? _currentUser;
  bool _initialized = false;

  bool get initialized => _initialized;
  AppUser? get currentUser => _currentUser;
  String? get currentUserId => _currentUser?.id;
  bool get isLoggedIn => _currentUser != null;

  SessionManager() {
    AuthService.instance.authStateChanges.listen((user) {
      _currentUser = user;
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

  Future<void> deleteAccount() async {
    await AuthService.instance.deleteAccount();
  }
}
