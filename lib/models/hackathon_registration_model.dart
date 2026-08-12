import 'dart:convert';
import 'package:unisphere/models/hackathon_model.dart';

class HackathonRegistrationModel {
  final String id; // registrationId
  final String hackathonId;
  final String hackathonTitle;
  final String studentId;
  final String studentName;
  final String department;
  final String year;
  final String email;
  final String phone;
  final String teamName;
  final List<String> teamMembers;
  final DateTime registrationDate;
  final DateTime startDate;
  final DateTime endDate;
  final String participationStatus; // e.g. 'Registration Confirmed', 'Active Participant', 'Participation Completed'
  final String mode; // 'Online', 'Offline', 'Hybrid'
  final String location; // Venue name if offline
  final String organizer;
  final String description;
  final String bannerImage;
  final List<String> rules;
  final DateTime? submissionDeadline;
  final String? projectSubmissionUrl;
  final String? projectSubmissionTitle;
  final String? projectSubmissionNotes;
  final DateTime? submittedAt;

  HackathonRegistrationModel({
    required this.id,
    required this.hackathonId,
    required this.hackathonTitle,
    required this.studentId,
    required this.studentName,
    required this.department,
    required this.year,
    required this.email,
    required this.phone,
    required this.teamName,
    required this.teamMembers,
    required this.registrationDate,
    required this.startDate,
    required this.endDate,
    required this.participationStatus,
    required this.mode,
    required this.location,
    required this.organizer,
    this.description = '',
    this.bannerImage = '',
    this.rules = const [],
    this.submissionDeadline,
    this.projectSubmissionUrl,
    this.projectSubmissionTitle,
    this.projectSubmissionNotes,
    this.submittedAt,
  });

  /// Dynamic lifecycle status based on current date vs start/end dates
  /// Registered + Start date in future -> PENDING
  /// Current date between start and end date -> ONGOING
  /// End date passed -> COMPLETED
  String get status {
    final now = DateTime.now();
    if (now.isBefore(startDate)) {
      return 'pending';
    } else if (now.isAfter(endDate)) {
      return 'completed';
    } else {
      return 'ongoing';
    }
  }

  bool get isOngoing => status == 'ongoing';
  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';

  HackathonModel toHackathonModel() {
    return HackathonModel(
      id: hackathonId,
      title: hackathonTitle,
      description: description.isNotEmpty
          ? description
          : '36-hour innovation hackathon focusing on AI agents, cloud pipelines, and software engineering.',
      category: 'Hackathon',
      organizer: organizer,
      mode: mode,
      bannerImage: bannerImage.isNotEmpty
          ? bannerImage
          : 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=800&q=80',
      startDate: startDate,
      endDate: endDate,
      registrationOpen: !isCompleted,
      registrationDeadline: startDate.subtract(const Duration(days: 1)),
      prizePool: '₹2,50,000',
      registeredTeams: 120,
      maxTeams: 200,
      teamSize: teamMembers.isNotEmpty ? teamMembers.length : 4,
      status: status,
      userRegistrationStatus: 'registered',
      registrationId: id,
      location: location,
      tags: ['Innovation', 'Development'],
    );
  }

  HackathonRegistrationModel copyWith({
    String? id,
    String? hackathonId,
    String? hackathonTitle,
    String? studentId,
    String? studentName,
    String? department,
    String? year,
    String? email,
    String? phone,
    String? teamName,
    List<String>? teamMembers,
    DateTime? registrationDate,
    DateTime? startDate,
    DateTime? endDate,
    String? participationStatus,
    String? mode,
    String? location,
    String? organizer,
    String? description,
    String? bannerImage,
    List<String>? rules,
    DateTime? submissionDeadline,
    String? projectSubmissionUrl,
    String? projectSubmissionTitle,
    String? projectSubmissionNotes,
    DateTime? submittedAt,
  }) {
    return HackathonRegistrationModel(
      id: id ?? this.id,
      hackathonId: hackathonId ?? this.hackathonId,
      hackathonTitle: hackathonTitle ?? this.hackathonTitle,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      department: department ?? this.department,
      year: year ?? this.year,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      teamName: teamName ?? this.teamName,
      teamMembers: teamMembers ?? this.teamMembers,
      registrationDate: registrationDate ?? this.registrationDate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      participationStatus: participationStatus ?? this.participationStatus,
      mode: mode ?? this.mode,
      location: location ?? this.location,
      organizer: organizer ?? this.organizer,
      description: description ?? this.description,
      bannerImage: bannerImage ?? this.bannerImage,
      rules: rules ?? this.rules,
      submissionDeadline: submissionDeadline ?? this.submissionDeadline,
      projectSubmissionUrl: projectSubmissionUrl ?? this.projectSubmissionUrl,
      projectSubmissionTitle: projectSubmissionTitle ?? this.projectSubmissionTitle,
      projectSubmissionNotes: projectSubmissionNotes ?? this.projectSubmissionNotes,
      submittedAt: submittedAt ?? this.submittedAt,
    );
  }

