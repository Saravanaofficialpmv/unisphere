import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/models/announcement_model.dart';
import 'package:unisphere/models/assignment_model.dart';
import 'package:unisphere/models/mark_model.dart';
import 'package:unisphere/models/attendance_model.dart';
import 'package:unisphere/models/submission_model.dart';
import 'dart:async';

import 'package:unisphere/services/firebase_firestore_service.dart';

bool get shouldUseMock => false;

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  try {
    return FirebaseFirestoreService();
  } catch (e) {
    return MockSupabaseService();
  }
});

final announcementsStreamProvider = StreamProvider<List<AnnouncementModel>>((ref) {
  final service = ref.watch(supabaseServiceProvider);
  return service.getAnnouncements();
});

final assignmentsStreamProvider = StreamProvider<List<AssignmentModel>>((ref) {
  final service = ref.watch(supabaseServiceProvider);
  return service.getAssignments();
});

final marksStreamProvider = StreamProvider.family<List<MarkModel>, String>((ref, studentUid) {
  final service = ref.watch(supabaseServiceProvider);
  return service.getMarks(studentUid);
});

final attendanceStreamProvider = StreamProvider.family<List<AttendanceRecord>, String>((ref, studentUid) {
  final service = ref.watch(supabaseServiceProvider);
  return service.getAttendance(studentUid);
});

abstract class SupabaseService {
  Stream<List<AnnouncementModel>> getAnnouncements();
  Stream<List<AssignmentModel>> getAssignments();
  Future<void> submitAssignment(SubmissionModel submission);
  Stream<List<SubmissionModel>> getSubmissions(String assignmentId);
  Stream<List<MarkModel>> getMarks(String studentUid);
  Stream<List<AttendanceRecord>> getAttendance(String studentUid);
  Future<void> addMarks(MarkModel mark);
}

class RealSupabaseService implements SupabaseService {
  final SupabaseClient _supabase;

  RealSupabaseService(this._supabase);

  @override
  Stream<List<AnnouncementModel>> getAnnouncements() {
    return _supabase
        .from('announcements')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => AnnouncementModel.fromMap(json)).toList());
  }

  @override
  Stream<List<AssignmentModel>> getAssignments() {
    return _supabase
        .from('assignments')
        .stream(primaryKey: ['id'])
        .order('due_date', ascending: false)
        .map((data) => data.map((json) => AssignmentModel.fromMap(json)).toList());
  }

  @override
  Future<void> submitAssignment(SubmissionModel submission) async {
    await _supabase.from('submissions').insert(submission.toMap());
  }

  @override
  Stream<List<SubmissionModel>> getSubmissions(String assignmentId) {
    return _supabase
        .from('submissions')
        .stream(primaryKey: ['id'])
        .eq('assignment_id', assignmentId)
        .map((data) => data.map((json) => SubmissionModel.fromMap(json)).toList());
  }

  @override
  Stream<List<MarkModel>> getMarks(String studentUid) {
    return _supabase
        .from('marks')
        .stream(primaryKey: ['id'])
        .eq('student_uid', studentUid)
        .map((data) => data.map((json) => MarkModel.fromMap(json)).toList());
  }

  @override
  Stream<List<AttendanceRecord>> getAttendance(String studentUid) {
    return _supabase
        .from('attendance')
        .stream(primaryKey: ['id'])
        .eq('student_uid', studentUid)
        .order('date', ascending: false)
        .map((data) => data.map((json) => AttendanceRecord.fromMap(json)).toList());
  }

  @override
  Future<void> addMarks(MarkModel mark) async {
    await _supabase.from('marks').insert(mark.toMap());
  }
}

class MockSupabaseService implements SupabaseService {
  MockSupabaseService();

  @override
  Stream<List<AnnouncementModel>> getAnnouncements() {
    return Stream.value([
      AnnouncementModel(
        id: '1',
        title: 'End Semester Exam Date Out!',
        content: 'The exams will start from 15th June. Check timetable.',
        authorName: 'Admin',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        category: 'College',
      ),
      AnnouncementModel(
        id: '2',
        title: 'New Library Timings',
        content: 'Library will be open till 10 PM from Monday.',
        authorName: 'Admin',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        category: 'College',
      ),
    ]);
  }

  @override
  Stream<List<AssignmentModel>> getAssignments() {
    return Stream.value([
      AssignmentModel(
        id: 'a1',
        title: 'Advanced Mathematics: Unit 1',
        description: 'Complete the derivatives and integrations.',
        authorName: 'Prof. Carter',
        subjectName: 'Mathematics',
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        dueDate: DateTime.now().add(const Duration(days: 2)),
        maxMarks: 100,
        targetedClasses: ['CS-A'],
      ),
    ]);
  }

  @override
  Future<void> submitAssignment(SubmissionModel submission) async {
    return;
  }

  @override
  Stream<List<SubmissionModel>> getSubmissions(String assignmentId) {
    return Stream.value([]);
  }

  @override
  Stream<List<MarkModel>> getMarks(String studentUid) {
    return Stream.value([
      MarkModel(
        id: 'm1',
        studentUid: studentUid,
        subjectName: 'Mathematics',
        obtainedMarks: 88,
        totalMarks: 100,
        examType: 'Mid-term',
        updatedAt: DateTime.now(),
      ),
    ]);
  }

  @override
  Stream<List<AttendanceRecord>> getAttendance(String studentUid) {
    return Stream.value([
      AttendanceRecord(
        id: 'at1',
        studentUid: studentUid,
        studentName: 'Student',
        subjectCode: 'CS401',
        subjectName: 'Advanced Data Structures',
        date: DateTime.now().subtract(const Duration(days: 1)),
        timeSlot: '09:00 AM',
        status: AttendanceStatus.present,
        facultyName: 'Dr. Vance',
      ),
    ]);
  }

  @override
  Future<void> addMarks(MarkModel mark) async {
    return;
  }
}
