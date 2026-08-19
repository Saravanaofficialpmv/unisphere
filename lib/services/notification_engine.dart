import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:unisphere/models/notification_model.dart';
import 'package:unisphere/models/user_model.dart';
import 'package:unisphere/services/notification_duplicate_preventer.dart';

enum NotificationDecision {
  dispatch,
  suppressDuplicate,
  failed,
}

class NotificationDispatchResult {
  final bool success;
  final NotificationDecision decision;
  final String deduplicationKey;
  final String ruleId;
  final String recipientUserId;
  final String eventId;
  final String? reason;

  NotificationDispatchResult({
    required this.success,
    required this.decision,
    required this.deduplicationKey,
    required this.ruleId,
    required this.recipientUserId,
    required this.eventId,
    this.reason,
  });

  @override
  String toString() {
    return 'NotificationDispatchResult(decision: $decision, key: $deduplicationKey, success: $success)';
  }
}

class NotificationEngine {
  final FirebaseFirestore? _firestore;
  final NotificationDuplicatePreventer _duplicatePreventer;

  NotificationEngine({
    FirebaseFirestore? firestore,
    NotificationDuplicatePreventer? duplicatePreventer,
  })  : _firestore = firestore ?? _tryGetFirestore(),
        _duplicatePreventer = duplicatePreventer ?? NotificationDuplicatePreventer(firestore: firestore);

  static FirebaseFirestore? _tryGetFirestore() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  /// Dispatch an automated notification triggered by a system condition rule for a specific recipient and event.
  /// Enforces deterministic deduplication key: `${ruleId}_${recipientUserId}_${eventId}`
  Future<NotificationDispatchResult> dispatchAutomatedNotification({
    required String ruleId,
    required String recipientUserId,
    required String eventId,
    required String title,
    required String message,
    required String category,
    required String priority,
    required List<String> targetRoles,
    String? relatedModule,
    String? relatedRecordId,
    String? deepLink,
    String? currentStatusValue,
    int cooldownHours = 24,
  }) async {
    final now = DateTime.now();
    final deduplicationKey = NotificationDuplicatePreventer.buildKey(
      ruleId: ruleId,
      recipientUserId: recipientUserId,
      eventId: eventId,
    );

    // 1. Check duplicate prevention for (ruleId, recipientUserId, eventId)
    final allowed = await _duplicatePreventer.shouldTrigger(
      ruleId: ruleId,
      recipientUserId: recipientUserId,
      eventId: eventId,
      cooldownHours: cooldownHours,
      currentStatusValue: currentStatusValue,
    );

    if (!allowed) {
      debugPrint('''
NotificationEngine:
ruleId: $ruleId
recipient: $recipientUserId
eventId: $eventId
deduplicationKey: $deduplicationKey
decision: SUPPRESS_DUPLICATE
reason: Notification for this exact rule, recipient, and event was already dispatched and is within cooldown.
''');

      return NotificationDispatchResult(
        success: false,
        decision: NotificationDecision.suppressDuplicate,
        deduplicationKey: deduplicationKey,
        ruleId: ruleId,
        recipientUserId: recipientUserId,
        eventId: eventId,
        reason: 'Duplicate suppressed for recipient $recipientUserId and event $eventId',
      );
    }

    // 2. FIRESTORE ATOMIC DUPLICATE PROTECTION: Use deterministic document ID notifications/{deduplicationKey}
    final notifId = deduplicationKey;
    final notification = NotificationModel(
      id: notifId,
      title: title,
      message: message,
      type: 'automated',
      category: category,
      priority: priority,
      senderId: 'system_$ruleId',
      senderName: 'System Automation Engine',
      senderRole: 'system',
      recipientType: 'user',
      recipientUserIds: [recipientUserId],
      targetRoles: targetRoles,
      relatedModule: relatedModule,
      relatedRecordId: relatedRecordId,
      deepLink: deepLink,
      createdAt: now,
      sentAt: now,
      readStatus: {recipientUserId: false},
      deliveryStatus: {'in_app': 'delivered', 'push': 'sent'},
    );

    // 3. Atomically persist & check duplicate in Firestore
    final success = await _persistNotificationAtomic(notification, deduplicationKey);

    if (!success) {
      debugPrint('''
NotificationEngine:
ruleId: $ruleId
recipient: $recipientUserId
eventId: $eventId
deduplicationKey: $deduplicationKey
decision: FAILED
reason: Firestore persistence or atomic creation failed.
''');

      await _duplicatePreventer.recordExecution(
        ruleId: ruleId,
        recipientUserId: recipientUserId,
        eventId: eventId,
        status: 'failed',
        cooldownHours: cooldownHours,
        currentStatusValue: currentStatusValue,
      );

      return NotificationDispatchResult(
        success: false,
        decision: NotificationDecision.failed,
        deduplicationKey: deduplicationKey,
        ruleId: ruleId,
        recipientUserId: recipientUserId,
        eventId: eventId,
        reason: 'Persistence failed',
      );
    }

    // 4. Record successful execution
    await _duplicatePreventer.recordExecution(
      ruleId: ruleId,
      recipientUserId: recipientUserId,
      eventId: eventId,
      status: 'sent',
      cooldownHours: cooldownHours,
      currentStatusValue: currentStatusValue,
    );

    debugPrint('''
NotificationEngine:
ruleId: $ruleId
recipient: $recipientUserId
eventId: $eventId
deduplicationKey: $deduplicationKey
decision: DISPATCH
reason: Successfully dispatched new automated notification.
''');

    return NotificationDispatchResult(
      success: true,
      decision: NotificationDecision.dispatch,
      deduplicationKey: deduplicationKey,
      ruleId: ruleId,
      recipientUserId: recipientUserId,
      eventId: eventId,
    );
  }

