class Comment {
  final int id;
  final String body;
  final CommentUser? user;
  final String createdAt;

  Comment({
    required this.id,
    required this.body,
    this.user,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      body: json['body'] ?? '',
      user: json['user'] != null ? CommentUser.fromJson(json['user']) : null,
      createdAt: json['created_at'] ?? '',
    );
  }
}

class CommentUser {
  final int id;
  final String name;

  CommentUser({required this.id, required this.name});

  factory CommentUser.fromJson(Map<String, dynamic> json) {
    return CommentUser(
      id: json['id'],
      name: json['name'] ?? '',
    );
  }
}
