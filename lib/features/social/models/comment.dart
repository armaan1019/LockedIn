class Comment {
  final int? id;
  final String? remoteId;
  final String userId;
  final String username;
  final int postId;
  final String? remotePostId;
  final String content;
  final DateTime createdAt;

  Comment({
    this.id,
    this.remoteId,
    required this.userId,
    required this.username,
    required this.postId,
    this.remotePostId,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'remote_id': remoteId,
      'user_id': userId,
      'username': username,
      'post_id': postId,
      'remote_post_id': remotePostId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      remoteId: map['remote_id'],
      userId: map['user_id'],
      username: map['username'],
      postId: map['post_id'],
      remotePostId: map['remote_post_id'],
      content: map['content'],
      createdAt: DateTime.parse(['created_at'] as String),
    );
  }

  Comment copyWith({
    int? id,
    String? remoteId,
    String? userId,
    String? username,
    int? postId,
    String? remotePostId,
    String? content,
    DateTime? createdAt,
  }) {
    return Comment(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      postId: postId ?? this.postId,
      remotePostId: remotePostId ?? this.remotePostId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
