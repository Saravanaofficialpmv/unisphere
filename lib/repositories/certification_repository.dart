import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/models/certification_model.dart';

final certificationRepositoryProvider = Provider<CertificationRepository>((ref) {
  return CertificationRepository();
});

class CertificationRepository {
  final FirebaseFirestore? _firestore;

  CertificationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? _tryGetFirestore();

  static FirebaseFirestore? _tryGetFirestore() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  /// Watch real-time certifications for a specific student
  Stream<List<CertificationModel>> watchStudentCertifications(String studentUid, {CertificationType? type}) {
    final firestore = _firestore;
    if (studentUid.isEmpty || firestore == null) {
      return Stream.value([]);
    }
    Query query = firestore
        .collection('certifications')
        .where('student_uid', isEqualTo: studentUid);

    if (type != null) {
      query = query.where('type', isEqualTo: type.name);
    }

    return query.snapshots().map((snapshot) => snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return CertificationModel.fromMap(data, doc.id);
        }).toList()).handleError((e) {
      debugPrint('Firestore certification stream notice: $e');
      return <CertificationModel>[];
    });
  }

  /// Add new NPTEL or Industry certification record
  Future<void> addCertification(CertificationModel cert) async {
    final firestore = _firestore;
    if (firestore == null) return;
    try {
      await firestore.collection('certifications').doc(cert.id).set(cert.toMap());
    } catch (e) {
      debugPrint('Firestore addCertification error: $e');
    }
  }

  /// Update certification approval status (HOD / Admin action)
  Future<void> updateCertificationStatus(String certId, String verificationStatus, String approvalStatus) async {
    final firestore = _firestore;
    if (firestore == null) return;
    try {
      await firestore.collection('certifications').doc(certId).update({
        'verification_status': verificationStatus,
        'approval_status': approvalStatus,
      });
    } catch (e) {
      debugPrint('Firestore updateCertificationStatus error: $e');
    }
  }
}
