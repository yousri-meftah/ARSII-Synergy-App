import 'package:arsii_mvp/models/enums.dart';

class AppNotification {
  final int id;
  final int userId;
  final NotificationType type;
  final String payload;
  final String? readAt;
  final String createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.payload,
    required this.readAt,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      type: notificationTypeFromString(json['type'] as String),
      payload: json['payload'] as String,
      readAt: json['read_at'] as String?,
      createdAt: json['created_at'] as String,
    );
  }
}
