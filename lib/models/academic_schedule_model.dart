import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

enum ScheduleStatus {
  active,
  archived,
  draft,
}

class ScheduleEventItem {
  final String dateString;
  final DateTime? date;
  final String title;
  final String category; // 'Academic', 'Holiday', 'Examination', 'Assessment', 'Event'
  final String? description;
  final bool isHoliday;

  const ScheduleEventItem({
    required this.dateString,
    this.date,
    required this.title,
    this.category = 'Academic',
    this.description,
    this.isHoliday = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'dateString': dateString,
      'date': date != null ? Timestamp.fromDate(date!) : null,
      'title': title,
      'category': category,
      'description': description,
      'isHoliday': isHoliday,
    };
  }

  factory ScheduleEventItem.fromMap(Map<String, dynamic> map) {
    DateTime? parsedDate;
    if (map['date'] is Timestamp) {
      parsedDate = (map['date'] as Timestamp).toDate();
    } else if (map['date'] is String) {
      parsedDate = DateTime.tryParse(map['date']);
    }

    return ScheduleEventItem(
      dateString: map['dateString']?.toString() ?? '',
      date: parsedDate,
      title: map['title']?.toString() ?? '',
      category: map['category']?.toString() ?? 'Academic',
      description: map['description']?.toString(),
      isHoliday: map['isHoliday'] == true,
    );
  }
}

class AcademicScheduleModel {
  final String id;
  final String title;
  final String description;
  final String academicYear; // e.g. '2026-27'
  final String departmentId; // 'all' or specific 'DEP-CSE'
  final String departmentName; // 'All Departments' or 'Computer Science & Engineering'
  final String targetStudentYear; // 'I Year', 'II Year', 'III Year', 'IV Year', 'All Years'
  final String semester; // 'Odd Semester', 'Even Semester', 'Semester 1', etc.
  final String fileName;
  final String fileType; // 'xls', 'xlsx', 'pdf', 'jpg', 'png'
  final String fileUrl;
  final String storagePath;
  final int fileSize; // in bytes
  final int version; // 1, 2, 3...
  final ScheduleStatus status;
  final bool isLatest;
  final DateTime? publishedAt;
  final DateTime uploadedAt;
  final String uploadedBy;
  final String uploadedByName;
  final DateTime updatedAt;
  final DateTime? archivedAt;
  final List<ScheduleEventItem> scheduleEvents;

