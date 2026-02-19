class Post {
  final String id;
  final String userId;
  final String content;
  final DateTime createdAt;
  final int likes;

  Post({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.likes = 0,
  });

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'],
      userId: map['userId'],
      content: map['content'],
      createdAt: DateTime.parse(map['createdAt']),
      likes: map['likes'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
    };
  }
}
