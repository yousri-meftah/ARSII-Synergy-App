import 'package:arsii_mvp/models/enums.dart';

class User {
  final int id;
  final String email;
  final String fullName;
  final Role role;
  final int? teamId;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.teamId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      fullName: json['full_name'] as String? ?? '',
      role: roleFromString(json['role'] as String),
      teamId: json['team_id'] as int?,
    );
  }
}
