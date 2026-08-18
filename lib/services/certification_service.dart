import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/models/certification_model.dart';
import 'package:unisphere/services/storage_service.dart';

final certificationServiceProvider = Provider<CertificationService>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return CertificationService(storageService: storageService);
});

class CertificationService {
  final FirebaseFirestore? _firestore;
  final StorageService _storageService;

  CertificationService({
    FirebaseFirestore? firestore,
    required StorageService storageService,
  })  : _firestore = firestore ?? _tryGetFirestore(),
        _storageService = storageService;

  static FirebaseFirestore? _tryGetFirestore() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  /// Submit new certification record and upload document to Firebase Storage if file provided
  Future<String?> submitCertification({
    required CertificationModel certification,
    File? documentFile,
  }) async {
    final firestore = _firestore;
    if (firestore == null) return null;

    try {
      String? storagePath = certification.certificateStoragePath;

      if (documentFile != null) {
        final path = _storageService.certificatePath(certification.studentId, certification.id);
        final uploadedUrl = await _storageService.uploadFile(storagePath: path, file: documentFile);
        if (uploadedUrl != null) {
          storagePath = path;
        }
      }

      final updatedCert = CertificationModel(
        id: certification.id,
        studentId: certification.studentId,
        studentName: certification.studentName,
        title: certification.title,
        courseName: certification.courseName,
        provider: certification.provider,
        type: certification.type,
        typeName: certification.typeName,
        certificateId: certification.certificateId,
        issueDate: certification.issueDate,
        expiryDate: certification.expiryDate,
        certificateStoragePath: storagePath,
        documentUrl: certification.documentUrl ?? storagePath,
        verificationStatus: certification.verificationStatus,
        verifiedBy: certification.verifiedBy,
        approvalStatus: certification.approvalStatus,
        createdAt: certification.createdAt,
        updatedAt: DateTime.now(),
      );

      await firestore.collection('certifications').doc(certification.id).set(updatedCert.toMap(), SetOptions(merge: true));
      return certification.id;
    } catch (e) {
      debugPrint('CertificationService submitCertification error: $e');
      return null;
    }
  }

  /// Get certifications for a student
  Future<List<CertificationModel>> getStudentCertifications(String studentId) async {
    final firestore = _firestore;
    if (firestore == null || studentId.isEmpty) return [];
    try {
      final snap = await firestore.collection('certifications').where('studentId', isEqualTo: studentId).get();
      return snap.docs.map((d) => CertificationModel.fromMap(d.data(), d.id)).toList();
    } catch (e) {
      debugPrint('CertificationService getStudentCertifications error: $e');
      return [];
    }
  }

  /// Verify or reject certification by authorized user (HOD, Advisor, Admin)
  Future<void> verifyCertification({
    required String certificateId,
    required String verificationStatus,
    required String verifiedByUid,
  }) async {
    final firestore = _firestore;
    if (firestore == null || certificateId.isEmpty) return;
    try {
      await firestore.collection('certifications').doc(certificateId).update({
        'verificationStatus': verificationStatus,
        'verification_status': verificationStatus,
        'verifiedBy': verifiedByUid,
        'verified_by': verifiedByUid,
        'approvalStatus': verificationStatus == 'verified' ? 'approved' : 'rejected',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('CertificationService verifyCertification error: $e');
    }
  }
}
