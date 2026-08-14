import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/models/user_model.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

class ProfileRepository {
  final FirebaseFirestore? _firestore;

  ProfileRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? _tryGetFirestore();

  static FirebaseFirestore? _tryGetFirestore() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  /// Watch real-time profile updates for logged-in user
  Stream<UserModel?> watchUserProfile(String uid) {
    final firestore = _firestore;
    if (uid.isEmpty || firestore == null) return Stream.value(null);

    return firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return UserModel.fromMap(snapshot.data()!, uid);
      }
      return null;
    }).handleError((e) {
      debugPrint('Firestore profile stream notice: $e');
      return null;
    });
  }

  /// Update user profile details in Firestore
  Future<void> updateProfile(UserModel user) async {
    final firestore = _firestore;
    if (firestore == null) return;
    try {
      await firestore
          .collection('users')
          .doc(user.uid)
          .set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore updateProfile error: $e');
    }
  }
}
