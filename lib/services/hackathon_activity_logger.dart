import 'package:unisphere/models/hackathon_activity_model.dart';

class HackathonActivityLogger {
  /// Helper to generate a new HackathonActivityModel record
  static HackathonActivityModel createActivity({
    required String hackathonId,
    required String teamId,
    required String studentId,
    required String actorId,
    required String actorRole,
    required String activityType,
    required String description,
    String? previousStatus,
    String? newStatus,
  }) {
    final now = DateTime.now();
    final id = 'ACT-${now.millisecondsSinceEpoch}-${activityType.hashCode.abs()}';

    return HackathonActivityModel(
      id: id,
      hackathonId: hackathonId,
      teamId: teamId,
      studentId: studentId,
      actorId: actorId,
      actorRole: actorRole,
      activityType: activityType,
      description: description,
      previousStatus: previousStatus,
      newStatus: newStatus,
      timestamp: now,
    );
  }
}
