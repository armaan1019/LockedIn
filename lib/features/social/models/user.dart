class User {
  final String id;
  final String username;
  final String email;
  final String password;
  final String? profileImageUrl;
  final String bio;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    this.profileImageUrl,
    this.bio = '',
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      profileImageUrl: map['profileImageUrl'],
      bio: map['bio'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
    };
  }
}
