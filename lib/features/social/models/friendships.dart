class Friendships {
  final String? id;
  final String userId;
  final String friendId;
  final DateTime createdAt;

  Friendships({
    this.id,
    required this.userId,
    required this.friendId,
    required this.createdAt,
  });
}
