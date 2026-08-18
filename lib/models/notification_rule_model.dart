class NotificationRuleModel {
  final String ruleId;
  final String ruleName;
  final String category;
  final bool enabled;
  final double warningThreshold; // e.g. 80.0
  final double criticalThreshold; // e.g. 75.0
  final int consecutiveAbsenceLimit; // e.g. 2
  final List<int> reminderDays; // e.g. [3, 1, 0]
  final int cooldownHours; // e.g. 24
  final String priority; // 'critical', 'high', 'medium', 'low'
  final List<String> enabledChannels; // ['in_app', 'push', 'email']
  final List<String> targetRoles; // ['student', 'parent', 'staff', 'hod', 'admin']
  final bool quietHoursEnabled;
  final String quietHoursStart; // "22:00"
  final String quietHoursEnd; // "07:00"

  NotificationRuleModel({
    required this.ruleId,
    required this.ruleName,
    required this.category,
    this.enabled = true,
    this.warningThreshold = 80.0,
    this.criticalThreshold = 75.0,
    this.consecutiveAbsenceLimit = 2,
    this.reminderDays = const [3, 1, 0],
    this.cooldownHours = 24,
    this.priority = 'high',
    this.enabledChannels = const ['in_app', 'push'],
    this.targetRoles = const ['student', 'parent'],
    this.quietHoursEnabled = false,
    this.quietHoursStart = '22:00',
    this.quietHoursEnd = '07:00',
  });

  factory NotificationRuleModel.fromMap(Map<String, dynamic> map, String docId) {
    return NotificationRuleModel(
      ruleId: docId,
      ruleName: map['rule_name'] ?? 'Automation Rule',
      category: map['category'] ?? 'Attendance',
      enabled: (map['enabled'] ?? true) as bool,
      warningThreshold: (map['warning_threshold'] as num?)?.toDouble() ?? 80.0,
      criticalThreshold: (map['critical_threshold'] as num?)?.toDouble() ?? 75.0,
      consecutiveAbsenceLimit: (map['consecutive_absence_limit'] as num?)?.toInt() ?? 2,
      reminderDays: List<int>.from(map['reminder_days'] ?? [3, 1, 0]),
      cooldownHours: (map['cooldown_hours'] as num?)?.toInt() ?? 24,
      priority: map['priority'] ?? 'high',
      enabledChannels: List<String>.from(map['enabled_channels'] ?? ['in_app', 'push']),
      targetRoles: List<String>.from(map['target_roles'] ?? ['student', 'parent']),
      quietHoursEnabled: (map['quiet_hours_enabled'] ?? false) as bool,
      quietHoursStart: map['quiet_hours_start'] ?? '22:00',
      quietHoursEnd: map['quiet_hours_end'] ?? '07:00',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rule_id': ruleId,
      'rule_name': ruleName,
      'category': category,
      'enabled': enabled,
      'warning_threshold': warningThreshold,
      'critical_threshold': criticalThreshold,
      'consecutive_absence_limit': consecutiveAbsenceLimit,
      'reminder_days': reminderDays,
      'cooldown_hours': cooldownHours,
      'priority': priority,
      'enabled_channels': enabledChannels,
      'target_roles': targetRoles,
      'quiet_hours_enabled': quietHoursEnabled,
      'quiet_hours_start': quietHoursStart,
      'quiet_hours_end': quietHoursEnd,
    };
  }

  NotificationRuleModel copyWith({
    bool? enabled,
    double? warningThreshold,
    double? criticalThreshold,
    int? consecutiveAbsenceLimit,
    List<int>? reminderDays,
    int? cooldownHours,
    String? priority,
    List<String>? enabledChannels,
    List<String>? targetRoles,
    bool? quietHoursEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
  }) {
    return NotificationRuleModel(
      ruleId: ruleId,
      ruleName: ruleName,
      category: category,
      enabled: enabled ?? this.enabled,
      warningThreshold: warningThreshold ?? this.warningThreshold,
      criticalThreshold: criticalThreshold ?? this.criticalThreshold,
      consecutiveAbsenceLimit: consecutiveAbsenceLimit ?? this.consecutiveAbsenceLimit,
      reminderDays: reminderDays ?? this.reminderDays,
      cooldownHours: cooldownHours ?? this.cooldownHours,
      priority: priority ?? this.priority,
      enabledChannels: enabledChannels ?? this.enabledChannels,
      targetRoles: targetRoles ?? this.targetRoles,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }
}
