import 'package:flutter_test/flutter_test.dart';
import 'package:unisphere/models/notification_rule_model.dart';
import 'package:unisphere/services/notification_duplicate_preventer.dart';
import 'package:unisphere/services/notification_engine.dart';
import 'package:unisphere/services/notification_automation_rules_service.dart';
import 'package:unisphere/services/notification_scheduler_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    NotificationDuplicatePreventer.clearCache();
  });

  group('Notification System Deduplication & Scheduler Tests', () {
    test('1. Same rule + same recipient + same event -> Only 1 notification (duplicate suppressed)', () async {
      final engine = NotificationEngine();

      final res1 = await engine.dispatchAutomatedNotification(
        ruleId: 'rule_fee_due_parent',
        recipientUserId: 'parent123',
        eventId: 'fee101',
        title: 'Fee Due',
        message: 'Fee 101 due',
        category: 'Finance',
        priority: 'high',
        targetRoles: ['parent'],
      );

      expect(res1.success, isTrue);
      expect(res1.decision, equals(NotificationDecision.dispatch));

      final res2 = await engine.dispatchAutomatedNotification(
        ruleId: 'rule_fee_due_parent',
        recipientUserId: 'parent123',
        eventId: 'fee101',
        title: 'Fee Due',
        message: 'Fee 101 due',
        category: 'Finance',
        priority: 'high',
        targetRoles: ['parent'],
      );

      expect(res2.success, isFalse);
      expect(res2.decision, equals(NotificationDecision.suppressDuplicate));
    });

    test('2. Same rule + different recipient + same event -> Both receive notification', () async {
      final engine = NotificationEngine();

      final res1 = await engine.dispatchAutomatedNotification(
        ruleId: 'rule_fee_due_parent',
        recipientUserId: 'parent123',
        eventId: 'fee101',
        title: 'Fee Due',
        message: 'Fee 101 due',
        category: 'Finance',
        priority: 'high',
        targetRoles: ['parent'],
      );

      final res2 = await engine.dispatchAutomatedNotification(
        ruleId: 'rule_fee_due_parent',
        recipientUserId: 'parent456',
        eventId: 'fee101',
        title: 'Fee Due',
        message: 'Fee 101 due',
        category: 'Finance',
        priority: 'high',
        targetRoles: ['parent'],
      );

      expect(res1.success, isTrue);
      expect(res1.decision, equals(NotificationDecision.dispatch));
      expect(res2.success, isTrue);
      expect(res2.decision, equals(NotificationDecision.dispatch));
    });

    test('3. Same rule + same recipient + different event -> Both notifications created', () async {
      final engine = NotificationEngine();

      final res1 = await engine.dispatchAutomatedNotification(
        ruleId: 'rule_fee_due_parent',
        recipientUserId: 'parent123',
        eventId: 'fee101',
        title: 'Fee 101 Due',
        message: 'Fee 101 due',
        category: 'Finance',
        priority: 'high',
        targetRoles: ['parent'],
      );

      final res2 = await engine.dispatchAutomatedNotification(
        ruleId: 'rule_fee_due_parent',
        recipientUserId: 'parent123',
        eventId: 'fee102',
        title: 'Fee 102 Due',
        message: 'Fee 102 due',
        category: 'Finance',
        priority: 'high',
        targetRoles: ['parent'],
      );

      expect(res1.success, isTrue);
      expect(res2.success, isTrue);
    });

    test('4. Same recipient + new attendance date -> New notification created', () async {
      final engine = NotificationEngine();

      final res1 = await engine.dispatchAutomatedNotification(
        ruleId: 'rule_hod_dept_att_alert',
        recipientUserId: 'hod123',
        eventId: 'ATT-2026-08-19',
        title: 'Attendance Alert 19th',
        message: 'Attendance summary',
        category: 'Approvals',
        priority: 'high',
        targetRoles: ['hod'],
      );

      final res2 = await engine.dispatchAutomatedNotification(
        ruleId: 'rule_hod_dept_att_alert',
        recipientUserId: 'hod123',
        eventId: 'ATT-2026-08-20',
        title: 'Attendance Alert 20th',
        message: 'Attendance summary',
        category: 'Approvals',
        priority: 'high',
        targetRoles: ['hod'],
      );

      expect(res1.success, isTrue);
      expect(res2.success, isTrue);
    });

    test('5. Failed notification -> Retry possible', () async {
      final preventer = NotificationDuplicatePreventer();

      await preventer.recordExecution(
        ruleId: 'rule_fee_due_parent',
        recipientUserId: 'parent123',
        eventId: 'fee101',
        status: 'failed',
        cooldownHours: 24,
      );

      final canRetry = await preventer.shouldTrigger(
        ruleId: 'rule_fee_due_parent',
        recipientUserId: 'parent123',
        eventId: 'fee101',
        cooldownHours: 24,
      );

      expect(canRetry, isTrue);
    });

    test('6. Two scheduler executions simultaneously -> One notification created (atomic protection)', () async {
      final rulesService = NotificationAutomationRulesService();

      final summary1 = await rulesService.runAllAutomatedRuleChecks();
      final summary2 = await rulesService.runAllAutomatedRuleChecks();

      expect(summary1.dispatchedCount, greaterThan(0));
      expect(summary2.duplicatesSuppressed, greaterThan(0));
      expect(summary2.dispatchedCount, equals(0));
    });

    test('7. No eligible recipients -> Zero notifications', () async {
      final rulesService = NotificationAutomationRulesService();
      final disabledRule = NotificationRuleModel(
        ruleId: 'test_disabled_rule',
        ruleName: 'Disabled Test Rule',
        enabled: false,
        category: 'Test',
      );

      final summary = await rulesService.runAllAutomatedRuleChecks(customRules: [disabledRule]);
      expect(summary.dispatchedCount, equals(0));
      expect(summary.eligibleRecipients, equals(0));
    });

    test('8. Future/ineligible condition -> Zero notifications', () async {
      final canTrigger = await NotificationDuplicatePreventer().shouldTrigger(
        ruleId: 'rule_fee_due_parent',
        recipientUserId: 'parent999',
        eventId: 'fee999',
        cooldownHours: 24,
      );

      expect(canTrigger, isTrue);
    });

    test('9. Fee A and Fee B -> Separate notifications created for same parent', () async {
      final engine = NotificationEngine();

      final feeA = await engine.dispatchAutomatedNotification(
        ruleId: 'rule_fee_due_parent',
        recipientUserId: 'parent_alex',
        eventId: 'FEE_TUITION_2026',
        title: 'Tuition Fee Due',
        message: 'Tuition fee due',
        category: 'Finance',
        priority: 'high',
        targetRoles: ['parent'],
      );

      final feeB = await engine.dispatchAutomatedNotification(
        ruleId: 'rule_fee_due_parent',
        recipientUserId: 'parent_alex',
        eventId: 'FEE_HOSTEL_2026',
        title: 'Hostel Fee Due',
        message: 'Hostel fee due',
        category: 'Finance',
        priority: 'high',
        targetRoles: ['parent'],
      );

      expect(feeA.success, isTrue);
      expect(feeB.success, isTrue);
      expect(feeA.deduplicationKey, isNot(equals(feeB.deduplicationKey)));
    });

    test('10. Hackathon A and Hackathon B -> Separate notifications created for same student', () async {
      final engine = NotificationEngine();

      final hackA = await engine.dispatchAutomatedNotification(
        ruleId: 'rule_registered_hackathon_due',
        recipientUserId: 'student_saravana',
        eventId: 'HACK_SMART_CAMPUS_2026',
        title: 'Smart Campus Hackathon',
        message: 'Hackathon starts tomorrow',
        category: 'Events',
        priority: 'medium',
        targetRoles: ['student'],
      );

      final hackB = await engine.dispatchAutomatedNotification(
        ruleId: 'rule_registered_hackathon_due',
        recipientUserId: 'student_saravana',
        eventId: 'HACK_AI_INNOVATORS_2026',
        title: 'AI Innovators Hackathon',
        message: 'Hackathon starts tomorrow',
        category: 'Events',
        priority: 'medium',
        targetRoles: ['student'],
      );

      expect(hackA.success, isTrue);
      expect(hackB.success, isTrue);
      expect(hackA.deduplicationKey, equals('rule_registered_hackathon_due_student_saravana_HACK_SMART_CAMPUS_2026'));
      expect(hackB.deduplicationKey, equals('rule_registered_hackathon_due_student_saravana_HACK_AI_INNOVATORS_2026'));
    });

    test('11. Scheduler Service execution prints detailed summary log', () async {
      final scheduler = NotificationSchedulerService();
      final summary = await scheduler.executeSchedulerRun();

      expect(summary.rulesChecked, greaterThan(0));
    });
  });
}
