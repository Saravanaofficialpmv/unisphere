class SubmissionModel {
  final String id;
  final String assignmentId;
  final String studentUid;
  final String studentName;
  final String registerNumber;
  final String? fileName;
  final String? fileUrl;
  final String? fileType; // PDF, DOCX, ZIP, PNG, JPG
  final int? fileSizeBytes;
  final DateTime submittedAt;
  final String status; // 'Draft', 'Submitted', 'Late', 'Graded'
  final bool isGraded;
  final int? obtainedMarks;
  final String? feedback;
  final String? gradedBy;
  final DateTime? gradedAt;

  SubmissionModel({
    required this.id,
    required this.assignmentId,
    required this.studentUid,
    required this.studentName,
    required this.registerNumber,
    this.fileName,
    this.fileUrl,
    this.fileType,
    this.fileSizeBytes,
    required this.submittedAt,
    this.status = 'Submitted',
    this.isGraded = false,
    this.obtainedMarks,
    this.feedback,
    this.gradedBy,
    this.gradedAt,
  });

  factory SubmissionModel.fromMap(Map<String, dynamic> map) {
    return SubmissionModel(
      id: map['id'].toString(),
      assignmentId: map['assignment_id'] ?? '',
      studentUid: map['student_uid'] ?? '',
      studentName: map['student_name'] ?? '',
      registerNumber: map['register_number'] ?? 'RA2111003010001',
      fileName: map['file_name'],
      fileUrl: map['file_url'],
      fileType: map['file_type'] ?? 'PDF',
      fileSizeBytes: map['file_size_bytes'],
      submittedAt: DateTime.parse(map['submitted_at'] ?? DateTime.now().toIso8601String()),
      status: map['status'] ?? (map['is_graded'] == true ? 'Graded' : 'Submitted'),
      isGraded: map['is_graded'] ?? false,
      obtainedMarks: map['obtained_marks'],
      feedback: map['feedback'],
      gradedBy: map['graded_by'],
      gradedAt: map['graded_at'] != null ? DateTime.parse(map['graded_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'assignment_id': assignmentId,
      'student_uid': studentUid,
      'student_name': studentName,
      'register_number': registerNumber,
      'file_name': fileName,
      'file_url': fileUrl,
      'file_type': fileType,
      'file_size_bytes': fileSizeBytes,
      'submitted_at': submittedAt.toIso8601String(),
      'status': status,
      'is_graded': isGraded,
      'obtained_marks': obtainedMarks,
      'feedback': feedback,
      'graded_by': gradedBy,
      'graded_at': gradedAt?.toIso8601String(),
    };
  }

  SubmissionModel copyWith({
    String? status,
    bool? isGraded,
    int? obtainedMarks,
    String? feedback,
    String? gradedBy,
    DateTime? gradedAt,
    String? fileName,
    String? fileUrl,
    String? fileType,
    int? fileSizeBytes,
    DateTime? submittedAt,
  }) {
    return SubmissionModel(
      id: id,
      assignmentId: assignmentId,
      studentUid: studentUid,
      studentName: studentName,
      registerNumber: registerNumber,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      fileType: fileType ?? this.fileType,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      submittedAt: submittedAt ?? this.submittedAt,
      status: status ?? this.status,
      isGraded: isGraded ?? this.isGraded,
      obtainedMarks: obtainedMarks ?? this.obtainedMarks,
      feedback: feedback ?? this.feedback,
      gradedBy: gradedBy ?? this.gradedBy,
      gradedAt: gradedAt ?? this.gradedAt,
    );
  }
}
