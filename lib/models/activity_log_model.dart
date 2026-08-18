class ActivityLogModel {
  final String logId;
  final String userId;
  final String action;
  final String module;
  final String? entityId;
  final String description;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  ActivityLogModel({
    required this.logId,
    required this.userId,
    required this.action,
    required this.module,
    this.entityId,
    required this.description,
    this.metadata,
    required this.createdAt,
  });

  factory ActivityLogModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString()) ?? DateTime.now();
    }

    return ActivityLogModel(
      logId: id,
      userId: map['userId'] ?? map['user_id'] ?? '',
      action: map['action'] ?? '',
      module: map['module'] ?? '',
      entityId: map['entityId'] ?? map['entity_id'],
      description: map['description'] ?? '',
      metadata: map['metadata'] is Map ? Map<String, dynamic>.from(map['metadata']) : null,
      createdAt: parseDate(map['createdAt'] ?? map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'logId': logId,
      'log_id': logId,
      'userId': userId,
      'user_id': userId,
      'action': action,
      'module': module,
      'entityId': entityId,
      'entity_id': entityId,
      'description': description,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
