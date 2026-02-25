class Post {
  final int? id;
  final String? remoteId;
  final String content;
  final DateTime createdAt;

  Post({
    this.id,
    this.remoteId,
    required this.content,
    required this.createdAt,
  });

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'],
      remoteId: map['remote_id'],
      content: map['content'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'remote_id': remoteId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
