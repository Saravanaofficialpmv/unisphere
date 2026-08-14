enum CertificationType { nptel, industry, custom }

class CertificationModel {
  final String id;
  final String studentUid;
  final String studentName;
  final String title;
  final String provider;
  final CertificationType type;
  final String? certificateId;
  final DateTime issueDate;
  final DateTime? expiryDate;
  final String? documentUrl;
  final String verificationStatus; // 'verified', 'pending', 'rejected'
  final String approvalStatus;     // 'approved', 'under_review', 'rejected'
  final DateTime createdAt;

  CertificationModel({
    required this.id,
    required this.studentUid,
    required this.studentName,
    required this.title,
    required this.provider,
    required this.type,
    this.certificateId,
    required this.issueDate,
    this.expiryDate,
    this.documentUrl,
    this.verificationStatus = 'pending',
    this.approvalStatus = 'under_review',
    required this.createdAt,
  });

  factory CertificationModel.fromMap(Map<String, dynamic> map, String docId) {
    return CertificationModel(
      id: docId,
      studentUid: map['student_uid'] ?? map['studentUid'] ?? '',
      studentName: map['student_name'] ?? map['studentName'] ?? 'Student',
      title: map['title'] ?? '',
      provider: map['provider'] ?? 'NPTEL / SWAYAM',
      type: _parseType(map['type']),
      certificateId: map['certificate_id'] ?? map['certificateId'],
      issueDate: map['issue_date'] != null
          ? DateTime.parse(map['issue_date'].toString())
          : DateTime.now(),
      expiryDate: map['expiry_date'] != null
          ? DateTime.parse(map['expiry_date'].toString())
          : null,
      documentUrl: map['document_url'] ?? map['documentUrl'],
      verificationStatus: map['verification_status'] ?? map['verificationStatus'] ?? 'pending',
      approvalStatus: map['approval_status'] ?? map['approvalStatus'] ?? 'under_review',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'].toString())
          : DateTime.now(),
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
      'student_uid': studentUid,
      'student_name': studentName,
      'title': title,
      'provider': provider,
      'type': type.name,
      'certificate_id': certificateId,
      'issue_date': issueDate.toIso8601String(),
      'expiry_date': expiryDate?.toIso8601String(),
      'document_url': documentUrl,
      'verification_status': verificationStatus,
      'approval_status': approvalStatus,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
