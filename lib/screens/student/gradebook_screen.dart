import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:clg_application/providers/gradebook_provider.dart';
import 'package:clg_application/screens/student/cgpa_details_screen.dart';

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
  });

  double? get gradePoint => VsbecGradeCalculator.getGradePoint(grade);

  bool get isExcluded => VsbecGradeCalculator.isExcludedGrade(grade);

  bool get isPassed => gradePoint != null && gradePoint! >= 5.0;

  double get weightedPoints {
    final gp = gradePoint;
    if (gp == null) return 0.0;
    return credits * gp;
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
}

// ── CALCULATOR ENTRY ROW MODELS ─────────────────────────────────────────────

class CalcSemesterRow {
  TextEditingController nameController;
  TextEditingController sgpaController;
  TextEditingController creditsController;

  CalcSemesterRow({
    required String name,
    required double sgpa,
    required int credits,
  })  : nameController = TextEditingController(text: name),
        sgpaController = TextEditingController(text: sgpa.toStringAsFixed(2)),
        creditsController = TextEditingController(text: credits.toString());

  void dispose() {
    nameController.dispose();
    sgpaController.dispose();
    creditsController.dispose();
  }
}

class CalcSubjectRow {
  TextEditingController nameController;
  TextEditingController creditsController;
  String selectedGrade;

  CalcSubjectRow({
    required String name,
    required int credits,
    required this.selectedGrade,
  })  : nameController = TextEditingController(text: name),
        creditsController = TextEditingController(text: credits.toString());

  void dispose() {
    nameController.dispose();
    creditsController.dispose();
  }
}

// ── MAIN WIDGET ──────────────────────────────────────────────────────────────

class GradebookScreen extends ConsumerStatefulWidget {
  final bool initialShowPlanner;
  final VoidCallback? onBack;

  const GradebookScreen({
    super.key,
    this.initialShowPlanner = false,
    this.onBack,
  });

  @override
  ConsumerState<GradebookScreen> createState() => _GradebookScreenState();
}

