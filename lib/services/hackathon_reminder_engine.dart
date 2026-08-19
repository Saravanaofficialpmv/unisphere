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

      // -----------------------------------------------------------------------
      // SMART STOPPING RULE:
      // If team registration is verified or submitted with valid proof and no pending correction,
      // stop all future registration reminders.
      // -----------------------------------------------------------------------
      final isRegistrationComplete = reg.isVerified || (reg.hasExternalRegId && reg.hasScreenshotProof && reg.hasRequiredMembers && !reg.isCorrectionRequired);
      if (isRegistrationComplete) {
        // Registration is fully complete & satisfied -> Stop all registration reminders
        continue;
      }

      // -----------------------------------------------------------------------
      // CORRECTION REMINDER: Send ONLY to Team Leader when Advisor requests correction
      // -----------------------------------------------------------------------
      if (reg.isCorrectionRequired) {
        final noteText = reg.advisorCorrectionNotes ?? 'Please review and re-upload clear screenshot proof.';
        final dispatched = await _notificationEngine.dispatchAutomatedNotification(
          ruleId: 'hackathon_correction_${reg.id}',
          title: '🔴 Advisor Requested Correction: ${reg.hackathonTitle}',
          message: 'Class Advisor (${reg.assignedAdvisorName}) requested correction for team "${reg.teamName}": "$noteText"',
          category: 'Hackathon',
          priority: 'urgent',
          targetUserIds: [teamLeaderId], // ONLY TEAM LEADER
          targetRoles: ['student'],
          relatedModule: 'hackathon',
          relatedRecordId: reg.id,
          deepLink: '/hackathons/details/${reg.hackathonId}',
          currentStatusValue: 'Correction Required',
          cooldownHours: 12,
        );
        if (dispatched) sentCount++;
      }

      if (hackathon != null) {
        final now = DateTime.now();
        final daysUntilDeadline = hackathon.registrationDeadline.difference(now).inDays;
        final hoursUntilDeadline = hackathon.registrationDeadline.difference(now).inHours;

        // -----------------------------------------------------------------------
        // SCHEDULED DEADLINE REMINDERS (7d, 3d, 1d, 0d) -> Sent ONLY to Team Leader
        // -----------------------------------------------------------------------

        // 7 DAYS BEFORE DEADLINE
        if (daysUntilDeadline == 7 || (daysUntilDeadline > 5 && daysUntilDeadline <= 7)) {
          final dispatched = await _notificationEngine.dispatchAutomatedNotification(
            ruleId: 'hackathon_remind_7d_${reg.id}',
            title: '📅 7 Days Remaining: ${hackathon.title}',
            message: 'Hackathon registration closes in 7 days. Team Leader ${reg.studentName}, complete your team "${reg.teamName}" registration.',
            category: 'Hackathon',
            priority: 'medium',
            targetUserIds: [teamLeaderId], // ONLY TEAM LEADER
            targetRoles: ['student'],
            relatedModule: 'hackathon',
            relatedRecordId: reg.id,
            deepLink: '/hackathons/details/${reg.hackathonId}',
            currentStatusValue: '7 Days Left',
            cooldownHours: 24,
          );
          if (dispatched) sentCount++;
        }

        // 3 DAYS BEFORE DEADLINE
        if (daysUntilDeadline == 3 || (daysUntilDeadline > 1 && daysUntilDeadline <= 3)) {
          final dispatched = await _notificationEngine.dispatchAutomatedNotification(
            ruleId: 'hackathon_remind_3d_${reg.id}',
            title: '⏳ 3 Days Remaining: ${hackathon.title}',
            message: 'Your team "${reg.teamName}" hackathon registration is incomplete. Please complete it before the deadline.',
            category: 'Hackathon',
            priority: 'high',
            targetUserIds: [teamLeaderId], // ONLY TEAM LEADER
            targetRoles: ['student'],
            relatedModule: 'hackathon',
            relatedRecordId: reg.id,
            deepLink: '/hackathons/details/${reg.hackathonId}',
            currentStatusValue: '3 Days Left',
            cooldownHours: 24,
          );
          if (dispatched) sentCount++;
        }

        // 1 DAY BEFORE DEADLINE
        if (daysUntilDeadline == 1 || (hoursUntilDeadline > 12 && hoursUntilDeadline <= 24)) {
          final dispatched = await _notificationEngine.dispatchAutomatedNotification(
            ruleId: 'hackathon_remind_1d_${reg.id}',
            title: '⚠️ Registration Closes Tomorrow: ${hackathon.title}',
            message: 'Your team "${reg.teamName}" registration closes tomorrow. Complete the required details and upload screenshot proof.',
            category: 'Hackathon',
            priority: 'urgent',
            targetUserIds: [teamLeaderId], // ONLY TEAM LEADER
            targetRoles: ['student'],
            relatedModule: 'hackathon',
            relatedRecordId: reg.id,
            deepLink: '/hackathons/details/${reg.hackathonId}',
            currentStatusValue: '1 Day Left',
            cooldownHours: 12,
          );
          if (dispatched) sentCount++;
        }

        // DEADLINE DAY (0 Days Left)
        if (daysUntilDeadline == 0 || (hoursUntilDeadline >= 0 && hoursUntilDeadline <= 12)) {
          final dispatched = await _notificationEngine.dispatchAutomatedNotification(
            ruleId: 'hackathon_remind_today_${reg.id}',
            title: '🚨 Deadline Today: ${hackathon.title}',
            message: 'Your team "${reg.teamName}" hackathon registration closes today! Complete the registration before deadline.',
            category: 'Hackathon',
            priority: 'urgent',
            targetUserIds: [teamLeaderId], // ONLY TEAM LEADER
            targetRoles: ['student'],
            relatedModule: 'hackathon',
            relatedRecordId: reg.id,
            deepLink: '/hackathons/details/${reg.hackathonId}',
            currentStatusValue: 'Deadline Today',
            cooldownHours: 6,
          );
          if (dispatched) sentCount++;
        }
      }
    }

    if (sentCount > 0) {
      debugPrint('HackathonReminderEngine: Sent $sentCount targeted automated reminders exclusively to Team Leaders.');
    }

    return sentCount;
  }
}
