import 'package:flutter/material.dart';
import 'package:unisphere/models/assignment_model.dart';
import 'package:unisphere/models/submission_model.dart';

class AssignmentService extends ChangeNotifier {
  static final AssignmentService _instance = AssignmentService._internal();
  factory AssignmentService() => _instance;

  AssignmentService._internal() {
    _initSeedData();
  }

  final List<AssignmentModel> _assignments = [];
  final List<SubmissionModel> _submissions = [];

  List<AssignmentModel> get assignments => List.unmodifiable(_assignments);
  List<SubmissionModel> get submissions => List.unmodifiable(_submissions);

  void _initSeedData() {
    final now = DateTime.now();

    _assignments.addAll([
      AssignmentModel(
        id: 'asg_101',
        title: 'Submit Lab Record',
        courseCode: 'CS201',
        subjectName: 'Data Structures Lab',
        authorName: 'Prof. Sarah Jenkins',
        description: 'Prepare and submit your lab record for Data Structures. Include all executed algorithm code snippets, output logs, and AVL tree rotation diagrams.',
        createdAt: now.subtract(const Duration(days: 1)),
        dueDate: DateTime(2025, 8, 12, 23, 59),
        maxMarks: 100,
        targetedClasses: ['CSE - 3rd Year - Sec A', 'CSE - 3rd Year - Sec B'],
        allowedFileTypes: ['pdf', 'docx', 'zip'],
        regNoQuestionMap: {
          'RA2111003010001': 'Set A: Implement AVL Tree with left-right double rotations and benchmark insertion for N=10,000 nodes.',
          'RA2111003010002': 'Set B: Implement AVL Tree with deletion operations and rebalancing visualization graph.',
          'RA2111003010003-RA2111003010050': 'Set C: Implement Red-Black Tree insertion algorithm with height verification tests.',
        },
      ),
      AssignmentModel(
        id: 'asg_102',
        title: 'Project Review',
        courseCode: 'CS304',
        subjectName: 'Mini Project',
        authorName: 'Dr. Robert Miller',
        description: 'Upload your Mini Project progress report and dynamic slide presentation for Phase 1 review.',
        createdAt: now.subtract(const Duration(days: 3)),
        dueDate: DateTime(2025, 8, 14, 10, 0),
        maxMarks: 50,
        targetedClasses: ['CSE - 3rd Year - Sec A'],
        allowedFileTypes: ['zip', 'pdf', 'pptx'],
        regNoQuestionMap: {
          'RA2111003010001': 'Set A: Design a Student Analytics Card with chart widgets and interactive modal overlays.',
          'RA2111003010002-RA2111003010050': 'Set B: Design a Staff Grading Sheet with real-time mark updates and export functionality.',
        },
      ),
      AssignmentModel(
        id: 'asg_103',
        title: 'Seminar Presentation',
        courseCode: 'CS205',
        subjectName: 'Computer Networks',
        authorName: 'Prof. Anita Sharma',
        description: 'Submit your research seminar paper on Next-Gen TCP/IP Protocol Optimizations and IPv6 Migration.',
        createdAt: now.subtract(const Duration(days: 5)),
        dueDate: DateTime(2025, 8, 18, 14, 0),
        maxMarks: 100,
        targetedClasses: ['CSE - 3rd Year - Sec A', 'CSE - 3rd Year - Sec C'],
        allowedFileTypes: ['pdf', 'docx'],
        regNoQuestionMap: {
          'RA2111003010001': 'Set A: Analyze TCP Congestion Control Algorithms (Reno vs Cubic) in high-latency wireless networks.',
        },
      ),
    ]);

    _submissions.addAll([
      SubmissionModel(
        id: 'sub_301',
        assignmentId: 'asg_103',
        studentUid: 'std_alex_01',
        studentName: 'Alex Johnson',
        registerNumber: 'RA2111003010001',
        fileName: 'Alex_Johnson_SQL_Optimization_Report.pdf',
        fileUrl: 'https://storage.unisphere.edu/submissions/Alex_Johnson_SQL_Optimization_Report.pdf',
        fileType: 'PDF',
        fileSizeBytes: 2450000, // 2.45 MB
        submittedAt: now.subtract(const Duration(days: 2)),
        status: 'Graded',
        isGraded: true,
        obtainedMarks: 94,
        feedback: 'Excellent index tuning and execution plan analysis! Your query cost reduction graphs were clearly explained.',
        gradedBy: 'Prof. Anita Sharma',
        gradedAt: now.subtract(const Duration(days: 1)),
      ),
      SubmissionModel(
        id: 'sub_302',
        assignmentId: 'asg_102',
        studentUid: 'std_alex_01',
        studentName: 'Alex Johnson',
        registerNumber: 'RA2111003010001',
        fileName: 'Alex_Johnson_WebTech_Dashboard.zip',
        fileUrl: 'https://storage.unisphere.edu/submissions/Alex_Johnson_WebTech_Dashboard.zip',
        fileType: 'ZIP',
        fileSizeBytes: 8120000, // 8.12 MB
        submittedAt: now.subtract(const Duration(hours: 2)),
        status: 'Late',
        isGraded: false,
      ),
    ]);
  }

