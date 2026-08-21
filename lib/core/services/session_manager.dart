import 'package:flutter/material.dart';
import '../../features/social/models/user.dart';
import 'auth_service.dart';
import '../../features/social/repositories/user_repository.dart';
import '../widgets/login_response.dart';

class SessionManager extends ChangeNotifier {
  AppUser? _currentUser;
  bool _initialized = false;
  bool _emailVerified = false;
  bool _emailVerificationRequired = false;

  Set<String> _blockedUserIds = {};
  final _userRepo = UserRepository();
  bool _blockedUsersLoaded = false;

  bool get blockedUsersLoaded => _blockedUsersLoaded;
  bool get initialized => _initialized;
  AppUser? get currentUser => _currentUser;
  String? get currentUserId => _currentUser?.id;
  bool get isLoggedIn => _currentUser != null;
  bool get emailVerified => _emailVerified;
  Set<String> get blockedUserIds => _blockedUserIds;
  bool get emailVerificationRequired => _emailVerificationRequired;

  SessionManager() {
    AuthService.instance.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser == null) {
        _currentUser = null;
        _emailVerified = false;
        _emailVerificationRequired = false;
        _blockedUserIds = {};
        _blockedUsersLoaded = false;
      } else {
        _emailVerified = await AuthService.instance.isEmailVerified();

        if (_emailVerified) {
          _emailVerificationRequired = false;

          _currentUser =
              await AuthService.instance.getCurrentAppUser();

          if (_currentUser != null) {
            await loadBlockedUsers();
          }
        } else {
          _currentUser = null;
          _emailVerificationRequired = true;
          _blockedUserIds = {};
          _blockedUsersLoaded = true;
        }
      }

      _initialized = true;
      notifyListeners();
    });
  }

  Future<LoginResponse> login(
    String username,
    String password,
  ) async {
    final response = await AuthService.instance.login(
      username,
      password,
    );

    if (response.result == LoginResult.success) {
      _currentUser = response.user;
      _emailVerificationRequired = false;

      if (_currentUser != null) {
        await loadBlockedUsers();
      }
    } else if (response.result == LoginResult.emailNotVerified) {
      _emailVerificationRequired = true;
    }

    notifyListeners();

    return response;
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
      _emailVerified = false;
      _blockedUserIds = {};
      _blockedUsersLoaded = true;

      notifyListeners();
      return true;
    }

    return false;
  }

  Future<bool> refreshEmailVerification() async {
    final verified =
        await AuthService.instance.isEmailVerified();

    _emailVerified = verified;

    if (verified) {
      _emailVerificationRequired = false;

      _currentUser =
          await AuthService.instance.getCurrentAppUser();

      if (_currentUser != null) {
        await loadBlockedUsers();
      }
    }

    notifyListeners();
    return verified;
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
    _emailVerified = false;
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
