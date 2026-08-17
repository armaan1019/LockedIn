class PublicProfile {
  final String id;
  final String username;
  final String? profileImageUrl;
  final String bio;

  PublicProfile({
    required this.id,
    required this.username,
    required this.profileImageUrl,
    required this.bio,
  });

  factory PublicProfile.fromMap(String id, Map<String, dynamic> map) {
    return PublicProfile(
      id: id,
      username: map['username'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      bio: map['bio'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
    };
  }
}
