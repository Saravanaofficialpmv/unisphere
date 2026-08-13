library;

/// Core Attendance Models for Unisphere Application

/// Status of an individual session record
enum AttendanceStatus { present, absent, onDuty, late }

extension AttendanceStatusExtension on AttendanceStatus {
  String get label {
    switch (this) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.onDuty:
        return 'On Duty';
      case AttendanceStatus.late:
        return 'Late';
    }
  }
}

/// Record for a specific class session
class AttendanceRecord {
  final String id;
  final String studentUid;
  final String studentName;
  final String subjectCode;
  final String subjectName;
  final DateTime date;
  final String timeSlot;
  final AttendanceStatus status;
  final String facultyName;

  AttendanceRecord({
    required this.id,
    required this.studentUid,
    required this.studentName,
    required this.subjectCode,
    required this.subjectName,
    required this.date,
    required this.timeSlot,
    required this.status,
    required this.facultyName,
  });

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    AttendanceStatus parsedStatus = AttendanceStatus.present;
    final statusStr = map['status']?.toString().toLowerCase() ?? 'present';
    if (statusStr == 'absent') {
      parsedStatus = AttendanceStatus.absent;
    } else if (statusStr == 'onduty' || statusStr == 'on duty') {
      parsedStatus = AttendanceStatus.onDuty;
    } else if (statusStr == 'late') {
      parsedStatus = AttendanceStatus.late;
    }

    return AttendanceRecord(
      id: map['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      studentUid: map['student_uid'] ?? '',
      studentName: map['student_name'] ?? 'Student',
      subjectCode: map['subject_code'] ?? 'CS301',
      subjectName: map['subject_name'] ?? 'Subject',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      timeSlot: map['time_slot'] ?? '09:00 - 10:00 AM',
      status: parsedStatus,
      facultyName: map['faculty_name'] ?? 'Faculty',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_uid': studentUid,
      'student_name': studentName,
      'subject_code': subjectCode,
      'subject_name': subjectName,
      'date': date.toIso8601String(),
      'time_slot': timeSlot,
      'status': status.label,
      'faculty_name': facultyName,
    };
  }
}

/// Subject-level attendance metrics for a student
class SubjectAttendance {
  final String code;
  final String name;
  final String facultyName;
  final int credits;
  final int attendedSessions;
  final int totalSessions;
  final int colorValue;

  SubjectAttendance({
    required this.code,
    required this.name,
    required this.facultyName,
    this.credits = 4,
    required this.attendedSessions,
    required this.totalSessions,
    this.colorValue = 0xFF2563EB,
  });

  double get percentage {
    if (totalSessions <= 0) return 0.0;
    return (attendedSessions / totalSessions) * 100.0;
  }

  bool get isLow => percentage < 80.0;

  String get safeMarginText {
    if (percentage >= 90.0) return 'Safe: Can skip 4 classes';
    if (percentage >= 85.0) return 'Safe: Can skip 3 classes';
    if (percentage >= 80.0) return 'Safe: Can skip 2 classes';
    return 'Warning: Attend next 2 classes!';
  }

  SubjectAttendance copyWith({
    int? attendedSessions,
    int? totalSessions,
  }) {
    return SubjectAttendance(
      code: code,
      name: name,
      facultyName: facultyName,
      credits: credits,
      attendedSessions: attendedSessions ?? this.attendedSessions,
      totalSessions: totalSessions ?? this.totalSessions,
      colorValue: colorValue,
    );
  }
}

/// Configuration for a semester set by Head of Department (HOD)
class HodSemesterConfig {
  final int semesterNumber;
  final String semesterName;
  final int totalWorkingDays;
  final double minimumRequiredPercentage;

  const HodSemesterConfig({
    required this.semesterNumber,
    required this.semesterName,
    required this.totalWorkingDays,
    this.minimumRequiredPercentage = 75.0,
  });

  HodSemesterConfig copyWith({
    int? totalWorkingDays,
    double? minimumRequiredPercentage,
  }) {
    return HodSemesterConfig(
      semesterNumber: semesterNumber,
      semesterName: semesterName,
      totalWorkingDays: totalWorkingDays ?? this.totalWorkingDays,
      minimumRequiredPercentage: minimumRequiredPercentage ?? this.minimumRequiredPercentage,
    );
  }
}

/// Student's semester attendance data
class SemesterAttendance {
  final int semesterNumber;
  final String semesterName;
  final int attendedWorkingDays;
  final int totalWorkingDays;
  final bool isCurrentSemester;
  final List<SubjectAttendance> subjects;

  const SemesterAttendance({
    required this.semesterNumber,
    required this.semesterName,
    required this.attendedWorkingDays,
    required this.totalWorkingDays,
    this.isCurrentSemester = false,
    this.subjects = const [],
  });

  double get attendancePercentage {
    if (totalWorkingDays <= 0) return 0.0;
    final pct = (attendedWorkingDays / totalWorkingDays) * 100.0;
    return pct > 100.0 ? 100.0 : pct;
  }

  String get statusLabel {
    final pct = attendancePercentage;
    if (pct >= 85.0) return 'Good';
    if (pct >= 75.0) return 'Safe Margin';
    return 'Critical';
  }

  String get safeMarginText {
    final pct = attendancePercentage;
    if (pct >= 85.0) return 'Safe Margin: Can skip up to 4 days';
    if (pct >= 75.0) return 'Warning: Attend next 3 classes!';
    return 'Shortage Alert: Below 75% requirement';
  }

  SemesterAttendance copyWith({
    int? attendedWorkingDays,
    int? totalWorkingDays,
    bool? isCurrentSemester,
    List<SubjectAttendance>? subjects,
  }) {
    return SemesterAttendance(
      semesterNumber: semesterNumber,
      semesterName: semesterName,
      attendedWorkingDays: attendedWorkingDays ?? this.attendedWorkingDays,
      totalWorkingDays: totalWorkingDays ?? this.totalWorkingDays,
      isCurrentSemester: isCurrentSemester ?? this.isCurrentSemester,
      subjects: subjects ?? this.subjects,
    );
  }
}

/// Leave & On-Duty request model
class LeaveRequestModel {
  final String id;
  final String studentName;
  final String type;
  final String duration;
  final String reason;
  final String status;
  final String appliedDate;
  final bool hasAttachment;

  LeaveRequestModel({
    required this.id,
    required this.studentName,
    required this.type,
    required this.duration,
    required this.reason,
    required this.status,
    required this.appliedDate,
    this.hasAttachment = false,
  });
}
