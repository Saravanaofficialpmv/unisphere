import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/models/attendance_model.dart';
import 'package:unisphere/models/user_model.dart';
import 'package:unisphere/services/auth_service.dart';
import 'package:unisphere/services/firebase_firestore_service.dart';

/// Combined State for the rebuilt Attendance System
class AttendanceSystemState {
  final Map<int, HodSemesterConfig> hodSemesterConfigs;
  final List<SemesterAttendance> studentSemesters;
  final int selectedSemesterIndex;
  final List<AttendanceRecord> attendanceLogs;
  final List<DailyAttendanceLog> dailyLogs;
  final List<LeaveRequestModel> leaveRequests;

  const AttendanceSystemState({
    required this.hodSemesterConfigs,
    required this.studentSemesters,
    this.selectedSemesterIndex = 3, // Default Sem 4 (Active)
    required this.attendanceLogs,
    required this.dailyLogs,
    required this.leaveRequests,
  });

  SemesterAttendance get selectedSemester {
    if (selectedSemesterIndex >= 0 && selectedSemesterIndex < studentSemesters.length) {
      return studentSemesters[selectedSemesterIndex];
    }
    return studentSemesters.last;
  }

  SemesterAttendance get activeSemester {
    return studentSemesters.firstWhere(
      (s) => s.isCurrentSemester,
      orElse: () => studentSemesters.last,
    );
  }

  AttendanceSystemState copyWith({
    Map<int, HodSemesterConfig>? hodSemesterConfigs,
    List<SemesterAttendance>? studentSemesters,
    int? selectedSemesterIndex,
    List<AttendanceRecord>? attendanceLogs,
    List<DailyAttendanceLog>? dailyLogs,
    List<LeaveRequestModel>? leaveRequests,
  }) {
    return AttendanceSystemState(
      hodSemesterConfigs: hodSemesterConfigs ?? this.hodSemesterConfigs,
      studentSemesters: studentSemesters ?? this.studentSemesters,
      selectedSemesterIndex: selectedSemesterIndex ?? this.selectedSemesterIndex,
      attendanceLogs: attendanceLogs ?? this.attendanceLogs,
      dailyLogs: dailyLogs ?? this.dailyLogs,
      leaveRequests: leaveRequests ?? this.leaveRequests,
    );
  }
}

class AttendanceSystemNotifier extends StateNotifier<AttendanceSystemState> {
  AttendanceSystemNotifier({UserModel? user}) : super(_buildInitialState(user));

