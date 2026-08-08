import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── VSBEC GRADE SERVICE & UTILS ─────────────────────────────────────────────

class VsbecGradeCalculator {
  /// Returns grade point for VSBEC grading scale:
  /// O = 10, A+ = 9, A = 8, B+ = 7, B = 6, C = 5
  /// RA, SA, W are EXCLUDED (returns null).
  static double? getGradePoint(String grade) {
    switch (grade.toUpperCase().trim()) {
      case 'O':
        return 10.0;
      case 'A+':
        return 9.0;
      case 'A':
        return 8.0;
      case 'B+':
        return 7.0;
      case 'B':
        return 6.0;
      case 'C':
        return 5.0;
      case 'RA':
      case 'SA':
      case 'W':
      default:
        return null;
    }
  }

  static bool isExcludedGrade(String grade) {
    return getGradePoint(grade) == null;
  }

  static String getGradeDisplay(String grade) {
    final gp = getGradePoint(grade);
    if (gp != null) {
      return '$grade (${gp.toInt()})';
    }
    switch (grade.toUpperCase().trim()) {
      case 'RA':
        return 'RA (Re-Appear)';
      case 'SA':
        return 'SA (Shortage Att.)';
      case 'W':
        return 'W (Withdrawn)';
      default:
        return '$grade (Excluded)';
    }
  }
}

// ── DATA MODELS ─────────────────────────────────────────────────────────────

class SubjectModel {
  String id;
  String name;
  String code;
  int credits;
  String grade; // O, A+, A, B+, B, C, RA, SA, W
  String faculty;
  String internalMarks;
  String quizMarks;
  String examMarks;
  String totalMarks;
  String remarks;

  SubjectModel({
    String? id,
    required this.name,
    required this.code,
    required this.credits,
    required this.grade,
    this.faculty = 'Prof. Academic Lead',
    this.internalMarks = '18/20',
    this.quizMarks = '9/10',
    this.examMarks = '45/50',
    this.totalMarks = '72/80',
    this.remarks = 'Good conceptual understanding & lab performance.',
  }) : id = id ?? '${code}_${DateTime.now().millisecondsSinceEpoch}';

  double? get gradePoint => VsbecGradeCalculator.getGradePoint(grade);

  bool get isExcluded => VsbecGradeCalculator.isExcludedGrade(grade);

  bool get isPassed => gradePoint != null && gradePoint! >= 5.0;

  double get weightedPoints {
    final gp = gradePoint;
    if (gp == null) return 0.0;
    return credits * gp;
  }

  SubjectModel copyWith({
    String? name,
    String? code,
    int? credits,
    String? grade,
    String? faculty,
    String? internalMarks,
    String? quizMarks,
    String? examMarks,
    String? totalMarks,
    String? remarks,
  }) {
    return SubjectModel(
      id: id,
      name: name ?? this.name,
      code: code ?? this.code,
      credits: credits ?? this.credits,
      grade: grade ?? this.grade,
      faculty: faculty ?? this.faculty,
      internalMarks: internalMarks ?? this.internalMarks,
      quizMarks: quizMarks ?? this.quizMarks,
      examMarks: examMarks ?? this.examMarks,
      totalMarks: totalMarks ?? this.totalMarks,
      remarks: remarks ?? this.remarks,
    );
  }
}

class SemesterModel {
  int number;
  String name;
  List<SubjectModel> subjects;
  bool isCurrent;

  SemesterModel({
    required this.number,
    required this.name,
    required this.subjects,
    this.isCurrent = false,
  });

  /// Total credits of all registered subjects (including RA/SA/W)
  int get registeredCredits => subjects.fold(0, (sum, s) => sum + s.credits);

  /// Total credits of eligible subjects (EXCLUDING RA, SA, W)
  int get eligibleCredits =>
      subjects.where((s) => !s.isExcluded).fold(0, (sum, s) => sum + s.credits);

  /// Earned credits of passed subjects
  int get earnedCredits =>
      subjects.where((s) => s.isPassed).fold(0, (sum, s) => sum + s.credits);

  /// Sum of weighted grade points for eligible subjects
  double get totalWeightedPoints =>
      subjects.fold(0.0, (sum, s) => sum + s.weightedPoints);

  int get passedCount => subjects.where((s) => s.isPassed).length;

  int get failedCount => subjects.where((s) => s.grade == 'RA').length;

  int get excludedCount => subjects.where((s) => s.isExcluded).length;

