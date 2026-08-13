import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Configuration for a semester set by Head of Department (HOD)
class SemesterWorkingDaysConfig {
  final int semesterNumber;
  final String semesterName;
  final int totalWorkingDays;
  final double minimumRequiredPercentage; // e.g. 75.0%

  const SemesterWorkingDaysConfig({
    required this.semesterNumber,
    required this.semesterName,
    required this.totalWorkingDays,
    this.minimumRequiredPercentage = 75.0,
  });

  SemesterWorkingDaysConfig copyWith({
    int? totalWorkingDays,
    double? minimumRequiredPercentage,
  }) {
    return SemesterWorkingDaysConfig(
      semesterNumber: semesterNumber,
      semesterName: semesterName,
      totalWorkingDays: totalWorkingDays ?? this.totalWorkingDays,
      minimumRequiredPercentage: minimumRequiredPercentage ?? this.minimumRequiredPercentage,
    );
  }
}

/// Student's attendance record for a specific semester
class StudentSemesterAttendanceData {
  final int semesterNumber;
  final String semesterName;
  final int attendedWorkingDays;
  final int totalWorkingDays; // Configured by HOD
  final double monthlyTrendPercentage; // e.g. 5.0%
  final bool isCurrentSemester;
  final List<Map<String, dynamic>> subjectBreakdown;

  const StudentSemesterAttendanceData({
    required this.semesterNumber,
    required this.semesterName,
    required this.attendedWorkingDays,
    required this.totalWorkingDays,
    this.monthlyTrendPercentage = 5.0,
    this.isCurrentSemester = false,
    this.subjectBreakdown = const [],
  });

  /// Calculate semester-wise attendance percentage based on HOD working days
  double get attendancePercentage {
    if (totalWorkingDays <= 0) return 0.0;
    final pct = (attendedWorkingDays / totalWorkingDays) * 100.0;
    return pct > 100.0 ? 100.0 : pct;
  }

  /// Status badge label: Good, Safe Margin, Critical
  String get statusLabel {
    final pct = attendancePercentage;
    if (pct >= 85.0) return 'Good';
    if (pct >= 75.0) return 'Safe Margin';
    return 'Critical';
  }

  /// Safe margin days description
  String get safeMarginText {
    final pct = attendancePercentage;
    if (pct >= 85.0) return 'Safe Margin: Can skip up to 4 days';
    if (pct >= 75.0) return 'Warning: Attend next 3 classes!';
    return 'Shortage Alert: Below 75% requirement';
  }

  StudentSemesterAttendanceData copyWith({
    int? attendedWorkingDays,
    int? totalWorkingDays,
    double? monthlyTrendPercentage,
    bool? isCurrentSemester,
    List<Map<String, dynamic>>? subjectBreakdown,
  }) {
    return StudentSemesterAttendanceData(
      semesterNumber: semesterNumber,
      semesterName: semesterName,
      attendedWorkingDays: attendedWorkingDays ?? this.attendedWorkingDays,
      totalWorkingDays: totalWorkingDays ?? this.totalWorkingDays,
      monthlyTrendPercentage: monthlyTrendPercentage ?? this.monthlyTrendPercentage,
      isCurrentSemester: isCurrentSemester ?? this.isCurrentSemester,
      subjectBreakdown: subjectBreakdown ?? this.subjectBreakdown,
    );
  }
}

/// Main state combining HOD semester configs and student semester attendance
class SemesterAttendanceState {
  final Map<int, SemesterWorkingDaysConfig> hodSemesterConfigs;
  final List<StudentSemesterAttendanceData> studentSemesters;
  final int selectedSemesterIndex;

  const SemesterAttendanceState({
    required this.hodSemesterConfigs,
    required this.studentSemesters,
    this.selectedSemesterIndex = 3, // Default Sem 4 (Active)
  });

  StudentSemesterAttendanceData get selectedSemesterData {
    if (selectedSemesterIndex >= 0 && selectedSemesterIndex < studentSemesters.length) {
      return studentSemesters[selectedSemesterIndex];
    }
    return studentSemesters.last;
  }

