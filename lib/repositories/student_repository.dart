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

  /// Fetch single student record by UID or Registration Number
  Future<StudentModel?> getStudentByUserId(String uid) async {
    final firestore = _firestore;
    if (uid.isEmpty || firestore == null) return null;
    try {
      // 1. Try lookup by doc ID (regNo or UID)
      final docSnap = await firestore.collection('students').doc(uid).get();
      if (docSnap.exists && docSnap.data() != null) {
        return StudentModel.fromMap(docSnap.data()!, docSnap.id);
      }

      // 2. Query by user_id
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

  /// Fetch single student record directly by unique Register Number
  Future<StudentModel?> getStudentByRegisterNumber(String regNo) async {
    final firestore = _firestore;
    final cleanReg = regNo.trim();
    if (cleanReg.isEmpty || firestore == null) return null;
    try {
      final docSnap = await firestore.collection('students').doc(cleanReg).get();
      if (docSnap.exists && docSnap.data() != null) {
        return StudentModel.fromMap(docSnap.data()!, docSnap.id);
      }

      final snapshot = await firestore
          .collection('students')
          .where('register_number', isEqualTo: cleanReg)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        return StudentModel.fromMap(doc.data(), doc.id);
      }
    } catch (e) {
      debugPrint('Firestore getStudentByRegisterNumber error: $e');
    }
    return null;
  }

  /// Listen to real-time student updates by UID
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

  /// Listen to real-time student updates by Register Number
  Stream<StudentModel?> watchStudentByRegisterNumber(String regNo) {
    final firestore = _firestore;
    final cleanReg = regNo.trim();
    if (cleanReg.isEmpty || firestore == null) {
      return Stream.value(null);
    }
    return firestore
        .collection('students')
        .doc(cleanReg)
        .snapshots()
        .map((docSnap) {
      if (docSnap.exists && docSnap.data() != null) {
        return StudentModel.fromMap(docSnap.data()!, docSnap.id);
      }
      return null;
    }).handleError((e) {
      debugPrint('Student regNo stream notice: $e');
      return null;
    });
  }

  /// Save or update student record stored under unique Register Number doc ID
  Future<void> saveStudent(StudentModel student) async {
    final firestore = _firestore;
    if (firestore == null) return;
    try {
      final regNo = student.registerNumber.trim();
      if (regNo.isNotEmpty) {
        await firestore
            .collection('students')
            .doc(regNo)
            .set(student.toMap(), SetOptions(merge: true));
      }
      if (student.studentId.isNotEmpty) {
        await firestore
            .collection('students')
            .doc(student.studentId)
            .set(student.toMap(), SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Firestore saveStudent error: $e');
    }
  }
}
