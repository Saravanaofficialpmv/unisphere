import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/models/batch_model.dart';
import 'package:unisphere/models/department_model.dart';

final departmentServiceProvider = Provider<DepartmentService>((ref) {
  return DepartmentService();
});

class DepartmentService {
  final FirebaseFirestore? _firestore;

  DepartmentService({FirebaseFirestore? firestore}) : _firestore = firestore ?? _tryGetFirestore();

  static FirebaseFirestore? _tryGetFirestore() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  /// Get all departments
  Future<List<DepartmentModel>> getDepartments() async {
    final firestore = _firestore;
    if (firestore == null) return [];
    try {
      final snap = await firestore.collection('departments').get();
      return snap.docs.map((d) => DepartmentModel.fromMap(d.data(), d.id)).toList();
    } catch (e) {
      debugPrint('DepartmentService getDepartments error: $e');
      return [];
    }
  }

  /// Save or update department
  Future<void> saveDepartment(DepartmentModel dept) async {
    final firestore = _firestore;
    if (firestore == null || dept.departmentId.isEmpty) return;
    try {
      final data = dept.toMap();
      data['updatedAt'] = FieldValue.serverTimestamp();
      await firestore.collection('departments').doc(dept.departmentId).set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint('DepartmentService saveDepartment error: $e');
    }
  }

  /// Get batches for a department
  Future<List<BatchModel>> getBatches({String? departmentId}) async {
    final firestore = _firestore;
    if (firestore == null) return [];
    try {
      Query query = firestore.collection('batches');
      if (departmentId != null && departmentId.isNotEmpty) {
        query = query.where('departmentId', isEqualTo: departmentId);
      }
      final snap = await query.get();
      return snap.docs.map((d) => BatchModel.fromMap(d.data() as Map<String, dynamic>, d.id)).toList();
    } catch (e) {
      debugPrint('DepartmentService getBatches error: $e');
      return [];
    }
  }

  /// Save or update batch
  Future<void> saveBatch(BatchModel batch) async {
    final firestore = _firestore;
    if (firestore == null || batch.batchId.isEmpty) return;
    try {
      final data = batch.toMap();
      data['updatedAt'] = FieldValue.serverTimestamp();
      await firestore.collection('batches').doc(batch.batchId).set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint('DepartmentService saveBatch error: $e');
    }
  }
}
