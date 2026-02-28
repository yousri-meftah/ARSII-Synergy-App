import 'package:dio/dio.dart';
import 'package:arsii_mvp/core/api_client.dart';
import 'package:arsii_mvp/models/team.dart';
import 'package:arsii_mvp/models/user.dart';

class TeamHierarchy {
  final Team team;
  final User? lead;
  final List<User> members;

  TeamHierarchy({required this.team, required this.lead, required this.members});
}

class TeamService {
  final String token;
  TeamService(this.token);

  Dio _dio() => buildDio(token: token);

  Future<List<Team>> list() async {
    final res = await _dio().get('/teams');
    return (res.data as List<dynamic>)
        .map((e) => Team.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TeamHierarchy> hierarchy(int teamId) async {
    final res = await _dio().get('/teams/$teamId/hierarchy');
    final data = res.data as Map<String, dynamic>;
    return TeamHierarchy(
      team: Team.fromJson(data['team'] as Map<String, dynamic>),
      lead: data['lead'] == null ? null : User.fromJson(data['lead'] as Map<String, dynamic>),
      members: (data['members'] as List<dynamic>)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
