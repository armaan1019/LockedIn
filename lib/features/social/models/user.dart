class AppUser {
  final String id;
  final String username;
  final String email;
  final String? profileImageUrl;
  final String bio;

  AppUser({
    required this.id,
    required this.username,
    required this.email,
    this.profileImageUrl,
    this.bio = '',
  });

  factory AppUser.fromMap(String id, Map<String, dynamic> map) {
    return AppUser(
      id: id,
      username: map['username'],
      email: map['email'],
      profileImageUrl: map['profileImageUrl'],
      bio: map['bio'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
    };
  }
}
