import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/models/parent_model.dart';
import 'package:unisphere/models/parent_portal_types.dart';

final parentServiceProvider = Provider<ParentService>((ref) {
  return ParentService();
});

class ParentService {
  final FirebaseFirestore? _firestore;

  ParentService({FirebaseFirestore? firestore}) : _firestore = firestore ?? _tryGetFirestore();

  static FirebaseFirestore? _tryGetFirestore() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  /// Get parent profile by parentId or student UID reference
  Future<ParentModel?> getParentById(String parentId) async {
    final firestore = _firestore;
    if (parentId.isEmpty || firestore == null) return null;
    try {
      final doc = await firestore.collection('parents').doc(parentId).get();
      if (doc.exists && doc.data() != null) {
        return ParentModel.fromMap(doc.data()!, doc.id);
      }

      // Fallback lookup by studentId array
      final snap = await firestore.collection('parents').where('studentIds', arrayContains: parentId).limit(1).get();
      if (snap.docs.isNotEmpty) {
        return ParentModel.fromMap(snap.docs.first.data(), snap.docs.first.id);
      }
    } catch (e) {
      debugPrint('ParentService getParentById error: $e');
    }
    return null;
  }

  /// Save or update parent profile under parents/{parentId}
  Future<void> saveParent(ParentModel parent) async {
    final firestore = _firestore;
    if (firestore == null || parent.parentId.isEmpty) return;
    try {
      final data = parent.toMap();
      data['updatedAt'] = FieldValue.serverTimestamp();
      await firestore.collection('parents').doc(parent.parentId).set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint('ParentService saveParent error: $e');
    }
  }

  /// Returns default mapped student wards for parent dashboard
  List<ParentStudentWard> getDefaultStudentWards() {
    return [
      ParentStudentWard(
        id: 'ward_23cse1042',
        name: 'Arun Kumar',
        regNo: '23CSE1042',
        department: 'Computer Science & Engineering',
        yearSection: 'CSE • III Year • VI Semester',
        currentYear: 'III Year',
        currentSemester: 'VI Semester',
        photoUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=200',
        avatarInitials: 'AK',
        attendancePercent: 0.87,
        presentCount: 142,
        absentCount: 15,
        leaveOdCount: 6,
        cgpa: '8.2',
        academicTrend: '+0.3 from Sem V',
        academicStatus: 'Good Standing',
        statusColor: const Color(0xFF10B981),
        totalFees: 50000,
        paidFees: 37500,
        pendingFees: 12500,
        feeDueDate: DateTime(2026, 9, 15),
        feeStatus: 'Payment Pending',
        isFeeOverdue: false,
        subjectGrades: [
          ParentSubjectGrade(subjectCode: 'MA601', subjectName: 'Discrete Mathematics', grade: 'A', color: const Color(0xFF2563EB)),
          ParentSubjectGrade(subjectCode: 'CS602', subjectName: 'Database Management (DBMS)', grade: 'A+', color: const Color(0xFF059669)),
          ParentSubjectGrade(subjectCode: 'CS603', subjectName: 'Operating Systems', grade: 'B+', color: const Color(0xFFD97706)),
          ParentSubjectGrade(subjectCode: 'CS604', subjectName: 'Computer Networks', grade: 'A', color: const Color(0xFF7C3AED)),
        ],
      ),
      ParentStudentWard(
        id: 'ward_24ece2018',
        name: 'Kavya Kumar',
        regNo: '24ECE2018',
        department: 'Electronics & Comm. Engineering',
        yearSection: 'ECE • II Year • IV Semester',
        currentYear: 'II Year',
        currentSemester: 'IV Semester',
        photoUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200',
        avatarInitials: 'KK',
        attendancePercent: 0.94,
        presentCount: 156,
        absentCount: 8,
        leaveOdCount: 2,
        cgpa: '9.1',
        academicTrend: '+0.2 from Sem III',
        academicStatus: 'Dean\'s Scholar',
        statusColor: const Color(0xFF7C3AED),
        totalFees: 48000,
        paidFees: 48000,
        pendingFees: 0,
        feeDueDate: DateTime(2026, 11, 30),
        feeStatus: 'All Fees Cleared',
        isFeeOverdue: false,
        subjectGrades: [
          ParentSubjectGrade(subjectCode: 'EC401', subjectName: 'Signals & Systems', grade: 'O', color: const Color(0xFF059669)),
          ParentSubjectGrade(subjectCode: 'EC402', subjectName: 'Analog Circuits', grade: 'A+', color: const Color(0xFF2563EB)),
          ParentSubjectGrade(subjectCode: 'EC403', subjectName: 'Electromagnetic Fields', grade: 'A', color: const Color(0xFF7C3AED)),
          ParentSubjectGrade(subjectCode: 'MA401', subjectName: 'Probability & Random Processes', grade: 'A+', color: const Color(0xFF059669)),
        ],
      ),
    ];
  }
}
