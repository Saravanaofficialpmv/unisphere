import 'dart:convert';

class HackathonModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String organizer;
  final String mode; // 'Online', 'Offline', 'Hybrid'
  final String bannerImage;
  final DateTime startDate;
  final DateTime endDate;
  final bool registrationOpen;
  final DateTime registrationDeadline;
  final String prizePool;
  final int registeredTeams;
  final int maxTeams;
  final int teamSize;
  final String status; // 'upcoming', 'ongoing', 'ended'
  final String userRegistrationStatus; // 'registered', 'not_registered', 'pending'
  final String? registrationId;
  final String location;
  final List<String> tags;
  final bool isFeatured;

  HackathonModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.organizer,
    required this.mode,
    required this.bannerImage,
    required this.startDate,
    required this.endDate,
    required this.registrationOpen,
    required this.registrationDeadline,
    required this.prizePool,
    required this.registeredTeams,
    required this.maxTeams,
    required this.teamSize,
    required this.status,
    required this.userRegistrationStatus,
    this.registrationId,
    required this.location,
    required this.tags,
    this.isFeatured = false,
  });

  bool get isRegistered => userRegistrationStatus.toLowerCase() == 'registered';

  factory HackathonModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString()) ?? DateTime.now();
    }

    return HackathonModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      category: map['category']?.toString() ?? 'General',
      organizer: map['organizer']?.toString() ?? 'Organizer',
      mode: map['mode']?.toString() ?? 'Online',
      bannerImage: map['bannerImage']?.toString() ?? map['banner_image']?.toString() ?? '',
      startDate: parseDate(map['startDate'] ?? map['start_date']),
      endDate: parseDate(map['endDate'] ?? map['end_date']),
      registrationOpen: map['registrationOpen'] ?? map['registration_open'] ?? true,
      registrationDeadline: parseDate(map['registrationDeadline'] ?? map['registration_deadline']),
      prizePool: map['prizePool']?.toString() ?? map['prize_pool']?.toString() ?? '₹0',
      registeredTeams: (map['registeredTeams'] ?? map['registered_teams'] ?? 0) as int,
      maxTeams: (map['maxTeams'] ?? map['max_teams'] ?? 100) as int,
      teamSize: (map['teamSize'] ?? map['team_size'] ?? 4) as int,
      status: map['status']?.toString() ?? 'upcoming',
      userRegistrationStatus: map['userRegistrationStatus']?.toString() ?? map['user_registration_status']?.toString() ?? 'not_registered',
      registrationId: map['registrationId']?.toString() ?? map['registration_id']?.toString(),
      location: map['location']?.toString() ?? 'Online',
      tags: (map['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      isFeatured: map['isFeatured'] ?? map['is_featured'] ?? false,
    );
  }

  factory HackathonModel.fromJson(String source) => HackathonModel.fromMap(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'organizer': organizer,
      'mode': mode,
      'bannerImage': bannerImage,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'registrationOpen': registrationOpen,
      'registrationDeadline': registrationDeadline.toIso8601String(),
      'prizePool': prizePool,
      'registeredTeams': registeredTeams,
      'maxTeams': maxTeams,
      'teamSize': teamSize,
      'status': status,
      'userRegistrationStatus': userRegistrationStatus,
      'registrationId': registrationId,
      'location': location,
      'tags': tags,
      'isFeatured': isFeatured,
    };
  }

  String toJson() => json.encode(toMap());

  HackathonModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? organizer,
    String? mode,
    String? bannerImage,
    DateTime? startDate,
    DateTime? endDate,
    bool? registrationOpen,
    DateTime? registrationDeadline,
    String? prizePool,
    int? registeredTeams,
    int? maxTeams,
    int? teamSize,
    String? status,
    String? userRegistrationStatus,
    String? registrationId,
    String? location,
    List<String>? tags,
    bool? isFeatured,
  }) {
    return HackathonModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      organizer: organizer ?? this.organizer,
      mode: mode ?? this.mode,
      bannerImage: bannerImage ?? this.bannerImage,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      registrationOpen: registrationOpen ?? this.registrationOpen,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      prizePool: prizePool ?? this.prizePool,
      registeredTeams: registeredTeams ?? this.registeredTeams,
      maxTeams: maxTeams ?? this.maxTeams,
      teamSize: teamSize ?? this.teamSize,
      status: status ?? this.status,
      userRegistrationStatus: userRegistrationStatus ?? this.userRegistrationStatus,
      registrationId: registrationId ?? this.registrationId,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }
}
