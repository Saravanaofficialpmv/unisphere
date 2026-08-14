import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/models/notification_model.dart';

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

  /// Watch targeted notifications for a user or broadcast 'ALL'
  Stream<List<NotificationModel>> watchUserNotifications(String targetUserId) {
    final firestore = _firestore;
    if (firestore == null) return Stream.value([]);

    return firestore
        .collection('notifications')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
          .where((n) => n.targetUserId == 'ALL' || n.targetUserId == targetUserId)
          .toList();
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
          .set(notification.toMap());
    } catch (e) {
      debugPrint('Firestore sendNotification error: $e');
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final firestore = _firestore;
    if (firestore == null) return;
    try {
      await firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'is_read': true});
    } catch (e) {
      debugPrint('Firestore markAsRead error: $e');
    }
  }
}
