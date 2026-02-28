import 'package:dio/dio.dart';
import 'package:arsii_mvp/core/api_client.dart';
import 'package:arsii_mvp/models/user.dart';

class AuthService {
  Future<(String, User)> login(String email, String password) async {
    final dio = buildDio();
    final res = await dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final token = res.data['access_token'] as String;
    final user = User.fromJson(res.data['user'] as Map<String, dynamic>);
    return (token, user);
  }

  Future<User> me(String token) async {
    final dio = buildDio(token: token);
    final res = await dio.get('/users/me');
    return User.fromJson(res.data as Map<String, dynamic>);
  }
}
