import 'package:flutter/material.dart';
import '../models/user.dart';

class SessionManager extends ChangeNotifier {
  User? _currentUser;

  bool get isLoggedIn => _currentUser != null;
  void login(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}