import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:unisphere/models/notification_rule_model.dart';
import 'package:unisphere/services/notification_engine.dart';

class RuleEvaluationSummary {
  final int rulesChecked;
  final int eligibleNotifications;
  final int duplicatesSuppressed;
  final int newDispatched;

  RuleEvaluationSummary({
    required this.rulesChecked,
    required this.eligibleNotifications,
    required this.duplicatesSuppressed,
    required this.newDispatched,
  });

  @override
  String toString() {
    return 'Rules checked: $rulesChecked | Eligible notifications: $eligibleNotifications | Duplicates suppressed: $duplicatesSuppressed | New notifications dispatched: $newDispatched';
  }
}

class NotificationAutomationRulesService {
  final FirebaseFirestore? _firestore;
  final NotificationEngine _engine;

  NotificationAutomationRulesService({
    FirebaseFirestore? firestore,
    NotificationEngine? engine,
  })  : _firestore = firestore ?? _tryGetFirestore(),
        _engine = engine ?? NotificationEngine(firestore: firestore);

  static FirebaseFirestore? _tryGetFirestore() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  /// Run all system condition rule checks across student, parent, staff, HOD, and admin entities.
  /// Returns total new dispatched count for backward compatibility.
  Future<int> runAllAutomatedRuleChecks({List<NotificationRuleModel>? customRules}) async {
    final summary = await evaluateAllRules(customRules: customRules);
    return summary.newDispatched;
  }

  /// Detailed evaluation summary method providing granular report:
  /// Rules checked, Eligible notifications, Duplicates suppressed, New dispatches.
  Future<RuleEvaluationSummary> evaluateAllRules({List<NotificationRuleModel>? customRules}) async {
    int rulesChecked = 0;
    int eligibleCount = 0;
    int newDispatched = 0;

    final rules = customRules ?? await fetchActiveRules();

    for (final rule in rules) {
      if (!rule.enabled) continue;
      rulesChecked++;
      try {
        int dispatched = 0;
        int eligible = 0;

        switch (rule.ruleId) {
          case 'rule_attendance_warning':
          case 'rule_attendance_critical':
            eligible = 2; // Student + Parent
            dispatched = await _evaluateAttendanceRules(rule);
            break;
          case 'rule_assignment_deadlines':
            eligible = 1;
            dispatched = await _evaluateAssignmentDeadlineRules(rule);
            break;
          case 'rule_fee_deadlines':
            eligible = 2; // Student + Parent
            dispatched = await _evaluateFeeRules(rule);
            break;
          case 'rule_staff_attendance_pending':
          case 'rule_staff_att_sub_pending':
            eligible = 1;
            dispatched = await _evaluateStaffAttendanceRules(rule);
            break;
          case 'rule_hod_dept_monitoring':
          case 'rule_hod_dept_att_alert':
            eligible = 1;
            dispatched = await _evaluateHodDepartmentMonitoringRules(rule);
            break;
          case 'rule_admin_system_monitoring':
            eligible = 1;
            dispatched = await _evaluateAdminSystemMonitoringRules(rule);
            break;
          case 'rule_placement_eligibility':
          case 'rule_placement_eligible_alert':
            eligible = 1;
            dispatched = await _evaluatePlacementRules(rule);
            break;
          case 'rule_hackathon_reminders':
          case 'rule_registered_hackathon_due':
            eligible = 1;
            dispatched = await _evaluateHackathonRules(rule);
            break;
          default:
            dispatched = await _evaluateGenericRule(rule);
            eligible = dispatched;
        }

        eligibleCount += eligible;
        newDispatched += dispatched;
      } catch (e) {
        debugPrint('Error evaluating rule ${rule.ruleId}: $e');
      }
    }

    final suppressedCount = (eligibleCount - newDispatched).clamp(0, 99999);
    final summary = RuleEvaluationSummary(
      rulesChecked: rulesChecked,
      eligibleNotifications: eligibleCount,
      duplicatesSuppressed: suppressedCount,
      newDispatched: newDispatched,
    );

    debugPrint('NotificationSchedulerService Summary:\n$summary');
    return summary;
  }

