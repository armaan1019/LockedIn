import 'package:flutter/material.dart';
import '../models/user.dart';

class SessionManager extends ChangeNotifier {
  User? currentUser;

  bool get isLoggedIn => currentUser != null;
  void login(User user) {
    currentUser = user;
    notifyListeners();
  }

  void logout() {
    currentUser = null;
    notifyListeners();
  }
}