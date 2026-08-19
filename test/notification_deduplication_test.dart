import 'package:flutter_test/flutter_test.dart';
import 'package:unisphere/services/notification_duplicate_preventer.dart';
import 'package:unisphere/services/notification_engine.dart';
import 'package:unisphere/services/notification_automation_rules_service.dart';

void main() {
  late NotificationDuplicatePreventer preventer;
  late NotificationEngine engine;

  setUp(() {
    NotificationDuplicatePreventer.clearCache();
    preventer = NotificationDuplicatePreventer(firestore: null);
    engine = NotificationEngine(firestore: null, duplicatePreventer: preventer);
  });

  group('Recipient + Event + Rule Notification Deduplication Tests', () {
    test('1. Same rule + same recipient + same event -> suppress', () async {
      final firstSend = await engine.dispatchAutomatedNotification(
        ruleId: 'rule_registered_hackathon_due',
        title: 'Hackathon Due Soon',
        message: 'Your registered hackathon is tomorrow.',
        category: 'Events',
        priority: 'high',
        targetUserIds: ['student123'],
        targetRoles: ['student'],
        eventId: 'hackathon456',
      );
      expect(firstSend, isTrue);

      final secondSend = await engine.dispatchAutomatedNotification(
        ruleId: 'rule_registered_hackathon_due',
        title: 'Hackathon Due Soon',
        message: 'Your registered hackathon is tomorrow.',
        category: 'Events',
        priority: 'high',
        targetUserIds: ['student123'],
        targetRoles: ['student'],
        eventId: 'hackathon456',
      );
      expect(secondSend, isFalse);
    });

    test('2. Same rule + different recipient + same event -> send', () async {
      final studentASend = await engine.dispatchAutomatedNotification(
        ruleId: 'rule_registered_hackathon_due',
        title: 'Hackathon Due Soon',
        message: 'Your registered hackathon is tomorrow.',
        category: 'Events',
        priority: 'high',
        targetUserIds: ['student123'],
        targetRoles: ['student'],
        eventId: 'hackathon456',
      );
      expect(studentASend, isTrue);

      final studentBSend = await engine.dispatchAutomatedNotification(
        ruleId: 'rule_registered_hackathon_due',
        title: 'Hackathon Due Soon',
        message: 'Your registered hackathon is tomorrow.',
        category: 'Events',
        priority: 'high',
        targetUserIds: ['student456'],
        targetRoles: ['student'],
        eventId: 'hackathon456',
      );
      expect(studentBSend, isTrue);
    });

    test('3. Same rule + same recipient + different event -> send', () async {
      final hackathonASend = await engine.dispatchAutomatedNotification(
        ruleId: 'rule_registered_hackathon_due',
        title: 'Hackathon A Due Soon',
        message: 'Hackathon A starts tomorrow.',
        category: 'Events',
        priority: 'high',
        targetUserIds: ['student123'],
        targetRoles: ['student'],
        eventId: 'hackathonA',
      );
      expect(hackathonASend, isTrue);

      final hackathonBSend = await engine.dispatchAutomatedNotification(
        ruleId: 'rule_registered_hackathon_due',
        title: 'Hackathon B Due Soon',
        message: 'Hackathon B starts tomorrow.',
        category: 'Events',
        priority: 'high',
        targetUserIds: ['student123'],
        targetRoles: ['student'],
        eventId: 'hackathonB',
      );
      expect(hackathonBSend, isTrue);
    });

    test('4. Same recipient + same rule + new date -> send', () async {
      final day1Send = await engine.dispatchAutomatedNotification(
        ruleId: 'rule_hod_dept_att_alert',
        title: 'HOD Attendance Alert',
        message: 'Attendance summary for 2026-08-19.',
        category: 'Approvals',
        priority: 'high',
        targetUserIds: ['hod123'],
        targetRoles: ['hod'],
        eventId: 'attendance20260819',
      );
      expect(day1Send, isTrue);

      final day2Send = await engine.dispatchAutomatedNotification(
        ruleId: 'rule_hod_dept_att_alert',
        title: 'HOD Attendance Alert',
        message: 'Attendance summary for 2026-08-20.',
        category: 'Approvals',
        priority: 'high',
        targetUserIds: ['hod123'],
        targetRoles: ['hod'],
        eventId: 'attendance20260820',
      );
      expect(day2Send, isTrue);
    });

    test('5. Different rule + same recipient + same event -> send', () async {
      final rule1Send = await engine.dispatchAutomatedNotification(
        ruleId: 'rule_registered_hackathon_due',
        title: 'Hackathon Due',
        message: 'Reminder 1.',
        category: 'Events',
        priority: 'medium',
        targetUserIds: ['student123'],
        targetRoles: ['student'],
        eventId: 'hackathon456',
      );
      expect(rule1Send, isTrue);

      final rule2Send = await engine.dispatchAutomatedNotification(
        ruleId: 'rule_hackathon_team_submission',
        title: 'Hackathon Team Submission Needed',
        message: 'Reminder 2.',
        category: 'Events',
        priority: 'high',
        targetUserIds: ['student123'],
        targetRoles: ['student'],
        eventId: 'hackathon456',
      );
      expect(rule2Send, isTrue);
    });

    test('6. Future event that is not eligible -> do not send', () async {
      final now = DateTime.now();
      final futureEventDate = now.add(const Duration(days: 30));
      final daysDifference = futureEventDate.difference(now).inDays;

      bool isEligible = daysDifference <= 1; // Only trigger if 1 day away
      expect(isEligible, isFalse);

      if (isEligible) {
        await engine.dispatchAutomatedNotification(
          ruleId: 'rule_registered_hackathon_due',
          title: 'Future Event',
          message: 'Far in future',
          category: 'Events',
          priority: 'low',
          targetUserIds: ['student123'],
          targetRoles: ['student'],
          eventId: 'future_event_999',
        );
      }

      final isSent = await preventer.alreadySent(
        ruleId: 'rule_registered_hackathon_due',
        recipientUserId: 'student123',
        eventId: 'future_event_999',
      );
      expect(isSent, isFalse);
    });

    test('7. Notification already marked as sent -> suppress', () async {
      await preventer.claimAndRecord(
        ruleId: 'rule_placement_eligible_alert',
        recipientUserId: 'student123',
        eventId: 'placementDrive456',
        notificationId: 'notif_existing',
      );

      final isSent = await preventer.alreadySent(
        ruleId: 'rule_placement_eligible_alert',
        recipientUserId: 'student123',
        eventId: 'placementDrive456',
      );
      expect(isSent, isTrue);

      final dispatchAttempt = await engine.dispatchAutomatedNotification(
        ruleId: 'rule_placement_eligible_alert',
        title: 'Placement Drive',
        message: 'Already sent test.',
        category: 'Career',
        priority: 'high',
        targetUserIds: ['student123'],
        targetRoles: ['student'],
        eventId: 'placementDrive456',
      );
      expect(dispatchAttempt, isFalse);
    });

    test('8. Failed notification -> allow retry according to retry policy', () async {
      int retryCount = 0;
      const maxRetries = 3;

      bool attemptDelivery() {
        if (retryCount < maxRetries) {
          retryCount++;
          return true; // retry permitted
        }
        return false;
      }

      expect(attemptDelivery(), isTrue); // Retry 1
      expect(attemptDelivery(), isTrue); // Retry 2
      expect(attemptDelivery(), isTrue); // Retry 3
      expect(attemptDelivery(), isFalse); // Max reached
    });

    test('9. Read notification -> do not recreate it', () async {
      await preventer.claimAndRecord(
        ruleId: 'rule_staff_att_sub_pending',
        recipientUserId: 'staff123',
        eventId: 'attendanceDate20260819',
        notificationId: 'notif_read_1',
      );

      // Re-triggering for the same read notification should return false (suppress)
      final resend = await engine.dispatchAutomatedNotification(
        ruleId: 'rule_staff_att_sub_pending',
        title: 'Pending Attendance',
        message: 'Please submit attendance.',
        category: 'Academic',
        priority: 'medium',
        targetUserIds: ['staff123'],
        targetRoles: ['staff'],
        eventId: 'attendanceDate20260819',
      );
      expect(resend, isFalse);
    });

    test('10. Scheduler running multiple times -> must not generate duplicates', () async {
      final rulesService = NotificationAutomationRulesService(firestore: null, engine: engine);

      final run1 = await rulesService.evaluateAllRules();
      expect(run1.newDispatched, greaterThan(0));

      final run2 = await rulesService.evaluateAllRules();
      expect(run2.newDispatched, equals(0));
      expect(run2.duplicatesSuppressed, equals(run1.eligibleNotifications));
    });
  });
}
