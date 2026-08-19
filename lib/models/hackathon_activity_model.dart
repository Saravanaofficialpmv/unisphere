import 'dart:convert';

class HackathonActivityModel {
  final String id;
  final String hackathonId;
  final String teamId;
  final String studentId;
  final String actorId;
  final String actorRole; // 'student', 'advisor', 'hod', 'system'
  final String activityType; // 'registration_started', 'external_link_opened', 'team_created', 'member_added', 'member_removed', 'registration_id_entered', 'screenshot_uploaded', 'screenshot_replaced', 'details_submitted', 'advisor_reviewed', 'correction_requested', 'correction_submitted', 'registration_verified', 'reminder_sent'
  final String description;
  final String? previousStatus;
  final String? newStatus;
  final DateTime timestamp;

  HackathonActivityModel({
    required this.id,
    required this.hackathonId,
    required this.teamId,
    required this.studentId,
    required this.actorId,
    required this.actorRole,
    required this.activityType,
    required this.description,
    this.previousStatus,
    this.newStatus,
    required this.timestamp,
  });

  factory HackathonActivityModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString()) ?? DateTime.now();
    }

    return HackathonActivityModel(
      id: map['id']?.toString() ?? 'ACT-${DateTime.now().millisecondsSinceEpoch}',
      hackathonId: map['hackathonId']?.toString() ?? map['hackathon_id']?.toString() ?? '',
      teamId: map['teamId']?.toString() ?? map['team_id']?.toString() ?? '',
      studentId: map['studentId']?.toString() ?? map['student_id']?.toString() ?? '',
      actorId: map['actorId']?.toString() ?? map['actor_id']?.toString() ?? '',
      actorRole: map['actorRole']?.toString() ?? map['actor_role']?.toString() ?? 'student',
      activityType: map['activityType']?.toString() ?? map['activity_type']?.toString() ?? 'general',
      description: map['description']?.toString() ?? '',
      previousStatus: map['previousStatus']?.toString() ?? map['previous_status']?.toString(),
      newStatus: map['newStatus']?.toString() ?? map['new_status']?.toString(),
      timestamp: parseDate(map['timestamp'] ?? map['createdAt'] ?? map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hackathonId': hackathonId,
      'teamId': teamId,
      'studentId': studentId,
      'actorId': actorId,
      'actorRole': actorRole,
      'activityType': activityType,
      'description': description,
      'previousStatus': previousStatus,
      'newStatus': newStatus,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  String toJson() => json.encode(toMap());

  factory HackathonActivityModel.fromJson(String source) => HackathonActivityModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
