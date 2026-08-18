class NotificationRecipientModel {
  final String id; // {notificationId}_{userId}
  final String notificationId;
  final String userId;
  final String userRole;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;
  final String priority;
  final String category;
  final String type; // 'automated' | 'manual'

  NotificationRecipientModel({
    required this.id,
    required this.notificationId,
    required this.userId,
    required this.userRole,
    this.isRead = false,
    this.readAt,
    required this.createdAt,
    this.priority = 'medium',
    this.category = 'General',
    this.type = 'automated',
  });

  factory NotificationRecipientModel.fromMap(Map<String, dynamic> map, String docId) {
    return NotificationRecipientModel(
      id: docId,
      notificationId: map['notification_id'] ?? '',
      userId: map['user_id'] ?? '',
      userRole: map['user_role'] ?? 'student',
      isRead: (map['is_read'] ?? false) as bool,
      readAt: map['read_at'] != null ? DateTime.tryParse(map['read_at'].toString()) : null,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      priority: map['priority'] ?? 'medium',
      category: map['category'] ?? 'General',
      type: map['type'] ?? 'automated',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'notification_id': notificationId,
      'user_id': userId,
      'user_role': userRole,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'priority': priority,
      'category': category,
      'type': type,
    };
  }
}
