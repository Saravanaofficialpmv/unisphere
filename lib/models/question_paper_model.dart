import 'dart:convert';

enum QuestionPaperType {
  universityPyq,
  internalAssessment1,
  internalAssessment2,
  modelExam,
  questionBankWithSolutions,
}

extension QuestionPaperTypeExtension on QuestionPaperType {
  String get displayName {
    switch (this) {
      case QuestionPaperType.universityPyq:
        return 'University End-Semester PYQ';
      case QuestionPaperType.internalAssessment1:
        return 'Internal Assessment 1 (IAT-1)';
      case QuestionPaperType.internalAssessment2:
        return 'Internal Assessment 2 (IAT-2)';
      case QuestionPaperType.modelExam:
        return 'Model Exam';
      case QuestionPaperType.questionBankWithSolutions:
        return '2-Mark & 16-Mark Question Bank';
    }
  }

  String get shortLabel {
    switch (this) {
      case QuestionPaperType.universityPyq:
        return 'University PYQ';
      case QuestionPaperType.internalAssessment1:
        return 'IAT-1';
      case QuestionPaperType.internalAssessment2:
        return 'IAT-2';
      case QuestionPaperType.modelExam:
        return 'Model Exam';
      case QuestionPaperType.questionBankWithSolutions:
        return 'Question Bank';
    }
  }

  String get code {
    switch (this) {
      case QuestionPaperType.universityPyq:
        return 'university_pyq';
      case QuestionPaperType.internalAssessment1:
        return 'iat_1';
      case QuestionPaperType.internalAssessment2:
        return 'iat_2';
      case QuestionPaperType.modelExam:
        return 'model_exam';
      case QuestionPaperType.questionBankWithSolutions:
        return 'question_bank';
    }
  }

  static QuestionPaperType fromCode(String? code) {
    if (code == null) return QuestionPaperType.universityPyq;
    switch (code.toLowerCase()) {
      case 'iat_1':
      case 'internalassessment1':
      case 'iat1':
        return QuestionPaperType.internalAssessment1;
      case 'iat_2':
      case 'internalassessment2':
      case 'iat2':
        return QuestionPaperType.internalAssessment2;
      case 'model_exam':
      case 'modelexam':
      case 'model':
        return QuestionPaperType.modelExam;
      case 'question_bank':
      case 'questionbank':
      case 'questionbankwithsolutions':
        return QuestionPaperType.questionBankWithSolutions;
      case 'university_pyq':
      case 'universitypyq':
      default:
        return QuestionPaperType.universityPyq;
    }
  }
}

class QuestionPaperModel {
  final String id;
  final String title;
  final String subjectCode;
  final String subjectName;
  final String department;
  final String regulation; // e.g. "Regulation 2021", "Regulation 2023"
  final String year; // "I Year", "II Year", "III Year", "IV Year"
  final String semester; // "Semester 1", "Semester 2", ...
  final String academicYear; // e.g. "2024–2025"
  final String examSession; // e.g. "Nov / Dec 2024", "Apr / May 2024"
  final QuestionPaperType paperType;
  final bool hasAnswerKey;
  final String fileUrl;
  final String fileName;
  final String fileSize;
  final String? answerKeyUrl;
  final String? answerKeyFileName;
  final String? answerKeyFileSize;
  final String uploadedByStaffId;
  final String uploadedByStaffName;
  final String uploadedByStaffDesignation;
  final DateTime uploadedAt;
  final int downloadCount;
  final bool isVerified;
  final List<String> tags;

  QuestionPaperModel({
    required this.id,
    required this.title,
    required this.subjectCode,
    required this.subjectName,
    required this.department,
    this.regulation = 'Regulation 2021',
    required this.year,
    required this.semester,
    required this.academicYear,
    required this.examSession,
    required this.paperType,
    this.hasAnswerKey = false,
    required this.fileUrl,
    required this.fileName,
    this.fileSize = '2.4 MB',
    this.answerKeyUrl,
    this.answerKeyFileName,
    this.answerKeyFileSize,
    required this.uploadedByStaffId,
    required this.uploadedByStaffName,
    this.uploadedByStaffDesignation = 'Course Faculty',
    DateTime? uploadedAt,
    this.downloadCount = 0,
    this.isVerified = true,
    this.tags = const [],
  }) : uploadedAt = uploadedAt ?? DateTime.now();