  /// VSBEC SGPA Formula = Σ(Credit × Grade Point) / Σ(Eligible Credits)
  double get sgpa {
    int totalCreds = 0;
    double totalPoints = 0.0;

    for (var s in subjects) {
      final gp = s.gradePoint;
      if (gp == null) continue; // Excluded RA, SA, W
      totalCreds += s.credits;
      totalPoints += (s.credits * gp);
    }

    if (totalCreds == 0) return 0.0;
    return (totalPoints / totalCreds).clamp(0.0, 10.0);
  }

  SemesterModel copyWith({
    int? number,
    String? name,
    List<SubjectModel>? subjects,
    bool? isCurrent,
  }) {
    return SemesterModel(
      number: number ?? this.number,
      name: name ?? this.name,
      subjects: subjects ?? List.from(this.subjects),
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }
}

// ── STATE MODEL ──────────────────────────────────────────────────────────────

class GradebookState {
  final List<SemesterModel> semesters;
  final int selectedSemesterIndex;

  GradebookState({
    required this.semesters,
    this.selectedSemesterIndex = 3,
  });

  /// VSBEC Credit-Weighted CGPA Formula =
  /// Σ(All Course Credits × All Course Grade Points) / Σ(All Eligible Course Credits)
  /// Excludes RA, SA, W.
  double get overallCgpa {
    int sumEligibleCredits = 0;
    double sumWeightedPoints = 0.0;

    for (var sem in semesters) {
      for (var sub in sem.subjects) {
        final gp = sub.gradePoint;
        if (gp == null) continue; // Exclude RA, SA, W
        sumEligibleCredits += sub.credits;
        sumWeightedPoints += (sub.credits * gp);
      }
    }

    if (sumEligibleCredits == 0) return 0.0;
    return (sumWeightedPoints / sumEligibleCredits).clamp(0.0, 10.0);
  }

  /// VSBEC Percentage Formula = CGPA × 10
  double get overallPercentage => overallCgpa * 10.0;

  int get overallEligibleCredits {
    return semesters.fold(0, (sum, sem) => sum + sem.eligibleCredits);
  }

  int get overallEarnedCredits {
    return semesters.fold(0, (sum, sem) => sum + sem.earnedCredits);
  }

  double get overallWeightedPoints {
    return semesters.fold(0.0, (sum, sem) => sum + sem.totalWeightedPoints);
  }

  double get currentSemSgpa {
    if (semesters.isEmpty) return 0.0;
    final idx = selectedSemesterIndex < semesters.length ? selectedSemesterIndex : 0;
    return semesters[idx].sgpa;
  }

  SemesterModel? get currentSemester {
    if (semesters.isEmpty) return null;
    final idx = selectedSemesterIndex < semesters.length ? selectedSemesterIndex : 0;
    return semesters[idx];
  }

  String get academicStanding {
    double cgpa = overallCgpa;
    if (cgpa >= 9.0) return 'First Class with Distinction';
    if (cgpa >= 7.5) return 'First Class';
    if (cgpa >= 6.0) return 'Second Class';
    if (cgpa >= 5.0) return 'Pass Class';
    return 'Re-Appear Required';
  }

  GradebookState copyWith({
    List<SemesterModel>? semesters,
    int? selectedSemesterIndex,
  }) {
    return GradebookState(
      semesters: semesters ?? this.semesters,
      selectedSemesterIndex: selectedSemesterIndex ?? this.selectedSemesterIndex,
    );
  }
}

// ── STATE NOTIFIER ───────────────────────────────────────────────────────────

class GradebookNotifier extends StateNotifier<GradebookState> {
  GradebookNotifier() : super(_initialState());

