import 'dart:convert';

class HackathonNotificationModel {
  final String id;
  final String hackathonId;
  final String teamId;
  final String recipientId; // ONLY Team Leader ID for reminders/corrections
  final String recipientRole; // 'student', 'advisor', 'hod'
  final String notificationType; // 'reminder_7d', 'reminder_3d', 'reminder_1d', 'reminder_today', 'correction_required', 'verified'
  final String title;
  final String message;
  final DateTime scheduledFor;
  final DateTime? sentAt;
  final DateTime? readAt;
  final String status; // 'pending', 'sent', 'cancelled', 'stopped'

  HackathonNotificationModel({
    required this.id,
    required this.hackathonId,
    required this.teamId,
    required this.recipientId,
    required this.recipientRole,
    required this.notificationType,
    required this.title,
    required this.message,
    required this.scheduledFor,
    this.sentAt,
    this.readAt,
    required this.status,
  });

  factory HackathonNotificationModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic val, DateTime fallback) {
      if (val == null) return fallback;
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString()) ?? fallback;
    }

    final now = DateTime.now();

    return HackathonNotificationModel(
      id: map['id']?.toString() ?? 'HACK-NOTIF-${now.millisecondsSinceEpoch}',
      hackathonId: map['hackathonId']?.toString() ?? map['hackathon_id']?.toString() ?? '',
      teamId: map['teamId']?.toString() ?? map['team_id']?.toString() ?? '',
      recipientId: map['recipientId']?.toString() ?? map['recipient_id']?.toString() ?? '',
      recipientRole: map['recipientRole']?.toString() ?? map['recipient_role']?.toString() ?? 'student',
      notificationType: map['notificationType']?.toString() ?? map['notification_type']?.toString() ?? 'reminder',
      title: map['title']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      scheduledFor: parseDate(map['scheduledFor'] ?? map['scheduled_for'], now),
      sentAt: map['sentAt'] != null ? parseDate(map['sentAt'], now) : null,
      readAt: map['readAt'] != null ? parseDate(map['readAt'], now) : null,
      status: map['status']?.toString() ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hackathonId': hackathonId,
      'teamId': teamId,
      'recipientId': recipientId,
      'recipientRole': recipientRole,
      'notificationType': notificationType,
      'title': title,
      'message': message,
      'scheduledFor': scheduledFor.toIso8601String(),
      'sentAt': sentAt?.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'status': status,
    };
  }

  String toJson() => json.encode(toMap());

  factory HackathonNotificationModel.fromJson(String source) => HackathonNotificationModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
