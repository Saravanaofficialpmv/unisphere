import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/models/admin_model.dart';

final adminServiceProvider = Provider<AdminService>((ref) {
  return AdminService();
});

class AdminService {
  final FirebaseFirestore? _firestore;

  AdminService({FirebaseFirestore? firestore}) : _firestore = firestore ?? _tryGetFirestore();

  static FirebaseFirestore? _tryGetFirestore() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  /// Get admin profile from admins/{uid}
  Future<AdminModel?> getAdminByUid(String uid) async {
    final firestore = _firestore;
    if (uid.isEmpty || firestore == null) return null;
    try {
      final doc = await firestore.collection('admins').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return AdminModel.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      debugPrint('AdminService getAdminByUid error: $e');
    }
    return null;
  }

  /// Save or update admin profile under admins/{uid}
  Future<void> saveAdmin(AdminModel admin) async {
    final firestore = _firestore;
    if (firestore == null || admin.userId.isEmpty) return;
    try {
      final data = admin.toMap();
      data['updatedAt'] = FieldValue.serverTimestamp();
      await firestore.collection('admins').doc(admin.userId).set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint('AdminService saveAdmin error: $e');
    }
  }
}
