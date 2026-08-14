class DepartmentModel {
  final String departmentId;
  final String departmentName;
  final String departmentCode;
  final String? hodId;
  final String? hodName;
  final int totalStudents;
  final int totalFaculty;

  DepartmentModel({
    required this.departmentId,
    required this.departmentName,
    required this.departmentCode,
    this.hodId,
    this.hodName,
    this.totalStudents = 0,
    this.totalFaculty = 0,
  });

  factory DepartmentModel.fromMap(Map<String, dynamic> map, String id) {
    return DepartmentModel(
      departmentId: id,
      departmentName: map['department_name'] ?? map['departmentName'] ?? '',
      departmentCode: map['department_code'] ?? map['departmentCode'] ?? '',
      hodId: map['hod_id'] ?? map['hodId'],
      hodName: map['hod_name'] ?? map['hodName'],
      totalStudents: (map['total_students'] ?? map['totalStudents'] ?? 0) as int,
      totalFaculty: (map['total_faculty'] ?? map['totalFaculty'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'department_id': departmentId,
      'department_name': departmentName,
      'department_code': departmentCode,
      'hod_id': hodId,
      'hod_name': hodName,
      'total_students': totalStudents,
      'total_faculty': totalFaculty,
    };
  }
}
