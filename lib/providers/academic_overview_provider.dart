import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  const AcademicOverviewData({
    required this.attendancePercentage,
    required this.attendanceTrend,
    required this.attendanceStatus,
    required this.cgpa,
    required this.cgpaTrend,
    required this.cgpaLabel,
    this.odDays = 4,
    this.odStatus = 'Approved',
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
          ),
        );

  void updateData({
    double? attendancePercentage,
    double? attendanceTrend,
    String? attendanceStatus,
    double? cgpa,
    double? cgpaTrend,
    String? cgpaLabel,
    int? odDays,
    String? odStatus,
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
    );
  }
}

/// Riverpod provider for student academic overview metrics.
final academicOverviewProvider =
    StateNotifierProvider<AcademicOverviewNotifier, AcademicOverviewData>(
  (ref) => AcademicOverviewNotifier(),
);
