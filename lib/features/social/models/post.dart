class Post {
  final String id;
  final String content;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.content,
    required this.createdAt,
  });

  factory Post.fromMap(String id, Map<String, dynamic> map) {
    return Post(
      id: id,
      content: map['content'],
      createdAt: map['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'createdAt': createdAt,
    };
  }
}
