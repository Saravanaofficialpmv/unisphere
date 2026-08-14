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
import 'package:unisphere/services/database_seeder.dart';
import 'package:unisphere/services/supabase_service.dart';

final firebaseFirestoreServiceProvider = Provider<FirebaseFirestoreService>((ref) {
  return FirebaseFirestoreService();
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
