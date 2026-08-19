import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class NotificationDeduplicationRecord {
  final String deduplicationKey;
  final String ruleId;
  final String recipientUserId;
  final String eventId;
  final DateTime createdAt;
  final String? statusValue;
  final String notificationId;

  NotificationDeduplicationRecord({
    required this.deduplicationKey,
    required this.ruleId,
    required this.recipientUserId,
    required this.eventId,
    required this.createdAt,
    this.statusValue,
    required this.notificationId,
  });

  factory NotificationDeduplicationRecord.fromMap(Map<String, dynamic> map, String key) {
    return NotificationDeduplicationRecord(
      deduplicationKey: key,
      ruleId: map['rule_id'] ?? map['ruleId'] ?? '',
      recipientUserId: map['recipient_user_id'] ?? map['recipientUserId'] ?? '',
      eventId: map['event_id'] ?? map['eventId'] ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      statusValue: map['status_value']?.toString(),
      notificationId: map['notification_id'] ?? map['notificationId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'deduplication_key': deduplicationKey,
      'rule_id': ruleId,
      'recipient_user_id': recipientUserId,
      'event_id': eventId,
      'created_at': createdAt.toIso8601String(),
      'status_value': statusValue,
      'notification_id': notificationId,
    };
  }
}

class NotificationDuplicatePreventer {
  final FirebaseFirestore? _firestore;
  static final Map<String, NotificationDeduplicationRecord> _inMemoryCache = {};

  NotificationDuplicatePreventer({FirebaseFirestore? firestore})
      : _firestore = firestore ?? _tryGetFirestore();

  static FirebaseFirestore? _tryGetFirestore() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  /// Generates deterministic deduplication key: ruleId_recipientUserId_eventId
  static String buildDeduplicationKey({
    required String ruleId,
    required String recipientUserId,
    required String eventId,
  }) {
    return '${ruleId}_${recipientUserId}_$eventId';
  }

  /// Scoped check to determine if a notification has ALREADY been sent.
  /// Returns `true` if already sent for (ruleId, recipientUserId, eventId).
  Future<bool> alreadySent({
    required String ruleId,
    required String recipientUserId,
    required String eventId,
  }) async {
    final key = buildDeduplicationKey(
      ruleId: ruleId,
      recipientUserId: recipientUserId,
      eventId: eventId,
    );

    // 1. Check in-memory cache
    if (_inMemoryCache.containsKey(key)) {
      _logSuppression(ruleId: ruleId, recipientUserId: recipientUserId, eventId: eventId, deduplicationKey: key);
      return true;
    }

    // 2. Check Firestore persistence
    final firestore = _firestore;
    if (firestore != null) {
      try {
        final doc = await firestore.collection('notification_rule_execution_history').doc(key).get();
        if (doc.exists && doc.data() != null) {
          final record = NotificationDeduplicationRecord.fromMap(doc.data()!, key);
          _inMemoryCache[key] = record;
          _logSuppression(ruleId: ruleId, recipientUserId: recipientUserId, eventId: eventId, deduplicationKey: key);
          return true;
        }
      } catch (e) {
        debugPrint('NotificationDuplicatePreventer Firestore check error: $e');
      }
    }

    return false;
  }

  /// Check whether a notification SHOULD trigger.
  /// Returns `true` if allowed (new/eligible), `false` if duplicate/suppressed.
  Future<bool> shouldTrigger({
    required String ruleId,
    required String recipientUserId,
    required String eventId,
    int cooldownHours = 24,
    String? currentStatusValue,
  }) async {
    final isSent = await alreadySent(
      ruleId: ruleId,
      recipientUserId: recipientUserId,
      eventId: eventId,
    );

    if (!isSent) {
      debugPrint('NotificationEngine:\nNew recipient/event detected\nruleId: $ruleId\nrecipientUserId: $recipientUserId\neventId: $eventId');
    }

    return !isSent;
  }

  /// Atomically claims and records the deduplication key to prevent concurrent duplicate dispatches.
  /// Returns `true` if claim succeeded, `false` if another execution claimed it concurrently.
  Future<bool> claimAndRecord({
    required String ruleId,
    required String recipientUserId,
    required String eventId,
    required String notificationId,
    String? currentStatusValue,
  }) async {
    final key = buildDeduplicationKey(
      ruleId: ruleId,
      recipientUserId: recipientUserId,
      eventId: eventId,
    );
    final now = DateTime.now();

    final record = NotificationDeduplicationRecord(
      deduplicationKey: key,
      ruleId: ruleId,
      recipientUserId: recipientUserId,
      eventId: eventId,
      createdAt: now,
      statusValue: currentStatusValue,
      notificationId: notificationId,
    );

    // Update in-memory cache
    _inMemoryCache[key] = record;

    final firestore = _firestore;
    if (firestore != null) {
      try {
        final docRef = firestore.collection('notification_rule_execution_history').doc(key);

        // Atomic transaction to ensure concurrency safety across simultaneous scheduler jobs
        return await firestore.runTransaction<bool>((transaction) async {
          final snapshot = await transaction.get(docRef);
          if (snapshot.exists) {
            _logSuppression(ruleId: ruleId, recipientUserId: recipientUserId, eventId: eventId, deduplicationKey: key);
            return false;
          }
          transaction.set(docRef, record.toMap());
          return true;
        });
      } catch (e) {
        debugPrint('NotificationDuplicatePreventer atomic claim error: $e');
        return true;
      }
    }

    return true;
  }

  /// Log execution record (for testing/compatibility)
  Future<void> recordExecution({
    required String ruleId,
    required String targetId,
    required int cooldownHours,
    String? currentStatusValue,
    String eventId = 'default_event',
    String notificationId = 'notif_auto',
  }) async {
    await claimAndRecord(
      ruleId: ruleId,
      recipientUserId: targetId,
      eventId: eventId,
      notificationId: notificationId,
      currentStatusValue: currentStatusValue,
    );
  }

  /// Clears in-memory cache (primarily for unit tests)
  static void clearCache() {
    _inMemoryCache.clear();
  }

  static void _logSuppression({
    required String ruleId,
    required String recipientUserId,
    required String eventId,
    required String deduplicationKey,
  }) {
    debugPrint('NotificationEngine:\nDuplicate suppressed\nruleId: $ruleId\nrecipientUserId: $recipientUserId\neventId: $eventId\ndeduplicationKey: $deduplicationKey');
  }
}
