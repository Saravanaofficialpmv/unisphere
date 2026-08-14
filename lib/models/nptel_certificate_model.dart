import 'package:flutter/material.dart';

enum NptelStatus {
  pending('Pending Verification', Color(0xFFF59E0B), Icons.pending_actions_rounded),
  verified('Verified', Color(0xFF10B981), Icons.verified_rounded),
  rejected('Rejected', Color(0xFFEF4444), Icons.cancel_rounded);

  final String label;
  final Color color;
  final IconData icon;

  const NptelStatus(this.label, this.color, this.icon);
}

class NptelCertificateModel {
  final String id;
  final String studentName;
  final String rollNo;
  final String department;
  final String courseName;
  final String courseCode;
  final String semester;
  final String academicYear;
  final String score;
  final String grade;
  final String certificateId;
  final String issueDate;
  final String fileName;
  final String fileSize;
  final DateTime uploadDate;
  String status; // 'Pending Verification', 'Verified', 'Rejected'
  String? rejectionReason;
  String? reviewedBy;
  DateTime? reviewedAt;

  NptelCertificateModel({
    required this.id,
    required this.studentName,
    required this.rollNo,
    required this.department,
    required this.courseName,
    required this.courseCode,
    required this.semester,
    required this.academicYear,
    required this.score,
    required this.grade,
    required this.certificateId,
    required this.issueDate,
    required this.fileName,
    required this.fileSize,
    required this.uploadDate,
    required this.status,
    this.rejectionReason,
    this.reviewedBy,
    this.reviewedAt,
  });

  Color get statusColor {
    switch (status) {
      case 'Verified':
        return const Color(0xFF10B981);
      case 'Rejected':
        return const Color(0xFFEF4444);
      case 'Pending Verification':
      default:
        return const Color(0xFFF59E0B);
    }
  }

  IconData get statusIcon {
    switch (status) {
      case 'Verified':
        return Icons.verified_rounded;
      case 'Rejected':
        return Icons.cancel_rounded;
      case 'Pending Verification':
      default:
        return Icons.hourglass_top_rounded;
    }
  }
}
