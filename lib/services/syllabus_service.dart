import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:unisphere/models/syllabus_model.dart';

class SyllabusService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Helper to extract integer start year from academic year string (e.g. "2026–2027" -> 2026)
  static int parseStartYear(String acYear) {
    final match = RegExp(r'\d{4}').firstMatch(acYear);
    if (match != null) {
      return int.tryParse(match.group(0)!) ?? 2026;
    }
    return 2026;
  }

  /// Fetch published syllabus records for students.
  /// Strictly filters out future syllabus records (effectiveStartYear > studentCurrentStartYear)
  /// and draft records (status != 'published').
  Future<List<SyllabusSubjectModel>> getStudentSyllabus({
    required String department,
    required String studentAcademicYear, // e.g. "2026–2027"
    String? year,
    String? semester,
    bool includePreviousYears = true,
  }) async {
    final studentStartYear = parseStartYear(studentAcademicYear);
    final normalizedDept = _normalizeDepartment(department);

    try {
      // Query Firestore for published syllabus records
      final snapshot = await _firestore
          .collection('syllabi')
          .where('status', isEqualTo: 'published')
          .get();

      if (snapshot.docs.isNotEmpty) {
        final allPublished = snapshot.docs.map((doc) {
          return SyllabusSubjectModel.fromMap(doc.data(), doc.id);
        }).toList();

        final filtered = allPublished.where((s) {
          // Rule 1: Must be published
          if (!s.isPublished) return false;

          // Rule 2: SECURITY & VISIBILITY: NEVER return future syllabus
          if (s.effectiveStartYear > studentStartYear) return false;

          // Rule 3: Department check
          final matchesDept = s.department.isEmpty ||
              s.department.toLowerCase() == 'all' ||
              _normalizeDepartment(s.department) == normalizedDept;
          if (!matchesDept) return false;

          // Rule 4: Previous vs Current filtering option
          if (!includePreviousYears && s.effectiveStartYear < studentStartYear) {
            return false;
          }

          // Rule 5: Optional year/sem match
          if (year != null && year.isNotEmpty && _normalizeYear(s.year) != _normalizeYear(year)) {
            return false;
          }
          if (semester != null && semester.isNotEmpty && _normalizeSemester(s.semester) != _normalizeSemester(semester)) {
            return false;
          }

          return true;
        }).toList();

        if (filtered.isNotEmpty) {
          return filtered;
        }
      }
    } catch (e) {
      debugPrint('SyllabusService error loading from Firestore: $e');
    }

    // Fallback to built-in syllabus repository
    final builtIn = _getBuiltInSyllabusDatabase(department);
    return builtIn.where((s) {
      // Must be published
      if (!s.isPublished) return false;

      // STRICT SECURITY RULE: effectiveStartYear MUST BE <= studentStartYear
      if (s.effectiveStartYear > studentStartYear) return false;

      final matchesDept = s.department.isEmpty ||
          s.department.toLowerCase() == 'all' ||
          _normalizeDepartment(s.department) == normalizedDept;
      if (!matchesDept) return false;

      if (!includePreviousYears && s.effectiveStartYear < studentStartYear) {
        return false;
      }

      if (year != null && year.isNotEmpty && _normalizeYear(s.year) != _normalizeYear(year)) {
        return false;
      }
      if (semester != null && semester.isNotEmpty && _normalizeSemester(s.semester) != _normalizeSemester(semester)) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Fetch HOD/Admin syllabus records (includes Current, Previous, Future, Draft, and Published).
  Future<List<SyllabusSubjectModel>> getHODAllSyllabi({
    required String department,
  }) async {
    final normalizedDept = _normalizeDepartment(department);
    try {
      final snapshot = await _firestore.collection('syllabi').get();
      if (snapshot.docs.isNotEmpty) {
        final allDocs = snapshot.docs
            .map((doc) => SyllabusSubjectModel.fromMap(doc.data(), doc.id))
            .where((s) => s.department.isEmpty || s.department.toLowerCase() == 'all' || _normalizeDepartment(s.department) == normalizedDept)
            .toList();
        if (allDocs.isNotEmpty) return allDocs;
      }
    } catch (e) {
      debugPrint('SyllabusService error loading HOD records: $e');
    }
    return _getBuiltInSyllabusDatabase(department);
  }

  /// Add a new subject record to Firestore syllabi collection
  Future<bool> createSubject(SyllabusSubjectModel subject) async {
    try {
      final docRef = _firestore.collection('syllabi').doc(subject.id.isNotEmpty ? subject.id : null);
      final finalSubject = SyllabusSubjectModel(
        id: docRef.id,
        subjectCode: subject.subjectCode,
        subjectName: subject.subjectName,
        department: subject.department,
        applicableBatch: subject.applicableBatch,
        year: subject.year,
        semester: subject.semester,
        academicYear: subject.academicYear,
        effectiveStartYear: subject.effectiveStartYear,
        credits: subject.credits,
        subjectType: subject.subjectType,
        description: subject.description,
        units: subject.units,
        textbooks: subject.textbooks,
        referenceBooks: subject.referenceBooks,
        documentUrl: subject.documentUrl,
        documentFileName: subject.documentFileName,
        documentSize: subject.documentSize,
        effectiveFrom: subject.effectiveFrom,
        lastUpdated: DateTime.now(),
        status: subject.status,
        uploadedBy: subject.uploadedBy,
        uploadedAt: DateTime.now(),
      );

      await docRef.set(finalSubject.toMap(), SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint('SyllabusService createSubject error: $e');
      return false;
    }
  }

  /// Update existing subject record in Firestore syllabi collection
  Future<bool> updateSubject(SyllabusSubjectModel subject) async {
    try {
      if (subject.id.isEmpty) return false;
      final updatedSubject = SyllabusSubjectModel(
        id: subject.id,
        subjectCode: subject.subjectCode,
        subjectName: subject.subjectName,
        department: subject.department,
        applicableBatch: subject.applicableBatch,
        year: subject.year,
        semester: subject.semester,
        academicYear: subject.academicYear,
        effectiveStartYear: subject.effectiveStartYear,
        credits: subject.credits,
        subjectType: subject.subjectType,
        description: subject.description,
        units: subject.units,
        textbooks: subject.textbooks,
        referenceBooks: subject.referenceBooks,
        documentUrl: subject.documentUrl,
        documentFileName: subject.documentFileName,
        documentSize: subject.documentSize,
        effectiveFrom: subject.effectiveFrom,
        lastUpdated: DateTime.now(),
        status: subject.status,
        uploadedBy: subject.uploadedBy,
        uploadedAt: subject.uploadedAt,
      );

      await _firestore.collection('syllabi').doc(subject.id).set(updatedSubject.toMap(), SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint('SyllabusService updateSubject error: $e');
      return false;
    }
  }

  /// Delete subject record from Firestore syllabi collection
  Future<bool> deleteSubject(String subjectId) async {
    try {
      if (subjectId.isEmpty) return false;
      await _firestore.collection('syllabi').doc(subjectId).delete();
      return true;
    } catch (e) {
      debugPrint('SyllabusService deleteSubject error: $e');
      return false;
    }
  }

  /// Toggle or update publish status ('published' vs 'draft')
  Future<bool> updateSubjectStatus(String subjectId, String newStatus) async {
    try {
      if (subjectId.isEmpty) return false;
      await _firestore.collection('syllabi').doc(subjectId).update({
        'status': newStatus,
        'lastUpdated': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('SyllabusService updateSubjectStatus error: $e');
      return false;
    }
  }

  /// Check if a subject code already exists within the same academic year and semester for a department
  Future<bool> isDuplicateSubjectCode({
    required String subjectCode,
    required String academicYear,
    required String semester,
    required String department,
    String? currentId,
  }) async {
    try {
      final snapshot = await _firestore.collection('syllabi').get();
      final normCode = subjectCode.trim().toLowerCase();
      final normAcYear = academicYear.trim().toLowerCase();
      final normSem = _normalizeSemester(semester);
      final normDept = _normalizeDepartment(department);

      for (var doc in snapshot.docs) {
        if (currentId != null && doc.id == currentId) continue;
        final data = doc.data();
        final cCode = (data['subjectCode'] ?? data['subject_code'] ?? '').toString().trim().toLowerCase();
        final cAcYear = (data['academicYear'] ?? data['academic_year'] ?? '').toString().trim().toLowerCase();
        final cSem = _normalizeSemester((data['semester'] ?? '').toString());
        final cDept = _normalizeDepartment((data['department'] ?? '').toString());

        if (cCode == normCode && cAcYear == normAcYear && cSem == normSem && cDept == normDept) {
          return true;
        }
      }
    } catch (e) {
      debugPrint('SyllabusService isDuplicateSubjectCode error: $e');
    }
    return false;
  }

  String _normalizeDepartment(String dept) {
    final lower = dept.toLowerCase().trim();
    if (lower.contains('cse') || lower.contains('computer science')) {
      return 'computer science & engineering';
    } else if (lower.contains('ece') || lower.contains('electronics')) {
      return 'electronics & communication engineering';
    } else if (lower.contains('eee') || lower.contains('electrical')) {
      return 'electrical & electronics engineering';
    } else if (lower.contains('mech') || lower.contains('mechanical')) {
      return 'mechanical engineering';
    } else if (lower.contains('it') || lower.contains('information tech')) {
      return 'information technology';
    }
    return lower;
  }

  String _normalizeYear(String yearStr) {
    final s = yearStr.trim().toLowerCase();
    if (s.contains('1st') || s.contains('i year') || s.contains('year 1') || s == '1' || s == 'i') {
      return 'I Year';
    } else if (s.contains('2nd') || s.contains('ii year') || s.contains('year 2') || s == '2' || s == 'ii') {
      return 'II Year';
    } else if (s.contains('3rd') || s.contains('iii year') || s.contains('year 3') || s == '3' || s == 'iii') {
      return 'III Year';
    } else if (s.contains('4th') || s.contains('iv year') || s.contains('year 4') || s == '4' || s == 'iv') {
      return 'IV Year';
    }
    return 'I Year';
  }

  String _normalizeSemester(String semStr) {
    final s = semStr.trim().toLowerCase();
    final numMatch = RegExp(r'\d+').firstMatch(s);
    if (numMatch != null) {
      return 'Semester ${numMatch.group(0)}';
    }
    return 'Semester 1';
  }

  /// Built-in dataset containing Current (2026–2027), Previous (2025–2026, 2024–2025), and Future (2027–2028) records
  List<SyllabusSubjectModel> _getBuiltInSyllabusDatabase(String department) {
    final deptName = department.isNotEmpty ? department : 'Computer Science & Engineering';

    return [
      // ─────────────────────────────────────────
      // CURRENT SYLLABUS (2026–2027)
      // ─────────────────────────────────────────
      SyllabusSubjectModel(
        id: 'SYLL-2026-CS101',
        subjectCode: 'CS101',
        subjectName: 'Programming in C',
        department: deptName,
        applicableBatch: '2026–2030',
        year: 'I Year',
        semester: 'Semester 1',
        academicYear: '2026–2027',
        effectiveStartYear: 2026,
        credits: 4,
        subjectType: 'Theory',
        description: 'Fundamental programming constructs, data types, control flow, functions, arrays, pointers, structures, file operations, and algorithmic logic in C language.',
        units: [
          SyllabusUnitModel(
            unitNumber: 'Unit I',
            title: 'C Language Fundamentals & Data Types',
            topics: ['Algorithm & Flowcharts', 'Structure of C Program', 'Variables & Data Types', 'Operators & Expressions', 'Input/Output Statements'],
          ),
          SyllabusUnitModel(
            unitNumber: 'Unit II',
            title: 'Control Flow & Decision Statements',
            topics: ['if-else Statements', 'switch-case Statements', 'while & do-while Loops', 'for Loops & Nested Loops', 'break, continue & goto'],
          ),
          SyllabusUnitModel(
            unitNumber: 'Unit III',
            title: 'Arrays, Strings & User-defined Functions',
            topics: ['Single & Multi-dimensional Arrays', 'String Manipulation', 'Function Prototypes', 'Pass by Value & Reference', 'Recursion'],
          ),
          SyllabusUnitModel(
            unitNumber: 'Unit IV',
            title: 'Pointers & Dynamic Memory Management',
            topics: ['Pointer Arithmetic', 'Pointers to Arrays & Functions', 'Dynamic Memory Allocation (malloc, calloc, realloc, free)'],
          ),
          SyllabusUnitModel(
            unitNumber: 'Unit V',
            title: 'Structures, Unions & File Handling',
            topics: ['Defining Structures & Unions', 'Array of Structures', 'File Pointers & Modes', 'Sequential & Random File Access'],
          ),
        ],
        textbooks: ['Programming in ANSI C (8th Edition) by E. Balagurusamy, McGraw Hill'],
        referenceBooks: ['The C Programming Language (2nd Edition) by Kernighan and Ritchie, Prentice Hall'],
        documentUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        documentFileName: 'CS101_Programming_in_C_2026-27.pdf',
        documentSize: '2.4 MB',
        lastUpdated: DateTime(2026, 8, 1),
        status: 'published',
      ),
      SyllabusSubjectModel(
        id: 'SYLL-2026-MA101',
        subjectCode: 'MA101',
        subjectName: 'Mathematics I: Calculus & Linear Algebra',
        department: deptName,
        applicableBatch: '2026–2030',
        year: 'I Year',
        semester: 'Semester 1',
        academicYear: '2026–2027',
        effectiveStartYear: 2026,
        credits: 4,
        subjectType: 'Theory',
        description: 'Matrix algebra, eigenvalues, multivariable calculus, partial derivatives, double and triple integrals, and vector calculus.',
        units: [
          SyllabusUnitModel(
            unitNumber: 'Unit I',
            title: 'Matrices & Linear Systems',
            topics: ['Rank of a Matrix', 'System of Linear Equations', 'Eigenvalues & Eigenvectors', 'Cayley-Hamilton Theorem'],
          ),
        ],
        textbooks: ['Higher Engineering Mathematics (44th Edition) by B.S. Grewal'],
        referenceBooks: ['Advanced Engineering Mathematics (10th Edition) by Erwin Kreyszig'],
        documentUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        documentFileName: 'MA101_Mathematics_I_2026-27.pdf',
        documentSize: '3.1 MB',
        lastUpdated: DateTime(2026, 8, 2),
        status: 'published',
      ),
      SyllabusSubjectModel(
        id: 'SYLL-2026-CS103',
        subjectCode: 'CS103',
        subjectName: 'Data Structures & Algorithms',
        department: deptName,
        applicableBatch: '2026–2030',
        year: 'I Year',
        semester: 'Semester 2',
        academicYear: '2026–2027',
        effectiveStartYear: 2026,
        credits: 4,
        subjectType: 'Theory',
        description: 'Arrays, linked lists, stacks, queues, trees, binary search trees, heaps, graphs, hashing, and time/space complexity analysis.',
        units: [
          SyllabusUnitModel(
            unitNumber: 'Unit I',
            title: 'Linear Data Structures',
            topics: ['Stacks & Queues', 'Linked Lists', 'Polynomial Addition'],
          ),
        ],
        textbooks: ['Data Structures and Algorithm Analysis in C by Mark Allen Weiss'],
        referenceBooks: ['Fundamentals of Data Structures in C by Horowitz and Sahni'],
        documentUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        documentFileName: 'CS103_Data_Structures_2026-27.pdf',
        documentSize: '2.8 MB',
        lastUpdated: DateTime(2026, 8, 10),
        status: 'published',
      ),

      // ─────────────────────────────────────────
      // PREVIOUS SYLLABUS (2025–2026)
      // ─────────────────────────────────────────
      SyllabusSubjectModel(
        id: 'SYLL-2025-CS101',
        subjectCode: 'CS101-R25',
        subjectName: 'Fundamentals of Computing & C',
        department: deptName,
        applicableBatch: '2025–2029',
        year: 'I Year',
        semester: 'Semester 1',
        academicYear: '2025–2026',
        effectiveStartYear: 2025,
        credits: 4,
        subjectType: 'Theory',
        description: 'Previous regulation (R25) syllabus covering computer logic, problem solving, flowcharts, and C programming fundamentals.',
        units: [
          SyllabusUnitModel(
            unitNumber: 'Unit I',
            title: 'Introduction to Computers & C',
            topics: ['Computer Hardware & Software', 'Algorithms & Flowcharts', 'C Program Architecture'],
          ),
        ],
        textbooks: ['Computer Fundamentals & C Programming by E. Balagurusamy'],
        referenceBooks: ['C How to Program by Paul Deitel & Harvey Deitel'],
        documentUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        documentFileName: 'CS101_C_Programming_2025-26_Archive.pdf',
        documentSize: '2.1 MB',
        lastUpdated: DateTime(2025, 7, 15),
        status: 'published',
      ),
      SyllabusSubjectModel(
        id: 'SYLL-2025-CS103',
        subjectCode: 'CS103-R25',
        subjectName: 'Basic Data Structures',
        department: deptName,
        applicableBatch: '2025–2029',
        year: 'I Year',
        semester: 'Semester 2',
        academicYear: '2025–2026',
        effectiveStartYear: 2025,
        credits: 4,
        subjectType: 'Theory',
        description: 'Previous regulation (R25) syllabus covering stacks, queues, linked lists, and basic sorting algorithms.',
        units: [
          SyllabusUnitModel(
            unitNumber: 'Unit I',
            title: 'Arrays & Stacks',
            topics: ['Array Operations', 'Stack Implementation using Arrays'],
          ),
        ],
        textbooks: ['Data Structures using C by Reema Thareja'],
        referenceBooks: ['Data Structures by Seymour Lipschutz'],
        documentUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        documentFileName: 'CS103_Data_Structures_2025-26_Archive.pdf',
        documentSize: '2.5 MB',
        lastUpdated: DateTime(2025, 7, 20),
        status: 'published',
      ),

      // ─────────────────────────────────────────
      // PREVIOUS SYLLABUS (2024–2025)
      // ─────────────────────────────────────────
      SyllabusSubjectModel(
        id: 'SYLL-2024-CS101',
        subjectCode: 'CS101-R24',
        subjectName: 'Problem Solving & Programming',
        department: deptName,
        applicableBatch: '2024–2028',
        year: 'I Year',
        semester: 'Semester 1',
        academicYear: '2024–2025',
        effectiveStartYear: 2024,
        credits: 4,
        subjectType: 'Theory',
        description: 'Legacy regulation (R24) syllabus for first year computer science students.',
        units: [
          SyllabusUnitModel(
            unitNumber: 'Unit I',
            title: 'Problem Solving Logic',
            topics: ['Pseudocode Development', 'Control Structures'],
          ),
        ],
        textbooks: ['Problem Solving and Program Design in C by Hanly & Koffman'],
        referenceBooks: ['Programming in C by Byron Gottfried'],
        documentUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        documentFileName: 'CS101_Problem_Solving_2024-25_Archive.pdf',
        documentSize: '1.9 MB',
        lastUpdated: DateTime(2024, 7, 10),
        status: 'published',
      ),

      // ─────────────────────────────────────────
      // FUTURE SYLLABUS (2027–2028) -> MUST NOT SHOW TO STUDENTS
      // ─────────────────────────────────────────
      SyllabusSubjectModel(
        id: 'SYLL-2027-CS101',
        subjectCode: 'CS101-R27',
        subjectName: 'AI-Assisted Systems & Modern C++',
        department: deptName,
        applicableBatch: '2027–2031',
        year: 'I Year',
        semester: 'Semester 1',
        academicYear: '2027–2028',
        effectiveStartYear: 2027,
        credits: 4,
        subjectType: 'Theory',
        description: 'Future regulation syllabus incorporating AI tools and modern C++23 standards for upcoming 2027 batch.',
        units: [
          SyllabusUnitModel(
            unitNumber: 'Unit I',
            title: 'Modern C++ Foundations',
            topics: ['C++23 Syntax', 'Smart Pointers', 'RAII Pattern'],
          ),
        ],
        textbooks: ['C++ Primer (6th Edition) by Stanley B. Lippman'],
        referenceBooks: ['The C++ Programming Language (4th Edition) by Bjarne Stroustrup'],
        documentUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
        documentFileName: 'CS101_Modern_CPP_2027-28_Future.pdf',
        documentSize: '3.4 MB',
        lastUpdated: DateTime(2026, 8, 15),
        status: 'published', // Published in DB for HOD preparation, but FUTURE for students!
      ),
    ];
  }
}
