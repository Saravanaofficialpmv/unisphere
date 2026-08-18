class ManualNotificationDraftModel {
  final String id;
  final String authorId;
  final String authorName;
  final String authorRole;
  final String title;
  final String message;
  final String priority;
  final String category;
  final String recipientType;
  final Map<String, dynamic> recipientsConfig;
  final DateTime updatedAt;

  ManualNotificationDraftModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorRole,
    required this.title,
    required this.message,
    this.priority = 'medium',
    this.category = 'General',
    this.recipientType = 'role',
    this.recipientsConfig = const {},
    required this.updatedAt,
  });

  factory ManualNotificationDraftModel.fromMap(Map<String, dynamic> map, String docId) {
    return ManualNotificationDraftModel(
      id: docId,
      authorId: map['author_id'] ?? '',
      authorName: map['author_name'] ?? 'Author',
      authorRole: map['author_role'] ?? 'admin',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      priority: map['priority'] ?? 'medium',
      category: map['category'] ?? 'General',
      recipientType: map['recipient_type'] ?? 'role',
      recipientsConfig: Map<String, dynamic>.from(map['recipients_config'] ?? {}),
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'author_id': authorId,
      'author_name': authorName,
      'author_role': authorRole,
      'title': title,
      'message': message,
      'priority': priority,
      'category': category,
      'recipient_type': recipientType,
      'recipients_config': recipientsConfig,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
