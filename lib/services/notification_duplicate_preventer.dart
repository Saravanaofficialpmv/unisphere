import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class RuleExecutionRecord {
  final String ruleId;
  final String targetId; // studentUid, staffUid, etc.
  final DateTime lastTriggeredAt;
  final String? lastStatusValue; // e.g. "74.5%" or "ABSENT_2_DAYS" or "OVERDUE_3_DAYS"
  final DateTime cooldownUntil;

  RuleExecutionRecord({
    required this.ruleId,
    required this.targetId,
    required this.lastTriggeredAt,
    this.lastStatusValue,
    required this.cooldownUntil,
  });

  factory RuleExecutionRecord.fromMap(Map<String, dynamic> map, String docId) {
    final parts = docId.split('_');
    final rId = parts.isNotEmpty ? parts[0] : 'rule';
    final tId = parts.length > 1 ? parts.sublist(1).join('_') : 'target';

    return RuleExecutionRecord(
      ruleId: map['rule_id'] ?? rId,
      targetId: map['target_id'] ?? tId,
      lastTriggeredAt: map['last_triggered_at'] != null
          ? DateTime.tryParse(map['last_triggered_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      lastStatusValue: map['last_status_value']?.toString(),
      cooldownUntil: map['cooldown_until'] != null
          ? DateTime.tryParse(map['cooldown_until'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rule_id': ruleId,
      'target_id': targetId,
      'last_triggered_at': lastTriggeredAt.toIso8601String(),
      'last_status_value': lastStatusValue,
      'cooldown_until': cooldownUntil.toIso8601String(),
    };
  }
}

class NotificationDuplicatePreventer {
  final FirebaseFirestore? _firestore;
  static final Map<String, RuleExecutionRecord> _localCache = {};

  NotificationDuplicatePreventer({FirebaseFirestore? firestore})
      : _firestore = firestore ?? _tryGetFirestore();

  static FirebaseFirestore? _tryGetFirestore() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  /// Check if a notification rule should trigger for targetId.
  /// Returns `true` if allowed, `false` if duplicate/suppressed.
  Future<bool> shouldTrigger({
    required String ruleId,
    required String targetId,
    required int cooldownHours,
    String? currentStatusValue,
  }) async {
    final key = '${ruleId}_$targetId';
    final now = DateTime.now();

    // 1. Check local cache or Firestore execution history
    RuleExecutionRecord? record = _localCache[key];
    if (record == null && _firestore != null) {
      try {
        final doc = await _firestore
            .collection('notification_rule_execution_history')
            .doc(key)
            .get();
        if (doc.exists && doc.data() != null) {
          record = RuleExecutionRecord.fromMap(doc.data()!, doc.id);
          _localCache[key] = record;
        }
      } catch (e) {
        debugPrint('Error fetching execution history: $e');
      }
    }

    if (record == null) {
      // Never triggered before -> ALLOW
      return true;
    }

    // 2. Check if status value meaningfully changed (e.g. threshold crossed from warning to critical)
    if (currentStatusValue != null && record.lastStatusValue != currentStatusValue) {
      // Status state changed! -> ALLOW
      return true;
    }

    // 3. Check if cooldown has passed
    if (now.isAfter(record.cooldownUntil)) {
      // Cooldown expired -> ALLOW
      return true;
    }

    // Otherwise SUPPRESS (prevent duplicate)
    return false;
  }

  /// Log successful rule execution to prevent duplicate notifications until cooldown or status change.
  Future<void> recordExecution({
    required String ruleId,
    required String targetId,
    required int cooldownHours,
    String? currentStatusValue,
  }) async {
    final key = '${ruleId}_$targetId';
    final now = DateTime.now();
    final cooldownUntil = now.add(Duration(hours: cooldownHours));

    final record = RuleExecutionRecord(
      ruleId: ruleId,
      targetId: targetId,
      lastTriggeredAt: now,
      lastStatusValue: currentStatusValue,
      cooldownUntil: cooldownUntil,
    );

    _localCache[key] = record;

    if (_firestore != null) {
      try {
        await _firestore
            .collection('notification_rule_execution_history')
            .doc(key)
            .set(record.toMap());
      } catch (e) {
        debugPrint('Error saving execution history: $e');
      }
    }
  }
}
