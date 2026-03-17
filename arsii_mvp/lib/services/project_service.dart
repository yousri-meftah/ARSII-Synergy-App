import 'package:dio/dio.dart';
import 'package:arsii_mvp/core/api_client.dart';
import 'package:arsii_mvp/models/project.dart';

class ProjectService {
  final String token;
  ProjectService(this.token);

  Dio _dio() => buildDio(token: token);

  Future<List<Project>> list({int? teamId, String? status}) async {
    final res = await _dio().get('/projects', queryParameters: {
      if (teamId != null) 'team_id': teamId,
      if (status != null) 'status': status,
    });
    return (res.data as List<dynamic>)
        .map((e) => Project.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Project> create({
    required String name,
    required String description,
    int? teamId,
    String? dueDate,
  }) async {
    final res = await _dio().post('/projects', data: {
      'name': name,
      'description': description,
      'team_id': teamId,
      if (dueDate != null && dueDate.isNotEmpty) 'due_date': dueDate,
    });
    return Project.fromJson(res.data as Map<String, dynamic>);
  }
}
