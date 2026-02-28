import 'package:dio/dio.dart';
import 'package:arsii_mvp/core/api_client.dart';
import 'package:arsii_mvp/models/dashboard.dart';

class WorkloadService {
  final String token;
  WorkloadService(this.token);

  Dio _dio() => buildDio(token: token);

  Future<List<WorkloadItem>> list() async {
    final res = await _dio().get('/workload');
    return (res.data as List<dynamic>)
        .map((e) => WorkloadItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
