import 'package:dio/dio.dart';
import 'package:arsii_mvp/core/api_client.dart';
import 'package:arsii_mvp/models/user.dart';

class UserService {
  final String token;
  UserService(this.token);

  Dio _dio() => buildDio(token: token);

  Future<List<User>> list({String? role, int? teamId}) async {
    final res = await _dio().get('/users', queryParameters: {
      if (role != null) 'role': role,
      if (teamId != null) 'team_id': teamId,
    });
    return (res.data as List<dynamic>)
        .map((e) => User.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
