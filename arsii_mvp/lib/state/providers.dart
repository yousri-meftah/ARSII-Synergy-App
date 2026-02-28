import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arsii_mvp/state/auth_state.dart';
import 'package:arsii_mvp/services/task_service.dart';
import 'package:arsii_mvp/services/project_service.dart';
import 'package:arsii_mvp/services/dashboard_service.dart';
import 'package:arsii_mvp/services/notification_service.dart';
import 'package:arsii_mvp/services/team_service.dart';
import 'package:arsii_mvp/services/workload_service.dart';
import 'package:arsii_mvp/services/user_service.dart';
import 'package:arsii_mvp/models/task.dart';
import 'package:arsii_mvp/models/project.dart';
import 'package:arsii_mvp/models/dashboard.dart';
import 'package:arsii_mvp/models/notification.dart';
import 'package:arsii_mvp/models/team.dart';
import 'package:arsii_mvp/models/enums.dart';
import 'package:arsii_mvp/models/comment.dart';
import 'package:arsii_mvp/models/user.dart';

final tokenProvider = Provider<String?>((ref) => ref.watch(authProvider).token);

class TaskFilter {
  final int? projectId;
  final int? assigneeId;
  final TaskStatus? status;
  final String? search;

  const TaskFilter({this.projectId, this.assigneeId, this.status, this.search});

  @override
  bool operator ==(Object other) {
    return other is TaskFilter &&
        other.projectId == projectId &&
        other.assigneeId == assigneeId &&
        other.status == status &&
        other.search == search;
  }

  @override
  int get hashCode => Object.hash(projectId, assigneeId, status, search);
}

final taskServiceProvider = Provider<TaskService>((ref) {
  final token = ref.watch(tokenProvider);
  return TaskService(token ?? '');
});

final projectServiceProvider = Provider<ProjectService>((ref) {
  final token = ref.watch(tokenProvider);
  return ProjectService(token ?? '');
});

final dashboardServiceProvider = Provider<DashboardService>((ref) {
  final token = ref.watch(tokenProvider);
  return DashboardService(token ?? '');
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final token = ref.watch(tokenProvider);
  return NotificationService(token ?? '');
});

final teamServiceProvider = Provider<TeamService>((ref) {
  final token = ref.watch(tokenProvider);
  return TeamService(token ?? '');
});

final workloadServiceProvider = Provider<WorkloadService>((ref) {
  final token = ref.watch(tokenProvider);
  return WorkloadService(token ?? '');
});

final userServiceProvider = Provider<UserService>((ref) {
  final token = ref.watch(tokenProvider);
  return UserService(token ?? '');
});

final tasksProvider = FutureProvider.family<List<Task>, TaskFilter>((ref, filter) async {
  final service = ref.watch(taskServiceProvider);
  return service.list(
    projectId: filter.projectId,
    assigneeId: filter.assigneeId,
    status: filter.status,
    search: filter.search,
  );
});

final projectsProvider = FutureProvider<List<Project>>((ref) async {
  final service = ref.watch(projectServiceProvider);
  return service.list();
});

final dashboardProvider = FutureProvider<Dashboard>((ref) async {
  final service = ref.watch(dashboardServiceProvider);
  return service.fetch();
});

final notificationsProvider = FutureProvider<List<AppNotification>>((ref) async {
  final service = ref.watch(notificationServiceProvider);
  return service.list();
});

final workloadProvider = FutureProvider<List<WorkloadItem>>((ref) async {
  final service = ref.watch(workloadServiceProvider);
  return service.list();
});

final teamsProvider = FutureProvider<List<Team>>((ref) async {
  final service = ref.watch(teamServiceProvider);
  return service.list();
});

final usersProvider = FutureProvider<List<User>>((ref) async {
  final service = ref.watch(userServiceProvider);
  return service.list();
});

final teamHierarchyProvider = FutureProvider.family<TeamHierarchy, int>((ref, teamId) async {
  final service = ref.watch(teamServiceProvider);
  return service.hierarchy(teamId);
});

final commentsProvider = FutureProvider.family<List<Comment>, int>((ref, taskId) async {
  final service = ref.watch(taskServiceProvider);
  return service.comments(taskId);
});

final taskDetailProvider = FutureProvider.family<Task, int>((ref, taskId) async {
  final service = ref.watch(taskServiceProvider);
  return service.getById(taskId);
});
