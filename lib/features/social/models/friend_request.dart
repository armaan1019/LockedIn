class FriendRequest {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String status;

  FriendRequest({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    this.status = 'pending',
  });
}
