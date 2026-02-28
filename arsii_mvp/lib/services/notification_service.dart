import 'package:dio/dio.dart';
import 'package:arsii_mvp/core/api_client.dart';
import 'package:arsii_mvp/models/notification.dart';

class NotificationService {
  final String token;
  NotificationService(this.token);

  Dio _dio() => buildDio(token: token);

  Future<List<AppNotification>> list({bool? unread}) async {
    final res = await _dio().get('/notifications', queryParameters: {
      if (unread != null) 'unread': unread,
    });
    return (res.data as List<dynamic>)
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AppNotification> markRead(int id) async {
    final res = await _dio().post('/notifications/$id/read');
    return AppNotification.fromJson(res.data as Map<String, dynamic>);
  }
}
