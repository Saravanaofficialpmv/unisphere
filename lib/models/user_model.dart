enum UserRole { admin, student, staff, parent, hod, advisor, unknown }

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final UserRole role;
  final bool isActive;
  final bool profileCompleted;
  final String? profileImageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;
  final Map<String, dynamic>? metadata;

  UserModel({
    required this.uid,
    required this.email,
    String? fullName,
    String? name,
    required this.role,
    String? phone,
    String? phoneNumber,
    this.isActive = true,
    this.profileCompleted = true,
    this.profileImageUrl,
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
    this.metadata,
  })  : fullName = (fullName != null && fullName.isNotEmpty)
            ? fullName
            : ((name != null && name.isNotEmpty)
                ? name
                : (email.contains('@') ? email.split('@').first : 'User')),
        phone = (phone != null && phone.isNotEmpty)
            ? phone
            : (phoneNumber ?? '');

  String get name => fullName;
  String? get phoneNumber => phone;


  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString());
    }

    final nameVal = map['fullName'] ?? map['name'] ?? map['full_name'] ?? '';
    final phoneVal = map['phone'] ?? map['phone_number'] ?? map['phoneNumber'] ?? '';

    return UserModel(
      uid: id,
      email: map['email'] ?? '',
      fullName: nameVal.toString(),
      role: _parseRole(map['role']?.toString()),
      phone: phoneVal.toString(),
      isActive: map['isActive'] ?? map['is_active'] ?? true,
      profileCompleted: map['profileCompleted'] ?? map['profile_completed'] ?? true,
      profileImageUrl: map['profileImageUrl'] ?? map['profile_image_url'],
      createdAt: parseDate(map['createdAt'] ?? map['created_at']),
      updatedAt: parseDate(map['updatedAt'] ?? map['updated_at']),
      lastLoginAt: parseDate(map['lastLoginAt'] ?? map['last_login_at']),
      metadata: map['metadata'] is Map ? Map<String, dynamic>.from(map['metadata']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'name': fullName,
      'email': email,
      'phone': phone,
      'role': role.name,
      'isActive': isActive,
      'profileCompleted': profileCompleted,
      'profile_image_url': profileImageUrl,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  String get roleName {
    switch (role) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.hod:
        return 'HOD / Department Admin';
      case UserRole.advisor:
        return 'Class Advisor';
      case UserRole.staff:
        return 'Staff / Faculty';
      case UserRole.student:
        return 'Student';
      case UserRole.parent:
        return 'Parent / Guardian';
      default:
        return 'User';
    }
  }

  UserModel copyWith({
    String? fullName,
    String? name,
    String? email,
    String? phone,
    String? phoneNumber,
    UserRole? role,
    bool? isActive,
    bool? profileCompleted,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
      uid: uid,
      email: email ?? this.email,
      fullName: fullName ?? name ?? this.fullName,
      role: role ?? this.role,
      phone: phone ?? phoneNumber ?? this.phone,
      isActive: isActive ?? this.isActive,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      metadata: metadata ?? this.metadata,
    );
  }


  static UserRole _parseRole(String? role) {
    if (role == null) return UserRole.student;
    switch (role.toLowerCase().trim()) {
      case 'admin':
        return UserRole.admin;
      case 'student':
        return UserRole.student;
      case 'staff':
      case 'faculty':
        return UserRole.staff;
      case 'parent':
        return UserRole.parent;
      case 'hod':
      case 'head of department':
        return UserRole.hod;
      case 'advisor':
      case 'class advisor':
        return UserRole.advisor;
      default:
        return UserRole.unknown;
    }
  }
}

