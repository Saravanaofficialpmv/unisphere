import 'package:flutter/material.dart';
import 'package:clg_application/models/exam_model.dart';

class ExamService extends ChangeNotifier {
  static final ExamService _instance = ExamService._internal();
  factory ExamService() => _instance;

  ExamService._internal() {
    _initSeedExams();
  }

  final List<ExamModel> _exams = [];

  List<ExamModel> get exams => List.unmodifiable(_exams);

  List<ExamModel> get upcomingExams => _exams.where((e) => !e.isCompleted).toList()..sort((a, b) => a.date.compareTo(b.date));
  List<ExamModel> get completedExams => _exams.where((e) => e.isCompleted).toList()..sort((a, b) => b.date.compareTo(a.date));

  void _initSeedExams() {
    final now = DateTime.now();

    _exams.addAll([
      ExamModel(
        id: 'exam_201',
        subjectName: 'Data Structures & Algorithms',
        courseCode: 'CS201',
        examType: 'Internal Assessment',
        date: DateTime(now.year, 8, 20),
        startTime: '09:00 AM',
        endTime: '12:00 PM',
        durationMinutes: 180,
        venue: 'Main Block',
        roomNumber: 'Room 203',
        blockBuilding: 'Main Academic Building - 2nd Floor',
        instructions: 'Mobile phones, smart watches, and programmable devices are strictly prohibited. Arrive 15 mins prior to commencement.',
        facultyInvigilator: 'Prof. Sarah Jenkins & Dr. Robert Miller',
        eligibilityStatus: ExamEligibilityStatus.eligible,
        isHallTicketAvailable: true,
        hallTicketUrl: 'https://storage.unisphere.edu/halltickets/RA2111003010001_CS201.pdf',
        targetedClasses: ['CSE - 3rd Year - Sec A'],
        semester: 6,
        requirements: const [
          ExamRequirementItem(label: 'College ID Card', status: ExamRequirementStatus.required, note: 'Mandatory verification'),
          ExamRequirementItem(label: 'Hall Ticket', status: ExamRequirementStatus.required, note: 'Printed hall ticket'),
          ExamRequirementItem(label: 'Blue/Black Ballpoint Pen', status: ExamRequirementStatus.required),
          ExamRequirementItem(label: 'Non-Programmable Scientific Calculator', status: ExamRequirementStatus.allowed, note: 'Casio fx-991EX permitted'),
          ExamRequirementItem(label: 'Mobile Phone', status: ExamRequirementStatus.notAllowed, note: 'Deposit at entrance'),
          ExamRequirementItem(label: 'Smart Watch / Electronic Gadgets', status: ExamRequirementStatus.notAllowed),
        ],
      ),
      ExamModel(
        id: 'exam_202',
        subjectName: 'Computer Networks',
        courseCode: 'CS205',
        examType: 'Model Exam',
        date: DateTime(now.year, 8, 25),
        startTime: '01:00 PM',
        endTime: '04:00 PM',
        durationMinutes: 180,
        venue: 'Main Block',
        roomNumber: 'Room 104',
        blockBuilding: 'Main Academic Building - 1st Floor',
        instructions: 'Write answers cleanly on answer booklet. Rough sheets provided by invigilator.',
        facultyInvigilator: 'Prof. Anita Sharma',
        eligibilityStatus: ExamEligibilityStatus.eligible,
        isHallTicketAvailable: true,
        hallTicketUrl: 'https://storage.unisphere.edu/halltickets/RA2111003010001_CS205.pdf',
        targetedClasses: ['CSE - 3rd Year - Sec A'],
        semester: 6,
        requirements: const [
          ExamRequirementItem(label: 'College ID Card', status: ExamRequirementStatus.required),
          ExamRequirementItem(label: 'Hall Ticket', status: ExamRequirementStatus.required),
          ExamRequirementItem(label: 'Ruler & Stationary Kit', status: ExamRequirementStatus.allowed),
          ExamRequirementItem(label: 'Smart Watch', status: ExamRequirementStatus.notAllowed),
          ExamRequirementItem(label: 'Mobile Phone', status: ExamRequirementStatus.notAllowed),
        ],
      ),
      ExamModel(
        id: 'exam_203',
        subjectName: 'Operating Systems',
        courseCode: 'CS301',
        examType: 'End Semester',
        date: DateTime(now.year, 9, 2),
        startTime: '09:00 AM',
        endTime: '12:00 PM',
        durationMinutes: 180,
        venue: 'Main Block',
        roomNumber: 'Room 201',
        blockBuilding: 'Main Academic Building - 2nd Floor',
        instructions: 'Comprehensive end-semester university evaluation. Strict invigilator supervision.',
        facultyInvigilator: 'Dr. Alan Turing & Team',
        eligibilityStatus: ExamEligibilityStatus.eligible,
        isHallTicketAvailable: true,
        hallTicketUrl: 'https://storage.unisphere.edu/halltickets/RA2111003010001_CS301.pdf',
        targetedClasses: ['CSE - 3rd Year - Sec A'],
        semester: 6,
        requirements: const [
          ExamRequirementItem(label: 'College ID Card', status: ExamRequirementStatus.required),
          ExamRequirementItem(label: 'Hall Ticket', status: ExamRequirementStatus.required),
          ExamRequirementItem(label: 'Blue/Black Pen', status: ExamRequirementStatus.required),
          ExamRequirementItem(label: 'Mobile Phone', status: ExamRequirementStatus.notAllowed),
          ExamRequirementItem(label: 'Smart Watch', status: ExamRequirementStatus.notAllowed),
        ],
      ),
    ]);
  }

  List<ExamModel> getFilteredExams({
    int? semester,
    String? subject,
    String? examType,
    String? searchQuery,
    bool showUpcomingOnly = false,
  }) {
    return _exams.where((exam) {
      final matchesSemester = semester == null || exam.semester == semester;
      final matchesSubject = subject == null || subject == 'All' || exam.subjectName == subject;
      final matchesType = examType == null || examType == 'All' || exam.examType == examType;
      final matchesStatus = !showUpcomingOnly || !exam.isCompleted;

      final query = searchQuery?.toLowerCase().trim() ?? '';
      final matchesSearch = query.isEmpty ||
          exam.subjectName.toLowerCase().contains(query) ||
          exam.courseCode.toLowerCase().contains(query) ||
          exam.examType.toLowerCase().contains(query) ||
          exam.venue.toLowerCase().contains(query);

      return matchesSemester && matchesSubject && matchesType && matchesStatus && matchesSearch;
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  void addExam(ExamModel exam) {
    _exams.insert(0, exam);
    notifyListeners();
  }

  List<String> get availableExamTypes => [
        'All',
        'Unit Test',
        'Internal Assessment',
        'Model Exam',
        'Practical Exam',
        'Lab Exam',
        'End Semester',
        'Supplementary Exam',
      ];
}
