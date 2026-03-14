import 'package:flutter/material.dart';
import '../../features/social/models/user.dart';
import 'auth_service.dart';

class SessionManager extends ChangeNotifier {
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;
  String? get currentUserId => _currentUser?.id;
  bool get isLoggedIn => _currentUser != null;

  SessionManager() {
    AuthService.instance.authStateChanges.listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  Future<bool> login(String username, String password) async {
    final user = await AuthService.instance.login(username, password);
    return user != null;
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
    return user != null;
  }

  void logout() {
    AuthService.instance.logout();
  }
}
