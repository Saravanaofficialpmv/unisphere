enum UserRole { admin, student, staff, parent, hod, unknown }

class UserModel {
  final String uid;
  final String email;
  final String name;
  final UserRole role;
  final String? profileImageUrl;
  final String? phoneNumber;
  final Map<String, dynamic>? metadata; // For school, class, etc.

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.profileImageUrl,
    this.phoneNumber,
    this.metadata,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: _parseRole(map['role']),
      profileImageUrl: map['profile_image_url'],
      phoneNumber: map['phone_number'],
      metadata: map['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role.name,
      'profile_image_url': profileImageUrl,
      'phone_number': phoneNumber,
      'metadata': metadata,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    UserRole? role,
    String? profileImageUrl,
    String? phoneNumber,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
      uid: uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      metadata: metadata ?? this.metadata,
    );
  }

  static UserRole _parseRole(String? role) {
    if (role == null) return UserRole.student; // Default
    switch (role.toLowerCase()) {
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
      default:
        return UserRole.unknown;
    }
  }
}
