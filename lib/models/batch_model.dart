class BatchModel {
  final String batchId;
  final String departmentId;
  final String academicYear;
  final int startYear;
  final int endYear;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BatchModel({
    required this.batchId,
    required this.departmentId,
    required this.academicYear,
    required this.startYear,
    required this.endYear,
    this.createdAt,
    this.updatedAt,
  });

  factory BatchModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString());
    }

    return BatchModel(
      batchId: id,
      departmentId: map['departmentId'] ?? map['department_id'] ?? '',
      academicYear: map['academicYear'] ?? map['academic_year'] ?? '2022–2026',
      startYear: (map['startYear'] ?? map['start_year'] ?? 2022) as int,
      endYear: (map['endYear'] ?? map['end_year'] ?? 2026) as int,
      createdAt: parseDate(map['createdAt'] ?? map['created_at']),
      updatedAt: parseDate(map['updatedAt'] ?? map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'batchId': batchId,
      'batch_id': batchId,
      'departmentId': departmentId,
      'department_id': departmentId,
      'academicYear': academicYear,
      'academic_year': academicYear,
      'startYear': startYear,
      'start_year': startYear,
      'endYear': endYear,
      'end_year': endYear,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
