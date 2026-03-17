class AIInsightItem {
  final String title;
  final String detail;
  final String priority;
  final String? entityType;
  final int? entityId;

  AIInsightItem({
    required this.title,
    required this.detail,
    required this.priority,
    required this.entityType,
    required this.entityId,
  });

  factory AIInsightItem.fromJson(Map<String, dynamic> json) {
    return AIInsightItem(
      title: json['title'] as String,
      detail: json['detail'] as String,
      priority: json['priority'] as String,
      entityType: json['entity_type'] as String?,
      entityId: json['entity_id'] as int?,
    );
  }
}

class AIInsightsResponse {
  final String summary;
  final String source;
  final String generatedAt;
  final String scope;
  final List<AIInsightItem> insights;

  AIInsightsResponse({
    required this.summary,
    required this.source,
    required this.generatedAt,
    required this.scope,
    required this.insights,
  });

  factory AIInsightsResponse.fromJson(Map<String, dynamic> json) {
    return AIInsightsResponse(
      summary: json['summary'] as String,
      source: json['source'] as String,
      generatedAt: json['generated_at'] as String,
      scope: json['scope'] as String,
      insights: (json['insights'] as List<dynamic>)
          .map((e) => AIInsightItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AIConflictItem {
  final String title;
  final String detail;
  final String severity;
  final String recommendation;
  final String? entityType;
  final int? entityId;

  AIConflictItem({
    required this.title,
    required this.detail,
    required this.severity,
    required this.recommendation,
    required this.entityType,
    required this.entityId,
  });

  factory AIConflictItem.fromJson(Map<String, dynamic> json) {
    return AIConflictItem(
      title: json['title'] as String,
      detail: json['detail'] as String,
      severity: json['severity'] as String,
      recommendation: json['recommendation'] as String,
      entityType: json['entity_type'] as String?,
      entityId: json['entity_id'] as int?,
    );
  }
}

class AIConflictsResponse {
  final String summary;
  final String source;
  final String generatedAt;
  final String scope;
  final List<AIConflictItem> conflicts;

  AIConflictsResponse({
    required this.summary,
    required this.source,
    required this.generatedAt,
    required this.scope,
    required this.conflicts,
  });

  factory AIConflictsResponse.fromJson(Map<String, dynamic> json) {
    return AIConflictsResponse(
      summary: json['summary'] as String,
      source: json['source'] as String,
      generatedAt: json['generated_at'] as String,
      scope: json['scope'] as String,
      conflicts: (json['conflicts'] as List<dynamic>)
          .map((e) => AIConflictItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AIChatMessage {
  final String role;
  final String content;

  AIChatMessage({
    required this.role,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
    };
  }
}

class AIChatResponse {
  final String reply;
  final String source;
  final String generatedAt;
  final String scope;

  AIChatResponse({
    required this.reply,
    required this.source,
    required this.generatedAt,
    required this.scope,
  });

  factory AIChatResponse.fromJson(Map<String, dynamic> json) {
    return AIChatResponse(
      reply: json['reply'] as String,
      source: json['source'] as String,
      generatedAt: json['generated_at'] as String,
      scope: json['scope'] as String,
    );
  }
}

class AIRecommendedMember {
  final int userId;
  final String fullName;
  final int? teamId;
  final String? teamName;
  final String? role;
  final String? availability;
  final int? matchPercentage;
  final String reason;

  AIRecommendedMember({
    required this.userId,
    required this.fullName,
    required this.teamId,
    required this.teamName,
    required this.role,
    required this.availability,
    required this.matchPercentage,
    required this.reason,
  });

  factory AIRecommendedMember.fromJson(Map<String, dynamic> json) {
    return AIRecommendedMember(
      userId: json['user_id'] as int,
      fullName: json['full_name'] as String,
      teamId: json['team_id'] as int?,
      teamName: json['team_name'] as String?,
      role: json['role'] as String?,
      availability: json['availability'] as String?,
      matchPercentage: json['match_percentage'] as int?,
      reason: json['reason'] as String,
    );
  }
}

class AIRecommendedRoleSlot {
  final String label;
  final int count;
  final String note;

  AIRecommendedRoleSlot({
    required this.label,
    required this.count,
    required this.note,
  });

  factory AIRecommendedRoleSlot.fromJson(Map<String, dynamic> json) {
    return AIRecommendedRoleSlot(
      label: json['label'] as String,
      count: json['count'] as int,
      note: json['note'] as String,
    );
  }
}

class AIRecommendedTeam {
  final int teamId;
  final String teamName;
  final double score;
  final String reason;
  final List<String> specialties;
  final List<AIRecommendedMember> members;

  AIRecommendedTeam({
    required this.teamId,
    required this.teamName,
    required this.score,
    required this.reason,
    required this.specialties,
    required this.members,
  });

  factory AIRecommendedTeam.fromJson(Map<String, dynamic> json) {
    return AIRecommendedTeam(
      teamId: json['team_id'] as int,
      teamName: json['team_name'] as String,
      score: (json['score'] as num).toDouble(),
      reason: json['reason'] as String,
      specialties: (json['specialties'] as List<dynamic>? ?? []).cast<String>(),
      members: (json['members'] as List<dynamic>)
          .map((e) => AIRecommendedMember.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AIPlannedTask {
  final String title;
  final String description;
  final int? recommendedAssigneeId;
  final String? recommendedAssigneeName;

  AIPlannedTask({
    required this.title,
    required this.description,
    required this.recommendedAssigneeId,
    required this.recommendedAssigneeName,
  });

  factory AIPlannedTask.fromJson(Map<String, dynamic> json) {
    return AIPlannedTask(
      title: json['title'] as String,
      description: json['description'] as String,
      recommendedAssigneeId: json['recommended_assignee_id'] as int?,
      recommendedAssigneeName: json['recommended_assignee_name'] as String?,
    );
  }
}

class AIProjectPlanResponse {
  final String summary;
  final String source;
  final String generatedAt;
  final int suggestedTeamSize;
  final List<AIRecommendedMember> recommendedPeople;
  final List<AIRecommendedRoleSlot> suggestedRoles;
  final List<AIRecommendedTeam> recommendedTeams;
  final List<AIPlannedTask> tasks;

  AIProjectPlanResponse({
    required this.summary,
    required this.source,
    required this.generatedAt,
    required this.suggestedTeamSize,
    required this.recommendedPeople,
    required this.suggestedRoles,
    required this.recommendedTeams,
    required this.tasks,
  });

  factory AIProjectPlanResponse.fromJson(Map<String, dynamic> json) {
    return AIProjectPlanResponse(
      summary: json['summary'] as String,
      source: json['source'] as String,
      generatedAt: json['generated_at'] as String,
      suggestedTeamSize: json['suggested_team_size'] as int,
      recommendedPeople: (json['recommended_people'] as List<dynamic>)
          .map((e) => AIRecommendedMember.fromJson(e as Map<String, dynamic>))
          .toList(),
      suggestedRoles: (json['suggested_roles'] as List<dynamic>)
          .map((e) => AIRecommendedRoleSlot.fromJson(e as Map<String, dynamic>))
          .toList(),
      recommendedTeams: (json['recommended_teams'] as List<dynamic>)
          .map((e) => AIRecommendedTeam.fromJson(e as Map<String, dynamic>))
          .toList(),
      tasks: (json['tasks'] as List<dynamic>)
          .map((e) => AIPlannedTask.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
