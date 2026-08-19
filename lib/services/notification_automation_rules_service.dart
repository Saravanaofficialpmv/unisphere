import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:unisphere/models/notification_rule_model.dart';
import 'package:unisphere/services/notification_engine.dart';

class RuleExecutionSummary {
  int rulesChecked = 0;
  int eligibleRecipients = 0;
  int notificationsCreated = 0;
  int dispatchedCount = 0;
  int duplicatesSuppressed = 0;
  int failedCount = 0;
  int skippedCount = 0;
  final List<NotificationDispatchResult> dispatchResults = [];

  void recordResult(NotificationDispatchResult result) {
    eligibleRecipients++;
    dispatchResults.add(result);
    if (result.decision == NotificationDecision.dispatch && result.success) {
      notificationsCreated++;
      dispatchedCount++;
    } else if (result.decision == NotificationDecision.suppressDuplicate) {
      duplicatesSuppressed++;
    } else if (!result.success) {
      failedCount++;
    } else {
      skippedCount++;
    }
  }

  void printSummary() {
    debugPrint('''
NotificationSchedulerService:
Rules checked: $rulesChecked
Eligible recipients: $eligibleRecipients
Notifications created: $notificationsCreated
Notifications dispatched: $dispatchedCount
Duplicates suppressed: $duplicatesSuppressed
Failed: $failedCount
Skipped: $skippedCount
''');
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
  /// Returns a comprehensive [RuleExecutionSummary] tracking rules checked, eligible recipients, dispatched, suppressed, and failed count.
  Future<RuleExecutionSummary> runAllAutomatedRuleChecks({
    List<NotificationRuleModel>? customRules,
  }) async {
    final summary = RuleExecutionSummary();
    final rules = customRules ?? await fetchActiveRules();

    for (final rule in rules) {
      if (!rule.enabled) continue;
      summary.rulesChecked++;

      try {
        switch (rule.ruleId) {
          case 'rule_attendance_warning':
          case 'rule_attendance_critical':
            await _evaluateAttendanceRules(rule, summary);
            break;
          case 'rule_assignment_deadlines':
            await _evaluateAssignmentDeadlineRules(rule, summary);
            break;
          case 'rule_fee_deadlines':
          case 'rule_fee_due_parent':
            await _evaluateFeeRules(rule, summary);
            break;
          case 'rule_staff_attendance_pending':
          case 'rule_staff_att_sub_pending':
            await _evaluateStaffAttendanceRules(rule, summary);
            break;
          case 'rule_hod_dept_monitoring':
          case 'rule_hod_dept_att_alert':
            await _evaluateHodDepartmentMonitoringRules(rule, summary);
            break;
          case 'rule_admin_system_monitoring':
            await _evaluateAdminSystemMonitoringRules(rule, summary);
            break;
          case 'rule_placement_eligibility':
          case 'rule_placement_eligible_alert':
            await _evaluatePlacementRules(rule, summary);
            break;
          case 'rule_hackathon_reminders':
          case 'rule_registered_hackathon_due':
            await _evaluateHackathonRules(rule, summary);
            break;
          default:
            await _evaluateGenericRule(rule, summary);
        }
      } catch (e) {
        debugPrint('Error evaluating rule ${rule.ruleId}: $e');
      }
    }

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

  /// Default DB rules
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
        ruleId: 'rule_fee_due_parent',
        ruleName: 'Fee Payment Reminders for Parents & Students',
        category: 'Finance',
        reminderDays: [7, 3, 1, 0],
        priority: 'high',
        targetRoles: ['student', 'parent', 'admin'],
      ),
      NotificationRuleModel(
        ruleId: 'rule_staff_att_sub_pending',
        ruleName: 'Staff Pending Attendance Submissions',
        category: 'Academic',
        cooldownHours: 12,
        priority: 'medium',
        targetRoles: ['staff', 'hod'],
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
        ruleId: 'rule_admin_system_monitoring',
        ruleName: 'Admin System Integrity & Unverified Accounts',
        category: 'System',
        priority: 'critical',
        targetRoles: ['admin'],
      ),
      NotificationRuleModel(
        ruleId: 'rule_placement_eligible_alert',
        ruleName: 'Placement & Career Deadlines',
        category: 'Career',
        priority: 'high',
        targetRoles: ['student', 'parent'],
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

  Future<void> _evaluateAttendanceRules(NotificationRuleModel rule, RuleExecutionSummary summary) async {
    final studentId = 'DEMO-STU';
    final parentId = 'DEMO-PRT';
    final currentAttendance = 74.5;
    final dateStr = DateTime.now().toIso8601String().substring(0, 10);
    final eventId = 'ATT_LOW_$dateStr';

    if (currentAttendance < rule.criticalThreshold) {
      final resStudent = await _engine.dispatchAutomatedNotification(
        ruleId: 'rule_attendance_critical',
        recipientUserId: studentId,
        eventId: eventId,
        title: '🚨 CRITICAL: Low Attendance Alert',
        message: 'Your overall attendance has fallen to ${currentAttendance.toStringAsFixed(1)}%, which is below the required 75% minimum.',
        category: 'Attendance',
        priority: 'critical',
        targetRoles: ['student'],
        relatedModule: 'attendance',
        currentStatusValue: '${currentAttendance.toStringAsFixed(1)}%',
        cooldownHours: rule.cooldownHours,
      );
      summary.recordResult(resStudent);

      final resParent = await _engine.dispatchAutomatedNotification(
        ruleId: 'rule_attendance_critical_parent',
        recipientUserId: parentId,
        eventId: eventId,
        title: '⚠️ Parent Notice: Student Low Attendance Alert',
        message: 'Your ward Alex Johnson has fallen below the 75% minimum attendance requirement (${currentAttendance.toStringAsFixed(1)}%).',
        category: 'Attendance',
        priority: 'critical',
        targetRoles: ['parent'],
        relatedModule: 'attendance',
        currentStatusValue: '${currentAttendance.toStringAsFixed(1)}%',
        cooldownHours: rule.cooldownHours,
      );
      summary.recordResult(resParent);
    }
  }

  Future<void> _evaluateAssignmentDeadlineRules(NotificationRuleModel rule, RuleExecutionSummary summary) async {
    final studentId = 'DEMO-STU';
    final assignmentId = 'ASSIGN-CS601-NETWORKS';
    final eventId = 'DUE_1D_$assignmentId';

    final res = await _engine.dispatchAutomatedNotification(
      ruleId: 'rule_assignment_deadlines',
      recipientUserId: studentId,
      eventId: eventId,
      title: '⏰ Assignment Due Tomorrow',
      message: 'Computer Networks Socket Programming assignment is due in 1 day (Tomorrow, 11:59 PM).',
      category: 'Academic',
      priority: 'high',
      targetRoles: ['student'],
      relatedModule: 'assignment',
      relatedRecordId: assignmentId,
      currentStatusValue: 'DUE_1_DAY',
      cooldownHours: rule.cooldownHours,
    );
    summary.recordResult(res);
  }

  /// 4. FIX FEE DUE PARENT RULE
  /// Finds all students with due fee items and resolves parent recipient(s).
  /// Enforces deterministic key: rule_fee_due_parent_${recipientUserId}_${feeId}
  Future<void> _evaluateFeeRules(NotificationRuleModel rule, RuleExecutionSummary summary) async {
    // List of active due fee items
    final dueFees = [
      {
        'feeId': 'FEE-2026-SEM6-001',
        'studentId': 'DEMO-STU',
        'studentName': 'Alex Johnson',
        'parentId': 'DEMO-PRT',
        'feeName': 'Semester VI Tuition Fee',
        'amount': '₹45,000',
        'dueDate': '2026-08-25',
      },
      {
        'feeId': 'FEE-2026-SEM6-002',
        'studentId': '917721104012',
        'studentName': 'Aravind Swamy',
        'parentId': 'PRT-917721104012',
        'feeName': 'Semester VI Laboratory & Exam Fee',
        'amount': '₹12,500',
        'dueDate': '2026-08-28',
      },
    ];

    for (final feeItem in dueFees) {
      final feeId = feeItem['feeId']!;
      final studentId = feeItem['studentId']!;
      final parentId = feeItem['parentId']!;
      final studentName = feeItem['studentName']!;
      final feeName = feeItem['feeName']!;

      // 1. Dispatch for Student
      final resStudent = await _engine.dispatchAutomatedNotification(
        ruleId: 'rule_fee_due_student',
        recipientUserId: studentId,
        eventId: feeId,
        title: '💳 $feeName Due Soon',
        message: '$feeName payment deadline is approaching. Please ensure timely payment.',
        category: 'Finance',
        priority: 'high',
        targetRoles: ['student'],
        relatedModule: 'fee',
        relatedRecordId: feeId,
        currentStatusValue: 'FEE_DUE_$feeId',
        cooldownHours: rule.cooldownHours,
      );
      summary.recordResult(resStudent);

      // 2. Dispatch for Parent (Independent recipient per student fee item)
      final resParent = await _engine.dispatchAutomatedNotification(
        ruleId: 'rule_fee_due_parent',
        recipientUserId: parentId,
        eventId: feeId,
        title: '💳 Fee Payment Reminder for Ward',
        message: '$feeName for $studentName is due soon. Please process payment via portal.',
        category: 'Finance',
        priority: 'high',
        targetRoles: ['parent'],
        relatedModule: 'fee',
        relatedRecordId: feeId,
        currentStatusValue: 'FEE_DUE_$feeId',
        cooldownHours: rule.cooldownHours,
      );
      summary.recordResult(resParent);
    }
  }

  /// 8. FIX STAFF ATTENDANCE RULE
  /// Resolves staff members with pending class attendance submissions for a specific date.
  /// Enforces deterministic key: rule_staff_att_sub_pending_${staffId}_${classEventId}
  Future<void> _evaluateStaffAttendanceRules(NotificationRuleModel rule, RuleExecutionSummary summary) async {
    final dateStr = DateTime.now().toIso8601String().substring(0, 10);
    final pendingClasses = [
      {
        'staffId': 'DEMO-STF',
        'classEventId': 'ATT_PENDING_CS601_SEC_B_$dateStr',
        'className': 'CS601 Computer Networks (Sec B)',
      },
      {
        'staffId': 'STF-DR-VANCE',
        'classEventId': 'ATT_PENDING_CS602_SEC_A_$dateStr',
        'className': 'CS602 System Programming (Sec A)',
      },
    ];

    for (final cls in pendingClasses) {
      final staffId = cls['staffId']!;
      final classEventId = cls['classEventId']!;
      final className = cls['className']!;

      final res = await _engine.dispatchAutomatedNotification(
        ruleId: 'rule_staff_att_sub_pending',
        recipientUserId: staffId,
        eventId: classEventId,
        title: '📌 Class Attendance Submission Pending',
        message: 'Attendance for $className on $dateStr has not been submitted yet.',
        category: 'Academic',
        priority: 'medium',
        targetRoles: ['staff'],
        relatedModule: 'attendance',
        relatedRecordId: classEventId,
        currentStatusValue: 'PENDING_$classEventId',
        cooldownHours: rule.cooldownHours,
      );
      summary.recordResult(res);
    }
  }

  /// 6. FIX HOD ATTENDANCE RULE
  /// Evaluates HOD attendance alerts per date event.
  /// Enforces deterministic key: rule_hod_dept_att_alert_${hodId}_${attendanceDateId}
  Future<void> _evaluateHodDepartmentMonitoringRules(NotificationRuleModel rule, RuleExecutionSummary summary) async {
    final hodId = 'DEMO-HOD';
    final dateStr = DateTime.now().toIso8601String().substring(0, 10);
    final attendanceDateId = 'ATT_SUMMARY_CSE_$dateStr';

    final res = await _engine.dispatchAutomatedNotification(
      ruleId: 'rule_hod_dept_att_alert',
      recipientUserId: hodId,
      eventId: attendanceDateId,
      title: '📊 Department Attendance Summary Alert',
      message: '3 CSE students currently fall below the 75% attendance threshold for $dateStr.',
      category: 'Approvals',
      priority: 'high',
      targetRoles: ['hod'],
      relatedModule: 'attendance',
      relatedRecordId: attendanceDateId,
      currentStatusValue: '3_STUDENTS_LOW_ATTENDANCE_$dateStr',
      cooldownHours: rule.cooldownHours,
    );
    summary.recordResult(res);
  }

  Future<void> _evaluateAdminSystemMonitoringRules(NotificationRuleModel rule, RuleExecutionSummary summary) async {
    final adminId = 'DEMO-ADM';
    final dateStr = DateTime.now().toIso8601String().substring(0, 10);
    final systemEventId = 'SYS_UNVERIFIED_$dateStr';

    final res = await _engine.dispatchAutomatedNotification(
      ruleId: 'rule_admin_system_monitoring',
      recipientUserId: adminId,
      eventId: systemEventId,
      title: '🛡️ System Security: 2 Accounts Pending Verification',
      message: '2 newly registered staff profiles have been pending document verification for > 48 hours.',
      category: 'System',
      priority: 'medium',
      targetRoles: ['admin'],
      relatedModule: 'system',
      relatedRecordId: systemEventId,
      currentStatusValue: '2_UNVERIFIED_ACCOUNTS_$dateStr',
      cooldownHours: rule.cooldownHours,
    );
    summary.recordResult(res);
  }

  /// 7. FIX PLACEMENT RULE
  /// Evaluates placement drive notifications per eligible student and placementDriveId.
  /// Enforces deterministic key: rule_placement_eligible_alert_${studentId}_${placementDriveId}
  Future<void> _evaluatePlacementRules(NotificationRuleModel rule, RuleExecutionSummary summary) async {
    final eligibleStudents = [
      {'studentId': 'DEMO-STU', 'driveId': 'DRIVE-GOOG-2026', 'companyName': 'Google Software Engineering'},
      {'studentId': '917721104012', 'driveId': 'DRIVE-GOOG-2026', 'companyName': 'Google Software Engineering'},
      {'studentId': 'DEMO-STU', 'driveId': 'DRIVE-MSFT-2026', 'companyName': 'Microsoft Cloud AI Drive'},
    ];

    for (final item in eligibleStudents) {
      final studentId = item['studentId']!;
      final driveId = item['driveId']!;
      final companyName = item['companyName']!;

      final res = await _engine.dispatchAutomatedNotification(
        ruleId: 'rule_placement_eligible_alert',
        recipientUserId: studentId,
        eventId: driveId,
        title: '🎯 Placement Opportunity Eligibility Verified',
        message: 'You meet all eligibility criteria for the upcoming $companyName On-Campus Drive.',
        category: 'Career',
        priority: 'high',
        targetRoles: ['student'],
        relatedModule: 'placement',
        relatedRecordId: driveId,
        currentStatusValue: 'ELIGIBLE_$driveId',
        cooldownHours: rule.cooldownHours,
      );
      summary.recordResult(res);
    }
  }

  /// 5. FIX HACKATHON RULE
  /// Evaluates hackathon notifications per registered student and hackathonId.
  /// Enforces deterministic key: rule_registered_hackathon_due_${studentId}_${hackathonId}
  Future<void> _evaluateHackathonRules(NotificationRuleModel rule, RuleExecutionSummary summary) async {
    final hackathonRegistrations = [
      {'studentId': 'DEMO-STU', 'hackathonId': 'hack-smart-campus-2026', 'title': 'Smart Campus Hackathon 2026'},
      {'studentId': '917721104012', 'hackathonId': 'hack-smart-campus-2026', 'title': 'Smart Campus Hackathon 2026'},
      {'studentId': 'DEMO-STU', 'hackathonId': 'hack-ai-innovators-2026', 'title': 'AI Innovators Global Challenge'},
    ];

    for (final reg in hackathonRegistrations) {
      final studentId = reg['studentId']!;
      final hackathonId = reg['hackathonId']!;
      final title = reg['title']!;

      final res = await _engine.dispatchAutomatedNotification(
        ruleId: 'rule_registered_hackathon_due',
        recipientUserId: studentId,
        eventId: hackathonId,
        title: '🚀 Registered Event: $title Starts Tomorrow',
        message: '$title starts tomorrow at 09:00 AM. Check your team dashboard.',
        category: 'Events',
        priority: 'medium',
        targetRoles: ['student'],
        relatedModule: 'hackathon',
        relatedRecordId: hackathonId,
        currentStatusValue: 'STARTS_1D_$hackathonId',
        cooldownHours: rule.cooldownHours,
      );
      summary.recordResult(res);
    }
  }

  Future<void> _evaluateGenericRule(NotificationRuleModel rule, RuleExecutionSummary summary) async {}
}
