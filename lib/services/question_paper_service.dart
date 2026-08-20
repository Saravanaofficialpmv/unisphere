import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:unisphere/models/question_paper_model.dart';

class QuestionPaperService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // In-memory cache / custom uploaded list for instant responsiveness
  static final List<QuestionPaperModel> _inMemoryCustomPapers = [];

  /// Fetch question papers and question banks with filtering
  Future<List<QuestionPaperModel>> getQuestionPapers({
    String? department,
    String? semester,
    String? subjectCode,
    QuestionPaperType? paperType,
    String? regulation,
    String? examSession,
    String? searchQuery,
    bool? onlyWithAnswerKey,
  }) async {
    List<QuestionPaperModel> allPapers = [];

    try {
      final snapshot = await _firestore
          .collection('question_papers')
          .orderBy('uploadedAt', descending: true)
          .get();

      if (snapshot.docs.isNotEmpty) {
        allPapers = snapshot.docs
            .map((doc) => QuestionPaperModel.fromMap(doc.data(), doc.id))
            .toList();
      }
    } catch (e) {
      debugPrint('QuestionPaperService: Firestore fetch error (falling back to built-in): $e');
    }

    // Merge with in-memory custom uploads and built-in repository
    final builtIn = _getBuiltInQuestionPapers();
    final combined = <String, QuestionPaperModel>{};

    for (var p in builtIn) {
      combined[p.id] = p;
    }
    for (var p in _inMemoryCustomPapers) {
      combined[p.id] = p;
    }
    for (var p in allPapers) {
      combined[p.id] = p;
    }

    var result = combined.values.toList();

    // Sort by uploadedAt descending
    result.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));

    // Apply Department Filter
    if (department != null &&
        department.isNotEmpty &&
        department.toLowerCase() != 'all' &&
        department.toLowerCase() != 'all departments') {
      final normDept = _normalize(department);
      result = result.where((p) {
        final pDept = _normalize(p.department);
        return pDept.contains(normDept) ||
            normDept.contains(pDept) ||
            pDept.contains('all') ||
            pDept.isEmpty;
      }).toList();
    }

    // Apply Semester Filter
    if (semester != null &&
        semester.isNotEmpty &&
        semester.toLowerCase() != 'all' &&
        semester.toLowerCase() != 'all semesters') {
      final normSem = _normalizeSemester(semester);
      result = result.where((p) => _normalizeSemester(p.semester) == normSem).toList();
    }

    // Apply Subject Code Filter
    if (subjectCode != null && subjectCode.isNotEmpty) {
      final normCode = subjectCode.trim().toLowerCase();
      result = result.where((p) => p.subjectCode.toLowerCase() == normCode).toList();
    }

    // Apply Paper Type Filter
    if (paperType != null) {
      result = result.where((p) => p.paperType == paperType).toList();
    }

    // Apply Regulation Filter
    if (regulation != null &&
        regulation.isNotEmpty &&
        regulation.toLowerCase() != 'all' &&
        regulation.toLowerCase() != 'all regulations') {
      final normReg = _normalize(regulation);
      result = result.where((p) => _normalize(p.regulation).contains(normReg)).toList();
    }

    // Apply Exam Session Filter
    if (examSession != null &&
        examSession.isNotEmpty &&
        examSession.toLowerCase() != 'all') {
      final normSession = _normalize(examSession);
      result = result.where((p) => _normalize(p.examSession).contains(normSession)).toList();
    }

    // Apply Only With Answer Key Filter
    if (onlyWithAnswerKey == true) {
      result = result.where((p) => p.hasAnswerKey).toList();
    }

    // Apply Search Query Filter
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();
      result = result.where((p) {
        return p.title.toLowerCase().contains(query) ||
            p.subjectCode.toLowerCase().contains(query) ||
            p.subjectName.toLowerCase().contains(query) ||
            p.department.toLowerCase().contains(query) ||
            p.examSession.toLowerCase().contains(query) ||
            p.uploadedByStaffName.toLowerCase().contains(query) ||
            p.tags.any((tag) => tag.toLowerCase().contains(query));
      }).toList();
    }

    return result;
  }

  /// Get papers uploaded by a specific staff member
  Future<List<QuestionPaperModel>> getStaffUploadedPapers(String staffId) async {
    final all = await getQuestionPapers();
    return all.where((p) => p.uploadedByStaffId == staffId || staffId.isEmpty).toList();
  }

  /// Upload / Save a new Question Paper or Question Bank
  Future<QuestionPaperModel> uploadQuestionPaper(QuestionPaperModel paper) async {
    try {
      final docRef = _firestore.collection('question_papers').doc(paper.id.isEmpty ? null : paper.id);
      final finalId = docRef.id;
      final updatedPaper = paper.copyWith(id: finalId);

      await docRef.set(updatedPaper.toMap(), SetOptions(merge: true));

      // Cache locally
      _inMemoryCustomPapers.removeWhere((p) => p.id == finalId);
      _inMemoryCustomPapers.insert(0, updatedPaper);

      return updatedPaper;
    } catch (e) {
      debugPrint('QuestionPaperService: Firestore write error: $e. Storing in local cache.');
      final localId = paper.id.isEmpty ? 'qp_local_${DateTime.now().millisecondsSinceEpoch}' : paper.id;
      final localPaper = paper.copyWith(id: localId);
      _inMemoryCustomPapers.removeWhere((p) => p.id == localId);
      _inMemoryCustomPapers.insert(0, localPaper);
      return localPaper;
    }
  }

  /// Delete a question paper
  Future<void> deleteQuestionPaper(String id) async {
    try {
      await _firestore.collection('question_papers').doc(id).delete();
    } catch (e) {
      debugPrint('QuestionPaperService delete Firestore error: $e');
    }
    _inMemoryCustomPapers.removeWhere((p) => p.id == id);
  }

  /// Increment download count
  Future<void> incrementDownloadCount(String id) async {
    try {
      await _firestore.collection('question_papers').doc(id).update({
        'downloadCount': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('QuestionPaperService download increment error: $e');
    }

    final index = _inMemoryCustomPapers.indexWhere((p) => p.id == id);
    if (index != -1) {
      final current = _inMemoryCustomPapers[index];
      _inMemoryCustomPapers[index] = current.copyWith(downloadCount: current.downloadCount + 1);
    }
  }

  // --- Helpers ---
  String _normalize(String val) {
    return val.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  String _normalizeSemester(String sem) {
    final match = RegExp(r'\d+').firstMatch(sem);
    if (match != null) {
      return 'semester_${match.group(0)}';
    }
    return sem.toLowerCase().replaceAll(' ', '_');
  }

  /// Pre-seeded database of Anna University / Autonomous PYQ Papers & Solved Question Banks
  List<QuestionPaperModel> _getBuiltInQuestionPapers() {
    return [
      // 1. Data Structures - University PYQ Nov/Dec 2024 (Solved)
      QuestionPaperModel(
        id: 'qp_cs3301_nov2024',
        title: 'Data Structures - University End Semester Examination',
        subjectCode: 'CS3301',
        subjectName: 'Data Structures',
        department: 'Computer Science & Engineering',
        regulation: 'Regulation 2021',
        year: 'II Year',
        semester: 'Semester 3',
        academicYear: '2024–2025',
        examSession: 'Nov / Dec 2024',
        paperType: QuestionPaperType.universityPyq,
        hasAnswerKey: true,
        fileUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        fileName: 'CS3301_DataStructures_NovDec2024_University_QP.pdf',
        fileSize: '3.2 MB',
        answerKeyUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        answerKeyFileName: 'CS3301_DataStructures_NovDec2024_AnswerKey_Solved.pdf',
        answerKeyFileSize: '4.8 MB',
        uploadedByStaffId: 'staff_cse_01',
        uploadedByStaffName: 'Dr. S. Ramanathan, M.E., Ph.D.',
        uploadedByStaffDesignation: 'Professor & Head · CSE',
        uploadedAt: DateTime(2025, 1, 15),
        downloadCount: 342,
        isVerified: true,
        tags: ['Anna University', 'Solved Solutions', 'Trees & Graphs', 'B-Tree & AVL'],
      ),

      // 2. Data Structures - 2-Marks & 16-Marks Solved Question Bank (All 5 Units)
      QuestionPaperModel(
        id: 'qb_cs3301_all_units',
        title: 'Data Structures - Comprehensive 2-Mark & 16-Mark Question Bank with Model Answers',
        subjectCode: 'CS3301',
        subjectName: 'Data Structures',
        department: 'Computer Science & Engineering',
        regulation: 'Regulation 2021',
        year: 'II Year',
        semester: 'Semester 3',
        academicYear: '2024–2025',
        examSession: 'Academic Year 2024–2025',
        paperType: QuestionPaperType.questionBankWithSolutions,
        hasAnswerKey: true,
        fileUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        fileName: 'CS3301_Complete_5Units_QuestionBank_With_Solutions.pdf',
        fileSize: '6.5 MB',
        answerKeyUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        answerKeyFileName: 'CS3301_Complete_5Units_QuestionBank_With_Solutions.pdf',
        answerKeyFileSize: '6.5 MB',
        uploadedByStaffId: 'staff_cse_02',
        uploadedByStaffName: 'Prof. K. Meenakshi, M.Tech.',
        uploadedByStaffDesignation: 'Assistant Professor · CSE',
        uploadedAt: DateTime(2024, 11, 10),
        downloadCount: 512,
        isVerified: true,
        tags: ['Full 5 Units', '16 Mark Repeated', '2 Mark Definitions', 'Algorithm Traces'],
      ),

      // 3. Object Oriented Programming - University PYQ Apr/May 2024 (Solved)
      QuestionPaperModel(
        id: 'qp_cs3391_apr2024',
        title: 'Object Oriented Programming - University End Semester Exam',
        subjectCode: 'CS3391',
        subjectName: 'Object Oriented Programming',
        department: 'Computer Science & Engineering',
        regulation: 'Regulation 2021',
        year: 'II Year',
        semester: 'Semester 3',
        academicYear: '2023–2024',
        examSession: 'Apr / May 2024',
        paperType: QuestionPaperType.universityPyq,
        hasAnswerKey: true,
        fileUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        fileName: 'CS3391_OOP_AprMay2024_QP.pdf',
        fileSize: '2.8 MB',
        answerKeyUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        answerKeyFileName: 'CS3391_OOP_AprMay2024_Official_Key.pdf',
        answerKeyFileSize: '3.9 MB',
        uploadedByStaffId: 'staff_cse_03',
        uploadedByStaffName: 'Dr. V. Rajesh, Ph.D.',
        uploadedByStaffDesignation: 'Associate Professor · CSE',
        uploadedAt: DateTime(2024, 6, 20),
        downloadCount: 278,
        isVerified: true,
        tags: ['Java OOP', 'Polymorphism', 'Exception Handling', 'Multithreading'],
      ),

      // 4. Digital Principles & Computer Organization - IAT-1 Solved Model
      QuestionPaperModel(
        id: 'qp_cs3351_iat1',
        title: 'Digital Principles & Computer Organization - Internal Assessment Test 1 (IAT-1)',
        subjectCode: 'CS3351',
        subjectName: 'Digital Principles and Computer Organization',
        department: 'Computer Science & Engineering',
        regulation: 'Regulation 2021',
        year: 'II Year',
        semester: 'Semester 3',
        academicYear: '2024–2025',
        examSession: 'Sep / Oct 2024',
        paperType: QuestionPaperType.internalAssessment1,
        hasAnswerKey: true,
        fileUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        fileName: 'CS3351_DPCO_IAT1_QP_2024.pdf',
        fileSize: '1.9 MB',
        answerKeyUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        answerKeyFileName: 'CS3351_DPCO_IAT1_Answer_Key.pdf',
        answerKeyFileSize: '2.5 MB',
        uploadedByStaffId: 'staff_ece_01',
        uploadedByStaffName: 'Prof. Anitha Subramanian',
        uploadedByStaffDesignation: 'Assistant Professor · ECE',
        uploadedAt: DateTime(2024, 10, 5),
        downloadCount: 195,
        isVerified: true,
        tags: ['K-Map', 'Combinational Circuits', 'Adders & Subtractors', 'Unit 1 & 2'],
      ),

      // 5. Discrete Mathematics - Model Exam Paper with Step-by-Step Solutions
      QuestionPaperModel(
        id: 'qp_ma3354_model',
        title: 'Discrete Mathematics - Pre-Semester Model Examination',
        subjectCode: 'MA3354',
        subjectName: 'Discrete Mathematics',
        department: 'Computer Science & Engineering',
        regulation: 'Regulation 2021',
        year: 'II Year',
        semester: 'Semester 3',
        academicYear: '2024–2025',
        examSession: 'Nov / Dec 2024',
        paperType: QuestionPaperType.modelExam,
        hasAnswerKey: true,
        fileUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        fileName: 'MA3354_DiscreteMaths_ModelExam2024.pdf',
        fileSize: '3.1 MB',
        answerKeyUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        answerKeyFileName: 'MA3354_DiscreteMaths_ModelExam_StepByStepKey.pdf',
        answerKeyFileSize: '5.2 MB',
        uploadedByStaffId: 'staff_math_01',
        uploadedByStaffName: 'Dr. G. Balachandran',
        uploadedByStaffDesignation: 'Professor · Mathematics Department',
        uploadedAt: DateTime(2024, 11, 28),
        downloadCount: 420,
        isVerified: true,
        tags: ['Propositional Logic', 'Combinatorics', 'Graph Theory', 'Groups & Rings'],
      ),

      // 6. Database Management Systems - University End Semester Exam Nov/Dec 2023
      QuestionPaperModel(
        id: 'qp_cs3492_nov2023',
        title: 'Database Management Systems - University End Semester Examination',
        subjectCode: 'CS3492',
        subjectName: 'Database Management Systems',
        department: 'Computer Science & Engineering',
        regulation: 'Regulation 2021',
        year: 'II Year',
        semester: 'Semester 4',
        academicYear: '2023–2024',
        examSession: 'Nov / Dec 2023',
        paperType: QuestionPaperType.universityPyq,
        hasAnswerKey: true,
        fileUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        fileName: 'CS3492_DBMS_NovDec2023_University_QP.pdf',
        fileSize: '2.5 MB',
        answerKeyUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        answerKeyFileName: 'CS3492_DBMS_NovDec2023_Solved_Solutions.pdf',
        answerKeyFileSize: '4.1 MB',
        uploadedByStaffId: 'staff_cse_01',
        uploadedByStaffName: 'Dr. S. Ramanathan, M.E., Ph.D.',
        uploadedByStaffDesignation: 'Professor & Head · CSE',
        uploadedAt: DateTime(2024, 1, 10),
        downloadCount: 389,
        isVerified: true,
        tags: ['SQL Queries', 'Normalization (BCNF/3NF)', 'Transaction ACID', 'Indexing B+ Trees'],
      ),

      // 7. Operating Systems - 2-Marks & 16-Marks Question Bank
      QuestionPaperModel(
        id: 'qb_cs3451_os',
        title: 'Operating Systems - Important 16-Marks & 2-Marks Question Bank with Code',
        subjectCode: 'CS3451',
        subjectName: 'Operating Systems',
        department: 'Computer Science & Engineering',
        regulation: 'Regulation 2021',
        year: 'II Year',
        semester: 'Semester 4',
        academicYear: '2024–2025',
        examSession: 'Apr / May 2024',
        paperType: QuestionPaperType.questionBankWithSolutions,
        hasAnswerKey: true,
        fileUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        fileName: 'CS3451_OS_Full_Syllabus_QuestionBank.pdf',
        fileSize: '5.8 MB',
        answerKeyUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        answerKeyFileName: 'CS3451_OS_Full_Syllabus_QuestionBank.pdf',
        answerKeyFileSize: '5.8 MB',
        uploadedByStaffId: 'staff_cse_04',
        uploadedByStaffName: 'Prof. N. Karthikeyan',
        uploadedByStaffDesignation: 'Assistant Professor · CSE',
        uploadedAt: DateTime(2024, 4, 12),
        downloadCount: 310,
        isVerified: true,
        tags: ['Process Scheduling', 'Deadlocks Banker Algorithm', 'Paging & Segmentation', 'Disk Scheduling'],
      ),

      // 8. Artificial Intelligence & Machine Learning - University PYQ Nov/Dec 2024
      QuestionPaperModel(
        id: 'qp_ai3501_nov2024',
        title: 'Artificial Intelligence & Machine Learning - University End Semester Exam',
        subjectCode: 'AI3501',
        subjectName: 'Artificial Intelligence and Machine Learning',
        department: 'Artificial Intelligence & Data Science',
        regulation: 'Regulation 2021',
        year: 'III Year',
        semester: 'Semester 5',
        academicYear: '2024–2025',
        examSession: 'Nov / Dec 2024',
        paperType: QuestionPaperType.universityPyq,
        hasAnswerKey: true,
        fileUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        fileName: 'AI3501_AIML_NovDec2024_QP.pdf',
        fileSize: '3.4 MB',
        answerKeyUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        answerKeyFileName: 'AI3501_AIML_NovDec2024_Key_Solved.pdf',
        answerKeyFileSize: '4.9 MB',
        uploadedByStaffId: 'staff_aids_01',
        uploadedByStaffName: 'Dr. M. Soundararajan',
        uploadedByStaffDesignation: 'Professor · AI & DS',
        uploadedAt: DateTime(2025, 1, 8),
        downloadCount: 467,
        isVerified: true,
        tags: ['A* Search', 'Alpha-Beta Pruning', 'SVM & Neural Networks', 'Decision Trees'],
      ),

      // 9. Python Programming for Problem Solving - Semester 1 Solved PYQ
      QuestionPaperModel(
        id: 'qp_ge3151_nov2024',
        title: 'Problem Solving and Python Programming - University End Semester Exam',
        subjectCode: 'GE3151',
        subjectName: 'Problem Solving and Python Programming',
        department: 'Common to All Branches',
        regulation: 'Regulation 2021',
        year: 'I Year',
        semester: 'Semester 1',
        academicYear: '2024–2025',
        examSession: 'Jan / Feb 2025',
        paperType: QuestionPaperType.universityPyq,
        hasAnswerKey: true,
        fileUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        fileName: 'GE3151_Python_Jan2025_QP.pdf',
        fileSize: '2.1 MB',
        answerKeyUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        answerKeyFileName: 'GE3151_Python_Jan2025_AnswerKey.pdf',
        answerKeyFileSize: '3.5 MB',
        uploadedByStaffId: 'staff_cse_02',
        uploadedByStaffName: 'Prof. K. Meenakshi, M.Tech.',
        uploadedByStaffDesignation: 'Assistant Professor · CSE',
        uploadedAt: DateTime(2025, 2, 5),
        downloadCount: 620,
        isVerified: true,
        tags: ['Python Control Flow', 'Lists Tuples Dicts', 'File Handling', 'Exceptions'],
      ),

      // 10. Matrices and Calculus - Semester 1 Question Bank
      QuestionPaperModel(
        id: 'qb_ma3151_full',
        title: 'Matrices and Calculus - Question Bank with Solved Numerical Problems',
        subjectCode: 'MA3151',
        subjectName: 'Matrices and Calculus',
        department: 'Common to All Branches',
        regulation: 'Regulation 2021',
        year: 'I Year',
        semester: 'Semester 1',
        academicYear: '2024–2025',
        examSession: 'Jan / Feb 2025',
        paperType: QuestionPaperType.questionBankWithSolutions,
        hasAnswerKey: true,
        fileUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        fileName: 'MA3151_Matrices_Calculus_QuestionBank_Solutions.pdf',
        fileSize: '7.2 MB',
        answerKeyUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        answerKeyFileName: 'MA3151_Matrices_Calculus_QuestionBank_Solutions.pdf',
        answerKeyFileSize: '7.2 MB',
        uploadedByStaffId: 'staff_math_01',
        uploadedByStaffName: 'Dr. G. Balachandran',
        uploadedByStaffDesignation: 'Professor · Mathematics',
        uploadedAt: DateTime(2024, 12, 1),
        downloadCount: 540,
        isVerified: true,
        tags: ['Eigenvalues & Cayley-Hamilton', 'Double Integrals', 'Taylor Series', 'Partial Derivatives'],
      ),
    ];
  }
}
