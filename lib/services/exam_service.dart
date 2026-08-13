import 'dart:async';
import 'package:flutter/material.dart';
import 'package:unisphere/models/exam_model.dart';
import 'package:unisphere/services/firebase_firestore_service.dart';

class ExamService extends ChangeNotifier {
  static final ExamService _instance = ExamService._internal();
  factory ExamService() => _instance;

  StreamSubscription<List<ExamModel>>? _subscription;

  ExamService._internal() {
    _initSeedExams();
    _connectFirestoreStream();
  }

  final List<ExamModel> _exams = [];

  List<ExamModel> get exams => List.unmodifiable(_exams);

  List<ExamModel> get upcomingExams => _exams.where((e) => !e.isCompleted).toList()..sort((a, b) => a.date.compareTo(b.date));
  List<ExamModel> get completedExams => _exams.where((e) => e.isCompleted).toList()..sort((a, b) => b.date.compareTo(a.date));

  List<ExamModel> getFilteredExams({
    String? examType,
    String? searchQuery,
    bool showUpcomingOnly = true,
  }) {
    return _exams.where((e) {
      if (showUpcomingOnly && e.isCompleted) return false;
      if (!showUpcomingOnly && !e.isCompleted) return false;

      if (examType != null && examType.isNotEmpty && examType != 'All') {
        if (e.examType.toLowerCase() != examType.toLowerCase()) return false;
      }

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final query = searchQuery.trim().toLowerCase();
        final matchSubject = e.subjectName.toLowerCase().contains(query);
        final matchCode = e.courseCode.toLowerCase().contains(query);
        final matchVenue = e.venue.toLowerCase().contains(query);
        final matchRoom = e.roomNumber.toLowerCase().contains(query);
        if (!matchSubject && !matchCode && !matchVenue && !matchRoom) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _connectFirestoreStream() {
    try {
      final firestoreService = FirebaseFirestoreService();
      _subscription = firestoreService.getExams().listen(
        (list) {
          if (list.isNotEmpty) {
            _exams.clear();
            _exams.addAll(list);
            notifyListeners();
          }
        },
        onError: (e) {
          debugPrint('ExamService stream error: $e');
        },
      );
    } catch (e) {
      debugPrint('ExamService connect error: $e');
    }
  }

  void _initSeedExams() {
    final now = DateTime.now();

    _exams.addAll([
      ExamModel(
        id: 'exam_201',
        subjectName: 'Data Structures & Algorithms',
        courseCode: 'CS201',
        examType: 'Internal Assessment',
        date: DateTime(now.year, now.month, now.day + 7),
        startTime: '09:00 AM',
        endTime: '12:00 PM',
        durationMinutes: 180,
        venue: 'Main Block',
        roomNumber: 'Room 203',
        blockBuilding: 'Main Academic Building - 2nd Floor',
        instructions: 'Mobile phones and smart watches are strictly prohibited. Arrive 15 mins prior.',
        facultyInvigilator: 'Prof. Sarah Jenkins & Dr. Robert Miller',
        eligibilityStatus: ExamEligibilityStatus.eligible,
        isHallTicketAvailable: true,
        targetedClasses: ['CSE - 3rd Year - Sec A'],
        semester: 6,
      ),
      ExamModel(
        id: 'exam_202',
        subjectName: 'Computer Networks',
        courseCode: 'CS205',
        examType: 'Model Exam',
        date: DateTime(now.year, now.month, now.day + 12),
        startTime: '01:00 PM',
        endTime: '04:00 PM',
        durationMinutes: 180,
        venue: 'Main Block',
        roomNumber: 'Room 305',
        blockBuilding: 'Main Academic Building - 3rd Floor',
        instructions: 'Bring scientific calculator and hall ticket.',
        facultyInvigilator: 'Prof. Anita Sharma',
        eligibilityStatus: ExamEligibilityStatus.eligible,
        isHallTicketAvailable: true,
        targetedClasses: ['CSE - 3rd Year - Sec A'],
        semester: 6,
      ),
    ]);
  }

  void addExam(ExamModel exam) {
    _exams.insert(0, exam);
    notifyListeners();
    FirebaseFirestoreService().addExam(exam);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
