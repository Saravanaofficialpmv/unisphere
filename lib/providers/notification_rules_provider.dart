import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/models/notification_rule_model.dart';
import 'package:unisphere/repositories/notification_repository.dart';
import 'package:unisphere/services/notification_automation_rules_service.dart';

class NotificationRulesState {
  final List<NotificationRuleModel> rules;
  final bool isLoading;
  final String? errorMessage;

  NotificationRulesState({
    required this.rules,
    this.isLoading = false,
    this.errorMessage,
  });

  NotificationRulesState copyWith({
    List<NotificationRuleModel>? rules,
    bool? isLoading,
    String? errorMessage,
  }) {
    return NotificationRulesState(
      rules: rules ?? this.rules,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class NotificationRulesNotifier extends StateNotifier<NotificationRulesState> {
  final NotificationRepository _repository;
  final NotificationAutomationRulesService _rulesService;

  NotificationRulesNotifier(this._repository, this._rulesService)
      : super(NotificationRulesState(rules: NotificationAutomationRulesService.getDefaultRules())) {
    loadRules();
  }

  Future<void> loadRules() async {
    state = state.copyWith(isLoading: true);
    try {
      final activeRules = await _rulesService.fetchActiveRules();
      state = state.copyWith(rules: activeRules, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }

  Future<void> toggleRule(String ruleId, bool enabled) async {
    final updated = state.rules.map((r) {
      if (r.ruleId == ruleId) {
        return r.copyWith(enabled: enabled);
      }
      return r;
    }).toList();

    state = state.copyWith(rules: updated);
    final targetRule = updated.firstWhere((r) => r.ruleId == ruleId);
    await _repository.saveNotificationRule(targetRule);
  }

  Future<void> updateRule(NotificationRuleModel updatedRule) async {
    final updated = state.rules.map((r) {
      if (r.ruleId == updatedRule.ruleId) {
        return updatedRule;
      }
      return r;
    }).toList();

    state = state.copyWith(rules: updated);
    await _repository.saveNotificationRule(updatedRule);
  }

  Future<int> triggerManualRuleCheck() async {
    state = state.copyWith(isLoading: true);
    final count = await _rulesService.runAllAutomatedRuleChecks(customRules: state.rules);
    state = state.copyWith(isLoading: false);
    return count;
  }
}

final notificationRulesProvider =
    StateNotifierProvider<NotificationRulesNotifier, NotificationRulesState>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  final rulesService = NotificationAutomationRulesService();
  return NotificationRulesNotifier(repo, rulesService);
});
