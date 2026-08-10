enum ExamRequirementStatus {
  required,
  allowed,
  notAllowed,
}

class ExamRequirementItem {
  final String label;
  final ExamRequirementStatus status;
  final String? note;

  const ExamRequirementItem({
    required this.label,
    required this.status,
    this.note,
  });

  factory ExamRequirementItem.fromMap(Map<String, dynamic> map) {
    return ExamRequirementItem(
      label: map['label'] ?? '',
      status: _parseStatus(map['status']),
      note: map['note'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'status': status.name,
      'note': note,
    };
  }

  static ExamRequirementStatus _parseStatus(String? str) {
    if (str == 'allowed') return ExamRequirementStatus.allowed;
    if (str == 'notAllowed') return ExamRequirementStatus.notAllowed;
    return ExamRequirementStatus.required;
  }
}

enum ExamEligibilityStatus {
  eligible,
  pending,
  notEligible,
}

class ExamModel {
  final String id;
  final String subjectName;
  final String courseCode;
  final String examType; // 'Unit Test', 'Internal Assessment', 'Model Exam', 'Practical Exam', 'Lab Exam', 'End Semester', 'Supplementary Exam'
  final DateTime date;
  final String startTime;
  final String endTime;
  final int durationMinutes;
  final String venue;
  final String roomNumber;
  final String blockBuilding;
  final String instructions;
  final String? facultyInvigilator;
  final ExamEligibilityStatus eligibilityStatus;
  final List<ExamRequirementItem> requirements;
  final String? hallTicketUrl;
  final bool isHallTicketAvailable;
  final List<String> targetedClasses;
  final int semester;

  ExamModel({
    required this.id,
    required this.subjectName,
    required this.courseCode,
    required this.examType,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.venue,
    required this.roomNumber,
    required this.blockBuilding,
    this.instructions = 'Arrive 15 minutes before exam start time. Present College ID & Hall Ticket upon entry.',
    this.facultyInvigilator,
    this.eligibilityStatus = ExamEligibilityStatus.eligible,
    this.requirements = const [],
    this.hallTicketUrl,
    this.isHallTicketAvailable = true,
    this.targetedClasses = const [],
    this.semester = 6,
  });

  bool get isCompleted => date.isBefore(DateTime.now());

  factory ExamModel.fromMap(Map<String, dynamic> map) {
    return ExamModel(
      id: map['id'].toString(),
      subjectName: map['subject_name'] ?? '',
      courseCode: map['course_code'] ?? '',
      examType: map['exam_type'] ?? 'Internal Assessment',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      startTime: map['start_time'] ?? '09:00 AM',
      endTime: map['end_time'] ?? '12:00 PM',
      durationMinutes: map['duration_minutes'] ?? 180,
      venue: map['venue'] ?? 'Main Block',
      roomNumber: map['room_number'] ?? 'Room 201',
      blockBuilding: map['block_building'] ?? 'Main Academic Block',
      instructions: map['instructions'] ?? 'Arrive 15 minutes before exam start time.',
      facultyInvigilator: map['faculty_invigilator'],
      eligibilityStatus: map['eligibility_status'] == 'notEligible'
          ? ExamEligibilityStatus.notEligible
          : (map['eligibility_status'] == 'pending'
              ? ExamEligibilityStatus.pending
              : ExamEligibilityStatus.eligible),
      requirements: (map['requirements'] as List<dynamic>?)
              ?.map((item) => ExamRequirementItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      hallTicketUrl: map['hall_ticket_url'],
      isHallTicketAvailable: map['is_hall_ticket_available'] ?? true,
      targetedClasses: List<String>.from(map['targeted_classes'] ?? []),
      semester: map['semester'] ?? 6,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject_name': subjectName,
      'course_code': courseCode,
      'exam_type': examType,
      'date': date.toIso8601String(),
      'start_time': startTime,
      'end_time': endTime,
      'duration_minutes': durationMinutes,
      'venue': venue,
      'room_number': roomNumber,
      'block_building': blockBuilding,
      'instructions': instructions,
      'faculty_invigilator': facultyInvigilator,
      'eligibility_status': eligibilityStatus.name,
      'requirements': requirements.map((r) => r.toMap()).toList(),
      'hall_ticket_url': hallTicketUrl,
      'is_hall_ticket_available': isHallTicketAvailable,
      'targeted_classes': targetedClasses,
      'semester': semester,
    };
  }
}
