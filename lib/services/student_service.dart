import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/models/student_model.dart';

final studentServiceProvider = Provider<StudentService>((ref) {
  return StudentService();
});

class StudentService {
  final FirebaseFirestore? _firestore;

  StudentService({FirebaseFirestore? firestore}) : _firestore = firestore ?? _tryGetFirestore();

  static FirebaseFirestore? _tryGetFirestore() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  /// Get student record by Auth UID from students/{uid}
  Future<StudentModel?> getStudentByUid(String uid) async {
    final firestore = _firestore;
    if (uid.isEmpty || firestore == null) return null;
    try {
      final doc = await firestore.collection('students').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return StudentModel.fromMap(doc.data()!, doc.id);
      }

      final query = await firestore.collection('students').where('userId', isEqualTo: uid).limit(1).get();
      if (query.docs.isNotEmpty) {
        return StudentModel.fromMap(query.docs.first.data(), query.docs.first.id);
      }
    } catch (e) {
      debugPrint('StudentService getStudentByUid error: $e');
    }
    return null;
  }

  /// Watch real-time student record from students/{uid}
  Stream<StudentModel?> watchStudentByUid(String uid) {
    final firestore = _firestore;
    if (uid.isEmpty || firestore == null) return Stream.value(null);
    return firestore.collection('students').doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return StudentModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    }).handleError((e) {
      debugPrint('StudentService watchStudentByUid error: $e');
      return null;
    });
  }

  /// Save or update student record under students/{uid}
  Future<void> saveStudent(StudentModel student) async {
    final firestore = _firestore;
    if (firestore == null) return;
    try {
      final targetId = student.userId.isNotEmpty ? student.userId : student.studentId;
      if (targetId.isEmpty) return;

      final data = student.toMap();
      data['updatedAt'] = FieldValue.serverTimestamp();
      await firestore.collection('students').doc(targetId).set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint('StudentService saveStudent error: $e');
    }
  }

  /// Get all students (with optional department filter)
  Future<List<StudentModel>> getStudents({String? departmentId, String? batchId}) async {
    final firestore = _firestore;
    if (firestore == null) return [];
    try {
      Query query = firestore.collection('students');
      if (departmentId != null && departmentId.isNotEmpty) {
        query = query.where('departmentId', isEqualTo: departmentId);
      }
      if (batchId != null && batchId.isNotEmpty) {
        query = query.where('batchId', isEqualTo: batchId);
      }
      final snap = await query.get();
      return snap.docs.map((d) => StudentModel.fromMap(d.data() as Map<String, dynamic>, d.id)).toList();
    } catch (e) {
      debugPrint('StudentService getStudents error: $e');
      return [];
    }
  }

  /// Get student count
  Future<int> getStudentCount() async {
    final firestore = _firestore;
    if (firestore == null) return 0;
    try {
      final snap = await firestore.collection('students').count().get();
      return snap.count ?? 0;
    } catch (e) {
      debugPrint('StudentService getStudentCount notice: $e');
      return 0;
    }
  }
}
