class ParentModel {
  final String parentId;
  final String userId;
  final String fullName;
  final String phone;
  final String? email; // Optional per requirements
  final List<String> studentIds;
  final List<String> wardRegisterNumbers;
  final String? fatherPhotoPath;
  final String? motherPhotoPath;
  final Map<String, dynamic>? fatherDetails;
  final Map<String, dynamic>? motherDetails;
  final Map<String, dynamic>? guardianDetails;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ParentModel({
    required this.parentId,
    required this.userId,
    required this.fullName,
    required this.phone,
    this.email,
    required this.studentIds,
    this.wardRegisterNumbers = const [],
    this.fatherPhotoPath,
    this.motherPhotoPath,
    this.fatherDetails,
    this.motherDetails,
    this.guardianDetails,
    this.createdAt,
    this.updatedAt,
  });

  factory ParentModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString());
    }

    return ParentModel(
      parentId: id,
      userId: map['userId'] ?? map['user_id'] ?? id,
      fullName: map['fullName'] ?? map['name'] ?? map['full_name'] ?? 'Parent / Guardian',
      phone: map['phone'] ?? map['phone_number'] ?? '',
      email: map['email'],
      studentIds: List<String>.from(map['studentIds'] ?? map['student_ids'] ?? []),
      wardRegisterNumbers: List<String>.from(map['wardRegisterNumbers'] ?? map['ward_register_numbers'] ?? []),
      fatherPhotoPath: map['fatherPhotoPath'] ?? map['father_photo_path'],
      motherPhotoPath: map['motherPhotoPath'] ?? map['mother_photo_path'],
      fatherDetails: map['fatherDetails'] is Map ? Map<String, dynamic>.from(map['fatherDetails']) : null,
      motherDetails: map['motherDetails'] is Map ? Map<String, dynamic>.from(map['motherDetails']) : null,
      guardianDetails: map['guardianDetails'] is Map ? Map<String, dynamic>.from(map['guardianDetails']) : null,
      createdAt: parseDate(map['createdAt'] ?? map['created_at']),
      updatedAt: parseDate(map['updatedAt'] ?? map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'parentId': parentId,
      'parent_id': parentId,
      'userId': userId,
      'user_id': userId,
      'fullName': fullName,
      'name': fullName,
      'phone': phone,
      'email': email,
      'studentIds': studentIds,
      'student_ids': studentIds,
      'wardRegisterNumbers': wardRegisterNumbers,
      'fatherPhotoPath': fatherPhotoPath,
      'father_photo_path': fatherPhotoPath,
      'motherPhotoPath': motherPhotoPath,
      'mother_photo_path': motherPhotoPath,
      'fatherDetails': fatherDetails,
      'motherDetails': motherDetails,
      'guardianDetails': guardianDetails,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
