import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/models/notification_model.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  final FirebaseFirestore? _firestore;

  NotificationService({FirebaseFirestore? firestore}) : _firestore = firestore ?? _tryGetFirestore();

  static FirebaseFirestore? _tryGetFirestore() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  /// Create central notification record under notifications/{notificationId}
  /// and populate individual user status under users/{uid}/notifications/{notificationId}
  Future<void> sendNotification(NotificationModel notification) async {
    final firestore = _firestore;
    if (firestore == null || notification.id.isEmpty) return;

    try {
      // 1. Write to central notifications/{notificationId}
      await firestore.collection('notifications').doc(notification.id).set(notification.toMap(), SetOptions(merge: true));

      // 2. Deliver per-user status in users/{uid}/notifications/{notificationId}
      if (notification.targetUserIds.isNotEmpty) {
        final batch = firestore.batch();
        for (final uid in notification.targetUserIds) {
          final userNotifRef = firestore.collection('users').doc(uid).collection('notifications').doc(notification.id);
          batch.set(
            userNotifRef,
            {
              'notificationId': notification.id,
              'isRead': false,
              'readAt': null,
              'deliveryStatus': 'delivered',
              'createdAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
        }
        await batch.commit();
      }
    } catch (e) {
      debugPrint('NotificationService sendNotification error: $e');
    }
  }

  /// Watch notifications for a specific user from users/{uid}/notifications subcollection
  Stream<List<NotificationModel>> watchUserNotifications(String uid) {
    final firestore = _firestore;
    if (firestore == null || uid.isEmpty) return Stream.value([]);
    try {
      return firestore.collection('users').doc(uid).collection('notifications').orderBy('createdAt', descending: true).snapshots().asyncMap((userNotifSnap) async {
        final List<NotificationModel> result = [];
        for (final doc in userNotifSnap.docs) {
          final notifId = doc.id;
          final isRead = doc.data()['isRead'] as bool? ?? false;
          final centralDoc = await firestore.collection('notifications').doc(notifId).get();
          if (centralDoc.exists && centralDoc.data() != null) {
            final model = NotificationModel.fromMap(centralDoc.data()!, centralDoc.id, currentUserId: uid);
            result.add(model.copyWith(isRead: isRead));
          }
        }
        return result;
      }).handleError((e) {
        debugPrint('NotificationService watchUserNotifications error: $e');
        return <NotificationModel>[];
      });
    } catch (e) {
      debugPrint('NotificationService watchUserNotifications exception: $e');
      return Stream.value([]);
    }
  }

  /// Mark individual user notification as read
  Future<void> markNotificationRead(String uid, String notificationId) async {
    final firestore = _firestore;
    if (firestore == null || uid.isEmpty || notificationId.isEmpty) return;
    try {
      final userNotifRef = firestore.collection('users').doc(uid).collection('notifications').doc(notificationId);
      await userNotifRef.update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
        'deliveryStatus': 'read',
      });

      // Also update array in central notification if applicable
      await firestore.collection('notifications').doc(notificationId).update({
        'read_status.$uid': true,
      });
    } catch (e) {
      debugPrint('NotificationService markNotificationRead notice: $e');
    }
  }
}
