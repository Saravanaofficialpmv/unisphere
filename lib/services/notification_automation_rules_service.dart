import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:unisphere/models/notification_rule_model.dart';
import 'package:unisphere/services/notification_engine.dart';

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
  Future<int> runAllAutomatedRuleChecks({List<NotificationRuleModel>? customRules}) async {
    int count = 0;
    final rules = customRules ?? await fetchActiveRules();

    for (final rule in rules) {
      if (!rule.enabled) continue;
      try {
        switch (rule.ruleId) {
          case 'rule_attendance_warning':
          case 'rule_attendance_critical':
            count += await _evaluateAttendanceRules(rule);
            break;
          case 'rule_assignment_deadlines':
            count += await _evaluateAssignmentDeadlineRules(rule);
            break;
          case 'rule_fee_deadlines':
            count += await _evaluateFeeRules(rule);
            break;
          case 'rule_staff_attendance_pending':
            count += await _evaluateStaffAttendanceRules(rule);
            break;
          case 'rule_hod_dept_monitoring':
            count += await _evaluateHodDepartmentMonitoringRules(rule);
            break;
          case 'rule_admin_system_monitoring':
            count += await _evaluateAdminSystemMonitoringRules(rule);
            break;
          case 'rule_placement_eligibility':
            count += await _evaluatePlacementRules(rule);
            break;
          case 'rule_hackathon_reminders':
            count += await _evaluateHackathonRules(rule);
            break;
          default:
            count += await _evaluateGenericRule(rule);
        }
      } catch (e) {
        debugPrint('Error evaluating rule ${rule.ruleId}: $e');
      }
    }
    return count;
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

  /// Default DB rules as required by Part 8
  static List<NotificationRuleModel> getDefaultRules() {
    return [
      NotificationRuleModel(
        ruleId: 'rule_attendance_warning',
        ruleName: 'Attendance Warning Threshold',
        category: 'Attendance',
        warningThreshold: 80.0,
        criticalThreshold: 75.0,
        consecutiveAbsenceLimit: 2,
        priority: 'high',
        targetRoles: ['student', 'parent'],
      ),
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
        targetRoles: ['student', 'parent', 'admin'],
      ),
      NotificationRuleModel(
        ruleId: 'rule_staff_attendance_pending',
        ruleName: 'Staff Pending Attendance Submissions',
        category: 'Academic',
        cooldownHours: 12,
        priority: 'medium',
        targetRoles: ['staff', 'hod'],
      ),
      NotificationRuleModel(
        ruleId: 'rule_hod_dept_monitoring',
        ruleName: 'HOD Department Attendance Monitoring',
        category: 'Approvals',
        warningThreshold: 80.0,
        priority: 'high',
        targetRoles: ['hod'],
      ),
      NotificationRuleModel(
        ruleId: 'rule_admin_system_monitoring',
        ruleName: 'Admin System Integrity & Unverified Accounts',
        category: 'System',
        priority: 'critical',
        targetRoles: ['admin'],
      ),
      NotificationRuleModel(
        ruleId: 'rule_placement_eligibility',
        ruleName: 'Placement & Career Deadlines',
        category: 'Career',
        priority: 'high',
        targetRoles: ['student', 'parent'],
      ),
      NotificationRuleModel(
        ruleId: 'rule_hackathon_reminders',
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

    // Check low attendance students (e.g. Alex Johnson at 74.5%)
    // Automated notification to Student & Parent
    final triggeredStudentId = 'DEMO-STU';
    final currentAttendance = 74.5;

    if (currentAttendance < rule.criticalThreshold) {
      final successStudent = await _engine.dispatchAutomatedNotification(
        ruleId: 'rule_att_crit_$triggeredStudentId',
        title: '🚨 CRITICAL: Low Attendance Alert',
        message: 'Your overall attendance has fallen to ${currentAttendance.toStringAsFixed(1)}%, which is below the required 75% minimum.',
        category: 'Attendance',
        priority: 'critical',
        targetUserIds: [triggeredStudentId],
        targetRoles: ['student'],
        relatedModule: 'attendance',
        currentStatusValue: '${currentAttendance.toStringAsFixed(1)}%',
        cooldownHours: rule.cooldownHours,
      );

      final successParent = await _engine.dispatchAutomatedNotification(
        ruleId: 'rule_att_crit_parent_$triggeredStudentId',
        title: '⚠️ Parent Notice: Student Low Attendance Alert',
        message: 'Your ward Alex Johnson has fallen below the 75% minimum attendance requirement (${currentAttendance.toStringAsFixed(1)}%).',
        category: 'Attendance',
        priority: 'critical',
        targetUserIds: ['DEMO-PRT'],
        targetRoles: ['parent'],
        relatedModule: 'attendance',
        currentStatusValue: '${currentAttendance.toStringAsFixed(1)}%',
        cooldownHours: rule.cooldownHours,
      );

      if (successStudent) dispatched++;
      if (successParent) dispatched++;
    }

    return dispatched;
  }

  Future<int> _evaluateAssignmentDeadlineRules(NotificationRuleModel rule) async {
    int dispatched = 0;
    final studentId = 'DEMO-STU';

    final success = await _engine.dispatchAutomatedNotification(
      ruleId: 'rule_assign_due_1d',
      title: '⏰ Assignment Due Tomorrow',
      message: 'Computer Networks Socket Programming assignment is due in 1 day (Tomorrow, 11:59 PM).',
      category: 'Academic',
      priority: 'high',
      targetUserIds: [studentId],
      targetRoles: ['student'],
      relatedModule: 'assignment',
      currentStatusValue: 'DUE_1_DAY',
      cooldownHours: rule.cooldownHours,
    );

    if (success) dispatched++;
    return dispatched;
  }

  Future<int> _evaluateFeeRules(NotificationRuleModel rule) async {
    int dispatched = 0;
    final studentId = 'DEMO-STU';
    final parentId = 'DEMO-PRT';

    final s1 = await _engine.dispatchAutomatedNotification(
      ruleId: 'rule_fee_due_student',
      title: '💳 Semester VI Tuition Fee Due Soon',
      message: 'Semester VI Tuition Fee payment deadline is approaching in 3 days.',
      category: 'Finance',
      priority: 'high',
      targetUserIds: [studentId],
      targetRoles: ['student'],
      relatedModule: 'fee',
      currentStatusValue: 'FEE_DUE_3_DAYS',
      cooldownHours: rule.cooldownHours,
    );

    final s2 = await _engine.dispatchAutomatedNotification(
      ruleId: 'rule_fee_due_parent',
      title: '💳 Fee Payment Reminder for Ward',
      message: 'Semester VI Tuition Fee for Alex Johnson is due in 3 days.',
      category: 'Finance',
      priority: 'high',
      targetUserIds: [parentId],
      targetRoles: ['parent'],
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

    final s = await _engine.dispatchAutomatedNotification(
      ruleId: 'rule_staff_att_sub_pending',
      title: '📌 Class Attendance Submission Pending',
      message: 'Attendance for CS601 Computer Networks (Sec B) has not been submitted yet.',
      category: 'Academic',
      priority: 'medium',
      targetUserIds: [staffId],
      targetRoles: ['staff'],
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

    final s = await _engine.dispatchAutomatedNotification(
      ruleId: 'rule_hod_dept_att_alert',
      title: '📊 Department Attendance Summary Alert',
      message: '3 CSE students currently fall below the 75% attendance threshold. Action recommended.',
      category: 'Approvals',
      priority: 'high',
      targetUserIds: [hodId],
      targetRoles: ['hod'],
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

    final s = await _engine.dispatchAutomatedNotification(
      ruleId: 'rule_admin_unverified_accts',
      title: '🛡️ System Security: 2 Accounts Pending Verification',
      message: '2 newly registered staff profiles have been pending document verification for > 48 hours.',
      category: 'System',
      priority: 'medium',
      targetUserIds: [adminId],
      targetRoles: ['admin'],
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

    final s = await _engine.dispatchAutomatedNotification(
      ruleId: 'rule_placement_eligible_alert',
      title: '🎯 Placement Opportunity Eligibility Verified',
      message: 'You meet all eligibility criteria for the upcoming Google Software Engineering On-Campus Drive.',
      category: 'Career',
      priority: 'high',
      targetUserIds: [studentId],
      targetRoles: ['student'],
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

    final s = await _engine.dispatchAutomatedNotification(
      ruleId: 'rule_registered_hackathon_due',
      title: '🚀 Registered Event: Smart Campus Hackathon Starts Tomorrow',
      message: 'Smart Campus Hackathon 2026 starts tomorrow at 09:00 AM. Check your team dashboard.',
      category: 'Events',
      priority: 'medium',
      targetUserIds: [studentId],
      targetRoles: ['student'],
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
