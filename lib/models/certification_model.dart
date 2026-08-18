enum CertificationType { nptel, industry, custom }

class CertificationModel {
  final String id;
  final String studentId;
  final String studentUid;
  final String studentName;
  final String title;
  final String courseName;
  final String provider;
  final CertificationType type;
  final String typeName;
  final String? certificateId;
  final DateTime issueDate;
  final DateTime? expiryDate;
  final String? certificateStoragePath;
  final String? documentUrl;
  final String verificationStatus; // 'verified', 'pending', 'rejected'
  final String? verifiedBy;
  final String approvalStatus;     // 'approved', 'under_review', 'rejected'
  final DateTime createdAt;
  final DateTime? updatedAt;

  CertificationModel({
    required this.id,
    required this.studentId,
    String? studentUid,
    required this.studentName,
    required this.title,
    String? courseName,
    required this.provider,
    required this.type,
    String? typeName,
    this.certificateId,
    required this.issueDate,
    this.expiryDate,
    this.certificateStoragePath,
    this.documentUrl,
    this.verificationStatus = 'pending',
    this.verifiedBy,
    this.approvalStatus = 'under_review',
    required this.createdAt,
    this.updatedAt,
  })  : studentUid = studentUid ?? studentId,
        courseName = courseName ?? title,
        typeName = typeName ?? type.name;

  factory CertificationModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic val, [DateTime? fallback]) {
      if (val == null) return fallback ?? DateTime.now();
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString()) ?? fallback ?? DateTime.now();
    }

    final sId = map['studentId'] ?? map['student_id'] ?? map['studentUid'] ?? map['student_uid'] ?? '';
    final course = map['courseName'] ?? map['course_name'] ?? map['title'] ?? 'Course';
    final path = map['certificateStoragePath'] ?? map['certificate_storage_path'] ?? map['document_url'] ?? map['documentUrl'];

    return CertificationModel(
      id: docId,
      studentId: sId.toString(),
      studentUid: sId.toString(),
      studentName: map['student_name'] ?? map['studentName'] ?? 'Student',
      title: course.toString(),
      courseName: course.toString(),
      provider: map['provider'] ?? 'NPTEL / SWAYAM',
      type: _parseType(map['type']),
      typeName: map['type']?.toString() ?? 'Other Certification',
      certificateId: map['certificate_id'] ?? map['certificateId'],
      issueDate: parseDate(map['issueDate'] ?? map['issue_date']),
      expiryDate: map['expiryDate'] != null || map['expiry_date'] != null
          ? parseDate(map['expiryDate'] ?? map['expiry_date'])
          : null,
      certificateStoragePath: path?.toString(),
      documentUrl: path?.toString(),
      verificationStatus: map['verificationStatus'] ?? map['verification_status'] ?? 'pending',
      verifiedBy: map['verifiedBy'] ?? map['verified_by'],
      approvalStatus: map['approvalStatus'] ?? map['approval_status'] ?? 'under_review',
      createdAt: parseDate(map['createdAt'] ?? map['created_at']),
      updatedAt: map['updatedAt'] != null ? parseDate(map['updatedAt'] ?? map['updated_at']) : null,
    );
  }

  static CertificationType _parseType(dynamic val) {
    final str = val?.toString().toLowerCase() ?? '';
    if (str.contains('nptel')) return CertificationType.nptel;
    if (str.contains('industry')) return CertificationType.industry;
    return CertificationType.custom;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'student_id': studentId,
      'studentUid': studentUid,
      'student_uid': studentUid,
      'student_name': studentName,
      'title': title,
      'courseName': courseName,
      'course_name': courseName,
      'provider': provider,
      'type': typeName,
      'certificate_id': certificateId,
      'certificateId': certificateId,
      'issue_date': issueDate.toIso8601String(),
      'issueDate': issueDate.toIso8601String(),
      'expiry_date': expiryDate?.toIso8601String(),
      'certificateStoragePath': certificateStoragePath,
      'certificate_storage_path': certificateStoragePath,
      'document_url': documentUrl,
      'verification_status': verificationStatus,
      'verificationStatus': verificationStatus,
      'verifiedBy': verifiedBy,
      'verified_by': verifiedBy,
      'approval_status': approvalStatus,
      'created_at': createdAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