  // ─────────────────────────────────────────
  // Student Actions
  // ─────────────────────────────────────────
  SubmissionModel? getSubmissionForStudent(String assignmentId, String studentUid) {
    try {
      return _submissions.firstWhere(
        (s) => s.assignmentId == assignmentId && s.studentUid == studentUid,
      );
    } catch (_) {
      return null;
    }
  }

  void saveSubmission({
    required String assignmentId,
    required String studentUid,
    required String studentName,
    required String registerNumber,
    required String fileName,
    required String fileType,
    required int fileSizeBytes,
    required bool isFinalSubmit,
  }) {
    final existingIndex = _submissions.indexWhere(
      (s) => s.assignmentId == assignmentId && s.studentUid == studentUid,
    );

    final assignment = _assignments.firstWhere((a) => a.id == assignmentId);
    final now = DateTime.now();

    String status = 'Draft';
    if (isFinalSubmit) {
      status = now.isAfter(assignment.dueDate) ? 'Late' : 'Submitted';
    }

    final newSubmission = SubmissionModel(
      id: existingIndex != -1 ? _submissions[existingIndex].id : 'sub_${DateTime.now().millisecondsSinceEpoch}',
      assignmentId: assignmentId,
      studentUid: studentUid,
      studentName: studentName,
      registerNumber: registerNumber,
      fileName: fileName,
      fileUrl: 'https://storage.unisphere.edu/submissions/$fileName',
      fileType: fileType,
      fileSizeBytes: fileSizeBytes,
      submittedAt: now,
      status: status,
      isGraded: false,
    );

    if (existingIndex != -1) {
      _submissions[existingIndex] = newSubmission;
    } else {
      _submissions.add(newSubmission);
    }

    notifyListeners();
  }

  // ─────────────────────────────────────────
  // Staff Actions
  // ─────────────────────────────────────────
  void addAssignment(AssignmentModel newAssignment) {
    _assignments.insert(0, newAssignment);
    notifyListeners();
  }

  void gradeSubmission({
    required String submissionId,
    required int marks,
    required String feedback,
    required String gradedBy,
  }) {
    final index = _submissions.indexWhere((s) => s.id == submissionId);
    if (index != -1) {
      final old = _submissions[index];
      _submissions[index] = old.copyWith(
        status: 'Graded',
        isGraded: true,
        obtainedMarks: marks,
        feedback: feedback,
        gradedBy: gradedBy,
        gradedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  List<SubmissionModel> getSubmissionsForAssignment(String assignmentId) {
    return _submissions.where((s) => s.assignmentId == assignmentId).toList();
  }
}