  const AcademicScheduleModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.academicYear,
    this.departmentId = 'all',
    this.departmentName = 'All Departments',
    required this.targetStudentYear,
    this.semester = 'Odd Semester',
    required this.fileName,
    required this.fileType,
    required this.fileUrl,
    this.storagePath = '',
    this.fileSize = 0,
    this.version = 1,
    this.status = ScheduleStatus.active,
    this.isLatest = true,
    this.publishedAt,
    required this.uploadedAt,
    required this.uploadedBy,
    required this.uploadedByName,
    required this.updatedAt,
    this.archivedAt,
    this.scheduleEvents = const [],
  });

  bool get isActive => status == ScheduleStatus.active;
  bool get isArchived => status == ScheduleStatus.archived;
  bool get isDraft => status == ScheduleStatus.draft;

  String get formattedUpdatedDate {
    final dt = publishedAt ?? updatedAt;
    return DateFormat('dd MMM yyyy').format(dt);
  }

  String get formattedFileSize {
    if (fileSize <= 0) return '';
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  String get fileExtensionUpper => fileType.toUpperCase();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'academicYear': academicYear,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'targetStudentYear': targetStudentYear,
      'semester': semester,
      'fileName': fileName,
      'fileType': fileType.toLowerCase(),
      'fileUrl': fileUrl,
      'storagePath': storagePath,
      'fileSize': fileSize,
      'version': version,
      'status': status.name,
      'isLatest': isLatest,
      'publishedAt': publishedAt != null ? Timestamp.fromDate(publishedAt!) : null,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'uploadedBy': uploadedBy,
      'uploadedByName': uploadedByName,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'archivedAt': archivedAt != null ? Timestamp.fromDate(archivedAt!) : null,
      'scheduleEvents': scheduleEvents.map((e) => e.toMap()).toList(),
    };
  }

  factory AcademicScheduleModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic val, [DateTime? fallback]) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? (fallback ?? DateTime.now());
      return fallback ?? DateTime.now();
    }

    ScheduleStatus parseStatus(String? str) {
      if (str == null) return ScheduleStatus.active;
      switch (str.toLowerCase()) {
        case 'archived':
          return ScheduleStatus.archived;
        case 'draft':
          return ScheduleStatus.draft;
        case 'active':
        default:
          return ScheduleStatus.active;
      }
    }

    List<ScheduleEventItem> parsedEvents = [];
    if (map['scheduleEvents'] is List) {
      parsedEvents = (map['scheduleEvents'] as List)
          .map((e) => ScheduleEventItem.fromMap(e as Map<String, dynamic>))
          .toList();
    }

    return AcademicScheduleModel(
      id: docId.isNotEmpty ? docId : (map['id']?.toString() ?? ''),
      title: map['title']?.toString() ?? 'Official Academic Schedule',
      description: map['description']?.toString() ?? '',
      academicYear: map['academicYear']?.toString() ?? '2026-27',
      departmentId: map['departmentId']?.toString() ?? 'all',
      departmentName: map['departmentName']?.toString() ?? 'All Departments',
      targetStudentYear: map['targetStudentYear']?.toString() ?? 'I Year',
      semester: map['semester']?.toString() ?? 'Odd Semester',
      fileName: map['fileName']?.toString() ?? '',
      fileType: map['fileType']?.toString() ?? 'xls',
      fileUrl: map['fileUrl']?.toString() ?? '',
      storagePath: map['storagePath']?.toString() ?? '',
      fileSize: (map['fileSize'] as num?)?.toInt() ?? 0,
      version: (map['version'] as num?)?.toInt() ?? 1,
      status: parseStatus(map['status']?.toString()),
      isLatest: map['isLatest'] == true,
      publishedAt: map['publishedAt'] != null ? parseDate(map['publishedAt']) : null,
      uploadedAt: parseDate(map['uploadedAt']),
      uploadedBy: map['uploadedBy']?.toString() ?? '',
      uploadedByName: map['uploadedByName']?.toString() ?? '',
      updatedAt: parseDate(map['updatedAt']),
      archivedAt: map['archivedAt'] != null ? parseDate(map['archivedAt']) : null,
      scheduleEvents: parsedEvents,
    );
  }

  AcademicScheduleModel copyWith({
    String? id,
    String? title,
    String? description,
    String? academicYear,
    String? departmentId,
    String? departmentName,
    String? targetStudentYear,
    String? semester,
    String? fileName,
    String? fileType,
    String? fileUrl,
    String? storagePath,
    int? fileSize,
    int? version,
    ScheduleStatus? status,
    bool? isLatest,
    DateTime? publishedAt,
    DateTime? uploadedAt,
    String? uploadedBy,
    String? uploadedByName,
    DateTime? updatedAt,
    DateTime? archivedAt,
    List<ScheduleEventItem>? scheduleEvents,
  }) {
    return AcademicScheduleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      academicYear: academicYear ?? this.academicYear,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      targetStudentYear: targetStudentYear ?? this.targetStudentYear,
      semester: semester ?? this.semester,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      fileUrl: fileUrl ?? this.fileUrl,
      storagePath: storagePath ?? this.storagePath,
      fileSize: fileSize ?? this.fileSize,
      version: version ?? this.version,
      status: status ?? this.status,
      isLatest: isLatest ?? this.isLatest,
      publishedAt: publishedAt ?? this.publishedAt,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploadedByName: uploadedByName ?? this.uploadedByName,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      scheduleEvents: scheduleEvents ?? this.scheduleEvents,
    );
  }
}