  static AttendanceSystemState _buildInitialState(UserModel? user) {
    final email = user?.email.toLowerCase().trim() ?? '';
    final isDemo = email == 'saravanapmvofficial@gmail.com' || (user != null && user.uid == 'DEMO-STU');
    final meta = user?.metadata ?? {};

    final double? dbAtt = double.tryParse(meta['attendance']?.toString() ?? '');
    final double targetAtt = dbAtt ?? (isDemo ? 85.0 : 0.0);
    final int sem4Attended = ((targetAtt / 100.0) * 90).round();

    return AttendanceSystemState(
      hodSemesterConfigs: {
        1: const HodSemesterConfig(semesterNumber: 1, semesterName: 'Semester 1 (1st Year)', totalWorkingDays: 90),
        2: const HodSemesterConfig(semesterNumber: 2, semesterName: 'Semester 2 (1st Year)', totalWorkingDays: 90),
        3: const HodSemesterConfig(semesterNumber: 3, semesterName: 'Semester 3 (2nd Year)', totalWorkingDays: 95),
        4: const HodSemesterConfig(semesterNumber: 4, semesterName: 'Semester 4 (2nd Year)', totalWorkingDays: 90),
        5: const HodSemesterConfig(semesterNumber: 5, semesterName: 'Semester 5 (3rd Year)', totalWorkingDays: 90),
        6: const HodSemesterConfig(semesterNumber: 6, semesterName: 'Semester 6 (3rd Year)', totalWorkingDays: 90),
        7: const HodSemesterConfig(semesterNumber: 7, semesterName: 'Semester 7 (4th Year)', totalWorkingDays: 90),
        8: const HodSemesterConfig(semesterNumber: 8, semesterName: 'Semester 8 (4th Year)', totalWorkingDays: 90),
      },
      studentSemesters: [
        SemesterAttendance(
          semesterNumber: 1,
          semesterName: 'Semester 1',
          attendedWorkingDays: isDemo ? 79 : 0,
          totalWorkingDays: 90,
          isCurrentSemester: false,
          subjects: isDemo ? [
            SubjectAttendance(code: 'GE101', name: 'Basic Electrical Engineering', facultyName: 'Dr. K. Sharma', credits: 4, attendedSessions: 43, totalSessions: 50, colorValue: 0xFF2563EB),
            SubjectAttendance(code: 'GE102', name: 'Engineering Graphics', facultyName: 'Prof. V. Raman', credits: 3, attendedSessions: 45, totalSessions: 50, colorValue: 0xFF059669),
            SubjectAttendance(code: 'GE103', name: 'Engineering Chemistry', facultyName: 'Dr. S. Priya', credits: 4, attendedSessions: 44, totalSessions: 50, colorValue: 0xFF7C3AED),
            SubjectAttendance(code: 'MA101', name: 'Matrices & Calculus', facultyName: 'Prof. R. Menon', credits: 4, attendedSessions: 44, totalSessions: 50, colorValue: 0xFFD97706),
          ] : [],
        ),
        SemesterAttendance(
          semesterNumber: 2,
          semesterName: 'Semester 2',
          attendedWorkingDays: isDemo ? 82 : 0,
          totalWorkingDays: 90,
          isCurrentSemester: false,
          subjects: isDemo ? [
            SubjectAttendance(code: 'CS101', name: 'Python Programming', facultyName: 'Dr. M. Tech', credits: 4, attendedSessions: 47, totalSessions: 50, colorValue: 0xFF059669),
            SubjectAttendance(code: 'CS102', name: 'Engineering Physics', facultyName: 'Dr. H. Verma', credits: 3, attendedSessions: 45, totalSessions: 50, colorValue: 0xFF2563EB),
            SubjectAttendance(code: 'MA102', name: 'Differential Equations', facultyName: 'Prof. R. Menon', credits: 4, attendedSessions: 44, totalSessions: 50, colorValue: 0xFF7C3AED),
            SubjectAttendance(code: 'CS103', name: 'Digital Electronics', facultyName: 'Prof. A. Joseph', credits: 3, attendedSessions: 46, totalSessions: 50, colorValue: 0xFFDC2626),
          ] : [],
        ),
        SemesterAttendance(
          semesterNumber: 3,
          semesterName: 'Semester 3',
          attendedWorkingDays: isDemo ? 85 : 0,
          totalWorkingDays: 95,
          isCurrentSemester: false,
          subjects: isDemo ? [
            SubjectAttendance(code: 'CS201', name: 'Data Structures & Algorithms', facultyName: 'Dr. Dennis Ritchie', credits: 4, attendedSessions: 46, totalSessions: 50, colorValue: 0xFF2563EB),
            SubjectAttendance(code: 'CS202', name: 'Object Oriented Java', facultyName: 'Prof. James Gosling', credits: 4, attendedSessions: 44, totalSessions: 50, colorValue: 0xFF059669),
            SubjectAttendance(code: 'CS203', name: 'Discrete Mathematics', facultyName: 'Dr. Donald Knuth', credits: 3, attendedSessions: 43, totalSessions: 50, colorValue: 0xFFD97706),
            SubjectAttendance(code: 'CS204', name: 'Computer Architecture', facultyName: 'Dr. Hennessy', credits: 4, attendedSessions: 45, totalSessions: 50, colorValue: 0xFF7C3AED),
          ] : [],
        ),
        SemesterAttendance(
          semesterNumber: 4,
          semesterName: 'Semester 4',
          attendedWorkingDays: sem4Attended,
          totalWorkingDays: 90,
          isCurrentSemester: true,
          subjects: [
            SubjectAttendance(code: 'CS301', name: 'Computer Networks', facultyName: 'Dr. Robert Vance', credits: 4, attendedSessions: ((targetAtt / 100.0) * 42).round(), totalSessions: 42, colorValue: 0xFF2563EB),
            SubjectAttendance(code: 'CS302', name: 'Database Systems', facultyName: 'Prof. Sarah Jenkins', credits: 4, attendedSessions: ((targetAtt / 100.0) * 40).round(), totalSessions: 40, colorValue: 0xFF059669),
            SubjectAttendance(code: 'CS303', name: 'Web Technology', facultyName: 'Dr. Alan Turing', credits: 3, attendedSessions: ((targetAtt / 100.0) * 38).round(), totalSessions: 38, colorValue: 0xFFD97706),
            SubjectAttendance(code: 'CS304', name: 'Software Engineering', facultyName: 'Prof. Michael Scott', credits: 3, attendedSessions: ((targetAtt / 100.0) * 40).round(), totalSessions: 40, colorValue: 0xFF7C3AED),
            SubjectAttendance(code: 'CS305', name: 'AI & Machine Learning', facultyName: 'Dr. Grace Hopper', credits: 4, attendedSessions: ((targetAtt / 100.0) * 35).round(), totalSessions: 35, colorValue: 0xFFDC2626),
          ],
        ),
      ],
      selectedSemesterIndex: 3,
      dailyLogs: isDemo ? [
        DailyAttendanceLog(
          id: 'd1',
          dateStr: '13 Aug 2026',
          date: DateTime.now(),
          status: AttendanceStatus.present,
          dayName: 'Thursday',
          subjectsCovered: [
            'CS301 - Computer Networks (09:00 AM)',
            'CS302 - Database Systems (10:15 AM)',
            'CS303 - Web Technology (11:30 AM)',
            'CS304 - Software Engineering (02:00 PM)',
            'CS305 - AI & Machine Learning (03:15 PM)',
          ],
          classInCharge: 'Dr. Robert Vance',
          remarks: 'Present for all 5 timetable sessions',
        ),
        DailyAttendanceLog(
          id: 'd2',
          dateStr: '12 Aug 2026',
          date: DateTime.now().subtract(const Duration(days: 1)),
          status: AttendanceStatus.onDuty,
          dayName: 'Wednesday',
          subjectsCovered: [
            'CS301 - Computer Networks',
            'CS302 - Database Systems',
            'CS303 - Web Technology',
            'CS304 - Software Engineering',
            'CS305 - AI & Machine Learning',
          ],
          classInCharge: 'Prof. Sarah Jenkins',
          remarks: 'On Duty (OD): IIT Madras Inter-College Hackathon 2026',
        ),
        DailyAttendanceLog(
          id: 'd3',
          dateStr: '11 Aug 2026',
          date: DateTime.now().subtract(const Duration(days: 2)),
          status: AttendanceStatus.present,
          dayName: 'Tuesday',
          subjectsCovered: [
            'CS301 - Computer Networks',
            'CS302 - Database Systems',
            'CS303 - Web Technology',
            'CS304 - Software Engineering',
            'CS305 - AI & Machine Learning',
          ],
          classInCharge: 'Dr. Alan Turing',
          remarks: 'Present for all 5 timetable sessions',
        ),
        DailyAttendanceLog(
          id: 'd4',
          dateStr: '10 Aug 2026',
          date: DateTime.now().subtract(const Duration(days: 3)),
          status: AttendanceStatus.absent,
          dayName: 'Monday',
          subjectsCovered: [
            'CS301 - Computer Networks',
            'CS302 - Database Systems',
            'CS303 - Web Technology',
            'CS304 - Software Engineering',
            'CS305 - AI & Machine Learning',
          ],
          classInCharge: 'Prof. Michael Scott',
          remarks: 'Absent for full day (All 5 sessions marked Absent)',
        ),
      ] : [],
      attendanceLogs: isDemo ? [
        AttendanceRecord(id: '1', studentUid: '917722104022', studentName: 'Alex Johnson', subjectCode: 'CS301', subjectName: 'Computer Networks', date: DateTime.now().subtract(const Duration(hours: 4)), timeSlot: '09:00 - 10:00 AM', status: AttendanceStatus.present, facultyName: 'Dr. Robert Vance'),
        AttendanceRecord(id: '2', studentUid: '917722104022', studentName: 'Alex Johnson', subjectCode: 'CS302', subjectName: 'Database Systems', date: DateTime.now().subtract(const Duration(hours: 2)), timeSlot: '10:15 - 11:15 AM', status: AttendanceStatus.present, facultyName: 'Prof. Sarah Jenkins'),
        AttendanceRecord(id: '3', studentUid: '917722104022', studentName: 'Alex Johnson', subjectCode: 'CS303', subjectName: 'Web Technology', date: DateTime.now().subtract(const Duration(days: 1)), timeSlot: '11:30 AM - 12:30 PM', status: AttendanceStatus.absent, facultyName: 'Dr. Alan Turing'),
      ] : [],
      leaveRequests: isDemo ? [
        LeaveRequestModel(id: 'l1', studentName: 'Alex Johnson', type: 'Medical Leave', duration: '04 Aug - 05 Aug 2026 (2 Days)', reason: 'High fever & doctor advised bed rest', status: 'Approved', appliedDate: '03 Aug 2026', hasAttachment: true),
        LeaveRequestModel(id: 'l2', studentName: 'Alex Johnson', type: 'On Duty (OD)', duration: '28 Jul 2026 (1 Day)', reason: 'Attended Inter-College Hackathon at IIT Madras', status: 'Approved', appliedDate: '26 Jul 2026', hasAttachment: true),
      ] : [],
    );
  }

