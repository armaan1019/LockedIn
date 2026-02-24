class Post {
  final int? id;
  final String? remoteId;
  final String userId;
  final String content;
  final DateTime createdAt;

  Post({
    this.id,
    this.remoteId,
    required this.userId,
    required this.content,
    required this.createdAt,
  });

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'],
      remoteId: map['remote_id'],
      userId: map['user_id'],
      content: map['content'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'remote_id': remoteId,
      'user_id': userId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
