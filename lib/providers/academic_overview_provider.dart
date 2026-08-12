import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/services/leetcode_service.dart';

/// Data model representing the student's academic overview metrics.
class AcademicOverviewData {
  final double attendancePercentage;
  final double attendanceTrend;
  final String attendanceStatus;
  final double cgpa;
  final double cgpaTrend;
  final String cgpaLabel;
  final int odDays;
  final String odStatus;
  final int leetcodeSolved;
  final String leetcodeStatus;
  final String leetcodeUsername;

  const AcademicOverviewData({
    required this.attendancePercentage,
    required this.attendanceTrend,
    required this.attendanceStatus,
    required this.cgpa,
    required this.cgpaTrend,
    required this.cgpaLabel,
    this.odDays = 4,
    this.odStatus = 'Approved',
    this.leetcodeSolved = 130,
    this.leetcodeStatus = '130 Solved',
    this.leetcodeUsername = 'saravanapmv',
  });
}

/// Notifier to manage state updates for the student's academic overview.
class AcademicOverviewNotifier extends StateNotifier<AcademicOverviewData> {
  AcademicOverviewNotifier()
      : super(
          const AcademicOverviewData(
            attendancePercentage: 85.0,
            attendanceTrend: 5.0,
            attendanceStatus: 'Good',
            cgpa: 8.72,
            cgpaTrend: 0.24,
            cgpaLabel: 'Current CGPA',
            odDays: 4,
            odStatus: 'Approved',
            leetcodeSolved: 130,
            leetcodeStatus: '130 Solved',
            leetcodeUsername: 'saravanapmv',
          ),
        ) {
    // Automatically fetch student LeetCode count on startup
    fetchLeetCodeStats(state.leetcodeUsername);
  }

  /// Automatically updates LeetCode solved count from public LeetCode API
  Future<void> fetchLeetCodeStats(String username) async {
    final stats = await LeetCodeService.fetchUserStats(username);
    state = AcademicOverviewData(
      attendancePercentage: state.attendancePercentage,
      attendanceTrend: state.attendanceTrend,
      attendanceStatus: state.attendanceStatus,
      cgpa: state.cgpa,
      cgpaTrend: state.cgpaTrend,
      cgpaLabel: state.cgpaLabel,
      odDays: state.odDays,
      odStatus: state.odStatus,
      leetcodeSolved: stats.totalSolved,
      leetcodeStatus: stats.status,
      leetcodeUsername: username,
    );
  }

  void updateData({
    double? attendancePercentage,
    double? attendanceTrend,
    String? attendanceStatus,
    double? cgpa,
    double? cgpaTrend,
    String? cgpaLabel,
    int? odDays,
    String? odStatus,
    int? leetcodeSolved,
    String? leetcodeStatus,
    String? leetcodeUsername,
  }) {
    state = AcademicOverviewData(
      attendancePercentage: attendancePercentage ?? state.attendancePercentage,
      attendanceTrend: attendanceTrend ?? state.attendanceTrend,
      attendanceStatus: attendanceStatus ?? state.attendanceStatus,
      cgpa: cgpa ?? state.cgpa,
      cgpaTrend: cgpaTrend ?? state.cgpaTrend,
      cgpaLabel: cgpaLabel ?? state.cgpaLabel,
      odDays: odDays ?? state.odDays,
      odStatus: odStatus ?? state.odStatus,
      leetcodeSolved: leetcodeSolved ?? state.leetcodeSolved,
      leetcodeStatus: leetcodeStatus ?? state.leetcodeStatus,
      leetcodeUsername: leetcodeUsername ?? state.leetcodeUsername,
    );
  }
}

/// Riverpod provider for student academic overview metrics.
final academicOverviewProvider =
    StateNotifierProvider<AcademicOverviewNotifier, AcademicOverviewData>(
  (ref) => AcademicOverviewNotifier(),
);
