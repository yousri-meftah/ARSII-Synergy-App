class Team {
  final int id;
  final String name;
  final int? leadId;

  Team({required this.id, required this.name, required this.leadId});

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] as int,
      name: json['name'] as String,
      leadId: json['lead_id'] as int?,
    );
  }
}
