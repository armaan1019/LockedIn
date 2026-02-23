import 'package:flutter/material.dart';
import '../models/user.dart';
import 'auth_service.dart';
import 'package:provider/provider.dart';

class SessionManager extends ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;
  String? get currentUserId => _currentUser?.id;
  bool get isLoggedIn => _currentUser != null;

  Future<bool> login(String username, String password) async {
    final user = await AuthService.instance.login(username, password);

    if (user == null) {
      return false;
    }

    _currentUser = user;
    notifyListeners();
    return true;
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
    if (user == null) {
      return false;
    }
    _currentUser = user;
    notifyListeners();
    return true;
  }

  void logout() {
    AuthService.instance.logout();
    _currentUser = null;
    notifyListeners();
  }
}
