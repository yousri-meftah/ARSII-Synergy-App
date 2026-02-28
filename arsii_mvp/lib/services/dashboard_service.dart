import 'package:dio/dio.dart';
import 'package:arsii_mvp/core/api_client.dart';
import 'package:arsii_mvp/models/dashboard.dart';

class DashboardService {
  final String token;
  DashboardService(this.token);

  Dio _dio() => buildDio(token: token);

  Future<Dashboard> fetch() async {
    final res = await _dio().get('/dashboard');
    return Dashboard.fromJson(res.data as Map<String, dynamic>);
  }
}