  StudentSemesterAttendanceData get activeSemesterData {
    return studentSemesters.firstWhere(
      (s) => s.isCurrentSemester,
      orElse: () => studentSemesters.last,
    );
  }

  SemesterAttendanceState copyWith({
    Map<int, SemesterWorkingDaysConfig>? hodSemesterConfigs,
    List<StudentSemesterAttendanceData>? studentSemesters,
    int? selectedSemesterIndex,
  }) {
    return SemesterAttendanceState(
      hodSemesterConfigs: hodSemesterConfigs ?? this.hodSemesterConfigs,
      studentSemesters: studentSemesters ?? this.studentSemesters,
      selectedSemesterIndex: selectedSemesterIndex ?? this.selectedSemesterIndex,
    );
  }
}

class SemesterAttendanceNotifier extends StateNotifier<SemesterAttendanceState> {
  SemesterAttendanceNotifier()
      : super(
          SemesterAttendanceState(
            hodSemesterConfigs: {
              1: const SemesterWorkingDaysConfig(semesterNumber: 1, semesterName: 'Semester 1', totalWorkingDays: 90),
              2: const SemesterWorkingDaysConfig(semesterNumber: 2, semesterName: 'Semester 2', totalWorkingDays: 90),
              3: const SemesterWorkingDaysConfig(semesterNumber: 3, semesterName: 'Semester 3', totalWorkingDays: 95),
              4: const SemesterWorkingDaysConfig(semesterNumber: 4, semesterName: 'Semester 4', totalWorkingDays: 90),
              5: const SemesterWorkingDaysConfig(semesterNumber: 5, semesterName: 'Semester 5', totalWorkingDays: 90),
              6: const SemesterWorkingDaysConfig(semesterNumber: 6, semesterName: 'Semester 6', totalWorkingDays: 90),
              7: const SemesterWorkingDaysConfig(semesterNumber: 7, semesterName: 'Semester 7', totalWorkingDays: 85),
              8: const SemesterWorkingDaysConfig(semesterNumber: 8, semesterName: 'Semester 8', totalWorkingDays: 80),
            },
            studentSemesters: [
              const StudentSemesterAttendanceData(
                semesterNumber: 1,
                semesterName: 'Semester 1',
                attendedWorkingDays: 79,
                totalWorkingDays: 90,
                monthlyTrendPercentage: 3.2,
                isCurrentSemester: false,
                subjectBreakdown: [
                  {
                    'code': 'GE101',
                    'subject': 'Basic Electrical Engineering',
                    'attended': 43,
                    'total': 50,
                    'percentage': 0.860,
                    'faculty': 'Dr. K. Sharma',
                    'status': 'Completed',
                    'safeMargin': 'Good Standing',
                    'colorValue': 0xFF2563EB,
                    'credits': 4,
                  },
                  {
                    'code': 'GE102',
                    'subject': 'Engineering Graphics',
                    'attended': 45,
                    'total': 50,
                    'percentage': 0.900,
                    'faculty': 'Prof. V. Raman',
                    'status': 'Completed',
                    'safeMargin': 'Good Standing',
                    'colorValue': 0xFF059669,
                    'credits': 3,
                  },
                  {
                    'code': 'GE103',
                    'subject': 'Engineering Chemistry',
                    'attended': 44,
                    'total': 50,
                    'percentage': 0.880,
                    'faculty': 'Dr. S. Priya',
                    'status': 'Completed',
                    'safeMargin': 'Good Standing',
                    'colorValue': 0xFF7C3AED,
                    'credits': 4,
                  },
                  {
                    'code': 'MA101',
                    'subject': 'Matrices & Calculus',
                    'attended': 44,
                    'total': 50,
                    'percentage': 0.880,
                    'faculty': 'Prof. R. Menon',
                    'status': 'Completed',
                    'safeMargin': 'Good Standing',
                    'colorValue': 0xFFD97706,
                    'credits': 4,
                  },
                ],
              ),
              const StudentSemesterAttendanceData(
                semesterNumber: 2,
                semesterName: 'Semester 2',
                attendedWorkingDays: 82,
                totalWorkingDays: 90,
                monthlyTrendPercentage: 4.5,
                isCurrentSemester: false,
                subjectBreakdown: [
                  {
                    'code': 'CS101',
                    'subject': 'Python Programming',
                    'attended': 47,
                    'total': 50,
                    'percentage': 0.940,
                    'faculty': 'Dr. M. Tech',
                    'status': 'Completed',
                    'safeMargin': 'Distinction Standing',
                    'colorValue': 0xFF059669,
                    'credits': 4,
                  },
                  {
                    'code': 'CS102',
                    'subject': 'Engineering Physics',
                    'attended': 45,
                    'total': 50,
                    'percentage': 0.900,
                    'faculty': 'Dr. H. Verma',
                    'status': 'Completed',
                    'safeMargin': 'Good Standing',
                    'colorValue': 0xFF2563EB,
                    'credits': 3,
                  },
                  {
                    'code': 'MA102',
                    'subject': 'Differential Equations',
                    'attended': 44,
                    'total': 50,
                    'percentage': 0.880,
                    'faculty': 'Prof. R. Menon',
                    'status': 'Completed',
                    'safeMargin': 'Good Standing',
                    'colorValue': 0xFF7C3AED,
                    'credits': 4,
                  },
                  {
                    'code': 'CS103',
                    'subject': 'Digital Electronics',
                    'attended': 46,
                    'total': 50,
                    'percentage': 0.920,
                    'faculty': 'Prof. A. Joseph',
                    'status': 'Completed',
                    'safeMargin': 'Good Standing',
                    'colorValue': 0xFFDC2626,
                    'credits': 3,
                  },
                ],
              ),
              const StudentSemesterAttendanceData(
                semesterNumber: 3,
                semesterName: 'Semester 3',
                attendedWorkingDays: 85,
                totalWorkingDays: 95,
                monthlyTrendPercentage: 2.8,
                isCurrentSemester: false,
                subjectBreakdown: [
                  {
                    'code': 'CS201',
                    'subject': 'Data Structures & Algorithms',
                    'attended': 46,
                    'total': 50,
                    'percentage': 0.920,
                    'faculty': 'Dr. Dennis Ritchie',
                    'status': 'Completed',
                    'safeMargin': 'Good Standing',
                    'colorValue': 0xFF2563EB,
                    'credits': 4,
                  },
                  {
                    'code': 'CS202',
                    'subject': 'Object Oriented Java',
                    'attended': 44,
                    'total': 50,
                    'percentage': 0.880,
                    'faculty': 'Prof. James Gosling',
                    'status': 'Completed',
                    'safeMargin': 'Good Standing',
                    'colorValue': 0xFF059669,
                    'credits': 4,
                  },
                  {
                    'code': 'CS203',
                    'subject': 'Discrete Mathematics',
                    'attended': 43,
                    'total': 50,
                    'percentage': 0.860,
                    'faculty': 'Dr. Donald Knuth',
                    'status': 'Completed',
                    'safeMargin': 'Good Standing',
                    'colorValue': 0xFFD97706,
                    'credits': 3,
                  },
                  {
                    'code': 'CS204',
                    'subject': 'Computer Architecture',
                    'attended': 45,
                    'total': 50,
                    'percentage': 0.900,
                    'faculty': 'Dr. Hennessy',
                    'status': 'Completed',
                    'safeMargin': 'Good Standing',
                    'colorValue': 0xFF7C3AED,
                    'credits': 4,
                  },
                ],
              ),
              const StudentSemesterAttendanceData(
                semesterNumber: 4,
                semesterName: 'Semester 4',
                attendedWorkingDays: 77,
                totalWorkingDays: 90,
                monthlyTrendPercentage: 5.0,
                isCurrentSemester: true,
                subjectBreakdown: [
                  {
                    'code': 'CS301',
                    'subject': 'Computer Networks',
                    'attended': 38,
                    'total': 42,
                    'percentage': 0.905,
                    'faculty': 'Dr. Robert Vance',
                    'status': 'Good Standing',
                    'safeMargin': 'Safe: Can skip 4 classes',
                    'colorValue': 0xFF2563EB,
                    'credits': 4,
                  },
                  {
                    'code': 'CS302',
                    'subject': 'Database Systems',
                    'attended': 35,
                    'total': 40,
                    'percentage': 0.875,
                    'faculty': 'Prof. Sarah Jenkins',
                    'status': 'Good Standing',
                    'safeMargin': 'Safe: Can skip 3 classes',
                    'colorValue': 0xFF059669,
                    'credits': 4,
                  },
                  {
                    'code': 'CS303',
                    'subject': 'Web Technology',
                    'attended': 29,
                    'total': 38,
                    'percentage': 0.763,
                    'faculty': 'Dr. Alan Turing',
                    'status': 'Attention Needed (<80%)',
                    'safeMargin': 'Warning: Attend next 2 classes!',
                    'colorValue': 0xFFD97706,
                    'credits': 3,
                  },
                  {
                    'code': 'CS304',
                    'subject': 'Software Engineering',
                    'attended': 36,
                    'total': 40,
                    'percentage': 0.900,
                    'faculty': 'Prof. Michael Scott',
                    'status': 'Good Standing',
                    'safeMargin': 'Safe: Can skip 4 classes',
                    'colorValue': 0xFF7C3AED,
                    'credits': 3,
                  },
                  {
                    'code': 'CS305',
                    'subject': 'AI & Machine Learning',
                    'attended': 31,
                    'total': 35,
                    'percentage': 0.885,
                    'faculty': 'Dr. Grace Hopper',
                    'status': 'Good Standing',
                    'safeMargin': 'Safe: Can skip 3 classes',
                    'colorValue': 0xFFDC2626,
                    'credits': 4,
                  },
                ],
              ),
            ],
            selectedSemesterIndex: 3,
          ),
        );

