import '../models/user.dart';

class AuthService {
  Future<User?> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    if (email.isNotEmpty && password.isNotEmpty) {
      return User(
        id: "demo_user", 
        username: "Demo User", 
        email: email,
        password: password,
      );
    }

    return null;
  }
}