  /// HOD updates total working days for a semester
  void updateSemesterWorkingDaysByHod(int semNumber, int newWorkingDays) {
    if (newWorkingDays <= 0) return;

    final updatedConfigs = Map<int, HodSemesterConfig>.from(state.hodSemesterConfigs);
    updatedConfigs[semNumber] = (updatedConfigs[semNumber] ?? HodSemesterConfig(semesterNumber: semNumber, semesterName: 'Semester $semNumber', totalWorkingDays: newWorkingDays))
        .copyWith(totalWorkingDays: newWorkingDays);

    final updatedSemesters = state.studentSemesters.map((s) {
      if (s.semesterNumber == semNumber) {
        final double currentAttPct = s.attendancePercentage;
        final newAttended = ((currentAttPct / 100.0) * newWorkingDays).round();
        return s.copyWith(
          totalWorkingDays: newWorkingDays,
          attendedWorkingDays: newAttended,
        );
      }
      return s;
    }).toList();

    state = state.copyWith(
      hodSemesterConfigs: updatedConfigs,
      studentSemesters: updatedSemesters,
    );

    // Save to Firestore so student view reads updated working days from HOD
    FirebaseFirestoreService().saveSemesterWorkingDays(semNumber, newWorkingDays);
  }

  /// Change active selected semester index
  void selectSemesterIndex(int index) {
    if (index >= 0 && index < state.studentSemesters.length) {
      state = state.copyWith(selectedSemesterIndex: index);
    }
  }

