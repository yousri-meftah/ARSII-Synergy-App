class Comment {
  final int id;
  final int taskId;
  final int authorId;
  final String body;
  final String createdAt;

  Comment({
    required this.id,
    required this.taskId,
    required this.authorId,
    required this.body,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int,
      taskId: json['task_id'] as int,
      authorId: json['author_id'] as int,
      body: json['body'] as String,
      createdAt: json['created_at'] as String,
    );
  }
}
