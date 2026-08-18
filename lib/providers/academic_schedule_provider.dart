import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/models/academic_schedule_model.dart';
import 'package:unisphere/services/academic_schedule_service.dart';
import 'package:unisphere/services/auth_service.dart';

/// Provider fetching the latest active schedule scoped to the logged-in student or staff user
final userAcademicScheduleProvider = StreamProvider<AcademicScheduleModel?>((ref) {
  final scheduleService = ref.watch(academicScheduleServiceProvider);
  final user = ref.watch(authServiceProvider).currentUser;

  final studentYear = user?.metadata?['year']?.toString() ?? 'I Year';
  final departmentId = user?.metadata?['department']?.toString() ?? 'all';
  final academicYear = user?.metadata?['academicYear']?.toString() ?? '2026-27';

  return scheduleService.watchLatestScheduleForScope(
    academicYear: academicYear,
    studentYear: studentYear,
    departmentId: departmentId,
  );
});

/// Provider fetching all schedules for HOD dashboard
final departmentAcademicSchedulesProvider = StreamProvider.family<List<AcademicScheduleModel>, String>((ref, departmentId) {
  final scheduleService = ref.watch(academicScheduleServiceProvider);
  return scheduleService.watchDepartmentSchedules(departmentId: departmentId);
});

/// Provider fetching version history for a specific scope
final scheduleVersionHistoryProvider = StreamProvider.family<List<AcademicScheduleModel>, ({String targetYear, String academicYear})>((ref, args) {
  final scheduleService = ref.watch(academicScheduleServiceProvider);
  return scheduleService.watchVersionHistory(
    targetStudentYear: args.targetYear,
    academicYear: args.academicYear,
  );
});
