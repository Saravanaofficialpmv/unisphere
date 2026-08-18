import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/models/user_model.dart';

final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

class UserService {
  final FirebaseFirestore? _firestore;

  UserService({FirebaseFirestore? firestore}) : _firestore = firestore ?? _tryGetFirestore();

  static FirebaseFirestore? _tryGetFirestore() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  /// Get user document from central users/{uid}
  Future<UserModel?> getUser(String uid) async {
    final firestore = _firestore;
    if (uid.isEmpty || firestore == null) return null;
    try {
      final doc = await firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, uid);
      }
    } catch (e) {
      debugPrint('UserService getUser error: $e');
    }
    return null;
  }

  /// Watch real-time updates for user document users/{uid}
  Stream<UserModel?> watchUser(String uid) {
    final firestore = _firestore;
    if (uid.isEmpty || firestore == null) return Stream.value(null);
    return firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    }).handleError((e) {
      debugPrint('UserService watchUser error: $e');
      return null;
    });
  }

  /// Save or update central user document users/{uid}
  Future<void> saveUser(UserModel user) async {
    final firestore = _firestore;
    if (firestore == null || user.uid.isEmpty) return;
    try {
      final map = user.toMap();
      map['updatedAt'] = FieldValue.serverTimestamp();
      await firestore.collection('users').doc(user.uid).set(map, SetOptions(merge: true));
    } catch (e) {
      debugPrint('UserService saveUser error: $e');
    }
  }

  /// Update user lastLoginAt timestamp
  Future<void> updateLastLogin(String uid) async {
    final firestore = _firestore;
    if (firestore == null || uid.isEmpty) return;
    try {
      await firestore.collection('users').doc(uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('UserService updateLastLogin notice: $e');
    }
  }

  /// Query users by role
  Future<List<UserModel>> getUsersByRole(UserRole role) async {
    final firestore = _firestore;
    if (firestore == null) return [];
    try {
      final snap = await firestore.collection('users').where('role', isEqualTo: role.name).get();
      return snap.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      debugPrint('UserService getUsersByRole error: $e');
      return [];
    }
  }
}
