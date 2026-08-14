class FacultyModel {
  final String facultyId;
  final String userId;
  final String departmentId;
  final String departmentName;
  final String designation;
  final List<String> assignedSubjects;

  FacultyModel({
    required this.facultyId,
    required this.userId,
    required this.departmentId,
    required this.departmentName,
    required this.designation,
    required this.assignedSubjects,
  });

  factory FacultyModel.fromMap(Map<String, dynamic> map, String id) {
    return FacultyModel(
      facultyId: id,
      userId: map['user_id'] ?? map['userId'] ?? '',
      departmentId: map['department_id'] ?? map['departmentId'] ?? '',
      departmentName: map['department_name'] ?? map['departmentName'] ?? 'Computer Science',
      designation: map['designation'] ?? 'Assistant Professor',
      assignedSubjects: List<String>.from(map['assigned_subjects'] ?? map['assignedSubjects'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'faculty_id': facultyId,
      'user_id': userId,
      'department_id': departmentId,
      'department_name': departmentName,
      'designation': designation,
      'assigned_subjects': assignedSubjects,
    };
  }
}