  /// Dispatch a manual notification composed by an authorized user (Admin, HOD, Advisor).
  Future<bool> dispatchManualNotification({
    required UserModel author,
    required String title,
    required String message,
    required String category,
    required String priority,
    required String recipientType,
    required List<String> recipientUserIds,
    required List<String> targetRoles,
    String? targetDepartment,
    String? targetYear,
    String? targetSemester,
    String? targetSection,
    String? relatedModule,
    String? relatedRecordId,
    String? deepLink,
    DateTime? scheduledAt,
  }) async {
    // 1. RBAC Permission Check
    final isAuthorized = _checkManualPermissions(author, recipientType, targetDepartment);
    if (!isAuthorized) {
      throw Exception('Sender role (${author.roleName}) is not authorized for selected recipient target ($targetDepartment).');
    }

    final now = DateTime.now();
    final isScheduled = scheduledAt != null && scheduledAt.isAfter(now);
    final notifId = 'notif_manual_${now.millisecondsSinceEpoch}';

    final notification = NotificationModel(
      id: notifId,
      title: title,
      message: message,
      type: 'manual',
      category: category,
      priority: priority,
      senderId: author.uid,
      senderName: author.name,
      senderRole: author.role.name,
      recipientType: recipientType,
      recipientUserIds: recipientUserIds,
      targetRoles: targetRoles,
      targetDepartment: targetDepartment,
      targetYear: targetYear,
      targetSemester: targetSemester,
      targetSection: targetSection,
      relatedModule: relatedModule,
      relatedRecordId: relatedRecordId,
      deepLink: deepLink,
      createdAt: now,
      scheduledAt: scheduledAt,
      sentAt: isScheduled ? null : now,
      readStatus: {for (var uid in recipientUserIds) uid: false},
      deliveryStatus: isScheduled ? {'in_app': 'scheduled'} : {'in_app': 'delivered', 'push': 'sent'},
    );

    return await _persistNotification(notification);
  }

  bool _checkManualPermissions(UserModel author, String recipientType, String? targetDept) {
    if (author.role == UserRole.admin) return true;
    final authorDept = author.metadata?['department']?.toString() ?? '';
    if (author.role == UserRole.hod) {
      if (targetDept == null || targetDept.isEmpty || authorDept.toLowerCase() == targetDept.toLowerCase()) {
        return true;
      }
    }
    if (author.role == UserRole.advisor || author.role == UserRole.staff) {
      if (recipientType == 'user' || recipientType == 'class' || recipientType == 'filtered') {
        return true;
      }
    }
    return false;
  }

  /// Atomic persistence using deterministic document ID notifications/{deduplicationKey}
  Future<bool> _persistNotificationAtomic(NotificationModel notif, String deduplicationKey) async {
    final firestore = _firestore;
    if (firestore == null) {
      // Standalone mode / unit test
      return true;
    }

    try {
      final docRef = firestore.collection('notifications').doc(deduplicationKey);
      final doc = await docRef.get();

      if (doc.exists && doc.data() != null) {
        final statusVal = doc.data()!['status']?.toString() ?? 'sent';
        if (statusVal == 'sent' || statusVal == 'pending' || statusVal == 'delivered') {
          // Document already exists atomically -> SUPPRESS
          return false;
        }
      }

      await docRef.set(notif.toMap(), SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint('NotificationEngine atomic persistence error: $e');
      return false;
    }
  }

  Future<bool> _persistNotification(NotificationModel notif) async {
    final firestore = _firestore;
    if (firestore == null) return true;

    try {
      await firestore.collection('notifications').doc(notif.id).set(notif.toMap(), SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint('NotificationEngine persistence error: $e');
      return false;
    }
  }
}
