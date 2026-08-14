class NotificationModel {
  final String id;
  final String targetUserId; // Specific user UID or 'ALL' or role name
  final String title;
  final String message;
  final String type; // 'Announcement', 'Exam', 'Assignment', 'Attendance', 'System'
  final bool isRead;
  final DateTime createdAt;
  final String? deepLink;

  NotificationModel({
    required this.id,
    required this.targetUserId,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    required this.createdAt,
    this.deepLink,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String docId) {
    return NotificationModel(
      id: docId,
      targetUserId: map['target_user_id'] ?? map['targetUserId'] ?? 'ALL',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: map['type'] ?? 'General',
      isRead: (map['is_read'] ?? map['isRead'] ?? false) as bool,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'].toString())
          : DateTime.now(),
      deepLink: map['deep_link'] ?? map['deepLink'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'target_user_id': targetUserId,
      'title': title,
      'message': message,
      'type': type,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'deep_link': deepLink,
    };
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      targetUserId: targetUserId,
      title: title,
      message: message,
      type: type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      deepLink: deepLink,
    );
  }
}