class _GradebookScreenState extends ConsumerState<GradebookScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int _selectedSemIndex = 3; // Default Sem 4 (Current)
  late List<SemesterModel> _semesters;

  // CGPA Semester Calculator State
  late List<CalcSemesterRow> _calcSemRows;
  double _calculatedCgpaResult = 0.0;
  double _calculatedCgpaPercentage = 0.0;
  int _calculatedCgpaTotalCredits = 0;

  // SGPA Subject Calculator State
  late List<CalcSubjectRow> _calcSubjectRows;
  double _calculatedSgpaResult = 0.0;
  int _calculatedSgpaEligibleCredits = 0;

  // Target Forecast State
  final TextEditingController _targetCgpaController =
      TextEditingController(text: '9.00');
  final TextEditingController _remainingSemsController =
      TextEditingController(text: '4');
  double _requiredFutureSgpa = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialShowPlanner ? 1 : 0,
    );

    _initSampleVsbecData();
    _initCalculators();
    _recalculateCgpaFromRows();
    _recalculateSgpaFromRows();
    _calculateTargetForecast();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _targetCgpaController.dispose();
    _remainingSemsController.dispose();

    for (var r in _calcSemRows) {
      r.dispose();
    }
    for (var r in _calcSubjectRows) {
      r.dispose();
    }

    super.dispose();
  }

  void _initSampleVsbecData() {
    _semesters = [
      SemesterModel(
        number: 1,
        name: 'Semester 1',
        subjects: [
          SubjectModel(name: 'Mathematics I', code: 'MA101', credits: 4, grade: 'A+'),
          SubjectModel(name: 'Engineering Physics', code: 'PH101', credits: 4, grade: 'A'),
          SubjectModel(name: 'Basic Electrical Engg', code: 'EE101', credits: 3, grade: 'B+'),
          SubjectModel(name: 'C Programming Lab', code: 'CS101', credits: 3, grade: 'O'),
          SubjectModel(name: 'Engineering Graphics', code: 'ME101', credits: 2, grade: 'RA'), // Excluded from calculation
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
          SubjectModel(name: 'Environmental Science', code: 'EV201', credits: 2, grade: 'SA'), // Excluded from calculation
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
    ];
  }

  void _initCalculators() {
    _calcSemRows = [
      CalcSemesterRow(name: 'Sem 1', sgpa: 8.50, credits: 14),
      CalcSemesterRow(name: 'Sem 2', sgpa: 8.60, credits: 15),
      CalcSemesterRow(name: 'Sem 3', sgpa: 8.33, credits: 18),
      CalcSemesterRow(name: 'Sem 4', sgpa: 8.80, credits: 20),
    ];

    _calcSubjectRows = [
      CalcSubjectRow(name: 'Advanced AI & ML', credits: 4, selectedGrade: 'O'),
      CalcSubjectRow(name: 'Cloud Computing & DevOps', credits: 4, selectedGrade: 'A+'),
      CalcSubjectRow(name: 'Compiler Design', credits: 3, selectedGrade: 'A'),
      CalcSubjectRow(name: 'Cyber Security & Crypto', credits: 3, selectedGrade: 'B+'),
      CalcSubjectRow(name: 'Elective Lab (Arrear)', credits: 2, selectedGrade: 'RA'), // VSBEC RA Excluded
    ];
  }

  // ── COMPUTED VSBEC OVERALL STATS ──────────────────────────────────────────

  /// VSBEC Credit-Weighted CGPA Formula =
  /// Σ(All Course Credits × All Course Grade Points) / Σ(All Eligible Course Credits)
  /// Excludes RA, SA, W.
  double get overallCgpa {
    int sumEligibleCredits = 0;
    double sumWeightedPoints = 0.0;

    for (var sem in _semesters) {
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
    return _semesters.fold(0, (sum, sem) => sum + sem.eligibleCredits);
  }

  int get overallEarnedCredits {
    return _semesters.fold(0, (sum, sem) => sum + sem.earnedCredits);
  }

  double get currentSemSgpa {
    if (_semesters.isEmpty) return 0.0;
    return _semesters[_selectedSemIndex < _semesters.length ? _selectedSemIndex : 0].sgpa;
  }

  String get academicStanding {
    double cgpa = overallCgpa;
    if (cgpa >= 9.0) return 'First Class with Distinction';
    if (cgpa >= 7.5) return 'First Class';
    if (cgpa >= 6.0) return 'Second Class';
    if (cgpa >= 5.0) return 'Pass Class';
    return 'Re-Appear Required';
  }

  // ── VSBEC CALCULATOR LOGIC ────────────────────────────────────────────────

  void _recalculateCgpaFromRows() {
    int totalCredits = 0;
    double totalPoints = 0.0;

    for (var r in _calcSemRows) {
      double sgpa = double.tryParse(r.sgpaController.text) ?? 0.0;
      int creds = int.tryParse(r.creditsController.text) ?? 0;
      if (creds > 0 && sgpa >= 0) {
        totalCredits += creds;
        totalPoints += (sgpa.clamp(0.0, 10.0) * creds);
      }
    }

    final computedCgpa = totalCredits > 0 ? (totalPoints / totalCredits).clamp(0.0, 10.0) : 0.0;

    setState(() {
      _calculatedCgpaTotalCredits = totalCredits;
      _calculatedCgpaResult = computedCgpa;
      _calculatedCgpaPercentage = computedCgpa * 10.0;
    });
  }

  void _recalculateSgpaFromRows() {
    int eligibleCredits = 0;
    double totalWeightedPoints = 0.0;

    for (var r in _calcSubjectRows) {
      int creds = int.tryParse(r.creditsController.text) ?? 0;
      final gp = VsbecGradeCalculator.getGradePoint(r.selectedGrade);

      // Exclude RA, SA, W from both numerator & denominator
      if (gp != null && creds > 0) {
        eligibleCredits += creds;
        totalWeightedPoints += (creds * gp);
      }
    }

    final computedSgpa = eligibleCredits > 0 ? (totalWeightedPoints / eligibleCredits).clamp(0.0, 10.0) : 0.0;

    setState(() {
      _calculatedSgpaEligibleCredits = eligibleCredits;
      _calculatedSgpaResult = computedSgpa;
    });
  }

  void _calculateTargetForecast() {
    double targetCgpa = double.tryParse(_targetCgpaController.text) ?? 9.00;
    int remainingSems = int.tryParse(_remainingSemsController.text) ?? 4;

    int completedCredits = overallEligibleCredits;
    double currentPoints = overallCgpa * completedCredits;

    int estimatedFutureCreditsPerSem = 20;
    int totalFutureCredits = remainingSems * estimatedFutureCreditsPerSem;
    int grandTotalCredits = completedCredits + totalFutureCredits;

    if (totalFutureCredits <= 0 || grandTotalCredits <= 0) {
      setState(() => _requiredFutureSgpa = 0.0);
      return;
    }

    double neededTotalPoints = targetCgpa * grandTotalCredits;
    double neededFuturePoints = neededTotalPoints - currentPoints;
    double requiredSgpa = neededFuturePoints / totalFutureCredits;

    setState(() {
      _requiredFutureSgpa = requiredSgpa.clamp(0.0, 10.0);
    });
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.onBack == null,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (widget.onBack != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) widget.onBack!();
          });
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              _buildSegmentedTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGradebookTab(),
                    _buildCgpaCalculatorTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── APP BAR ────────────────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2980B9), Color(0xFF6DD5FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () {
              if (widget.onBack != null) {
                widget.onBack!();
              } else if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                context.go('/student');
              }
            },
          ),
          const Column(
            children: [
              Text(
                'VSBEC Gradebook & CGPA',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
              Text(
                'VSB Engineering College Rules Applied',
                style: TextStyle(fontSize: 10, color: Color(0xFFE0F2FE), fontWeight: FontWeight.w600),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: Colors.white70, size: 22),
            onPressed: _showVsbecInfoDialog,
          ),
        ],
      ),
    );
  }

  // ── SEGMENTED TAB BAR ──────────────────────────────────────────────────────

  Widget _buildSegmentedTabBar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2980B9), Color(0xFF6DD5FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: const Color(0xFF2980B9),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2980B9).withValues(alpha: 0.5),
                blurRadius: 8,
                offset: const Offset(0, 3),
              )
            ],
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.8),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_graph_rounded, size: 16),
                  SizedBox(width: 6),
                  Text('Gradebook'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calculate_rounded, size: 16),
                  SizedBox(width: 6),
                  Text('CGPA Calculator'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 1: GRADEBOOK & SEMESTER ANALYTICS
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildGradebookTab() {
    final currentSem = _semesters.isNotEmpty
        ? _semesters[_selectedSemIndex < _semesters.length ? _selectedSemIndex : 0]
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Summary Overview Cards Grid
          _buildVsbecOverallSummaryCards(),
          const SizedBox(height: 20),

          // Semester Selector Chips Row
          _buildSemesterSelectorChips(),
          const SizedBox(height: 16),

          // Active Semester Stat Banner
          if (currentSem != null) _buildSemesterSummaryCard(currentSem),
          const SizedBox(height: 20),

          // Subject List Header & Add Subject Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Subject Performance (${currentSem?.name ?? ''})',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _showAddSubjectDialog(currentSem),
                icon: const Icon(Icons.add_rounded, size: 16, color: Color(0xFF2980B9)),
                label: const Text('Add Subject', style: TextStyle(color: Color(0xFF2980B9), fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Subject Cards List
          if (currentSem == null || currentSem.subjects.isEmpty)
            _buildEmptyStateCard('No eligible subjects available for calculation in ${currentSem?.name ?? 'this semester'}', () => _showAddSubjectDialog(currentSem))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: currentSem.subjects.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final sub = currentSem.subjects[index];
                return _buildSubjectCard(sub);
              },
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildVsbecOverallSummaryCards() {
    final gradebookState = ref.watch(gradebookProvider);

    return LayoutBuilder(builder: (context, constraints) {
      final width = (constraints.maxWidth - 12) / 2;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _buildStatCard(
            width: width,
            title: 'Overall CGPA',
            value: gradebookState.overallCgpa.toStringAsFixed(2),
            subtext: gradebookState.academicStanding,
            icon: Icons.emoji_events_rounded,
            color: const Color(0xFF10B981),
            bgColor: const Color(0xFFECFDF5),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CgpaDetailsScreen(initialTabIndex: 0),
                ),
              );
            },
          ),
          _buildStatCard(
            width: width,
            title: 'Equivalent Score %',
            value: '${gradebookState.overallPercentage.toStringAsFixed(2)}%',
            subtext: 'Formula: CGPA × 10',
            icon: Icons.percent_rounded,
            color: const Color(0xFF3B82F6),
            bgColor: const Color(0xFFEFF6FF),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CgpaDetailsScreen(initialTabIndex: 1),
                ),
              );
            },
          ),
          _buildStatCard(
            width: width,
            title: 'Eligible Credits',
            value: '${gradebookState.overallEligibleCredits} Credits',
            subtext: 'Excludes RA, SA & W',
            icon: Icons.school_rounded,
            color: const Color(0xFF2980B9),
            bgColor: const Color(0xFFEDF8FF),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CgpaDetailsScreen(initialTabIndex: 2),
                ),
              );
            },
          ),
          _buildStatCard(
            width: width,
            title: 'Current SGPA',
            value: gradebookState.currentSemSgpa.toStringAsFixed(2),
            subtext: gradebookState.currentSemester?.name ?? 'Semester 4',
            icon: Icons.trending_up_rounded,
            color: const Color(0xFFF59E0B),
            bgColor: const Color(0xFFFFFBEB),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CgpaDetailsScreen(initialTabIndex: 3),
                ),
              );
            },
          ),
        ],
      );
    });
  }

  Widget _buildStatCard({
    required double width,
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
    required Color color,
    required Color bgColor,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: width,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
                    child: Icon(icon, color: color, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
              const SizedBox(height: 4),
              Text(subtext, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSemesterSelectorChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...List.generate(_semesters.length, (index) {
            final isSelected = index == _selectedSemIndex;
            final sem = _semesters[index];
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilterChip(
                label: Text('Sem ${sem.number}'),
                selected: isSelected,
                onSelected: (val) {
                  if (val) setState(() => _selectedSemIndex = index);
                },
                selectedColor: const Color(0xFF2980B9),
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: isSelected ? const Color(0xFF2980B9) : const Color(0xFFE2E8F0)),
                ),
                showCheckmark: false,
              ),
            );
          }),
          IconButton.filledTonal(
            onPressed: _showAddSemesterDialog,
            icon: const Icon(Icons.add_rounded, size: 20),
            style: IconButton.styleFrom(backgroundColor: const Color(0xFFF1F5F9), foregroundColor: const Color(0xFF2980B9)),
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterSummaryCard(SemesterModel sem) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B4F72), Color(0xFF2980B9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2980B9).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(sem.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  if (sem.isCurrent) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(8)),
                      child: const Text('Active', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${sem.eligibleCredits} Eligible Credits • ${sem.subjects.length} Total Subjects',
                style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 4),
                  Text('${sem.passedCount} Passed', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                  if (sem.failedCount > 0) ...[
                    const SizedBox(width: 10),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                    Text('${sem.failedCount} RA', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                  ],
                  if (sem.excludedCount > 0) ...[
                    const SizedBox(width: 10),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: Color(0xFFF59E0B), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                    Text('${sem.excludedCount} Excluded', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                  ],
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                const Text('SGPA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70)),
                const SizedBox(height: 2),
                Text(
                  sem.sgpa.toStringAsFixed(2),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF38BDF8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(SubjectModel sub) {
    Color gradeColor;
    String statusText;

    if (sub.isExcluded) {
      gradeColor = const Color(0xFFF59E0B);
      statusText = 'Excluded (RA/SA/W)';
    } else if (sub.grade == 'O' || sub.grade == 'A+') {
      gradeColor = const Color(0xFF10B981);
      statusText = 'Pass';
    } else if (sub.grade == 'A' || sub.grade == 'B+') {
      gradeColor = const Color(0xFF3B82F6);
      statusText = 'Pass';
    } else {
      gradeColor = const Color(0xFF6366F1);
      statusText = 'Pass';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  sub.code,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sub.name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sub.isExcluded
                          ? '${sub.credits} Credits • Excluded from SGPA'
                          : '${sub.credits} Credits • Grade Point: ${sub.gradePoint} • W.Points: ${sub.weightedPoints}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: gradeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: gradeColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  VsbecGradeCalculator.getGradeDisplay(sub.grade),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: gradeColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    sub.isExcluded ? Icons.warning_amber_rounded : Icons.star_rounded,
                    size: 14,
                    color: gradeColor,
                  ),
                  const SizedBox(width: 4),
                  Text('Status: ', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: gradeColor,
                    ),
                  ),
                ],
              ),
              Text(
                'Total Score: ${sub.totalMarks}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 2: VSBEC CGPA & SGPA CALCULATOR
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildCgpaCalculatorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Semester-Level CGPA Calculator
          _buildVsbecCgpaCalculatorSection(),
          const SizedBox(height: 24),

          // Section 2: Subject-Level SGPA Calculator
          _buildVsbecSgpaCalculatorSection(),
          const SizedBox(height: 24),

          // Section 3: Target CGPA Goal Forecaster ("What-If")
          _buildTargetForecastSection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildVsbecCgpaCalculatorSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.functions_rounded, color: Color(0xFF2980B9), size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Semester CGPA Calculator',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 20, color: Color(0xFF64748B)),
                onPressed: _resetSemRows,
                tooltip: 'Reset Semesters',
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'CGPA = Σ(SGPA × Credits) / Σ(Credits) • Percentage = CGPA × 10',
            style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),

          // Semester Entry Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _calcSemRows.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final row = _calcSemRows[index];
              return Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: row.nameController,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: row.sgpaController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (val) => _recalculateCgpaFromRows(),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2980B9)),
                      decoration: InputDecoration(
                        labelText: 'SGPA (0-10)',
                        labelStyle: const TextStyle(fontSize: 10),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: row.creditsController,
                      keyboardType: TextInputType.number,
                      onChanged: (val) => _recalculateCgpaFromRows(),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: 'Eligible Credits',
                        labelStyle: const TextStyle(fontSize: 10),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.redAccent, size: 20),
                    onPressed: () => _removeSemRow(index),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: _addSemRow,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Semester Row', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF2980B9),
              side: const BorderSide(color: Color(0xFF2980B9)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 16),

          // Calculation Result Display Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF8FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFBEE3F8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('VSBEC CGPA & PERCENTAGE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2980B9))),
                    const SizedBox(height: 2),
                    Text('Total Eligible Credits: $_calculatedCgpaTotalCredits', style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                    const SizedBox(height: 2),
                    Text('Percentage: ${_calculatedCgpaPercentage.toStringAsFixed(2)}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                  ],
                ),
                Text(
                  _calculatedCgpaResult.toStringAsFixed(2),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF2980B9)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVsbecSgpaCalculatorSection() {
    final vsbecGradeOptions = ['O', 'A+', 'A', 'B+', 'B', 'C', 'RA', 'SA', 'W'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.calculate_outlined, color: Color(0xFF10B981), size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Subject SGPA Calculator',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 20, color: Color(0xFF64748B)),
                onPressed: _resetSubjectRows,
                tooltip: 'Reset Subjects',
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'SGPA = Σ(Credit × Grade Point) / Σ(Eligible Credits) • RA/SA/W Excluded',
            style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),

          // Subject Entry Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _calcSubjectRows.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final row = _calcSubjectRows[index];
              return Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: TextField(
                      controller: row.nameController,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: row.creditsController,
                      keyboardType: TextInputType.number,
                      onChanged: (val) => _recalculateSgpaFromRows(),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: 'Credits',
                        labelStyle: const TextStyle(fontSize: 10),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 4,
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: row.selectedGrade,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: vsbecGradeOptions.map((g) {
                        return DropdownMenuItem(
                          value: g,
                          child: Text(
                            VsbecGradeCalculator.getGradeDisplay(g),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: VsbecGradeCalculator.isExcludedGrade(g)
                                  ? Colors.orange.shade800
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            row.selectedGrade = val;
                          });
                          _recalculateSgpaFromRows();
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.redAccent, size: 20),
                    onPressed: () => _removeSubjectRow(index),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: _addSubjectRow,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Subject Row', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF10B981),
              side: const BorderSide(color: Color(0xFF10B981)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 16),

          // Calculation Result Display Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CALCULATED VSBEC SGPA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                    const SizedBox(height: 2),
                    Text('Eligible Credits: $_calculatedSgpaEligibleCredits', style: const TextStyle(fontSize: 12, color: Color(0xFF047857))),
                  ],
                ),
                Text(
                  _calculatedSgpaResult.toStringAsFixed(2),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF059669)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetForecastSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.track_changes_rounded, color: Color(0xFF3B82F6), size: 22),
              SizedBox(width: 8),
              Text(
                'Target CGPA Forecaster ("What-If")',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Simulate required SGPA in remaining semesters to achieve your target CGPA goal.',
            style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _targetCgpaController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (val) => _calculateTargetForecast(),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF3B82F6)),
                  decoration: InputDecoration(
                    labelText: 'Target Goal CGPA',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _remainingSemsController,
                  keyboardType: TextInputType.number,
                  onChanged: (val) => _calculateTargetForecast(),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: 'Remaining Semesters',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('REQUIRED SGPA PER SEMESTER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                    const SizedBox(height: 2),
                    Text('Current CGPA: ${overallCgpa.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: Color(0xFF1E40AF))),
                  ],
                ),
                Text(
                  _requiredFutureSgpa.toStringAsFixed(2),
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: _requiredFutureSgpa > 10.0 ? Colors.red : const Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── HELPER DIALOGS & CONTROLLERS ───────────────────────────────────────────

  void _addSemRow() {
    setState(() {
      _calcSemRows.add(CalcSemesterRow(
        name: 'Sem ${_calcSemRows.length + 1}',
        sgpa: 8.50,
        credits: 20,
      ));
    });
    _recalculateCgpaFromRows();
  }

  void _removeSemRow(int index) {
    if (_calcSemRows.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Must keep at least 1 semester row.')));
      return;
    }
    setState(() {
      _calcSemRows.removeAt(index);
    });
    _recalculateCgpaFromRows();
  }

  void _resetSemRows() {
    setState(() {
      for (var r in _calcSemRows) {
        r.dispose();
      }
      _initCalculators();
    });
    _recalculateCgpaFromRows();
  }

  void _addSubjectRow() {
    setState(() {
      _calcSubjectRows.add(CalcSubjectRow(
        name: 'Subject ${_calcSubjectRows.length + 1}',
        credits: 3,
        selectedGrade: 'A+',
      ));
    });
    _recalculateSgpaFromRows();
  }

  void _removeSubjectRow(int index) {
    if (_calcSubjectRows.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Must keep at least 1 subject row.')));
      return;
    }
    setState(() {
      _calcSubjectRows.removeAt(index);
    });
    _recalculateSgpaFromRows();
  }

  void _resetSubjectRows() {
    setState(() {
      for (var r in _calcSubjectRows) {
        r.dispose();
      }
      _initCalculators();
    });
    _recalculateSgpaFromRows();
  }

  Widget _buildEmptyStateCard(String message, VoidCallback onAdd) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          const Icon(Icons.folder_open_rounded, size: 48, color: Color(0xFF94A3B8)),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Subject Record'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2980B9),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddSemesterDialog() {
    final textController = TextEditingController(text: 'Semester ${_semesters.length + 1}');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Semester'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(labelText: 'Semester Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                setState(() {
                  _semesters.add(SemesterModel(
                    number: _semesters.length + 1,
                    name: textController.text.trim(),
                    subjects: [],
                  ));
                  _selectedSemIndex = _semesters.length - 1;
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddSubjectDialog(SemesterModel? sem) {
    if (sem == null) return;
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController(text: 'CS${sem.number}0${sem.subjects.length + 1}');
    final credCtrl = TextEditingController(text: '3');
    String selectedGrade = 'A+';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text('Add Subject to ${sem.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Subject Name')),
              const SizedBox(height: 8),
              TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Subject Code')),
              const SizedBox(height: 8),
              TextField(controller: credCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Credits (1-6)')),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: selectedGrade,
                decoration: const InputDecoration(labelText: 'VSBEC Grade'),
                items: ['O', 'A+', 'A', 'B+', 'B', 'C', 'RA', 'SA', 'W'].map((g) {
                  return DropdownMenuItem(
                    value: g,
                    child: Text(VsbecGradeCalculator.getGradeDisplay(g)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setModalState(() => selectedGrade = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty) {
                  int creds = int.tryParse(credCtrl.text) ?? 3;
                  setState(() {
                    sem.subjects.add(SubjectModel(
                      name: nameCtrl.text.trim(),
                      code: codeCtrl.text.trim(),
                      credits: creds,
                      grade: selectedGrade,
                    ));
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Save Subject'),
            ),
          ],
        ),
      ),
    );
  }

  void _showVsbecInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('VSBEC Grading System & Rules'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('VSB Engineering College Grade Points:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('• O  = 10\n• A+ = 9\n• A  = 8\n• B+ = 7\n• B  = 6\n• C  = 5'),
              SizedBox(height: 10),
              Text('EXCLUDED GRADES (Excluded from SGPA/CGPA):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
              SizedBox(height: 4),
              Text('• RA = Re-Appear (Excluded)\n• SA = Shortage of Attendance (Excluded)\n• W  = Withdrawal (Excluded)'),
              SizedBox(height: 12),
              Text('Calculations:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('• SGPA = Σ(Credit × Grade Point) / Σ(Eligible Credits)\n• CGPA = Σ(All Course Credits × Grade Points) / Σ(All Eligible Credits)\n• Percentage = CGPA × 10'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Got it')),
        ],
      ),
    );
  }
}
