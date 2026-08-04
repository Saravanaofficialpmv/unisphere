class AttendanceModel {
  final String id;
  final String studentUid;
  final DateTime date;
  final bool isPresent;
  final String? subjectName;

  AttendanceModel({
    required this.id,
    required this.studentUid,
    required this.date,
    required this.isPresent,
    this.subjectName,
  });

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      id: map['id'].toString(),
      studentUid: map['student_uid'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      isPresent: map['is_present'] ?? false,
      subjectName: map['subject_name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'student_uid': studentUid,
      'date': date.toIso8601String(),
      'is_present': isPresent,
      'subject_name': subjectName,
    };
  }
}
