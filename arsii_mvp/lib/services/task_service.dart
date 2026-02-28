import 'package:dio/dio.dart';
import 'package:arsii_mvp/core/api_client.dart';
import 'package:arsii_mvp/models/task.dart';
import 'package:arsii_mvp/models/comment.dart';
import 'package:arsii_mvp/models/enums.dart';

class TaskService {
  final String token;
  TaskService(this.token);

  Dio _dio() => buildDio(token: token);

  Future<List<Task>> list({
    int? projectId,
    int? assigneeId,
    TaskStatus? status,
    String? dueBefore,
    String? search,
  }) async {
    final res = await _dio().get('/tasks', queryParameters: {
      if (projectId != null) 'project_id': projectId,
      if (assigneeId != null) 'assignee_id': assigneeId,
      if (status != null) 'status': taskStatusToString(status),
      if (dueBefore != null) 'due_before': dueBefore,
      if (search != null && search.isNotEmpty) 'search': search,
    });
    return (res.data as List<dynamic>)
        .map((e) => Task.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Task> getById(int id) async {
    final res = await _dio().get('/tasks/$id');
    return Task.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Task> updateStatus(int id, TaskStatus status) async {
    final res = await _dio().post('/tasks/$id/status', data: {
      'status': taskStatusToString(status),
    });
    return Task.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<Comment>> comments(int taskId) async {
    final res = await _dio().get('/tasks/$taskId/comments');
    return (res.data as List<dynamic>)
        .map((e) => Comment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Comment> addComment(int taskId, String body) async {
    final res = await _dio().post('/tasks/$taskId/comments', data: {
      'body': body,
    });
    return Comment.fromJson(res.data as Map<String, dynamic>);
  }
}
