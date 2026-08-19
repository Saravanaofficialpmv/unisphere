import 'package:flutter/foundation.dart';
import 'package:unisphere/models/hackathon_model.dart';
import 'package:unisphere/models/hackathon_registration_model.dart';
import 'package:unisphere/services/notification_engine.dart';

class HackathonReminderEngine {
  final NotificationEngine _notificationEngine;

  HackathonReminderEngine({NotificationEngine? notificationEngine})
      : _notificationEngine = notificationEngine ?? NotificationEngine();

  /// Evaluates hackathon registrations and dispatches targeted automated reminders ONLY to Team Leaders.
  /// Enforces Smart Stopping Rule: If registration is complete and submitted/verified, future reminders are stopped.
  Future<int> evaluateAndSendReminders({
    required List<HackathonRegistrationModel> registrations,
    required List<HackathonModel> hackathons,
  }) async {
    int sentCount = 0;
    final hackathonMap = {for (var h in hackathons) h.id: h};

    for (final reg in registrations) {
      final hackathon = hackathonMap[reg.hackathonId];
      final teamLeaderId = reg.teamLeaderId.isNotEmpty ? reg.teamLeaderId : reg.studentId;

      // SMART STOPPING RULE
      final isRegistrationComplete = reg.isVerified ||
          (reg.hasExternalRegId && reg.hasScreenshotProof && reg.hasRequiredMembers && !reg.isCorrectionRequired);
      if (isRegistrationComplete) {
        continue;
      }

      // CORRECTION REMINDER
      if (reg.isCorrectionRequired) {
        final noteText = reg.advisorCorrectionNotes ?? 'Please review and re-upload clear screenshot proof.';
        final res = await _notificationEngine.dispatchAutomatedNotification(
          ruleId: 'hackathon_correction',
          recipientUserId: teamLeaderId,
          eventId: reg.id,
          title: '🔴 Advisor Requested Correction: ${reg.hackathonTitle}',
          message: 'Class Advisor (${reg.assignedAdvisorName}) requested correction for team "${reg.teamName}": "$noteText"',
          category: 'Hackathon',
          priority: 'urgent',
          targetRoles: ['student'],
          relatedModule: 'hackathon',
          relatedRecordId: reg.id,
          deepLink: '/hackathons/details/${reg.hackathonId}',
          currentStatusValue: 'Correction Required',
          cooldownHours: 12,
        );
        if (res.success) sentCount++;
      }

      if (hackathon != null) {
        final now = DateTime.now();
        final daysUntilDeadline = hackathon.registrationDeadline.difference(now).inDays;
        final hoursUntilDeadline = hackathon.registrationDeadline.difference(now).inHours;

        // 7 DAYS BEFORE DEADLINE
        if (daysUntilDeadline == 7 || (daysUntilDeadline > 5 && daysUntilDeadline <= 7)) {
          final res = await _notificationEngine.dispatchAutomatedNotification(
            ruleId: 'hackathon_remind_7d',
            recipientUserId: teamLeaderId,
            eventId: '${reg.hackathonId}_7d',
            title: '📅 7 Days Remaining: ${hackathon.title}',
            message: 'Hackathon registration closes in 7 days. Team Leader ${reg.studentName}, complete your team "${reg.teamName}" registration.',
            category: 'Hackathon',
            priority: 'medium',
            targetRoles: ['student'],
            relatedModule: 'hackathon',
            relatedRecordId: reg.id,
            deepLink: '/hackathons/details/${reg.hackathonId}',
            currentStatusValue: '7 Days Left',
            cooldownHours: 24,
          );
          if (res.success) sentCount++;
        }

        // 3 DAYS BEFORE DEADLINE
        if (daysUntilDeadline == 3 || (daysUntilDeadline > 1 && daysUntilDeadline <= 3)) {
          final res = await _notificationEngine.dispatchAutomatedNotification(
            ruleId: 'hackathon_remind_3d',
            recipientUserId: teamLeaderId,
            eventId: '${reg.hackathonId}_3d',
            title: '⏳ 3 Days Remaining: ${hackathon.title}',
            message: 'Your team "${reg.teamName}" hackathon registration is incomplete. Please complete it before the deadline.',
            category: 'Hackathon',
            priority: 'high',
            targetRoles: ['student'],
            relatedModule: 'hackathon',
            relatedRecordId: reg.id,
            deepLink: '/hackathons/details/${reg.hackathonId}',
            currentStatusValue: '3 Days Left',
            cooldownHours: 24,
          );
          if (res.success) sentCount++;
        }

        // 1 DAY BEFORE DEADLINE
        if (daysUntilDeadline == 1 || (hoursUntilDeadline > 12 && hoursUntilDeadline <= 24)) {
          final res = await _notificationEngine.dispatchAutomatedNotification(
            ruleId: 'hackathon_remind_1d',
            recipientUserId: teamLeaderId,
            eventId: '${reg.hackathonId}_1d',
            title: '⚠️ Registration Closes Tomorrow: ${hackathon.title}',
            message: 'Your team "${reg.teamName}" registration closes tomorrow. Complete the required details and upload screenshot proof.',
            category: 'Hackathon',
            priority: 'urgent',
            targetRoles: ['student'],
            relatedModule: 'hackathon',
            relatedRecordId: reg.id,
            deepLink: '/hackathons/details/${reg.hackathonId}',
            currentStatusValue: '1 Day Left',
            cooldownHours: 12,
          );
          if (res.success) sentCount++;
        }

        // DEADLINE DAY (0 Days Left)
        if (daysUntilDeadline == 0 || (hoursUntilDeadline >= 0 && hoursUntilDeadline <= 12)) {
          final res = await _notificationEngine.dispatchAutomatedNotification(
            ruleId: 'hackathon_remind_today',
            recipientUserId: teamLeaderId,
            eventId: '${reg.hackathonId}_today',
            title: '🚨 Deadline Today: ${hackathon.title}',
            message: 'Your team "${reg.teamName}" hackathon registration closes today! Complete the registration before deadline.',
            category: 'Hackathon',
            priority: 'urgent',
            targetRoles: ['student'],
            relatedModule: 'hackathon',
            relatedRecordId: reg.id,
            deepLink: '/hackathons/details/${reg.hackathonId}',
            currentStatusValue: 'Deadline Today',
            cooldownHours: 6,
          );
          if (res.success) sentCount++;
        }
      }
    }

    if (sentCount > 0) {
      debugPrint('HackathonReminderEngine: Sent $sentCount targeted automated reminders exclusively to Team Leaders.');
    }

    return sentCount;
  }
}
