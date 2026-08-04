class MarkModel {
  final String id;
  final String studentUid;
  final String subjectName;
  final int obtainedMarks;
  final int totalMarks;
  final String examType;
  final DateTime updatedAt;

  MarkModel({
    required this.id,
    required this.studentUid,
    required this.subjectName,
    required this.obtainedMarks,
    required this.totalMarks,
    required this.examType,
    required this.updatedAt,
  });

  factory MarkModel.fromMap(Map<String, dynamic> map) {
    return MarkModel(
      id: map['id'].toString(),
      studentUid: map['student_uid'] ?? '',
      subjectName: map['subject_name'] ?? '',
      obtainedMarks: map['obtained_marks'] ?? 0,
      totalMarks: map['total_marks'] ?? 100,
      examType: map['exam_type'] ?? 'General',
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'student_uid': studentUid,
      'subject_name': subjectName,
      'obtained_marks': obtainedMarks,
      'total_marks': totalMarks,
      'exam_type': examType,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
