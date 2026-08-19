import 'dart:convert';

class SyllabusUnitModel {
  final String unitNumber; // e.g., "Unit I"
  final String title; // e.g., "Basics of C Programming & Control Structures"
  final List<String> topics;

  SyllabusUnitModel({
    required this.unitNumber,
    required this.title,
    required this.topics,
  });

  Map<String, dynamic> toMap() {
    return {
      'unitNumber': unitNumber,
      'title': title,
      'topics': topics,
    };
  }

  factory SyllabusUnitModel.fromMap(Map<String, dynamic> map) {
    return SyllabusUnitModel(
      unitNumber: map['unitNumber']?.toString() ?? map['unit_number']?.toString() ?? 'Unit I',
      title: map['title']?.toString() ?? '',
      topics: (map['topics'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class SyllabusSubjectModel {
  final String id;
  final String subjectCode; // e.g., "CS101"
  final String subjectName; // e.g., "Programming in C"
  final String department; // e.g., "Computer Science & Engineering"
  final String year; // "I Year", "II Year", "III Year", "IV Year"
  final String semester; // "Semester 1", "Semester 2", ...
  final String academicYear; // "2026–2027"
  final int credits; // e.g., 4
  final String subjectType; // "Theory", "Practical", "Elective"
  final String description;
  final List<SyllabusUnitModel> units;
  final List<String> textbooks;
  final List<String> referenceBooks;
  final String documentUrl;
  final String documentFileName;
  final String documentSize;
  final DateTime lastUpdated;
  final String status; // "published", "draft"

  SyllabusSubjectModel({
    required this.id,
    required this.subjectCode,
    required this.subjectName,
    required this.department,
    required this.year,
    required this.semester,
    required this.academicYear,
    required this.credits,
    required this.subjectType,
    required this.description,
    required this.units,
    required this.textbooks,
    required this.referenceBooks,
    required this.documentUrl,
    required this.documentFileName,
    required this.documentSize,
    required this.lastUpdated,
    this.status = 'published',
  });

  bool get isPublished => status.toLowerCase() == 'published';

  factory SyllabusSubjectModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString()) ?? DateTime.now();
    }

    final rawUnits = map['units'] as List<dynamic>?;
    List<SyllabusUnitModel> parsedUnits = [];
    if (rawUnits != null) {
      for (var u in rawUnits) {
        if (u is Map<String, dynamic>) {
          parsedUnits.add(SyllabusUnitModel.fromMap(u));
        }
      }
    }

    return SyllabusSubjectModel(
      id: docId ?? map['id']?.toString() ?? '',
      subjectCode: map['subjectCode']?.toString() ?? map['subject_code']?.toString() ?? 'SUB101',
      subjectName: map['subjectName']?.toString() ?? map['subject_name']?.toString() ?? 'Subject Title',
      department: map['department']?.toString() ?? 'Computer Science & Engineering',
      year: map['year']?.toString() ?? 'I Year',
      semester: map['semester']?.toString() ?? 'Semester 1',
      academicYear: map['academicYear']?.toString() ?? map['academic_year']?.toString() ?? '2026–2027',
      credits: (map['credits'] ?? 4) as int,
      subjectType: map['subjectType']?.toString() ?? map['subject_type']?.toString() ?? 'Theory',
      description: map['description']?.toString() ?? '',
      units: parsedUnits,
      textbooks: (map['textbooks'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      referenceBooks: (map['referenceBooks'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      documentUrl: map['documentUrl']?.toString() ?? map['document_url']?.toString() ?? '',
      documentFileName: map['documentFileName']?.toString() ?? map['document_file_name']?.toString() ?? 'syllabus_document.pdf',
      documentSize: map['documentSize']?.toString() ?? map['document_size']?.toString() ?? '1.8 MB',
      lastUpdated: parseDate(map['lastUpdated'] ?? map['last_updated'] ?? map['updatedAt']),
      status: map['status']?.toString() ?? 'published',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subjectCode': subjectCode,
      'subject_code': subjectCode,
      'subjectName': subjectName,
      'subject_name': subjectName,
      'department': department,
      'year': year,
      'semester': semester,
      'academicYear': academicYear,
      'academic_year': academicYear,
      'credits': credits,
      'subjectType': subjectType,
      'subject_type': subjectType,
      'description': description,
      'units': units.map((u) => u.toMap()).toList(),
      'textbooks': textbooks,
      'referenceBooks': referenceBooks,
      'documentUrl': documentUrl,
      'document_url': documentUrl,
      'documentFileName': documentFileName,
      'document_file_name': documentFileName,
      'documentSize': documentSize,
      'document_size': documentSize,
      'lastUpdated': lastUpdated.toIso8601String(),
      'last_updated': lastUpdated.toIso8601String(),
      'status': status,
    };
  }

  String toJson() => json.encode(toMap());

  factory SyllabusSubjectModel.fromJson(String source) => SyllabusSubjectModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
