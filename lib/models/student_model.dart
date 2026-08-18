class StudentModel {
  final String studentId;
  final String userId;
  final String registerNumber;
  final String rollNumber;
  final String departmentId;
  final String departmentName;
  final String batch;
  final String semester;
  final String section;
  final int admissionYear;
  final String academicStatus;
  final String? cgpa;
  final String? attendancePercent;
  final String? membershipId;
  final String? membershipOrg;
  final bool? hasMembership;

  StudentModel({
    required this.studentId,
    required this.userId,
    required this.registerNumber,
    required this.rollNumber,
    required this.departmentId,
    required this.departmentName,
    required this.batch,
    required this.semester,
    required this.section,
    required this.admissionYear,
    this.academicStatus = 'Active',
    this.cgpa,
    this.attendancePercent,
    this.membershipId,
    this.membershipOrg,
    this.hasMembership,
  });

  factory StudentModel.fromMap(Map<String, dynamic> map, String id) {
    return StudentModel(
      studentId: id,
      userId: map['user_id'] ?? map['userId'] ?? '',
      registerNumber: map['register_number'] ?? map['registerNumber'] ?? '',
      rollNumber: map['roll_number'] ?? map['rollNumber'] ?? '',
      departmentId: map['department_id'] ?? map['departmentId'] ?? '',
      departmentName: map['department_name'] ?? map['departmentName'] ?? 'Computer Science',
      batch: map['batch'] ?? '2022–2026',
      semester: map['semester'] ?? 'Semester VI',
      section: map['section'] ?? 'Sec B',
      admissionYear: (map['admission_year'] ?? map['admissionYear'] ?? 2022) as int,
      academicStatus: map['academic_status'] ?? map['academicStatus'] ?? 'Active',
      cgpa: map['cgpa']?.toString(),
      attendancePercent: map['attendance_percent']?.toString() ?? map['attendancePercent']?.toString(),
      membershipId: map['membership_id'] ?? map['membershipId'],
      membershipOrg: map['membership_org'] ?? map['membershipOrg'],
      hasMembership: map['has_membership'] ?? map['hasMembership'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'student_id': studentId,
      'user_id': userId,
      'register_number': registerNumber,
      'roll_number': rollNumber,
      'department_id': departmentId,
      'department_name': departmentName,
      'batch': batch,
      'semester': semester,
      'section': section,
      'admission_year': admissionYear,
      'academic_status': academicStatus,
      'cgpa': cgpa,
      'attendance_percent': attendancePercent,
      'membership_id': membershipId,
      'membership_org': membershipOrg,
      'has_membership': hasMembership,
    };
  }
}
