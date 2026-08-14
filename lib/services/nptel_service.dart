import 'package:flutter/material.dart';
import 'package:unisphere/models/nptel_certificate_model.dart';

class NptelService extends ChangeNotifier {
  static final NptelService _instance = NptelService._internal();
  factory NptelService() => _instance;

  NptelService._internal() {
    _initSeedData();
  }

  final List<NptelCertificateModel> _certificates = [];

  List<NptelCertificateModel> get certificates => List.unmodifiable(_certificates);

  List<NptelCertificateModel> get pendingCertificates =>
      _certificates.where((c) => c.status == 'Pending Verification').toList();

  List<NptelCertificateModel> get verifiedCertificates =>
      _certificates.where((c) => c.status == 'Verified').toList();

  List<NptelCertificateModel> get rejectedCertificates =>
      _certificates.where((c) => c.status == 'Rejected').toList();

  void _initSeedData() {
    _certificates.addAll([
      NptelCertificateModel(
        id: 'NPTEL-2026-001',
        studentName: 'Alex Morgan',
        rollNo: 'RA2111003010001',
        department: 'Computer Science and Engineering',
        courseName: 'Programming in Java',
        courseCode: 'NPTEL24CS01',
        semester: '5th Semester',
        academicYear: '2026–27',
        score: '82%',
        grade: 'Elite',
        certificateId: 'NPTEL-CS20268812',
        issueDate: '10 Aug 2026',
        fileName: 'nptel_programming_in_java_cert.pdf',
        fileSize: '1.4 MB',
        uploadDate: DateTime.now().subtract(const Duration(hours: 4)),
        status: 'Pending Verification',
      ),
      NptelCertificateModel(
        id: 'NPTEL-2025-091',
        studentName: 'Alex Morgan',
        rollNo: 'RA2111003010001',
        department: 'Computer Science and Engineering',
        courseName: 'Data Structures and Algorithms in Java',
        courseCode: 'NPTEL25CS09',
        semester: '4th Semester',
        academicYear: '2025–26',
        score: '92%',
        grade: 'Elite + Gold',
        certificateId: 'NPTEL-CS-2025-091',
        issueDate: '15 Oct 2025',
        fileName: 'nptel_dsa_java_gold.pdf',
        fileSize: '1.2 MB',
        uploadDate: DateTime.now().subtract(const Duration(days: 120)),
        status: 'Verified',
        reviewedBy: 'Dr. Sarah Miller (HOD - CSE)',
        reviewedAt: DateTime.now().subtract(const Duration(days: 119)),
      ),
      NptelCertificateModel(
        id: 'NPTEL-2025-042',
        studentName: 'Alex Morgan',
        rollNo: 'RA2111003010001',
        department: 'Computer Science and Engineering',
        courseName: 'Database Management Systems',
        courseCode: 'NPTEL25CS42',
        semester: '3rd Semester',
        academicYear: '2024–25',
        score: '86%',
        grade: 'Elite + Silver',
        certificateId: 'NPTEL-CS-2025-042',
        issueDate: '20 Apr 2025',
        fileName: 'nptel_dbms_silver.pdf',
        fileSize: '1.5 MB',
        uploadDate: DateTime.now().subtract(const Duration(days: 300)),
        status: 'Verified',
        reviewedBy: 'Prof. Emily Carter',
        reviewedAt: DateTime.now().subtract(const Duration(days: 299)),
      ),
      NptelCertificateModel(
        id: 'NPTEL-2026-002',
        studentName: 'Michael Chen',
        rollNo: 'RA2111003010014',
        department: 'Computer Science and Engineering',
        courseName: 'Cloud Computing',
        courseCode: 'NPTEL26CS14',
        semester: '5th Semester',
        academicYear: '2026–27',
        score: '78%',
        grade: 'Elite',
        certificateId: 'NPTEL-CS20269914',
        issueDate: '05 Aug 2026',
        fileName: 'cloud_computing_cert.pdf',
        fileSize: '1.8 MB',
        uploadDate: DateTime.now().subtract(const Duration(days: 2)),
        status: 'Pending Verification',
      ),
      NptelCertificateModel(
        id: 'NPTEL-2026-003',
        studentName: 'Priya Sharma',
        rollNo: 'RA2111003010029',
        department: 'Computer Science and Engineering',
        courseName: 'Python for Data Science',
        courseCode: 'NPTEL26CS29',
        semester: '5th Semester',
        academicYear: '2026–27',
        score: '65%',
        grade: 'Successfully Completed',
        certificateId: 'NPTEL-CS20267729',
        issueDate: '02 Aug 2026',
        fileName: 'python_data_science_cert.pdf',
        fileSize: '1.1 MB',
        uploadDate: DateTime.now().subtract(const Duration(days: 3)),
        status: 'Rejected',
        rejectionReason: 'Certificate ID does not match the official NPTEL portal records. Please verify the ID and re-upload.',
        reviewedBy: 'Dr. Sarah Miller (HOD - CSE)',
        reviewedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ]);
  }

  void uploadCertificate(NptelCertificateModel cert) {
    _certificates.insert(0, cert);
    notifyListeners();
  }

  void reuploadCertificate({
    required String existingId,
    required String courseName,
    required String courseCode,
    required String semester,
    required String academicYear,
    required String score,
    required String grade,
    required String certificateId,
    required String issueDate,
    required String fileName,
    required String fileSize,
  }) {
    final index = _certificates.indexWhere((c) => c.id == existingId);
    if (index != -1) {
      final old = _certificates[index];
      _certificates[index] = NptelCertificateModel(
        id: old.id,
        studentName: old.studentName,
        rollNo: old.rollNo,
        department: old.department,
        courseName: courseName,
        courseCode: courseCode,
        semester: semester,
        academicYear: academicYear,
        score: score,
        grade: grade,
        certificateId: certificateId,
        issueDate: issueDate,
        fileName: fileName,
        fileSize: fileSize,
        uploadDate: DateTime.now(),
        status: 'Pending Verification',
        rejectionReason: null,
      );
      notifyListeners();
    }
  }

  void verifyCertificate(String id, String reviewer) {
    final index = _certificates.indexWhere((c) => c.id == id);
    if (index != -1) {
      _certificates[index].status = 'Verified';
      _certificates[index].reviewedBy = reviewer;
      _certificates[index].reviewedAt = DateTime.now();
      _certificates[index].rejectionReason = null;
      notifyListeners();
    }
  }

  void rejectCertificate(String id, String reason, String reviewer) {
    final index = _certificates.indexWhere((c) => c.id == id);
    if (index != -1) {
      _certificates[index].status = 'Rejected';
      _certificates[index].rejectionReason = reason;
      _certificates[index].reviewedBy = reviewer;
      _certificates[index].reviewedAt = DateTime.now();
      notifyListeners();
    }
  }
}
