import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/models/attendance_model.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository();
});

class AttendanceRepository {
  final FirebaseFirestore? _firestore;

  AttendanceRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? _tryGetFirestore();

  static FirebaseFirestore? _tryGetFirestore() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  /// Listen to real-time attendance records for a specific student
  Stream<List<AttendanceRecord>> watchStudentAttendance(String studentUid) {
    final firestore = _firestore;
    if (studentUid.isEmpty || firestore == null) {
      return Stream.value([]);
    }
    return firestore
        .collection('attendance')
        .where('student_uid', isEqualTo: studentUid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return AttendanceRecord.fromMap(data);
            }).toList())
        .handleError((e) {
      debugPrint('Firestore attendance stream error: $e');
      return <AttendanceRecord>[];
    });
  }

  /// Fetch attendance records synchronously
  Future<List<AttendanceRecord>> getStudentAttendance(String studentUid) async {
    final firestore = _firestore;
    if (studentUid.isEmpty || firestore == null) return [];
    try {
      final snapshot = await firestore
          .collection('attendance')
          .where('student_uid', isEqualTo: studentUid)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return AttendanceRecord.fromMap(data);
      }).toList();
    } catch (e) {
      debugPrint('Firestore getStudentAttendance error: $e');
      return [];
    }
  }

  /// Mark or log new attendance record
  Future<void> markAttendance(AttendanceRecord record) async {
    final firestore = _firestore;
    if (firestore == null) return;
    try {
      await firestore
          .collection('attendance')
          .doc(record.id)
          .set(record.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore markAttendance error: $e');
    }
  }

  /// Calculate real-time overall attendance percentage from raw logs
  double calculateAttendancePercentage(List<AttendanceRecord> records) {
    if (records.isEmpty) return 0.0;
    int totalClasses = records.length;
    int attendedClasses = records.where((r) => r.status == AttendanceStatus.present || r.status == AttendanceStatus.onDuty).length;
    return double.parse(((attendedClasses / totalClasses) * 100).toStringAsFixed(1));
  }
}
