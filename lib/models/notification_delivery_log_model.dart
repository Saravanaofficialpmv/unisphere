class NotificationDeliveryLogModel {
  final String id;
  final String notificationId;
  final String recipientId;
  final String channel; // 'in_app', 'push', 'email'
  final String status; // 'success', 'failed', 'pending'
  final DateTime timestamp;
  final String? errorMessage;
  final int retryCount;

  NotificationDeliveryLogModel({
    required this.id,
    required this.notificationId,
    required this.recipientId,
    required this.channel,
    required this.status,
    required this.timestamp,
    this.errorMessage,
    this.retryCount = 0,
  });

  factory NotificationDeliveryLogModel.fromMap(Map<String, dynamic> map, String docId) {
    return NotificationDeliveryLogModel(
      id: docId,
      notificationId: map['notification_id'] ?? '',
      recipientId: map['recipient_id'] ?? '',
      channel: map['channel'] ?? 'in_app',
      status: map['status'] ?? 'pending',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      errorMessage: map['error_message'],
      retryCount: (map['retry_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'notification_id': notificationId,
      'recipient_id': recipientId,
      'channel': channel,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      'error_message': errorMessage,
      'retry_count': retryCount,
    };
  }
}
