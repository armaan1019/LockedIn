class Like {
  final int? id;
  final String? remoteId;
  final int postId;
  final String userId;

  Like({this.id, this.remoteId, required this.postId, required this.userId});

  factory Like.fromMap(Map<String, dynamic> map) {
    return Like(
      id: map['id'],
      remoteId: map['remote_id'],
      postId: map['post_id'],
      userId: map['user_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'remote_id': remoteId,
      'post_id': postId,
      'user_id': userId,
    };
  }

  Like copyWith({int? id, String? remoteId, int? postId, String? userId}) {
    return Like(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
    );
  }
}
