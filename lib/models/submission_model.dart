class SubmissionModel {
  final String id;
  final String assignmentId;
  final String studentUid;
  final String studentName;
  final String? fileUrl;
  final DateTime submittedAt;
  final bool isGraded;
  final int? obtainedMarks;
  final String? feedback;

  SubmissionModel({
    required this.id,
    required this.assignmentId,
    required this.studentUid,
    required this.studentName,
    this.fileUrl,
    required this.submittedAt,
    required this.isGraded,
    this.obtainedMarks,
    this.feedback,
  });

  factory SubmissionModel.fromMap(Map<String, dynamic> map) {
    return SubmissionModel(
      id: map['id'].toString(),
      assignmentId: map['assignment_id'] ?? '',
      studentUid: map['student_uid'] ?? '',
      studentName: map['student_name'] ?? '',
      fileUrl: map['file_url'],
      submittedAt: DateTime.parse(map['submitted_at'] ?? DateTime.now().toIso8601String()),
      isGraded: map['is_graded'] ?? false,
      obtainedMarks: map['obtained_marks'],
      feedback: map['feedback'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'assignment_id': assignmentId,
      'student_uid': studentUid,
      'student_name': studentName,
      'file_url': fileUrl,
      'submitted_at': submittedAt.toIso8601String(),
      'is_graded': isGraded,
      'obtained_marks': obtainedMarks,
      'feedback': feedback,
    };
  }
}
