import 'package:arsii_mvp/models/enums.dart';
import 'package:arsii_mvp/models/task.dart';
import 'package:arsii_mvp/models/user.dart';

class WorkloadItem {
  final User user;
  final int openTasks;

  WorkloadItem({required this.user, required this.openTasks});

  factory WorkloadItem.fromJson(Map<String, dynamic> json) {
    return WorkloadItem(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      openTasks: json['open_tasks'] as int,
    );
  }
}

class Dashboard {
  final Role role;
  final int totalTasks;
  final int overdueTasks;
  final int dueSoonTasks;
  final List<Task> myTasks;
  final List<Task> teamTasks;
  final List<WorkloadItem> workload;
  final Map<String, int> projectsSummary;
  final Map<String, int> teamSummary;
  final int? userCount;
  final int? teamCount;

  Dashboard({
    required this.role,
    required this.totalTasks,
    required this.overdueTasks,
    required this.dueSoonTasks,
    required this.myTasks,
    required this.teamTasks,
    required this.workload,
    required this.projectsSummary,
    required this.teamSummary,
    required this.userCount,
    required this.teamCount,
  });

  factory Dashboard.fromJson(Map<String, dynamic> json) {
    final role = roleFromString(json['role'] as String);
    return Dashboard(
      role: role,
      totalTasks: json['total_tasks'] as int,
      overdueTasks: json['overdue_tasks'] as int,
      dueSoonTasks: json['due_soon_tasks'] as int,
      myTasks: (json['my_tasks'] as List<dynamic>? ?? [])
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList(),
      teamTasks: (json['team_tasks'] as List<dynamic>? ?? [])
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList(),
      workload: (json['workload'] as List<dynamic>? ?? [])
          .map((e) => WorkloadItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      projectsSummary: (json['projects_summary'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, v as int)),
      teamSummary: (json['team_summary'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, v as int)),
      userCount: json['user_count'] as int?,
      teamCount: json['team_count'] as int?,
    );
  }
}
