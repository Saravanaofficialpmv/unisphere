import 'package:flutter_test/flutter_test.dart';
import 'package:unisphere/models/notification_rule_model.dart';
import 'package:unisphere/services/notification_automation_rules_service.dart';
import 'package:unisphere/services/notification_duplicate_preventer.dart';
import 'package:unisphere/services/notification_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    NotificationDuplicatePreventer.clearCache();
  });

  group('Automated Notification System & Deduplication Engine Tests', () {
    test('Deduplication Key generation is deterministic: ruleId_recipientUserId_eventId', () {
      final key = NotificationDuplicatePreventer.buildKey(
        ruleId: 'rule_fee_due_parent',
        recipientUserId: 'parent123',
        eventId: 'fee456',
      );
      expect(key, equals('rule_fee_due_parent_parent123_fee456'));
    });

    test('TEST A: Parent A + Fee A first run creates notification, second run suppresses duplicate', () async {
      final engine = NotificationEngine();

      // First run
      final res1 = await engine.dispatchAutomatedNotification(
        ruleId: 'rule_fee_due_parent',
        recipientUserId: 'parentA',
        eventId: 'feeA',
        title: 'Fee Due',
        message: 'Fee payment due',
        category: 'Finance',
        priority: 'high',
        targetRoles: ['parent'],
      );
      expect(res1.success, isTrue);
      expect(res1.decision, equals(NotificationDecision.dispatch));
      expect(res1.deduplicationKey, equals('rule_fee_due_parent_parentA_feeA'));

      // Second run (exact same rule, recipient, and event)
      final res2 = await engine.dispatchAutomatedNotification(
        ruleId: 'rule_fee_due_parent',
        recipientUserId: 'parentA',
        eventId: 'feeA',
        title: 'Fee Due',
        message: 'Fee payment due',
        category: 'Finance',
        priority: 'high',
        targetRoles: ['parent'],
      );
      expect(res2.success, isFalse);
      expect(res2.decision, equals(NotificationDecision.suppressDuplicate));
    });

    test('TEST B: Parent B + Fee A creates a new notification (Does NOT let one user suppress another)', () async {
      final engine = NotificationEngine();

      // Parent A gets notified for Fee A
      await engine.dispatchAutomatedNotification(
        ruleId: 'rule_fee_due_parent',
        recipientUserId: 'parentA',
        eventId: 'feeA',
        title: 'Fee Due',
        message: 'Fee payment due',
        category: 'Finance',
        priority: 'high',
        targetRoles: ['parent'],
      );

      // Parent B gets notified for Fee A -> MUST BE DISPATCHED!
      final resParentB = await engine.dispatchAutomatedNotification(
        ruleId: 'rule_fee_due_parent',
        recipientUserId: 'parentB',
        eventId: 'feeA',
        title: 'Fee Due',
        message: 'Fee payment due',
        category: 'Finance',
        priority: 'high',
        targetRoles: ['parent'],
      );
      expect(resParentB.success, isTrue);
      expect(resParentB.decision, equals(NotificationDecision.dispatch));
      expect(resParentB.deduplicationKey, equals('rule_fee_due_parent_parentB_feeA'));
    });

    test('TEST C: Parent A + Fee B creates a new notification (New event for same user)', () async {
      final engine = NotificationEngine();

      // Parent A + Fee A
      await engine.dispatchAutomatedNotification(
        ruleId: 'rule_fee_due_parent',
        recipientUserId: 'parentA',
        eventId: 'feeA',
        title: 'Fee Due',
        message: 'Fee payment due',
        category: 'Finance',
        priority: 'high',
        targetRoles: ['parent'],
      );

      // Parent A + Fee B -> MUST BE DISPATCHED!
      final resFeeB = await engine.dispatchAutomatedNotification(
        ruleId: 'rule_fee_due_parent',
        recipientUserId: 'parentA',
        eventId: 'feeB',
        title: 'Fee Due',
        message: 'New fee due',
        category: 'Finance',
        priority: 'high',
        targetRoles: ['parent'],
      );
      expect(resFeeB.success, isTrue);
      expect(resFeeB.decision, equals(NotificationDecision.dispatch));
      expect(resFeeB.deduplicationKey, equals('rule_fee_due_parent_parentA_feeB'));
    });

    test('TEST D: Student Hackathon notifications evaluate independently per student & event', () async {
      final engine = NotificationEngine();

      // Student A + Hackathon A
      final res1 = await engine.dispatchAutomatedNotification(
        ruleId: 'rule_registered_hackathon_due',
        recipientUserId: 'studentA',
        eventId: 'hackathonA',
        title: 'Hackathon Due',
        message: 'Starts tomorrow',
        category: 'Events',
        priority: 'medium',
        targetRoles: ['student'],
      );
      expect(res1.success, isTrue);

      // Student A + Hackathon A again -> Suppressed
      final res1Again = await engine.dispatchAutomatedNotification(
        ruleId: 'rule_registered_hackathon_due',
        recipientUserId: 'studentA',
        eventId: 'hackathonA',
        title: 'Hackathon Due',
        message: 'Starts tomorrow',
        category: 'Events',
        priority: 'medium',
        targetRoles: ['student'],
      );
      expect(res1Again.decision, equals(NotificationDecision.suppressDuplicate));

      // Student B + Hackathon A -> Dispatched
      final resStudentB = await engine.dispatchAutomatedNotification(
        ruleId: 'rule_registered_hackathon_due',
        recipientUserId: 'studentB',
        eventId: 'hackathonA',
        title: 'Hackathon Due',
        message: 'Starts tomorrow',
        category: 'Events',
        priority: 'medium',
        targetRoles: ['student'],
      );
      expect(resStudentB.success, isTrue);
    });

    test('TEST E: HOD Attendance Event A vs Event B evaluation', () async {
      final engine = NotificationEngine();

      // HOD + Attendance Event A
      final resA = await engine.dispatchAutomatedNotification(
        ruleId: 'rule_hod_dept_att_alert',
        recipientUserId: 'hodCSE',
        eventId: 'ATT_2026_08_18',
        title: 'HOD Attendance Alert',
        message: 'Attendance summary',
        category: 'Approvals',
        priority: 'high',
        targetRoles: ['hod'],
      );
      expect(resA.success, isTrue);

      // HOD + Attendance Event A again -> Suppressed
      final resAAgain = await engine.dispatchAutomatedNotification(
        ruleId: 'rule_hod_dept_att_alert',
        recipientUserId: 'hodCSE',
        eventId: 'ATT_2026_08_18',
        title: 'HOD Attendance Alert',
        message: 'Attendance summary',
        category: 'Approvals',
        priority: 'high',
        targetRoles: ['hod'],
      );
      expect(resAAgain.decision, equals(NotificationDecision.suppressDuplicate));

      // HOD + Attendance Event B -> Dispatched
      final resB = await engine.dispatchAutomatedNotification(
        ruleId: 'rule_hod_dept_att_alert',
        recipientUserId: 'hodCSE',
        eventId: 'ATT_2026_08_19',
        title: 'HOD Attendance Alert',
        message: 'Attendance summary next day',
        category: 'Approvals',
        priority: 'high',
        targetRoles: ['hod'],
      );
      expect(resB.success, isTrue);
    });

    test('Full NotificationSchedulerService Run 1 vs Run 2 summary verification', () async {
      final rulesService = NotificationAutomationRulesService();

      // Run 1: Should dispatch notifications for eligible rules
      final summary1 = await rulesService.runAllAutomatedRuleChecks(
        customRules: [
          NotificationRuleModel(
            ruleId: 'rule_fee_due_parent',
            ruleName: 'Fee Payment Reminders',
            category: 'Finance',
            priority: 'high',
            targetRoles: ['parent', 'student'],
          ),
          NotificationRuleModel(
            ruleId: 'rule_registered_hackathon_due',
            ruleName: 'Hackathon Reminders',
            category: 'Events',
            priority: 'medium',
            targetRoles: ['student'],
          ),
        ],
      );

      expect(summary1.rulesChecked, equals(2));
      expect(summary1.eligibleRecipients, greaterThan(0));
      expect(summary1.notificationsCreated, greaterThan(0));
      expect(summary1.dispatchedCount, equals(summary1.notificationsCreated));
      expect(summary1.duplicatesSuppressed, equals(0));

      // Run 2: Exact same events -> All duplicates MUST be suppressed!
      final summary2 = await rulesService.runAllAutomatedRuleChecks(
        customRules: [
          NotificationRuleModel(
            ruleId: 'rule_fee_due_parent',
            ruleName: 'Fee Payment Reminders',
            category: 'Finance',
            priority: 'high',
            targetRoles: ['parent', 'student'],
          ),
          NotificationRuleModel(
            ruleId: 'rule_registered_hackathon_due',
            ruleName: 'Hackathon Reminders',
            category: 'Events',
            priority: 'medium',
            targetRoles: ['student'],
          ),
        ],
      );

      expect(summary2.rulesChecked, equals(2));
      expect(summary2.eligibleRecipients, equals(summary1.eligibleRecipients));
      expect(summary2.notificationsCreated, equals(0));
      expect(summary2.dispatchedCount, equals(0));
      expect(summary2.duplicatesSuppressed, equals(summary1.eligibleRecipients));
    });
  });
}
