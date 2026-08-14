import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/models/exam_model.dart';
import 'package:unisphere/models/mark_model.dart';

final academicRepositoryProvider = Provider<AcademicRepository>((ref) {
  return AcademicRepository();
});

class AcademicRepository {
  final FirebaseFirestore? _firestore;

  AcademicRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? _tryGetFirestore();

  static FirebaseFirestore? _tryGetFirestore() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  /// Watch real-time student internal marks
  Stream<List<MarkModel>> watchStudentMarks(String studentUid) {
    final firestore = _firestore;
    if (studentUid.isEmpty || firestore == null) return Stream.value([]);

    return firestore
        .collection('marks')
        .where('student_uid', isEqualTo: studentUid)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return MarkModel.fromMap(data);
            }).toList())
        .handleError((e) {
      debugPrint('Firestore marks stream error: $e');
      return <MarkModel>[];
    });
  }

  /// Watch exams
  Stream<List<ExamModel>> watchExams() {
    final firestore = _firestore;
    if (firestore == null) return Stream.value([]);

    return firestore
        .collection('exams')
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return ExamModel.fromMap(data);
            }).toList())
        .handleError((e) {
      debugPrint('Firestore exams stream error: $e');
      return <ExamModel>[];
    });
  }

  /// Save student mark record
  Future<void> saveMark(MarkModel mark) async {
    final firestore = _firestore;
    if (firestore == null) return;
    try {
      await firestore
          .collection('marks')
          .doc(mark.id)
          .set(mark.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore saveMark error: $e');
    }
  }
}
