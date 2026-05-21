class AppUser {
  final String id;
  final String username;
  final String email;
  final String? profileImageUrl;
  final String bio;

  final int? weight;
  final int? feet;
  final int? inches;

  AppUser({
    required this.id,
    required this.username,
    required this.email,
    this.profileImageUrl,
    this.bio = '',

    this.weight,
    this.feet,
    this.inches,
  });

  factory AppUser.fromMap(String id, Map<String, dynamic> map) {
    return AppUser(
      id: id,
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      bio: map['bio'] ?? '',

      weight: map['weight'],
      feet: map['feet'],
      inches: map['inches'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'bio': bio,

      'weight': weight,
      'feet': feet,
      'inches': inches,
    };
  }

  String get heightFormatted {
    if (feet == null || inches == null) return 'Not set';

    return '$feet\'$inches"';
  }

  AppUser copyWith({
    String? username,
    String? email,
    String? profileImageUrl,
    String? bio,
    int? weight,
    int? feet,
    int? inches,
  }) {
    return AppUser(
      id: id,
      username: username ?? this.username,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      weight: weight ?? this.weight,
      feet: feet ?? this.feet,
      inches: inches ?? this.inches,
    );
  }
}
