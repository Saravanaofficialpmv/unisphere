class StudentModel {
  final String studentId;
  final String userId;
  final String registerNumber;
  final String fullName;
  final String rollNumber;
  final String departmentId;
  final String departmentName;
  final String batchId;
  final String batch;
  final String semester;
  final String section;
  final int admissionYear;
  final String? dateOfBirth;
  final String? gender;
  final String? bloodGroup;
  final String? studentPhotoPath;
  final dynamic address;
  final String? comingMode;
  final dynamic hostelOrStayDetails;
  final String? parentId;
  final String academicStatus;
  final String? cgpa;
  final String? attendancePercent;
  final String? membershipId;
  final String? membershipOrg;
  final bool? hasMembership;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  StudentModel({
    required this.studentId,
    required this.userId,
    required this.registerNumber,
    required this.fullName,
    required this.rollNumber,
    required this.departmentId,
    required this.departmentName,
    required this.batchId,
    required this.batch,
    required this.semester,
    required this.section,
    required this.admissionYear,
    this.dateOfBirth,
    this.gender,
    this.bloodGroup,
    this.studentPhotoPath,
    this.address,
    this.comingMode,
    this.hostelOrStayDetails,
    this.parentId,
    this.academicStatus = 'Active',
    this.cgpa,
    this.attendancePercent,
    this.membershipId,
    this.membershipOrg,
    this.hasMembership,
    this.createdAt,
    this.updatedAt,
  });

  factory StudentModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString());
    }

    final userIdVal = map['userId'] ?? map['user_id'] ?? id;
    final regNo = map['registerNumber'] ?? map['register_number'] ?? '';
    final name = map['fullName'] ?? map['full_name'] ?? map['name'] ?? 'Student';
    final deptId = map['departmentId'] ?? map['department_id'] ?? 'DEPT-CSE';
    final bId = map['batchId'] ?? map['batch_id'] ?? 'BATCH-2022-26';

    return StudentModel(
      studentId: id,
      userId: userIdVal.toString(),
      registerNumber: regNo.toString(),
      fullName: name.toString(),
      rollNumber: (map['rollNumber'] ?? map['roll_number'] ?? regNo).toString(),
      departmentId: deptId.toString(),
      departmentName: map['departmentName'] ?? map['department_name'] ?? 'Computer Science & Engineering',
      batchId: bId.toString(),
      batch: map['batch']?.toString() ?? '2022–2026',
      semester: map['semester']?.toString() ?? 'Semester VI',
      section: map['section']?.toString() ?? 'Sec B',
      admissionYear: (map['admissionYear'] ?? map['admission_year'] ?? 2022) as int,
      dateOfBirth: map['dateOfBirth']?.toString() ?? map['date_of_birth']?.toString(),
      gender: map['gender']?.toString(),
      bloodGroup: map['bloodGroup']?.toString() ?? map['blood_group']?.toString(),
      studentPhotoPath: map['studentPhotoPath']?.toString() ?? map['photo_path']?.toString(),
      address: map['address'],
      comingMode: map['comingMode']?.toString() ?? map['coming_mode']?.toString(),
      hostelOrStayDetails: map['hostelOrStayDetails'] ?? map['stay_details'],
      parentId: map['parentId']?.toString() ?? map['parent_id']?.toString(),
      academicStatus: map['academicStatus']?.toString() ?? map['academic_status']?.toString() ?? 'Active',
      cgpa: map['cgpa']?.toString(),
      attendancePercent: map['attendancePercent']?.toString() ?? map['attendance_percent']?.toString(),
      membershipId: map['membershipId']?.toString() ?? map['membership_id']?.toString(),
      membershipOrg: map['membershipOrg']?.toString() ?? map['membership_org']?.toString(),
      hasMembership: map['hasMembership'] ?? map['has_membership'],
      createdAt: parseDate(map['createdAt'] ?? map['created_at']),
      updatedAt: parseDate(map['updatedAt'] ?? map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'student_id': studentId,
      'userId': userId,
      'user_id': userId,
      'registerNumber': registerNumber,
      'register_number': registerNumber,
      'fullName': fullName,
      'name': fullName,
      'rollNumber': rollNumber,
      'roll_number': rollNumber,
      'departmentId': departmentId,
      'department_id': departmentId,
      'departmentName': departmentName,
      'department_name': departmentName,
      'batchId': batchId,
      'batch_id': batchId,
      'batch': batch,
      'semester': semester,
      'section': section,
      'admissionYear': admissionYear,
      'admission_year': admissionYear,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'bloodGroup': bloodGroup,
      'studentPhotoPath': studentPhotoPath,
      'address': address,
      'comingMode': comingMode,
      'hostelOrStayDetails': hostelOrStayDetails,
      'parentId': parentId,
      'academicStatus': academicStatus,
      'academic_status': academicStatus,
      'cgpa': cgpa,
      'attendancePercent': attendancePercent,
      'attendance_percent': attendancePercent,
      'membershipId': membershipId,
      'membership_id': membershipId,
      'membershipOrg': membershipOrg,
      'membership_org': membershipOrg,
      'hasMembership': hasMembership,
      'has_membership': hasMembership,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

