import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/models/student_model.dart';

final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  return StudentRepository();
});

class StudentRepository {
  final FirebaseFirestore? _firestore;

  StudentRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? _tryGetFirestore();

  static FirebaseFirestore? _tryGetFirestore() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  /// Fetch single student record by UID
  Future<StudentModel?> getStudentByUserId(String uid) async {
    final firestore = _firestore;
    if (uid.isEmpty || firestore == null) return null;
    try {
      final snapshot = await firestore
          .collection('students')
          .where('user_id', isEqualTo: uid)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        return StudentModel.fromMap(doc.data(), doc.id);
      }
    } catch (e) {
      debugPrint('Firestore getStudentByUserId error: $e');
    }
    return null;
  }

  /// Listen to real-time student updates
  Stream<StudentModel?> watchStudentByUserId(String uid) {
    final firestore = _firestore;
    if (uid.isEmpty || firestore == null) {
      return Stream.value(null);
    }
    return firestore
        .collection('students')
        .where('user_id', isEqualTo: uid)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        return StudentModel.fromMap(doc.data(), doc.id);
      }
      return null;
    }).handleError((e) {
      debugPrint('Student snapshot stream notice: $e');
      return null;
    });
  }

  /// Save or update student record
  Future<void> saveStudent(StudentModel student) async {
    final firestore = _firestore;
    if (firestore == null) return;
    try {
      await firestore
          .collection('students')
          .doc(student.studentId)
          .set(student.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore saveStudent error: $e');
    }
  }
}