  /// HOD updates total working days for a specific semester
  void updateSemesterWorkingDaysByHod(int semesterNumber, int newWorkingDays) {
    if (newWorkingDays <= 0) return;

    final updatedConfigs = Map<int, SemesterWorkingDaysConfig>.from(state.hodSemesterConfigs);
    if (updatedConfigs.containsKey(semesterNumber)) {
      updatedConfigs[semesterNumber] = updatedConfigs[semesterNumber]!.copyWith(totalWorkingDays: newWorkingDays);
    } else {
      updatedConfigs[semesterNumber] = SemesterWorkingDaysConfig(
        semesterNumber: semesterNumber,
        semesterName: 'Semester $semesterNumber',
        totalWorkingDays: newWorkingDays,
      );
    }

    final updatedStudentSemesters = state.studentSemesters.map((s) {
      if (s.semesterNumber == semesterNumber) {
        return s.copyWith(totalWorkingDays: newWorkingDays);
      }
      return s;
    }).toList();

    state = state.copyWith(
      hodSemesterConfigs: updatedConfigs,
      studentSemesters: updatedStudentSemesters,
    );
  }

  /// Change active selected semester tab/view
  void selectSemesterIndex(int index) {
    if (index >= 0 && index < state.studentSemesters.length) {
      state = state.copyWith(selectedSemesterIndex: index);
    }
  }

  /// Update student attended days
  void updateStudentAttendedDays(int semesterNumber, int newAttendedDays) {
    final updatedSemesters = state.studentSemesters.map((s) {
      if (s.semesterNumber == semesterNumber) {
        return s.copyWith(attendedWorkingDays: newAttendedDays);
      }
      return s;
    }).toList();

    state = state.copyWith(studentSemesters: updatedSemesters);
  }
}

final semesterAttendanceProvider =
    StateNotifierProvider<SemesterAttendanceNotifier, SemesterAttendanceState>(
  (ref) => SemesterAttendanceNotifier(),
);
