class FriendRequest {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String status;
  final DateTime createdAt;

  FriendRequest({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    this.status = 'pending',
    required this.createdAt,
  });
}
