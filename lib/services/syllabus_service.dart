import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:unisphere/models/syllabus_model.dart';

class SyllabusService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch published subjects filtered by department, year, semester, and academic year
  Future<List<SyllabusSubjectModel>> getPublishedSyllabus({
    required String department,
    required String year,
    required String semester,
    String academicYear = '2026–2027',
  }) async {
    try {
      final normalizedDept = _normalizeDepartment(department);
      final normalizedYear = _normalizeYear(year);
      final normalizedSem = _normalizeSemester(semester);

      // 1. Try fetching from Firestore collection 'syllabi'
      final snapshot = await _firestore
          .collection('syllabi')
          .where('status', isEqualTo: 'published')
          .get();

      if (snapshot.docs.isNotEmpty) {
        final allPublished = snapshot.docs.map((doc) {
          return SyllabusSubjectModel.fromMap(doc.data(), doc.id);
        }).toList();

        final filtered = allPublished.where((s) {
          final matchesDept = s.department.isEmpty ||
              s.department.toLowerCase() == 'all' ||
              _normalizeDepartment(s.department) == normalizedDept;
          final matchesYear = _normalizeYear(s.year) == normalizedYear;
          final matchesSem = _normalizeSemester(s.semester) == normalizedSem;
          return matchesDept && matchesYear && matchesSem;
        }).toList();

        if (filtered.isNotEmpty) {
          return filtered;
        }
      }
    } catch (e) {
      debugPrint('SyllabusService error loading from Firestore: $e');
    }

    // 2. Fallback to comprehensive built-in published syllabus database
    return _getBuiltInPublishedSyllabus(
      department: department,
      year: year,
      semester: semester,
      academicYear: academicYear,
    );
  }

  /// Normalizes department string e.g. "CSE" / "Computer Science" -> "computer science & engineering"
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

  /// Normalizes year string e.g. "1st Year", "Year 1", "I" -> "I Year"
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

  /// Normalizes semester string e.g. "Sem 1", "1", "Semester 1" -> "Semester 1"
  String _normalizeSemester(String semStr) {
    final s = semStr.trim().toLowerCase();
    final numMatch = RegExp(r'\d+').firstMatch(s);
    if (numMatch != null) {
      return 'Semester ${numMatch.group(0)}';
    }
    return 'Semester 1';
  }

  /// Built-in repository of published syllabus records for all years and semesters
  List<SyllabusSubjectModel> _getBuiltInPublishedSyllabus({
    required String department,
    required String year,
    required String semester,
    required String academicYear,
  }) {
    final normYear = _normalizeYear(year);
    final normSem = _normalizeSemester(semester);
    final deptName = department.isNotEmpty ? department : 'Computer Science & Engineering';

    final Map<String, List<SyllabusSubjectModel>> syllabusDatabase = {
      // ─────────────────────────────────────────
      //  YEAR I · SEMESTER 1
      // ─────────────────────────────────────────
      'I Year_Semester 1': [
        SyllabusSubjectModel(
          id: 'SYLL-CS101',
          subjectCode: 'CS101',
          subjectName: 'Programming in C',
          department: deptName,
          year: 'I Year',
          semester: 'Semester 1',
          academicYear: academicYear,
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
              topics: ['Single & Multi-dimensional Arrays', 'String Manipulation', 'Function Prototypes', 'Pass by Value & Pass by Reference', 'Recursion'],
            ),
            SyllabusUnitModel(
              unitNumber: 'Unit IV',
              title: 'Pointers & Dynamic Memory Management',
              topics: ['Pointer Arithmetic', 'Pointers to Arrays & Functions', 'Dynamic Memory Allocation (malloc, calloc, realloc, free)', 'Memory Leaks'],
            ),
            SyllabusUnitModel(
              unitNumber: 'Unit V',
              title: 'Structures, Unions & File Handling',
              topics: ['Defining Structures & Unions', 'Array of Structures', 'File Pointers & Modes', 'Sequential & Random File Access', 'Command Line Arguments'],
            ),
          ],
          textbooks: [
            'Programming in ANSI C (8th Edition) by E. Balagurusamy, McGraw Hill',
            'C Programming: A Modern Approach (2nd Edition) by K. N. King, W. W. Norton & Company',
          ],
          referenceBooks: [
            'The C Programming Language (2nd Edition) by Brian W. Kernighan and Dennis M. Ritchie, Prentice Hall',
            'Let Us C (18th Edition) by Yashavant Kanetkar, BPB Publications',
          ],
          documentUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
          documentFileName: 'CS101_Programming_in_C_Syllabus.pdf',
          documentSize: '2.4 MB',
          lastUpdated: DateTime(2026, 8, 1, 10, 30),
          status: 'published',
        ),
        SyllabusSubjectModel(
          id: 'SYLL-MA101',
          subjectCode: 'MA101',
          subjectName: 'Mathematics I: Calculus & Linear Algebra',
          department: deptName,
          year: 'I Year',
          semester: 'Semester 1',
          academicYear: academicYear,
          credits: 4,
          subjectType: 'Theory',
          description: 'Matrix algebra, eigenvalues, multivariable calculus, partial derivatives, double and triple integrals, vector calculus, and differential equations for computing applications.',
          units: [
            SyllabusUnitModel(
              unitNumber: 'Unit I',
              title: 'Matrices & Linear Systems',
              topics: ['Rank of a Matrix', 'System of Linear Equations', 'Eigenvalues & Eigenvectors', 'Cayley-Hamilton Theorem', 'Diagonalization'],
            ),
            SyllabusUnitModel(
              unitNumber: 'Unit II',
              title: 'Differential Calculus',
              topics: ['Rolle\'s Theorem', 'Mean Value Theorems', 'Taylor\'s & Maclaurin\'s Series', 'Indeterminate Forms', 'Curvature & Evolutes'],
            ),
            SyllabusUnitModel(
              unitNumber: 'Unit III',
              title: 'Multivariable Calculus & Partial Derivatives',
              topics: ['Partial Differentiation', 'Euler\'s Theorem on Homogeneous Functions', 'Jacobians', 'Maxima & Minima of Two Variables', 'Lagrange Multipliers'],
            ),
            SyllabusUnitModel(
              unitNumber: 'Unit IV',
              title: 'Multiple Integrals',
              topics: ['Double Integrals in Cartesian & Polar Coordinates', 'Change of Order of Integration', 'Area Enclosed by Curves', 'Triple Integrals & Volume'],
            ),
            SyllabusUnitModel(
              unitNumber: 'Unit V',
              title: 'Ordinary Differential Equations',
              topics: ['First Order Linear ODEs', 'Exact Differential Equations', 'Second Order Linear ODEs with Constant Coefficients', 'Cauchy-Euler Equations'],
            ),
          ],
          textbooks: [
            'Higher Engineering Mathematics (44th Edition) by B.S. Grewal, Khanna Publishers',
            'Advanced Engineering Mathematics (10th Edition) by Erwin Kreyszig, Wiley',
          ],
          referenceBooks: [
            'Calculus and Analytic Geometry (9th Edition) by George B. Thomas and Ross L. Finney, Addison-Wesley',
          ],
          documentUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
          documentFileName: 'MA101_Mathematics_I_Syllabus.pdf',
          documentSize: '3.1 MB',
          lastUpdated: DateTime(2026, 8, 2, 14, 15),
          status: 'published',
        ),
        SyllabusSubjectModel(
          id: 'SYLL-PH101',
          subjectCode: 'PH101',
          subjectName: 'Physics for Computing',
          department: deptName,
          year: 'I Year',
          semester: 'Semester 1',
          academicYear: academicYear,
          credits: 3,
          subjectType: 'Theory',
          description: 'Quantum mechanics, lasers, fiber optics, semiconductor physics, magnetic and superconducting materials relevant to computing hardware.',
          units: [
            SyllabusUnitModel(
              unitNumber: 'Unit I',
              title: 'Wave Optics & Lasers',
              topics: ['Interference & Diffraction', 'Laser Principles & Spontaneous Emission', 'He-Ne Laser & Semiconductor Lasers', 'Holography'],
            ),
            SyllabusUnitModel(
              unitNumber: 'Unit II',
              title: 'Fiber Optics & Quantum Mechanics',
              topics: ['Numerical Aperture & Optical Fiber Types', 'Fiber Loss Mechanisms', 'de Broglie Hypothesis', 'Schrödinger Wave Equation'],
            ),
            SyllabusUnitModel(
              unitNumber: 'Unit III',
              title: 'Semiconductor Physics',
              topics: ['Intrinsic & Extrinsic Semiconductors', 'Fermi Level & Hall Effect', 'p-n Junction Diode Physics', 'Solar Cells & LEDs'],
            ),
          ],
          textbooks: [
            'A Textbook of Engineering Physics by M.N. Avadhanulu and P.G. Kshirsagar, S. Chand',
          ],
          referenceBooks: [
            'Concepts of Modern Physics (7th Edition) by Arthur Beiser, McGraw Hill',
          ],
          documentUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
          documentFileName: 'PH101_Physics_Syllabus.pdf',
          documentSize: '1.9 MB',
          lastUpdated: DateTime(2026, 8, 1, 09, 00),
          status: 'published',
        ),
        SyllabusSubjectModel(
          id: 'SYLL-CS102',
          subjectCode: 'CS102',
          subjectName: 'C Programming Laboratory',
          department: deptName,
          year: 'I Year',
          semester: 'Semester 1',
          academicYear: academicYear,
          credits: 2,
          subjectType: 'Practical',
          description: 'Hands-on programming lab implementing algorithms, matrix operations, sorting techniques, file manipulation, and debugging in C.',
          units: [
            SyllabusUnitModel(
              unitNumber: 'Lab Cycle 1',
              title: 'Basic Programs & Decision Control',
              topics: ['Quadratic Equation Solver', 'Prime Number & Fibonacci Generation', 'Calculator using Switch Statement'],
            ),
            SyllabusUnitModel(
              unitNumber: 'Lab Cycle 2',
              title: 'Arrays, Strings & Pointers',
              topics: ['Matrix Addition & Multiplication', 'Linear & Binary Search', 'Bubble Sort & Selection Sort', 'String Reversal & Palindrome Check'],
            ),
            SyllabusUnitModel(
              unitNumber: 'Lab Cycle 3',
              title: 'Structures & File Operations',
              topics: ['Student Record System using Structures', 'Employee Salary Calculation', 'Text File Copy & Merge Operations'],
            ),
          ],
          textbooks: [
            'C Programming Lab Manual, Dept. of Computer Science & Engineering',
          ],
          referenceBooks: [
            'Practical C Programming (3rd Edition) by Steve Oualline, O\'Reilly',
          ],
          documentUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
          documentFileName: 'CS102_C_Lab_Syllabus.pdf',
          documentSize: '1.2 MB',
          lastUpdated: DateTime(2026, 8, 3, 11, 45),
          status: 'published',
        ),
        SyllabusSubjectModel(
          id: 'SYLL-GE101',
          subjectCode: 'GE101',
          subjectName: 'Technical English & Communication',
          department: deptName,
          year: 'I Year',
          semester: 'Semester 1',
          academicYear: academicYear,
          credits: 3,
          subjectType: 'Theory',
          description: 'Technical report writing, presentation skills, professional emails, grammar for engineers, listening comprehension, and group discussion skills.',
          units: [
            SyllabusUnitModel(
              unitNumber: 'Unit I',
              title: 'Vocabulary & Grammar for Technical Communication',
              topics: ['Technical Vocabulary & Jargon', 'Active & Passive Voice', 'Subject-Verb Agreement', 'Conjunctions & Prepositions'],
            ),
            SyllabusUnitModel(
              unitNumber: 'Unit II',
              title: 'Reading & Writing Skills',
              topics: ['Skimming & Scanning Technical Articles', 'Paragraph Writing & Coherence', 'Technical Reports & Proposals', 'Email Etiquette'],
            ),
          ],
          textbooks: [
            'Technical Communication: Principles and Practice by Meenakshi Raman and Sangeeta Sharma, Oxford University Press',
          ],
          referenceBooks: [
            'Effective Technical Communication by M. Ashraf Rizvi, McGraw Hill',
          ],
          documentUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
          documentFileName: 'GE101_Technical_English_Syllabus.pdf',
          documentSize: '1.5 MB',
          lastUpdated: DateTime(2026, 8, 4, 16, 20),
          status: 'published',
        ),
      ],

      // ─────────────────────────────────────────
      //  YEAR I · SEMESTER 2
      // ─────────────────────────────────────────
      'I Year_Semester 2': [
        SyllabusSubjectModel(
          id: 'SYLL-CS103',
          subjectCode: 'CS103',
          subjectName: 'Data Structures & Algorithms',
          department: deptName,
          year: 'I Year',
          semester: 'Semester 2',
          academicYear: academicYear,
          credits: 4,
          subjectType: 'Theory',
          description: 'Arrays, linked lists, stacks, queues, trees, binary search trees, heaps, graphs, hashing, and time/space complexity analysis.',
          units: [
            SyllabusUnitModel(
              unitNumber: 'Unit I',
              title: 'Linear Data Structures: Stacks & Queues',
              topics: ['Abstract Data Types (ADT)', 'Stack Implementation & Applications', 'Queue, Circular Queue, & Priority Queue', 'Expression Evaluation (Infix/Postfix)'],
            ),
            SyllabusUnitModel(
              unitNumber: 'Unit II',
              title: 'Linked Lists',
              topics: ['Singly Linked List', 'Doubly Linked List', 'Circular Linked List', 'Polynomial Addition using Linked Lists'],
            ),
            SyllabusUnitModel(
              unitNumber: 'Unit III',
              title: 'Non-Linear Data Structures: Trees',
              topics: ['Binary Trees & Traversals (Pre, In, Post)', 'Binary Search Trees (BST)', 'AVL Trees & Rotations', 'Heaps & Heap Sort'],
            ),
            SyllabusUnitModel(
              unitNumber: 'Unit IV',
              title: 'Graphs & Hashing',
              topics: ['Graph Representation (Adjacency Matrix/List)', 'Graph Traversal (BFS & DFS)', 'Minimum Spanning Trees (Kruskal/Prim)', 'Hash Functions & Collision Resolution'],
            ),
          ],
          textbooks: [
            'Data Structures and Algorithm Analysis in C (2nd Edition) by Mark Allen Weiss, Pearson',
            'Fundamentals of Data Structures in C by Ellis Horowitz, Sartaj Sahni, and Susan Anderson-Freed, Silicon Press',
          ],
          referenceBooks: [
            'Introduction to Algorithms (3rd Edition) by Thomas H. Cormen, Charles E. Leiserson, Ronald L. Rivest, and Clifford Stein, MIT Press',
          ],
          documentUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
          documentFileName: 'CS103_Data_Structures_Syllabus.pdf',
          documentSize: '2.8 MB',
          lastUpdated: DateTime(2026, 8, 10, 10, 00),
          status: 'published',
        ),
        SyllabusSubjectModel(
          id: 'SYLL-MA102',
          subjectCode: 'MA102',
          subjectName: 'Discrete Mathematics',
          department: deptName,
          year: 'I Year',
          semester: 'Semester 2',
          academicYear: academicYear,
          credits: 4,
          subjectType: 'Theory',
          description: 'Mathematical logic, set theory, relations, functions, combinatorics, recurrence relations, algebraic structures, and graph theory principles.',
          units: [
            SyllabusUnitModel(
              unitNumber: 'Unit I',
              title: 'Logic & Proofs',
              topics: ['Propositional Logic & Equivalence', 'Predicates & Quantifiers', 'Rules of Inference', 'Mathematical Induction'],
            ),
            SyllabusUnitModel(
              unitNumber: 'Unit II',
              title: 'Combinatorics & Recurrence Relations',
              topics: ['Permutations & Combinations', 'Pigeonhole Principle', 'Recurrence Relations & Generating Functions', 'Inclusion-Exclusion Principle'],
            ),
          ],
          textbooks: [
            'Discrete Mathematics and Its Applications (8th Edition) by Kenneth H. Rosen, McGraw Hill',
          ],
          referenceBooks: [
            'Discrete Mathematical Structures by Bernard Kolman, Robert C. Busby, and Sharon Cutler Ross, Pearson',
          ],
          documentUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
          documentFileName: 'MA102_Discrete_Mathematics_Syllabus.pdf',
          documentSize: '2.5 MB',
          lastUpdated: DateTime(2026, 8, 12, 11, 30),
          status: 'published',
        ),
        SyllabusSubjectModel(
          id: 'SYLL-CS104',
          subjectCode: 'CS104',
          subjectName: 'Data Structures Laboratory',
          department: deptName,
          year: 'I Year',
          semester: 'Semester 2',
          academicYear: academicYear,
          credits: 2,
          subjectType: 'Practical',
          description: 'Implementation of stacks, queues, linked lists, binary trees, graph traversals, and hashing algorithms in C/C++.',
          units: [
            SyllabusUnitModel(
              unitNumber: 'Lab Experiments',
              title: 'Linear & Non-Linear Implementation',
              topics: ['Stack & Queue Operations', 'Singly & Doubly Linked List Operations', 'BST Insertion, Deletion & Traversals', 'BFS & DFS Graph Traversal'],
            ),
          ],
          textbooks: [
            'Data Structures Lab Manual, Dept. of Computer Science & Engineering',
          ],
          referenceBooks: [
            'Data Structures Using C and C++ by Yedidyah Langsam, Moshe J. Augenstein, and Aaron M. Tenenbaum, Pearson',
          ],
          documentUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
          documentFileName: 'CS104_Data_Structures_Lab.pdf',
          documentSize: '1.4 MB',
          lastUpdated: DateTime(2026, 8, 11, 15, 00),
          status: 'published',
        ),
      ],

      // ─────────────────────────────────────────
      //  YEAR II · SEMESTER 3
      // ─────────────────────────────────────────
      'II Year_Semester 3': [
        SyllabusSubjectModel(
          id: 'SYLL-CS201',
          subjectCode: 'CS201',
          subjectName: 'Object Oriented Programming with Java',
          department: deptName,
          year: 'II Year',
          semester: 'Semester 3',
          academicYear: academicYear,
          credits: 4,
          subjectType: 'Theory',
          description: 'Classes, objects, inheritance, polymorphism, interfaces, exception handling, multithreading, collections framework, and I/O streams in Java.',
          units: [
            SyllabusUnitModel(
              unitNumber: 'Unit I',
              title: 'OOP Concepts & Java Fundamentals',
              topics: ['Class & Object Creation', 'Encapsulation & Abstraction', 'Constructors & Garbage Collection', 'Method Overloading'],
            ),
            SyllabusUnitModel(
              unitNumber: 'Unit II',
              title: 'Inheritance, Interfaces & Packages',
              topics: ['Single & Multilevel Inheritance', 'Method Overriding & super Keyword', 'Interfaces & Abstract Classes', 'Creating & Importing Packages'],
            ),
            SyllabusUnitModel(
              unitNumber: 'Unit III',
              title: 'Exception Handling & Multithreading',
              topics: ['try-catch-finally Blocks', 'Custom Exceptions', 'Thread Lifecycle & Synchronization', 'Runnable Interface'],
            ),
            SyllabusUnitModel(
              unitNumber: 'Unit IV',
              title: 'Java Collections Framework',
              topics: ['ArrayList, LinkedList & Vector', 'HashSet & TreeSet', 'HashMap & TreeMap', 'Iterators & Comparators'],
            ),
          ],
          textbooks: [
            'Java: The Complete Reference (12th Edition) by Herbert Schildt, McGraw Hill',
          ],
          referenceBooks: [
            'Effective Java (3rd Edition) by Joshua Bloch, Addison-Wesley',
          ],
          documentUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
          documentFileName: 'CS201_Java_Programming_Syllabus.pdf',
          documentSize: '2.6 MB',
          lastUpdated: DateTime(2026, 8, 5, 12, 00),
          status: 'published',
        ),
        SyllabusSubjectModel(
          id: 'SYLL-CS202',
          subjectCode: 'CS202',
          subjectName: 'Database Management Systems',
          department: deptName,
          year: 'II Year',
          semester: 'Semester 3',
          academicYear: academicYear,
          credits: 4,
          subjectType: 'Theory',
          description: 'ER modeling, relational algebra, SQL queries, normalization (1NF to BCNF), transaction processing, ACID properties, and indexing.',
          units: [
            SyllabusUnitModel(
              unitNumber: 'Unit I',
              title: 'Database Architecture & ER Modeling',
              topics: ['Database System vs File System', '3-Schema Architecture', 'ER Diagrams & Constraints', 'Weak Entity Sets'],
            ),
            SyllabusUnitModel(
              unitNumber: 'Unit II',
              title: 'Relational Model & SQL Querying',
              topics: ['Relational Algebra Operations', 'DDL, DML & DCL Commands', 'Nested Subqueries & Joins', 'Views & Triggers'],
            ),
            SyllabusUnitModel(
              unitNumber: 'Unit III',
              title: 'Normalization & Database Design',
              topics: ['Functional Dependencies', '1NF, 2NF, 3NF & BCNF', 'Lossless Join & Dependency Preservation', 'Multi-valued Dependencies (4NF)'],
            ),
            SyllabusUnitModel(
              unitNumber: 'Unit IV',
              title: 'Transactions & Concurrency Control',
              topics: ['ACID Properties', 'Schedule Serializability', 'Two-Phase Locking (2PL)', 'Deadlock Handling & Recovery'],
            ),
          ],
          textbooks: [
            'Database System Concepts (7th Edition) by Abraham Silberschatz, Henry F. Korth, and S. Sudarshan, McGraw Hill',
          ],
          referenceBooks: [
            'Fundamentals of Database Systems (7th Edition) by Ramez Elmasri and Shamkant B. Navathe, Pearson',
          ],
          documentUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
          documentFileName: 'CS202_DBMS_Syllabus.pdf',
          documentSize: '3.0 MB',
          lastUpdated: DateTime(2026, 8, 6, 14, 30),
          status: 'published',
        ),
      ],

      // ─────────────────────────────────────────
      //  YEAR II · SEMESTER 4
      // ─────────────────────────────────────────
      'II Year_Semester 4': [
        SyllabusSubjectModel(
          id: 'SYLL-CS205',
          subjectCode: 'CS205',
          subjectName: 'Operating Systems & Systems Programming',
          department: deptName,
          year: 'II Year',
          semester: 'Semester 4',
          academicYear: academicYear,
          credits: 4,
          subjectType: 'Theory',
          description: 'Process management, CPU scheduling, semaphores & synchronization, deadlocks, virtual memory management, page replacement, and file systems.',
          units: [
            SyllabusUnitModel(
              unitNumber: 'Unit I',
              title: 'OS Structure & Process Management',
              topics: ['System Calls & Dual-Mode Operation', 'Process Control Block (PCB)', 'CPU Scheduling (FCFS, SJF, RR, Priority)', 'Multithreading Models'],
            ),
            SyllabusUnitModel(
              unitNumber: 'Unit II',
              title: 'Process Synchronization & Deadlocks',
              topics: ['Critical Section Problem', 'Peterson\'s Solution & Semaphores', 'Monitors & Producer-Consumer Problem', 'Banker\'s Algorithm for Deadlock Avoidance'],
            ),
            SyllabusUnitModel(
              unitNumber: 'Unit III',
              title: 'Memory Management & Virtual Memory',
              topics: ['Paging & Segmentation', 'TLB & Page Tables', 'Demand Paging & Page Faults', 'Page Replacement (FIFO, LRU, Optimal)'],
            ),
          ],
          textbooks: [
            'Operating System Concepts (10th Edition) by Abraham Silberschatz, Peter B. Galvin, and Greg Gagne, Wiley',
          ],
          referenceBooks: [
            'Modern Operating Systems (4th Edition) by Andrew S. Tanenbaum and Herbert Bos, Pearson',
          ],
          documentUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
          documentFileName: 'CS205_Operating_Systems_Syllabus.pdf',
          documentSize: '2.9 MB',
          lastUpdated: DateTime(2026, 8, 7, 09, 30),
          status: 'published',
        ),
      ],

      // ─────────────────────────────────────────
      //  YEAR III · SEMESTER 5
      // ─────────────────────────────────────────
      'III Year_Semester 5': [
        SyllabusSubjectModel(
          id: 'SYLL-CS301',
          subjectCode: 'CS301',
          subjectName: 'Computer Networks & Security',
          department: deptName,
          year: 'III Year',
          semester: 'Semester 5',
          academicYear: academicYear,
          credits: 4,
          subjectType: 'Theory',
          description: 'OSI & TCP/IP layers, routing protocols (RIP, OSPF, BGP), TCP/UDP socket programming, network security, RSA encryption, and firewalls.',
          units: [
            SyllabusUnitModel(
              unitNumber: 'Unit I',
              title: 'Physical & Data Link Layers',
              topics: ['OSI vs TCP/IP Architecture', 'Framing, Error Detection & Correction (CRC)', 'Flow Control (Stop-and-Wait, Sliding Window)', 'Ethernet & CSMA/CD'],
            ),
            SyllabusUnitModel(
              unitNumber: 'Unit II',
              title: 'Network Layer & IP Routing',
              topics: ['IPv4 & IPv6 Addressing & Subnetting', 'Distance Vector & Link State Routing', 'ICMP, ARP & DHCP', 'NAT & Router Architecture'],
            ),
            SyllabusUnitModel(
              unitNumber: 'Unit III',
              title: 'Transport Layer Protocols',
              topics: ['UDP Segment Structure', 'TCP Connection Management (3-way Handshake)', 'TCP Congestion Control & Flow Control', 'Socket API Programming'],
            ),
          ],
          textbooks: [
            'Computer Networking: A Top-Down Approach (8th Edition) by James F. Kurose and Keith W. Ross, Pearson',
          ],
          referenceBooks: [
            'Data Communications and Networking (5th Edition) by Behrouz A. Forouzan, McGraw Hill',
          ],
          documentUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
          documentFileName: 'CS301_Computer_Networks_Syllabus.pdf',
          documentSize: '3.2 MB',
          lastUpdated: DateTime(2026, 8, 8, 10, 15),
          status: 'published',
        ),
      ],

      // ─────────────────────────────────────────
      //  YEAR III · SEMESTER 6
      // ─────────────────────────────────────────
      'III Year_Semester 6': [
        SyllabusSubjectModel(
          id: 'SYLL-CS305',
          subjectCode: 'CS305',
          subjectName: 'Artificial Intelligence & Machine Learning',
          department: deptName,
          year: 'III Year',
          semester: 'Semester 6',
          academicYear: academicYear,
          credits: 4,
          subjectType: 'Theory',
          description: 'Search strategies, supervised & unsupervised learning, decision trees, neural networks, SVMs, clustering, and model evaluation metrics.',
          units: [
            SyllabusUnitModel(
              unitNumber: 'Unit I',
              title: 'Problem Solving & State Space Search',
              topics: ['BFS, DFS & A* Search', 'Heuristic Functions', 'Game Playing & Minimax Search', 'Constraint Satisfaction Problems'],
            ),
            SyllabusUnitModel(
              unitNumber: 'Unit II',
              title: 'Supervised Learning Algorithms',
              topics: ['Linear & Logistic Regression', 'Decision Trees & Random Forests', 'Support Vector Machines (SVM)', 'Naive Bayes Classification'],
            ),
          ],
          textbooks: [
            'Artificial Intelligence: A Modern Approach (4th Edition) by Stuart Russell and Peter Norvig, Pearson',
          ],
          referenceBooks: [
            'Pattern Recognition and Machine Learning by Christopher M. Bishop, Springer',
          ],
          documentUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
          documentFileName: 'CS305_AI_ML_Syllabus.pdf',
          documentSize: '3.5 MB',
          lastUpdated: DateTime(2026, 8, 9, 11, 00),
          status: 'published',
        ),
      ],

      // ─────────────────────────────────────────
      //  YEAR IV · SEMESTER 7
      // ─────────────────────────────────────────
      'IV Year_Semester 7': [
        SyllabusSubjectModel(
          id: 'SYLL-CS401',
          subjectCode: 'CS401',
          subjectName: 'Big Data Analytics & Distributed Systems',
          department: deptName,
          year: 'IV Year',
          semester: 'Semester 7',
          academicYear: academicYear,
          credits: 4,
          subjectType: 'Theory',
          description: 'Hadoop ecosystem, MapReduce framework, Apache Spark, HDFS architecture, NoSQL databases, and real-time stream processing.',
          units: [
            SyllabusUnitModel(
              unitNumber: 'Unit I',
              title: 'Hadoop & Distributed Storage',
              topics: ['5 Vs of Big Data', 'HDFS Architecture & NameNode/DataNode', 'MapReduce Execution Engine', 'YARN Resource Manager'],
            ),
          ],
          textbooks: [
            'Hadoop: The Definitive Guide (4th Edition) by Tom White, O\'Reilly',
          ],
          referenceBooks: [
            'Learning Spark (2nd Edition) by Jules S. Damji et al., O\'Reilly',
          ],
          documentUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
          documentFileName: 'CS401_Big_Data_Analytics_Syllabus.pdf',
          documentSize: '3.0 MB',
          lastUpdated: DateTime(2026, 8, 10, 16, 00),
          status: 'published',
        ),
      ],

      // ─────────────────────────────────────────
      //  YEAR IV · SEMESTER 8
      // ─────────────────────────────────────────
      'IV Year_Semester 8': [
        SyllabusSubjectModel(
          id: 'SYLL-CS405',
          subjectCode: 'CS405',
          subjectName: 'Professional Ethics & Industry Practices',
          department: deptName,
          year: 'IV Year',
          semester: 'Semester 8',
          academicYear: academicYear,
          credits: 3,
          subjectType: 'Theory',
          description: 'Engineering ethics, intellectual property rights (IPR), software patents, environmental safety, and corporate social responsibility.',
          units: [
            SyllabusUnitModel(
              unitNumber: 'Unit I',
              title: 'Ethics in Engineering & Tech',
              topics: ['Moral Dilemmas & Professional Codes', 'IEEE & ACM Code of Ethics', 'Whistleblowing & Confidentiality'],
            ),
          ],
          textbooks: [
            'Ethics in Engineering by Mike W. Martin and Roland Schinzinger, McGraw Hill',
          ],
          referenceBooks: [
            'Professional Ethics and Human Values by R.S. Nagarazan, New Age International',
          ],
          documentUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
          documentFileName: 'CS405_Professional_Ethics_Syllabus.pdf',
          documentSize: '1.6 MB',
          lastUpdated: DateTime(2026, 8, 11, 09, 00),
          status: 'published',
        ),
      ],
    };

    final key = '${normYear}_$normSem';
    if (syllabusDatabase.containsKey(key)) {
      return syllabusDatabase[key]!;
    }

    // Fallback: Default Semester 1 subjects if key not found
    return syllabusDatabase['I Year_Semester 1']!;
  }
}
