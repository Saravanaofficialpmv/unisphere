class AdminModel {
  final String userId;
  final String employeeId;
  final String fullName;
  final String email;
  final String phone;
  final String adminLevel;
  final String? departmentId;
  final List<String> managedModules;
  final String? photoPath;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AdminModel({
    required this.userId,
    required this.employeeId,
    required this.fullName,
    required this.email,
    required this.phone,
    this.adminLevel = 'Super Admin',
    this.departmentId,
    this.managedModules = const ['all'],
    this.photoPath,
    this.createdAt,
    this.updatedAt,
  });

  factory AdminModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString());
    }

    return AdminModel(
      userId: id,
      employeeId: map['employeeId'] ?? map['employee_id'] ?? id,
      fullName: map['fullName'] ?? map['name'] ?? map['full_name'] ?? 'Administrator',
      email: map['email'] ?? '',
      phone: map['phone'] ?? map['phone_number'] ?? '',
      adminLevel: map['adminLevel'] ?? map['admin_level'] ?? 'Super Admin',
      departmentId: map['departmentId'] ?? map['department_id'],
      managedModules: List<String>.from(map['managedModules'] ?? map['managed_modules'] ?? ['all']),
      photoPath: map['photoPath'] ?? map['photo_path'],
      createdAt: parseDate(map['createdAt'] ?? map['created_at']),
      updatedAt: parseDate(map['updatedAt'] ?? map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'user_id': userId,
      'employeeId': employeeId,
      'employee_id': employeeId,
      'fullName': fullName,
      'name': fullName,
      'email': email,
      'phone': phone,
      'adminLevel': adminLevel,
      'admin_level': adminLevel,
      'departmentId': departmentId,
      'department_id': departmentId,
      'managedModules': managedModules,
      'managed_modules': managedModules,
      'photoPath': photoPath,
      'photo_path': photoPath,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