  static GradebookState _initialState() {
    return GradebookState(
      selectedSemesterIndex: 3, // Default Sem 4
      semesters: [
        SemesterModel(
          number: 1,
          name: 'Semester 1',
          subjects: [
            SubjectModel(name: 'Mathematics I', code: 'MA101', credits: 4, grade: 'A+'),
            SubjectModel(name: 'Engineering Physics', code: 'PH101', credits: 4, grade: 'A'),
            SubjectModel(name: 'Basic Electrical Engg', code: 'EE101', credits: 3, grade: 'B+'),
            SubjectModel(name: 'C Programming Lab', code: 'CS101', credits: 3, grade: 'O'),
            SubjectModel(name: 'Engineering Graphics', code: 'ME101', credits: 2, grade: 'RA'),
          ],
        ),
        SemesterModel(
          number: 2,
          name: 'Semester 2',
          subjects: [
            SubjectModel(name: 'Mathematics II', code: 'MA201', credits: 4, grade: 'A'),
            SubjectModel(name: 'Engineering Chemistry', code: 'CH201', credits: 4, grade: 'A+'),
            SubjectModel(name: 'Data Structures in C++', code: 'CS201', credits: 4, grade: 'O'),
            SubjectModel(name: 'Digital Logic Design', code: 'EC201', credits: 3, grade: 'B+'),
            SubjectModel(name: 'Environmental Science', code: 'EV201', credits: 2, grade: 'SA'),
          ],
        ),
        SemesterModel(
          number: 3,
          name: 'Semester 3',
          subjects: [
            SubjectModel(name: 'Discrete Mathematics', code: 'MA301', credits: 4, grade: 'A+'),
            SubjectModel(name: 'Object Oriented Java', code: 'CS301', credits: 4, grade: 'A'),
            SubjectModel(name: 'Computer Architecture', code: 'CS302', credits: 4, grade: 'B+'),
            SubjectModel(name: 'Theory of Computation', code: 'CS303', credits: 3, grade: 'A'),
            SubjectModel(name: 'Database Foundations', code: 'CS304', credits: 3, grade: 'O'),
          ],
        ),
        SemesterModel(
          number: 4,
          name: 'Semester 4',
          isCurrent: true,
          subjects: [
            SubjectModel(name: 'Advanced Data Structures', code: 'CS401', credits: 4, grade: 'O'),
            SubjectModel(name: 'Database Mgmt. Systems', code: 'CS402', credits: 4, grade: 'A+'),
            SubjectModel(name: 'Operating Systems', code: 'CS403', credits: 4, grade: 'A'),
            SubjectModel(name: 'Computer Networks', code: 'CS404', credits: 3, grade: 'B+'),
            SubjectModel(name: 'Design & Analysis of Algo', code: 'CS405', credits: 3, grade: 'A+'),
            SubjectModel(name: 'Full-Stack Web Dev Lab', code: 'CS406', credits: 2, grade: 'O'),
          ],
        ),
      ],
    );
  }

  void selectSemester(int index) {
    if (index >= 0 && index < state.semesters.length) {
      state = state.copyWith(selectedSemesterIndex: index);
    }
  }

  void addSemester(String name) {
    final nextNum = state.semesters.length + 1;
    final newSem = SemesterModel(
      number: nextNum,
      name: name,
      subjects: [],
    );
    state = state.copyWith(
      semesters: [...state.semesters, newSem],
      selectedSemesterIndex: state.semesters.length,
    );
  }

  void removeSemester(int index) {
    if (state.semesters.length <= 1) return;
    final newSemesters = List<SemesterModel>.from(state.semesters)..removeAt(index);
    final newIndex = state.selectedSemesterIndex >= newSemesters.length
        ? newSemesters.length - 1
        : state.selectedSemesterIndex;
    state = state.copyWith(
      semesters: newSemesters,
      selectedSemesterIndex: newIndex,
    );
  }

  void addSubjectToSemester(int semIndex, SubjectModel subject) {
    if (semIndex < 0 || semIndex >= state.semesters.length) return;
    final sem = state.semesters[semIndex];
    final updatedSubjects = [...sem.subjects, subject];
    final updatedSem = sem.copyWith(subjects: updatedSubjects);

    final updatedSemesters = List<SemesterModel>.from(state.semesters);
    updatedSemesters[semIndex] = updatedSem;

    state = state.copyWith(semesters: updatedSemesters);
  }

  void updateSubjectInSemester(int semIndex, SubjectModel updatedSubject) {
    if (semIndex < 0 || semIndex >= state.semesters.length) return;
    final sem = state.semesters[semIndex];
    final updatedSubjects = sem.subjects.map((s) {
      return s.id == updatedSubject.id ? updatedSubject : s;
    }).toList();

    final updatedSem = sem.copyWith(subjects: updatedSubjects);
    final updatedSemesters = List<SemesterModel>.from(state.semesters);
    updatedSemesters[semIndex] = updatedSem;

    state = state.copyWith(semesters: updatedSemesters);
  }

  void removeSubjectFromSemester(int semIndex, String subjectId) {
    if (semIndex < 0 || semIndex >= state.semesters.length) return;
    final sem = state.semesters[semIndex];
    final updatedSubjects = sem.subjects.where((s) => s.id != subjectId).toList();

    final updatedSem = sem.copyWith(subjects: updatedSubjects);
    final updatedSemesters = List<SemesterModel>.from(state.semesters);
    updatedSemesters[semIndex] = updatedSem;

    state = state.copyWith(semesters: updatedSemesters);
  }

  void resetToDefaults() {
    state = _initialState();
  }
}

// ── PROVIDER DECLARATION ─────────────────────────────────────────────────────

final gradebookProvider =
    StateNotifierProvider<GradebookNotifier, GradebookState>((ref) {
  return GradebookNotifier();
});