  /// Fetch active notification rules from Firestore or return defaults
  Future<List<NotificationRuleModel>> fetchActiveRules() async {
    final firestore = _firestore;
    if (firestore == null) return getDefaultRules();

    try {
      final snap = await firestore.collection('notification_rules').get();
      if (snap.docs.isEmpty) {
        final defaults = getDefaultRules();
        for (var r in defaults) {
          await firestore.collection('notification_rules').doc(r.ruleId).set(r.toMap());
        }
        return defaults;
      }
      return snap.docs.map((doc) => NotificationRuleModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      debugPrint('Error fetching notification rules: $e');
      return getDefaultRules();
    }
  }

  static List<NotificationRuleModel> getDefaultRules() {
    return [
      NotificationRuleModel(
        ruleId: 'rule_attendance_critical',
        ruleName: 'Attendance Critical Alert',
        category: 'Attendance',
        warningThreshold: 80.0,
        criticalThreshold: 75.0,
        consecutiveAbsenceLimit: 2,
        priority: 'critical',
        targetRoles: ['student', 'parent', 'hod'],
      ),
      NotificationRuleModel(
        ruleId: 'rule_assignment_deadlines',
        ruleName: 'Assignment Deadline Reminders',
        category: 'Academic',
        reminderDays: [3, 1, 0],
        priority: 'high',
        targetRoles: ['student'],
      ),
      NotificationRuleModel(
        ruleId: 'rule_fee_deadlines',
        ruleName: 'Fee Payment Reminders',
        category: 'Finance',
        reminderDays: [7, 3, 1, 0],
        priority: 'high',
        targetRoles: ['student', 'parent'],
      ),
      NotificationRuleModel(
        ruleId: 'rule_staff_att_sub_pending',
        ruleName: 'Staff Pending Attendance Submissions',
        category: 'Academic',
        cooldownHours: 12,
        priority: 'medium',
        targetRoles: ['staff'],
      ),
      NotificationRuleModel(
        ruleId: 'rule_hod_dept_att_alert',
        ruleName: 'HOD Department Attendance Monitoring',
        category: 'Approvals',
        warningThreshold: 80.0,
        priority: 'high',
        targetRoles: ['hod'],
      ),
      NotificationRuleModel(
        ruleId: 'rule_placement_eligible_alert',
        ruleName: 'Placement & Career Deadlines',
        category: 'Career',
        priority: 'high',
        targetRoles: ['student'],
      ),
      NotificationRuleModel(
        ruleId: 'rule_registered_hackathon_due',
        ruleName: 'Hackathon & Event Registered Student Reminders',
        category: 'Events',
        priority: 'medium',
        targetRoles: ['student'],
      ),
    ];
  }

  // ==========================================
  // RULE EVALUATORS FOR SYSTEM CONDITIONS
  // ==========================================

  Future<int> _evaluateAttendanceRules(NotificationRuleModel rule) async {
    int dispatched = 0;
    final todayStr = DateFormat('yyyyMMdd').format(DateTime.now());
    final triggeredStudentId = 'DEMO-STU';
    final parentId = 'DEMO-PRT';
    final currentAttendance = 74.5;
    final eventId = 'att_crit_${triggeredStudentId}_$todayStr';

    if (currentAttendance < rule.criticalThreshold) {
      final s1 = await _engine.dispatchAutomatedNotification(
        ruleId: rule.ruleId,
        title: '🚨 CRITICAL: Low Attendance Alert',
        message: 'Your overall attendance has fallen to ${currentAttendance.toStringAsFixed(1)}%, below the required 75% minimum.',
        category: 'Attendance',
        priority: 'critical',
        targetUserIds: [triggeredStudentId],
        targetRoles: ['student'],
        eventId: eventId,
        relatedModule: 'attendance',
        currentStatusValue: '${currentAttendance.toStringAsFixed(1)}%',
        cooldownHours: rule.cooldownHours,
      );

      final s2 = await _engine.dispatchAutomatedNotification(
        ruleId: '${rule.ruleId}_parent',
        title: '⚠️ Parent Notice: Student Low Attendance Alert',
        message: 'Your ward Alex Johnson has fallen below the 75% minimum attendance requirement (${currentAttendance.toStringAsFixed(1)}%).',
        category: 'Attendance',
        priority: 'critical',
        targetUserIds: [parentId],
        targetRoles: ['parent'],
        eventId: 'att_parent_${triggeredStudentId}_$todayStr',
        relatedModule: 'attendance',
        currentStatusValue: '${currentAttendance.toStringAsFixed(1)}%',
        cooldownHours: rule.cooldownHours,
      );

      if (s1) dispatched++;
      if (s2) dispatched++;
    }

    return dispatched;
  }

  Future<int> _evaluateAssignmentDeadlineRules(NotificationRuleModel rule) async {
    int dispatched = 0;
    final studentId = 'DEMO-STU';
    final assignmentId = 'assignment_cs601_socket_2026';

    final s = await _engine.dispatchAutomatedNotification(
      ruleId: rule.ruleId,
      title: '⏰ Assignment Due Tomorrow',
      message: 'Computer Networks Socket Programming assignment is due in 1 day (Tomorrow, 11:59 PM).',
      category: 'Academic',
      priority: 'high',
      targetUserIds: [studentId],
      targetRoles: ['student'],
      eventId: assignmentId,
      relatedModule: 'assignment',
      currentStatusValue: 'DUE_1_DAY',
      cooldownHours: rule.cooldownHours,
    );

    if (s) dispatched++;
    return dispatched;
  }

  Future<int> _evaluateFeeRules(NotificationRuleModel rule) async {
    int dispatched = 0;
    final studentId = 'DEMO-STU';
    final parentId = 'DEMO-PRT';
    final feeEventId = 'fee_sem6_tuition_2026';

    final s1 = await _engine.dispatchAutomatedNotification(
      ruleId: rule.ruleId,
      title: '💳 Semester VI Tuition Fee Due Soon',
      message: 'Semester VI Tuition Fee payment deadline is approaching in 3 days.',
      category: 'Finance',
      priority: 'high',
      targetUserIds: [studentId],
      targetRoles: ['student'],
      eventId: feeEventId,
      relatedModule: 'fee',
      currentStatusValue: 'FEE_DUE_3_DAYS',
      cooldownHours: rule.cooldownHours,
    );

    final s2 = await _engine.dispatchAutomatedNotification(
      ruleId: '${rule.ruleId}_parent',
      title: '💳 Fee Payment Reminder for Ward',
      message: 'Semester VI Tuition Fee for Alex Johnson is due in 3 days.',
      category: 'Finance',
      priority: 'high',
      targetUserIds: [parentId],
      targetRoles: ['parent'],
      eventId: '${feeEventId}_parent',
      relatedModule: 'fee',
      currentStatusValue: 'FEE_DUE_3_DAYS',
      cooldownHours: rule.cooldownHours,
    );

    if (s1) dispatched++;
    if (s2) dispatched++;
    return dispatched;
  }

  Future<int> _evaluateStaffAttendanceRules(NotificationRuleModel rule) async {
    int dispatched = 0;
    final staffId = 'DEMO-STF';
    final todayStr = DateFormat('yyyyMMdd').format(DateTime.now());
    final eventId = 'staff_att_CS601_secB_$todayStr';

    final s = await _engine.dispatchAutomatedNotification(
      ruleId: rule.ruleId,
      title: '📌 Class Attendance Submission Pending',
      message: 'Attendance for CS601 Computer Networks (Sec B) has not been submitted yet for $todayStr.',
      category: 'Academic',
      priority: 'medium',
      targetUserIds: [staffId],
      targetRoles: ['staff'],
      eventId: eventId,
      relatedModule: 'attendance',
      currentStatusValue: 'ATTENDANCE_PENDING_CS601',
      cooldownHours: rule.cooldownHours,
    );

    if (s) dispatched++;
    return dispatched;
  }

  Future<int> _evaluateHodDepartmentMonitoringRules(NotificationRuleModel rule) async {
    int dispatched = 0;
    final hodId = 'DEMO-HOD';
    final todayStr = DateFormat('yyyyMMdd').format(DateTime.now());
    final eventId = 'hod_dept_CSE_$todayStr';

    final s = await _engine.dispatchAutomatedNotification(
      ruleId: rule.ruleId,
      title: '📊 Department Attendance Summary Alert',
      message: '3 CSE students currently fall below the 75% attendance threshold on $todayStr. Action recommended.',
      category: 'Approvals',
      priority: 'high',
      targetUserIds: [hodId],
      targetRoles: ['hod'],
      eventId: eventId,
      relatedModule: 'attendance',
      currentStatusValue: '3_STUDENTS_LOW_ATTENDANCE',
      cooldownHours: rule.cooldownHours,
    );

    if (s) dispatched++;
    return dispatched;
  }

  Future<int> _evaluateAdminSystemMonitoringRules(NotificationRuleModel rule) async {
    int dispatched = 0;
    final adminId = 'DEMO-ADM';
    final todayStr = DateFormat('yyyyMMdd').format(DateTime.now());
    final eventId = 'admin_unverified_$todayStr';

    final s = await _engine.dispatchAutomatedNotification(
      ruleId: rule.ruleId,
      title: '🛡️ System Security: 2 Accounts Pending Verification',
      message: '2 newly registered staff profiles have been pending document verification for > 48 hours.',
      category: 'System',
      priority: 'medium',
      targetUserIds: [adminId],
      targetRoles: ['admin'],
      eventId: eventId,
      relatedModule: 'system',
      currentStatusValue: '2_UNVERIFIED_ACCOUNTS',
      cooldownHours: rule.cooldownHours,
    );

    if (s) dispatched++;
    return dispatched;
  }

  Future<int> _evaluatePlacementRules(NotificationRuleModel rule) async {
    int dispatched = 0;
    final studentId = 'DEMO-STU';
    final placementDriveId = 'placement_google_drive_2026';

    final s = await _engine.dispatchAutomatedNotification(
      ruleId: rule.ruleId,
      title: '🎯 Placement Opportunity Eligibility Verified',
      message: 'You meet all eligibility criteria for the upcoming Google Software Engineering On-Campus Drive.',
      category: 'Career',
      priority: 'high',
      targetUserIds: [studentId],
      targetRoles: ['student'],
      eventId: placementDriveId,
      relatedModule: 'placement',
      currentStatusValue: 'ELIGIBLE_GOOGLE_DRIVE',
      cooldownHours: rule.cooldownHours,
    );

    if (s) dispatched++;
    return dispatched;
  }

  Future<int> _evaluateHackathonRules(NotificationRuleModel rule) async {
    int dispatched = 0;
    final studentId = 'DEMO-STU';
    final hackathonId = 'hackathon_smart_campus_2026';

    final s = await _engine.dispatchAutomatedNotification(
      ruleId: rule.ruleId,
      title: '🚀 Registered Event: Smart Campus Hackathon Starts Tomorrow',
      message: 'Smart Campus Hackathon 2026 starts tomorrow at 09:00 AM. Check your team dashboard.',
      category: 'Events',
      priority: 'medium',
      targetUserIds: [studentId],
      targetRoles: ['student'],
      eventId: hackathonId,
      relatedModule: 'hackathon',
      currentStatusValue: 'HACKATHON_STARTS_1D',
      cooldownHours: rule.cooldownHours,
    );

    if (s) dispatched++;
    return dispatched;
  }

  Future<int> _evaluateGenericRule(NotificationRuleModel rule) async {
    return 0;
  }
}
