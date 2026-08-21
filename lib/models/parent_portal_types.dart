import 'package:flutter/material.dart';

/// Detailed model representing a Student Ward under Parent supervision
class ParentStudentWard {
  final String id;
  final String name;
  final String regNo;
  final String department;
  final String yearSection;
  final String currentYear;
  final String currentSemester;
  final String? photoUrl;
  final String avatarInitials;
  final double attendancePercent;
  final int presentCount;
  final int absentCount;
  final int leaveOdCount;
  final String cgpa;
  final String academicTrend;
  final String academicStatus;
  final Color statusColor;
  final double totalFees;
  final double paidFees;
  final double pendingFees;
  final DateTime feeDueDate;
  final String feeStatus;
  final bool isFeeOverdue;
  final List<ParentSubjectGrade> subjectGrades;

  ParentStudentWard({
    required this.id,
    required this.name,
    required this.regNo,
    required this.department,
    required this.yearSection,
    required this.currentYear,
    required this.currentSemester,
    this.photoUrl,
    required this.avatarInitials,
    required this.attendancePercent,
    required this.presentCount,
    required this.absentCount,
    required this.leaveOdCount,
    required this.cgpa,
    required this.academicTrend,
    required this.academicStatus,
    required this.statusColor,
    required this.totalFees,
    required this.paidFees,
    required this.pendingFees,
    required this.feeDueDate,
    required this.feeStatus,
    this.isFeeOverdue = false,
    required this.subjectGrades,
  });

  /// Attendance health threshold status badge string & color
  String get attendanceHealthStatus {
    if (attendancePercent >= 0.85) return 'Healthy';
    if (attendancePercent >= 0.75) return 'Monitor';
    return 'Warning';
  }

  Color get attendanceHealthColor {
    if (attendancePercent >= 0.85) return const Color(0xFF10B981);
    if (attendancePercent >= 0.75) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}

/// Subject Grade entry for Academic Performance Summary
class ParentSubjectGrade {
  final String subjectCode;
  final String subjectName;
  final String grade;
  final Color color;

  ParentSubjectGrade({
    required this.subjectCode,
    required this.subjectName,
    required this.grade,
    required this.color,
  });
}

/// Model for Upcoming Exams in Parent Portal
class ParentExamModel {
  final String id;
  final String examName;
  final String subject;
  final DateTime examDate;
  final String timeSlot;
  final String venue;
  final String examType;

  ParentExamModel({
    required this.id,
    required this.examName,
    required this.subject,
    required this.examDate,
    required this.timeSlot,
    required this.venue,
    required this.examType,
  });
}

/// Model for Upcoming Events in Parent Portal
class ParentEventModel {
  final String id;
  final String title;
  final DateTime eventDate;
  final String timeSlot;
  final String venue;
  final String category;
  final String description;

  ParentEventModel({
    required this.id,
    required this.title,
    required this.eventDate,
    required this.timeSlot,
    required this.venue,
    required this.category,
    required this.description,
  });
}

/// Model for Important Announcements in Parent Portal
class ParentAnnouncementModel {
  final String id;
  final String title;
  final String description;
  final DateTime datePublished;
  final String category;
  final bool isImportant;
  final bool isRead;

  ParentAnnouncementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.datePublished,
    required this.category,
    this.isImportant = false,
    this.isRead = false,
  });
}

/// Model for Recent Notifications in Parent Portal with navigation target
class ParentNotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final IconData icon;
  final Color iconColor;
  final String targetTab; // 'attendance', 'academics', 'fees', 'exams', 'events', 'announcements'
  final int targetTabIndex; // 1: Attendance, 2: Academics, 3: Announcements, 6: Fees, 8: Events
  final bool isUnread;

  ParentNotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.icon,
    required this.iconColor,
    required this.targetTab,
    required this.targetTabIndex,
    this.isUnread = true,
  });
}
