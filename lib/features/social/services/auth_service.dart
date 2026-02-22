import '../models/user.dart';

class AuthService {
  Future<User?> login(String username, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    if (username.isNotEmpty && password.isNotEmpty) {
      return User(
        id: "demo_user", 
        username: username, 
        email: "$username@example.com",
        password: password,
      );
    }

    return null;
  }
}
