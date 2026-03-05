class Like {
  final String id;
  final String postId;
  final String userId;

  Like({required this.id, required this.postId, required this.userId});

  factory Like.fromMap(String id, Map<String, dynamic> map) {
    return Like(
      id: id,
      postId: map['postId'],
      userId: map['userId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
    };
  }

  Like copyWith({String? id, String? postId, String? userId}) {
    return Like(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
    );
  }
}
