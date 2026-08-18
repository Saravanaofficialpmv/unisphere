class HackathonTeamModel {
  final String teamId;
  final String hackathonId;
  final String teamName;
  final String leaderId;
  final List<String> memberIds;
  final int memberCount;
  final String registrationStatus;
  final bool registrationCompleted;
  final String hodReviewStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  HackathonTeamModel({
    required this.teamId,
    required this.hackathonId,
    required this.teamName,
    required this.leaderId,
    required this.memberIds,
    int? memberCount,
    this.registrationStatus = 'draft',
    this.registrationCompleted = false,
    this.hodReviewStatus = 'pending',
    this.createdAt,
    this.updatedAt,
  }) : memberCount = memberCount ?? memberIds.length;

  factory HackathonTeamModel.fromMap(Map<String, dynamic> map, String id, [String? hackId]) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString());
    }

    final members = List<String>.from(map['memberIds'] ?? map['member_ids'] ?? []);

    return HackathonTeamModel(
      teamId: id,
      hackathonId: hackId ?? map['hackathonId'] ?? map['hackathon_id'] ?? '',
      teamName: map['teamName'] ?? map['team_name'] ?? 'Team',
      leaderId: map['leaderId'] ?? map['leader_id'] ?? '',
      memberIds: members,
      memberCount: (map['memberCount'] ?? map['member_count'] ?? members.length) as int,
      registrationStatus: map['registrationStatus'] ?? map['registration_status'] ?? 'draft',
      registrationCompleted: map['registrationCompleted'] ?? map['registration_completed'] ?? false,
      hodReviewStatus: map['hodReviewStatus'] ?? map['hod_review_status'] ?? 'pending',
      createdAt: parseDate(map['createdAt'] ?? map['created_at']),
      updatedAt: parseDate(map['updatedAt'] ?? map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'teamId': teamId,
      'team_id': teamId,
      'hackathonId': hackathonId,
      'hackathon_id': hackathonId,
      'teamName': teamName,
      'team_name': teamName,
      'leaderId': leaderId,
      'leader_id': leaderId,
      'memberIds': memberIds,
      'member_ids': memberIds,
      'memberCount': memberCount,
      'member_count': memberCount,
      'registrationStatus': registrationStatus,
      'registration_status': registrationStatus,
      'registrationCompleted': registrationCompleted,
      'registration_completed': registrationCompleted,
      'hodReviewStatus': hodReviewStatus,
      'hod_review_status': hodReviewStatus,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
