import '../../features/social/models/user.dart';

class LoginResponse {
  final LoginResult result;
  final AppUser? user;

  const LoginResponse({required this.result, this.user});
}

enum LoginResult { success, emailNotVerified, invalidCredentials }
