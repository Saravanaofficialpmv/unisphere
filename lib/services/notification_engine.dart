import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:unisphere/models/notification_model.dart';
import 'package:unisphere/models/notification_recipient_model.dart';
import 'package:unisphere/models/notification_delivery_log_model.dart';
import 'package:unisphere/models/user_model.dart';
import 'package:unisphere/services/notification_duplicate_preventer.dart';

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

  /// Dispatch an automated notification triggered by a system condition rule.
  /// Enforces recipient + event + rule based deduplication.
  Future<bool> dispatchAutomatedNotification({
    required String ruleId,
    required String title,
    required String message,
    required String category,
    required String priority,
    required List<String> targetUserIds,
    required List<String> targetRoles,
    required String eventId, // Entity identifier e.g. hackathonId, attendanceDate_dept, placementId
    String? relatedModule,
    String? relatedRecordId,
    String? deepLink,
    String? currentStatusValue,
    int cooldownHours = 24,
  }) async {
    final now = DateTime.now();

    final allowedRecipients = <String>[];
    for (final userId in targetUserIds) {
      final key = NotificationDuplicatePreventer.buildDeduplicationKey(
        ruleId: ruleId,
        recipientUserId: userId,
        eventId: eventId,
      );

      final allowed = await _duplicatePreventer.shouldTrigger(
        ruleId: ruleId,
        recipientUserId: userId,
        eventId: eventId,
        cooldownHours: cooldownHours,
        currentStatusValue: currentStatusValue,
      );

      if (allowed) {
        allowedRecipients.add(userId);
        debugPrint('NotificationEngine:\nDispatching automated notification\nruleId: $ruleId\nrecipientUserId: $userId\neventId: $eventId\ndeduplicationKey: $key');
      }
    }

    if (allowedRecipients.isEmpty) {
      return false;
    }

    final notifId = 'notif_auto_${now.millisecondsSinceEpoch}_${ruleId.hashCode.abs()}';
    final firstUserId = allowedRecipients.first;
    final deduplicationKey = NotificationDuplicatePreventer.buildDeduplicationKey(
      ruleId: ruleId,
      recipientUserId: firstUserId,
      eventId: eventId,
    );

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
      recipientType: allowedRecipients.length == 1 ? 'user' : 'group',
      recipientUserIds: allowedRecipients,
      targetRoles: targetRoles,
      relatedModule: relatedModule,
      relatedRecordId: relatedRecordId ?? eventId,
      deepLink: deepLink,
      ruleId: ruleId,
      eventId: eventId,
      deduplicationKey: deduplicationKey,
      createdAt: now,
      sentAt: now,
      readStatus: {for (var uid in allowedRecipients) uid: false},
      deliveryStatus: {'in_app': 'delivered', 'push': 'sent'},
    );

    // Save notification & atomically record deduplication keys
    await _persistNotification(notification);

    for (final userId in allowedRecipients) {
      await _duplicatePreventer.claimAndRecord(
        ruleId: ruleId,
        recipientUserId: userId,
        eventId: eventId,
        notificationId: notifId,
        currentStatusValue: currentStatusValue,
      );
    }

    return true;
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
      deliveryStatus: {'in_app': isScheduled ? 'scheduled' : 'delivered', 'push': isScheduled ? 'pending' : 'sent'},
    );

    await _persistNotification(notification);
    return true;
  }

  bool _checkManualPermissions(UserModel author, String recipientType, String? targetDepartment) {
    switch (author.role) {
      case UserRole.admin:
        return true;
      case UserRole.hod:
        final authorDept = author.metadata?['department'] ?? author.metadata?['department_name'];
        if (targetDepartment == null || authorDept == null) return true;
        return targetDepartment.toLowerCase() == authorDept.toString().toLowerCase();
      case UserRole.staff:
        return recipientType != 'all' && recipientType != 'college';
      case UserRole.student:
      case UserRole.parent:
      default:
        return false;
    }
  }

  Future<void> _persistNotification(NotificationModel notification) async {
    final firestore = _firestore;
    if (firestore == null) {
      debugPrint('Firestore unavailable, notification saved in-memory: ${notification.id}');
      return;
    }

    try {
      await firestore.collection('notifications').doc(notification.id).set(notification.toMap(), SetOptions(merge: true));

      final batch = firestore.batch();
      for (final userId in notification.recipientUserIds) {
        final recipientId = '${notification.id}_$userId';
        final recipientDoc = firestore.collection('notification_recipients').doc(recipientId);
        final recipientModel = NotificationRecipientModel(
          id: recipientId,
          notificationId: notification.id,
          userId: userId,
          userRole: notification.targetRoles.isNotEmpty ? notification.targetRoles.first : 'user',
          isRead: false,
          createdAt: notification.createdAt,
          priority: notification.priority,
          category: notification.category,
          type: notification.type,
        );
        batch.set(recipientDoc, recipientModel.toMap(), SetOptions(merge: true));
      }
      await batch.commit();

      final logId = 'log_${notification.id}';
      final deliveryLog = NotificationDeliveryLogModel(
        id: logId,
        notificationId: notification.id,
        recipientId: notification.recipientUserIds.join(','),
        channel: 'in_app',
        status: 'success',
        timestamp: DateTime.now(),
      );
      await firestore.collection('notification_delivery_logs').doc(logId).set(deliveryLog.toMap());
    } catch (e) {
      debugPrint('NotificationEngine persistence error: $e');
    }
  }
}