  /// Staff submits session attendance for a class
  void submitStaffSessionAttendance({
    required String subjectCode,
    required String subjectName,
    required String facultyName,
    required String timeSlot,
    required List<Map<String, dynamic>> studentResults,
  }) {
    final now = DateTime.now();
    final newLogs = <AttendanceRecord>[];

    for (final s in studentResults) {
      final isPresent = s['isPresent'] as bool;
      final status = isPresent ? AttendanceStatus.present : AttendanceStatus.absent;

      newLogs.add(
        AttendanceRecord(
          id: DateTime.now().millisecondsSinceEpoch.toString() + s['id'].toString(),
          studentUid: s['id'] ?? 'student_1',
          studentName: s['name'] ?? 'Student',
          subjectCode: subjectCode,
          subjectName: subjectName,
          date: now,
          timeSlot: timeSlot,
          status: status,
          facultyName: facultyName,
        ),
      );
    }

    state = state.copyWith(
      attendanceLogs: [...newLogs, ...state.attendanceLogs],
    );
  }

  /// Student submits a new Leave / OD application
  void addLeaveRequest(LeaveRequestModel request) {
    state = state.copyWith(
      leaveRequests: [request, ...state.leaveRequests],
    );
  }
}

final attendanceSystemProvider =
    StateNotifierProvider<AttendanceSystemNotifier, AttendanceSystemState>(
  (ref) {
    final user = ref.watch(currentUserProvider).value ?? ref.watch(authServiceProvider).currentUser;
    return AttendanceSystemNotifier(user: user);
  },
);
