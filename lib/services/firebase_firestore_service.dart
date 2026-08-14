import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/models/announcement_model.dart';
import 'package:unisphere/models/assignment_model.dart';
import 'package:unisphere/models/attendance_model.dart';
import 'package:unisphere/models/exam_model.dart';
import 'package:unisphere/models/hackathon_model.dart';
import 'package:unisphere/models/mark_model.dart';
import 'package:unisphere/models/submission_model.dart';
import 'package:unisphere/models/user_model.dart';
import 'package:unisphere/services/database_seeder.dart';
import 'package:unisphere/services/supabase_service.dart';

final firebaseFirestoreServiceProvider = Provider<FirebaseFirestoreService>((ref) {
  return FirebaseFirestoreService();
});

final allStudentsStreamProvider = StreamProvider.autoDispose<List<UserModel>>((ref) {
  return ref.watch(firebaseFirestoreServiceProvider).getStudents();
});

final allTimetablesStreamProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  return ref.watch(firebaseFirestoreServiceProvider).getAllTimetablesStream();
});

final allAssignmentsStreamProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  return ref.watch(firebaseFirestoreServiceProvider).getAllAssignmentsStream();
});

class FirebaseFirestoreService implements SupabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MockSupabaseService _fallbackMock = MockSupabaseService();

  FirebaseFirestoreService();

  // ==========================================
  // ANNOUNCEMENTS
  // ==========================================
  @override
  Stream<List<AnnouncementModel>> getAnnouncements() {
    try {
      return _firestore
          .collection('announcements')
          .orderBy('created_at', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) {
                final data = doc.data();
                data['id'] = doc.id;
                return AnnouncementModel.fromMap(data);
              }).toList())
          .handleError((error) {
        debugPrint('Firestore Announcements Error, serving fallback: $error');
        return _fallbackMock.getAnnouncements();
      });
    } catch (e) {
      debugPrint('Firestore getAnnouncements exception: $e');
      return _fallbackMock.getAnnouncements();
    }
  }

  Future<void> addAnnouncement(AnnouncementModel announcement) async {
    try {
      await _firestore.collection('announcements').doc(announcement.id).set(announcement.toMap());
    } catch (e) {
      debugPrint('Firestore addAnnouncement error: $e');
    }
  }

  Future<void> markAnnouncementRead(String announcementId, String userId) async {
    try {
      await _firestore.collection('announcements').doc(announcementId).update({
        'read_by_users': FieldValue.arrayUnion([userId])
      });
    } catch (e) {
      debugPrint('Firestore markAnnouncementRead error: $e');
    }
  }

  // ==========================================
  // ASSIGNMENTS & SUBMISSIONS
  // ==========================================
  @override
  Stream<List<AssignmentModel>> getAssignments() {
    try {
      return _firestore
          .collection('assignments')
          .orderBy('due_date', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) {
                final data = doc.data();
                data['id'] = doc.id;
                return AssignmentModel.fromMap(data);
              }).toList())
          .handleError((error) {
        debugPrint('Firestore Assignments Error, serving fallback: $error');
        return _fallbackMock.getAssignments();
      });
    } catch (e) {
      return _fallbackMock.getAssignments();
    }
  }

  Future<void> createAssignment(AssignmentModel assignment) async {
    try {
      await _firestore.collection('assignments').doc(assignment.id).set(assignment.toMap());
    } catch (e) {
      debugPrint('Firestore createAssignment error: $e');
    }
  }

  @override
  Future<void> submitAssignment(SubmissionModel submission) async {
    try {
      await _firestore.collection('submissions').doc(submission.id).set(submission.toMap());
    } catch (e) {
      debugPrint('Firestore submitAssignment exception: $e');
    }
  }

  @override
  Stream<List<SubmissionModel>> getSubmissions(String assignmentId) {
    try {
      return _firestore
          .collection('submissions')
          .where('assignment_id', isEqualTo: assignmentId)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) {
                final data = doc.data();
                data['id'] = doc.id;
                return SubmissionModel.fromMap(data);
              }).toList())
          .handleError((error) => _fallbackMock.getSubmissions(assignmentId));
    } catch (e) {
      return _fallbackMock.getSubmissions(assignmentId);
    }
  }

  // ==========================================
  // MARKS & GRADEBOOK
  // ==========================================
  @override
  Stream<List<MarkModel>> getMarks(String studentUid) {
    try {
      return _firestore
          .collection('marks')
          .where('student_uid', isEqualTo: studentUid)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) {
                final data = doc.data();
                data['id'] = doc.id;
                return MarkModel.fromMap(data);
              }).toList())
          .handleError((error) => _fallbackMock.getMarks(studentUid));
    } catch (e) {
      return _fallbackMock.getMarks(studentUid);
    }
  }

  @override
  Future<void> addMarks(MarkModel mark) async {
    try {
      await _firestore.collection('marks').doc(mark.id).set(mark.toMap());
    } catch (e) {
      debugPrint('Firestore addMarks exception: $e');
    }
  }

  // ==========================================
  // ATTENDANCE & LEAVES
  // ==========================================
  @override
  Stream<List<AttendanceRecord>> getAttendance(String studentUid) {
    try {
      return _firestore
          .collection('attendance')
          .where('student_uid', isEqualTo: studentUid)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) {
                final data = doc.data();
                data['id'] = doc.id;
                return AttendanceRecord.fromMap(data);
              }).toList())
          .handleError((error) => _fallbackMock.getAttendance(studentUid));
    } catch (e) {
      return _fallbackMock.getAttendance(studentUid);
    }
  }

  Future<void> addAttendanceRecord(AttendanceRecord record) async {
    try {
      await _firestore.collection('attendance').doc(record.id).set(record.toMap());
    } catch (e) {
      debugPrint('Firestore addAttendanceRecord error: $e');
    }
  }

  // ==========================================
  // EXAMS
  // ==========================================
  Stream<List<ExamModel>> getExams() {
    try {
      return _firestore
          .collection('exams')
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) {
                final data = doc.data();
                data['id'] = doc.id;
                return ExamModel.fromMap(data);
              }).toList())
          .handleError((error) {
        debugPrint('Firestore Exams Stream error: $error');
        return <ExamModel>[];
      });
    } catch (e) {
      return Stream.value([]);
    }
  }

  Future<void> addExam(ExamModel exam) async {
    try {
      await _firestore.collection('exams').doc(exam.id).set(exam.toMap());
    } catch (e) {
      debugPrint('Firestore addExam error: $e');
    }
  }

  // ==========================================
  // HACKATHONS
  // ==========================================
  Stream<List<HackathonModel>> getHackathons() {
    try {
      return _firestore
          .collection('hackathons')
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) {
                final data = doc.data();
                data['id'] = doc.id;
                return HackathonModel.fromMap(data);
              }).toList())
          .handleError((error) {
        debugPrint('Firestore Hackathons Stream error: $error');
        return <HackathonModel>[];
      });
    } catch (e) {
      return Stream.value([]);
    }
  }

  Future<void> registerHackathonTeam(String hackathonId, Map<String, dynamic> registrationData) async {
    try {
      await _firestore
          .collection('hackathons')
          .doc(hackathonId)
          .collection('registrations')
          .add(registrationData);
      
      // Increment registered teams count
      await _firestore.collection('hackathons').doc(hackathonId).update({
        'registeredTeams': FieldValue.increment(1)
      });
    } catch (e) {
      debugPrint('Firestore registerHackathonTeam error: $e');
    }
  }
  // ==========================================
  // USERS & STUDENTS DIRECTORY
  // ==========================================
  Stream<List<UserModel>> getStudents() {
    try {
      return _firestore
          .collection('users')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => UserModel.fromMap(doc.data(), doc.id))
              .where((u) => u.role == UserRole.student)
              .toList());
    } catch (e) {
      debugPrint('Firestore getStudents error: $e');
      return Stream.value([]);
    }
  }

  Future<bool> isRegisterNumberTaken(String regNo, String currentUid) async {
    final cleanReg = regNo.trim().toLowerCase();
    if (cleanReg.isEmpty) return false;
    try {
      final snapshot = await _firestore.collection('users').get();
      for (var doc in snapshot.docs) {
        if (doc.id == currentUid) continue;
        final data = doc.data();
        final existingReg = data['metadata']?['registerNumber']?.toString().toLowerCase().trim() ?? '';
        if (existingReg == cleanReg && existingReg.isNotEmpty) {
          return true;
        }
      }
    } catch (e) {
      debugPrint('Firestore isRegisterNumberTaken error: $e');
    }
    return false;
  }

  Future<void> saveSemesterWorkingDays(int semNumber, int totalWorkingDays) async {
    try {
      await _firestore.collection('attendance_configs').doc('sem_$semNumber').set({
        'semNumber': semNumber,
        'totalWorkingDays': totalWorkingDays,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore saveSemesterWorkingDays error: $e');
    }
  }

  Stream<Map<int, int>> getSemesterWorkingDaysStream() {
    try {
      return _firestore.collection('attendance_configs').snapshots().map((snapshot) {
        final Map<int, int> configs = {};
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final semNum = data['semNumber'] as int? ?? int.tryParse(doc.id.replaceAll('sem_', ''));
          final days = data['totalWorkingDays'] as int?;
          if (semNum != null && days != null) {
            configs[semNum] = days;
          }
        }
        return configs;
      });
    } catch (e) {
      debugPrint('Firestore getSemesterWorkingDaysStream error: $e');
      return Stream.value({});
    }
  }

  Future<void> saveYearSectionTimetable({
    required String year,
    required String section,
    required String fileName,
    required String fileType,
    String? fileUrl,
    List<Map<String, dynamic>>? periods,
  }) async {
    try {
      final docId = '${year.replaceAll(' ', '_')}_${section.replaceAll(' ', '_')}'.toLowerCase();
      await _firestore.collection('timetables').doc(docId).set({
        'year': year,
        'section': section,
        'fileName': fileName,
        'fileType': fileType,
        'fileUrl': fileUrl ?? '',
        'uploadedAt': FieldValue.serverTimestamp(),
        'uploadedBy': 'HOD Computer Science',
        'periods': periods ?? [],
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore saveYearSectionTimetable error: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getAllTimetablesStream() {
    try {
      return _firestore.collection('timetables').snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      });
    } catch (e) {
      debugPrint('Firestore getAllTimetablesStream error: $e');
      return Stream.value([]);
    }
  }

  Future<void> saveAssignmentMarks({
    required String title,
    required String subject,
    required String examType,
    required String fileName,
    required String fileType,
    required List<Map<String, String>> studentRecords,
  }) async {
    try {
      final docId = 'assign_${subject.replaceAll(' ', '_')}_${examType.replaceAll(' ', '_')}'.toLowerCase();
      await _firestore.collection('assignments').doc(docId).set({
        'title': title,
        'subject': subject,
        'examType': examType,
        'fileName': fileName,
        'fileType': fileType,
        'uploadedAt': FieldValue.serverTimestamp(),
        'uploadedBy': 'Faculty Staff',
        'studentRecords': studentRecords,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore saveAssignmentMarks error: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getAllAssignmentsStream() {
    try {
      return _firestore.collection('assignments').snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      });
    } catch (e) {
      debugPrint('Firestore getAllAssignmentsStream error: $e');
      return Stream.value([]);
    }
  }

  // ==========================================
  // INITIAL DATABASE SEEDING
  // ==========================================
  Future<void> seedInitialDataIfEmpty() async {
    try {
      final annSnapshot = await _firestore
          .collection('announcements')
          .limit(1)
          .get(const GetOptions(source: Source.serverAndCache))
          .timeout(const Duration(seconds: 5));
      if (annSnapshot.docs.isEmpty) {
        debugPrint('Seeding initial Firestore database across all collections...');
        await DatabaseSeeder.seedAllData().timeout(const Duration(seconds: 10));
      }
    } catch (e) {
      if (!e.toString().contains('TimeoutException')) {
        debugPrint('Firestore seedInitialDataIfEmpty notice: $e');
      }
    }
  }
}