  QuestionPaperModel copyWith({
    String? id,
    String? title,
    String? subjectCode,
    String? subjectName,
    String? department,
    String? regulation,
    String? year,
    String? semester,
    String? academicYear,
    String? examSession,
    QuestionPaperType? paperType,
    bool? hasAnswerKey,
    String? fileUrl,
    String? fileName,
    String? fileSize,
    String? answerKeyUrl,
    String? answerKeyFileName,
    String? answerKeyFileSize,
    String? uploadedByStaffId,
    String? uploadedByStaffName,
    String? uploadedByStaffDesignation,
    DateTime? uploadedAt,
    int? downloadCount,
    bool? isVerified,
    List<String>? tags,
  }) {
    return QuestionPaperModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subjectCode: subjectCode ?? this.subjectCode,
      subjectName: subjectName ?? this.subjectName,
      department: department ?? this.department,
      regulation: regulation ?? this.regulation,
      year: year ?? this.year,
      semester: semester ?? this.semester,
      academicYear: academicYear ?? this.academicYear,
      examSession: examSession ?? this.examSession,
      paperType: paperType ?? this.paperType,
      hasAnswerKey: hasAnswerKey ?? this.hasAnswerKey,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      answerKeyUrl: answerKeyUrl ?? this.answerKeyUrl,
      answerKeyFileName: answerKeyFileName ?? this.answerKeyFileName,
      answerKeyFileSize: answerKeyFileSize ?? this.answerKeyFileSize,
      uploadedByStaffId: uploadedByStaffId ?? this.uploadedByStaffId,
      uploadedByStaffName: uploadedByStaffName ?? this.uploadedByStaffName,
      uploadedByStaffDesignation: uploadedByStaffDesignation ?? this.uploadedByStaffDesignation,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      downloadCount: downloadCount ?? this.downloadCount,
      isVerified: isVerified ?? this.isVerified,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subjectCode': subjectCode,
      'subjectName': subjectName,
      'department': department,
      'regulation': regulation,
      'year': year,
      'semester': semester,
      'academicYear': academicYear,
      'examSession': examSession,
      'paperType': paperType.code,
      'hasAnswerKey': hasAnswerKey,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'answerKeyUrl': answerKeyUrl,
      'answerKeyFileName': answerKeyFileName,
      'answerKeyFileSize': answerKeyFileSize,
      'uploadedByStaffId': uploadedByStaffId,
      'uploadedByStaffName': uploadedByStaffName,
      'uploadedByStaffDesignation': uploadedByStaffDesignation,
      'uploadedAt': uploadedAt.toIso8601String(),
      'downloadCount': downloadCount,
      'isVerified': isVerified,
      'tags': tags,
    };
  }

  factory QuestionPaperModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString()) ?? DateTime.now();
    }

    return QuestionPaperModel(
      id: docId ?? map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Question Paper',
      subjectCode: map['subjectCode']?.toString() ?? map['subject_code']?.toString() ?? '',
      subjectName: map['subjectName']?.toString() ?? map['subject_name']?.toString() ?? '',
      department: map['department']?.toString() ?? 'Computer Science & Engineering',
      regulation: map['regulation']?.toString() ?? 'Regulation 2021',
      year: map['year']?.toString() ?? 'II Year',
      semester: map['semester']?.toString() ?? 'Semester 3',
      academicYear: map['academicYear']?.toString() ?? '2024–2025',
      examSession: map['examSession']?.toString() ?? 'Nov / Dec 2024',
      paperType: QuestionPaperTypeExtension.fromCode(map['paperType']?.toString()),
      hasAnswerKey: map['hasAnswerKey'] == true || map['has_answer_key'] == true,
      fileUrl: map['fileUrl']?.toString() ?? '',
      fileName: map['fileName']?.toString() ?? 'Question_Paper.pdf',
      fileSize: map['fileSize']?.toString() ?? '2.4 MB',
      answerKeyUrl: map['answerKeyUrl']?.toString(),
      answerKeyFileName: map['answerKeyFileName']?.toString(),
      answerKeyFileSize: map['answerKeyFileSize']?.toString(),
      uploadedByStaffId: map['uploadedByStaffId']?.toString() ?? '',
      uploadedByStaffName: map['uploadedByStaffName']?.toString() ?? 'Course Faculty',
      uploadedByStaffDesignation: map['uploadedByStaffDesignation']?.toString() ?? 'Faculty Member',
      uploadedAt: parseDate(map['uploadedAt']),
      downloadCount: int.tryParse(map['downloadCount']?.toString() ?? '0') ?? 0,
      isVerified: map['isVerified'] ?? true,
      tags: (map['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  String toJson() => json.encode(toMap());

  factory QuestionPaperModel.fromJson(String source) =>
      QuestionPaperModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
