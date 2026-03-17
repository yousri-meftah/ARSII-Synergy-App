import 'package:dio/dio.dart';
import 'package:arsii_mvp/core/api_client.dart';
import 'package:arsii_mvp/models/ai.dart';

class AIService {
  final String token;
  AIService(this.token);

  Dio _dio() => buildDio(token: token);

  Future<AIInsightsResponse> insights() async {
    final res = await _dio().get('/ai/insights');
    return AIInsightsResponse.fromJson(res.data as Map<String, dynamic>);
  }

  Future<AIConflictsResponse> conflicts() async {
    final res = await _dio().get('/ai/workload-conflicts');
    return AIConflictsResponse.fromJson(res.data as Map<String, dynamic>);
  }

  Future<AIChatResponse> chat({
    required String message,
    required List<AIChatMessage> history,
  }) async {
    final res = await _dio().post('/ai/chat', data: {
      'message': message,
      'history': history.map((item) => item.toJson()).toList(),
    });
    return AIChatResponse.fromJson(res.data as Map<String, dynamic>);
  }

  Future<AIProjectPlanResponse> projectPlan({
    required String name,
    required String description,
    String? dueDate,
  }) async {
    final res = await _dio().post('/ai/project-plan', data: {
      'name': name,
      'description': description,
      if (dueDate != null && dueDate.isNotEmpty) 'due_date': dueDate,
    });
    return AIProjectPlanResponse.fromJson(res.data as Map<String, dynamic>);
  }
}