  factory HackathonRegistrationModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic val, DateTime fallback) {
      if (val == null) return fallback;
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString()) ?? fallback;
    }

    final now = DateTime.now();

    return HackathonRegistrationModel(
      id: map['registrationId']?.toString() ?? map['id']?.toString() ?? 'REG-${now.millisecondsSinceEpoch}',
      hackathonId: map['hackathonId']?.toString() ?? map['hackathon_id']?.toString() ?? '',
      hackathonTitle: map['hackathonTitle']?.toString() ?? map['hackathon_title']?.toString() ?? map['hackathonName']?.toString() ?? '',
      studentId: map['studentId']?.toString() ?? map['student_id']?.toString() ?? 'STU-2026-042',
      studentName: map['studentName']?.toString() ?? map['student_name']?.toString() ?? 'Alex Johnson',
      department: map['department']?.toString() ?? 'Computer Science & Engineering',
      year: map['year']?.toString() ?? '3rd Year',
      email: map['email']?.toString() ?? 'alex.j@unisphere.edu',
      phone: map['phone']?.toString() ?? '+91 98765 43210',
      teamName: map['teamName']?.toString() ?? map['team_name']?.toString() ?? 'Team Innovators',
      teamMembers: (map['teamMembers'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          (map['members'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          ['Alex Johnson (Lead)'],
      registrationDate: parseDate(map['registrationDate'] ?? map['registration_date'], now),
      startDate: parseDate(map['startDate'] ?? map['start_date'], now.subtract(const Duration(days: 1))),
      endDate: parseDate(map['endDate'] ?? map['end_date'], now.add(const Duration(days: 2))),
      participationStatus: map['participationStatus']?.toString() ?? map['status']?.toString() ?? 'Confirmed',
      mode: map['mode']?.toString() ?? 'Online',
      location: map['location']?.toString() ?? map['venue']?.toString() ?? 'Online',
      organizer: map['organizer']?.toString() ?? 'UniSphere Innovation Cell',
      description: map['description']?.toString() ?? '',
      bannerImage: map['bannerImage']?.toString() ?? map['banner_image']?.toString() ?? '',
      rules: (map['rules'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      submissionDeadline: map['submissionDeadline'] != null ? parseDate(map['submissionDeadline'], now) : null,
      projectSubmissionUrl: map['projectSubmissionUrl']?.toString(),
      projectSubmissionTitle: map['projectSubmissionTitle']?.toString(),
      projectSubmissionNotes: map['projectSubmissionNotes']?.toString(),
      submittedAt: map['submittedAt'] != null ? parseDate(map['submittedAt'], now) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'registrationId': id,
      'id': id,
      'hackathonId': hackathonId,
      'hackathonTitle': hackathonTitle,
      'hackathonName': hackathonTitle,
      'studentId': studentId,
      'studentName': studentName,
      'department': department,
      'year': year,
      'email': email,
      'phone': phone,
      'teamName': teamName,
      'teamMembers': teamMembers,
      'registrationDate': registrationDate.toIso8601String(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status,
      'participationStatus': participationStatus,
      'mode': mode,
      'location': location,
      'organizer': organizer,
      'description': description,
      'bannerImage': bannerImage,
      'rules': rules,
      'submissionDeadline': submissionDeadline?.toIso8601String(),
      'projectSubmissionUrl': projectSubmissionUrl,
      'projectSubmissionTitle': projectSubmissionTitle,
      'projectSubmissionNotes': projectSubmissionNotes,
      'submittedAt': submittedAt?.toIso8601String(),
    };
  }

  String toJson() => json.encode(toMap());

  factory HackathonRegistrationModel.fromJson(String source) => HackathonRegistrationModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

