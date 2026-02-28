import 'package:arsii_mvp/models/enums.dart';

class Task {
  final int id;
  final int projectId;
  final String title;
  final String? description;
  final int assigneeId;
  final TaskStatus status;
  final String? dueDate;
  final int createdBy;

  Task({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.assigneeId,
    required this.status,
    required this.dueDate,
    required this.createdBy,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int,
      projectId: json['project_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      assigneeId: json['assignee_id'] as int,
      status: taskStatusFromString(json['status'] as String),
      dueDate: json['due_date'] as String?,
      createdBy: json['created_by'] as int,
    );
  }
}
