import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/models/staff_model.dart';

final staffServiceProvider = Provider<StaffService>((ref) {
  return StaffService();
});

class StaffService {
  final FirebaseFirestore? _firestore;

  StaffService({FirebaseFirestore? firestore}) : _firestore = firestore ?? _tryGetFirestore();

  static FirebaseFirestore? _tryGetFirestore() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  /// Get staff profile from staff/{uid}
  Future<StaffModel?> getStaffByUid(String uid) async {
    final firestore = _firestore;
    if (uid.isEmpty || firestore == null) return null;
    try {
      final doc = await firestore.collection('staff').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return StaffModel.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      debugPrint('StaffService getStaffByUid error: $e');
    }
    return null;
  }

  /// Save or update staff profile staff/{uid}
  Future<void> saveStaff(StaffModel staff) async {
    final firestore = _firestore;
    if (firestore == null || staff.userId.isEmpty) return;
    try {
      final data = staff.toMap();
      data['updatedAt'] = FieldValue.serverTimestamp();
      await firestore.collection('staff').doc(staff.userId).set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint('StaffService saveStaff error: $e');
    }
  }

  /// Get all staff members
  Future<List<StaffModel>> getStaffMembers({String? departmentId}) async {
    final firestore = _firestore;
    if (firestore == null) return [];
    try {
      Query query = firestore.collection('staff');
      if (departmentId != null && departmentId.isNotEmpty) {
        query = query.where('departmentId', isEqualTo: departmentId);
      }
      final snap = await query.get();
      return snap.docs.map((d) => StaffModel.fromMap(d.data() as Map<String, dynamic>, d.id)).toList();
    } catch (e) {
      debugPrint('StaffService getStaffMembers error: $e');
      return [];
    }
  }

  /// Get staff count
  Future<int> getStaffCount() async {
    final firestore = _firestore;
    if (firestore == null) return 0;
    try {
      final snap = await firestore.collection('staff').count().get();
      return snap.count ?? 0;
    } catch (e) {
      debugPrint('StaffService getStaffCount notice: $e');
      return 0;
    }
  }
}
