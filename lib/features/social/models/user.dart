class User {
  final String id;
  final String username;
  final String email;
  final String password;
  final String? profileImageUrl;
  final String bio;
  final List<String> postIds;
  final List<String> friendsIds;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    this.profileImageUrl,
    this.bio = '',
    this.friendsIds = const [],
    this.postIds = const [],
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      profileImageUrl: map['profileImageUrl'],
      bio: map['bio'] ?? '',
      friendsIds: List<String>.from(map['friendsIds'] ?? []),
      postIds: List<String>.from(map['postIds'] ?? []),
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
      'friendsIds': friendsIds,
      'postIds': postIds,
    };
  }
}
