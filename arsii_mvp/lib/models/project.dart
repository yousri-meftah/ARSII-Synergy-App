import 'package:arsii_mvp/models/enums.dart';

class Project {
  final int id;
  final String name;
  final String? description;
  final int ownerId;
  final int? teamId;
  final String? startDate;
  final String? dueDate;
  final ProjectStatus status;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.teamId,
    required this.startDate,
    required this.dueDate,
    required this.status,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      ownerId: json['owner_id'] as int,
      teamId: json['team_id'] as int?,
      startDate: json['start_date'] as String?,
      dueDate: json['due_date'] as String?,
      status: projectStatusFromString(json['status'] as String),
    );
  }
}
