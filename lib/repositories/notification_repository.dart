import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/models/notification_model.dart';
import 'package:unisphere/models/notification_rule_model.dart';
import 'package:unisphere/models/manual_notification_draft_model.dart';
import 'package:unisphere/models/notification_delivery_log_model.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

class NotificationRepository {
  final FirebaseFirestore? _firestore;

  NotificationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? _tryGetFirestore();

  static FirebaseFirestore? _tryGetFirestore() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  /// Watch targeted notifications for a user based on UID, Role, and Department
  Stream<List<NotificationModel>> watchUserNotifications(
    String targetUserId, {
    String? userRole,
    String? department,
  }) {
    final firestore = _firestore;
    if (firestore == null) return Stream.value([]);

    return firestore
        .collection('notifications')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => NotificationModel.fromMap(doc.data(), doc.id, currentUserId: targetUserId))
          .where((n) {
        // 1. Direct recipient match
        if (n.recipientUserIds.contains(targetUserId) || n.recipientUserIds.contains('ALL')) {
          return true;
        }
        // 2. Target Role match
        if (userRole != null && n.targetRoles.map((r) => r.toLowerCase()).contains(userRole.toLowerCase())) {
          // If department specified on notification, check department match
          if (n.targetDepartment != null && department != null) {
            return n.targetDepartment!.toLowerCase() == department.toLowerCase();
          }
          return true;
        }
        // 3. Admin view sees all
        if (userRole?.toLowerCase() == 'admin' || userRole?.toLowerCase() == 'administrator') {
          return true;
        }
        return false;
      }).toList();
    }).handleError((e) {
      debugPrint('Firestore notifications stream error: $e');
      return <NotificationModel>[];
    });
  }

  /// Send notification
  Future<void> sendNotification(NotificationModel notification) async {
    final firestore = _firestore;
    if (firestore == null) return;
    try {
      await firestore
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore sendNotification error: $e');
    }
  }

  /// Mark single notification as read for user
  Future<void> markAsRead(String notificationId, {String? userId}) async {
    final firestore = _firestore;
    if (firestore == null) return;
    try {
      final updates = <String, dynamic>{
        'is_read': true,
      };
      if (userId != null) {
        updates['read_status.$userId'] = true;
      }
      await firestore
          .collection('notifications')
          .doc(notificationId)
          .update(updates);
    } catch (e) {
      debugPrint('Firestore markAsRead error: $e');
    }
  }

  /// Mark all notifications as read for user
  Future<void> markAllAsRead(String userId) async {
    final firestore = _firestore;
    if (firestore == null) return;
    try {
      final snap = await firestore.collection('notifications').get();
      final batch = firestore.batch();
      for (var doc in snap.docs) {
        batch.update(doc.reference, {
          'is_read': true,
          'read_status.$userId': true,
        });
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Firestore markAllAsRead error: $e');
    }
  }

  // ==========================================
  // NOTIFICATION RULES CRUD
  // ==========================================
  Stream<List<NotificationRuleModel>> watchNotificationRules() {
    final firestore = _firestore;
    if (firestore == null) return Stream.value([]);

    return firestore.collection('notification_rules').snapshots().map((snap) {
      return snap.docs.map((doc) => NotificationRuleModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> saveNotificationRule(NotificationRuleModel rule) async {
    final firestore = _firestore;
    if (firestore == null) return;
    try {
      await firestore.collection('notification_rules').doc(rule.ruleId).set(rule.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving notification rule: $e');
    }
  }

  // ==========================================
  // DRAFTS CRUD
  // ==========================================
  Future<List<ManualNotificationDraftModel>> fetchDrafts(String authorId) async {
    final firestore = _firestore;
    if (firestore == null) return [];
    try {
      final snap = await firestore
          .collection('manual_notification_drafts')
          .where('author_id', isEqualTo: authorId)
          .get();
      return snap.docs.map((doc) => ManualNotificationDraftModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      debugPrint('Error fetching drafts: $e');
      return [];
    }
  }

  Future<void> saveDraft(ManualNotificationDraftModel draft) async {
    final firestore = _firestore;
    if (firestore == null) return;
    try {
      await firestore.collection('manual_notification_drafts').doc(draft.id).set(draft.toMap());
    } catch (e) {
      debugPrint('Error saving draft: $e');
    }
  }

  Future<void> deleteDraft(String draftId) async {
    final firestore = _firestore;
    if (firestore == null) return;
    try {
      await firestore.collection('manual_notification_drafts').doc(draftId).delete();
    } catch (e) {
      debugPrint('Error deleting draft: $e');
    }
  }

  // ==========================================
  // DELIVERY LOGS
  // ==========================================
  Future<List<NotificationDeliveryLogModel>> fetchDeliveryLogs() async {
    final firestore = _firestore;
    if (firestore == null) return [];
    try {
      final snap = await firestore
          .collection('notification_delivery_logs')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();
      return snap.docs.map((doc) => NotificationDeliveryLogModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      debugPrint('Error fetching delivery logs: $e');
      return [];
    }
  }
}
