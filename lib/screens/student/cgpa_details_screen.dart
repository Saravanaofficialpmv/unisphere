import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clg_application/providers/gradebook_provider.dart';
import 'package:clg_application/screens/student/semester_grade_details_screen.dart';

class CgpaDetailsScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;
  final VoidCallback? onBack;

  const CgpaDetailsScreen({
    super.key,
    this.initialTabIndex = 0,
    this.onBack,
  });

  @override
  ConsumerState<CgpaDetailsScreen> createState() => _CgpaDetailsScreenState();
}

class _CgpaDetailsScreenState extends ConsumerState<CgpaDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isCalculatorOpen = false;

  // Local state for interactive CGPA calculator
  final List<CalcSemInputRow> _calcRows = [
    CalcSemInputRow(name: 'Sem 1', sgpa: 8.20, credits: 22),
    CalcSemInputRow(name: 'Sem 2', sgpa: 8.45, credits: 23),
    CalcSemInputRow(name: 'Sem 3', sgpa: 8.75, credits: 22),
    CalcSemInputRow(name: 'Sem 4', sgpa: 8.80, credits: 20),
  ];

  double _computedCgpa = 8.57;
  double _computedPercentage = 85.67;
  int _computedCredits = 87;

  @override
  void initState() {
    super.initState();
    final initialIdx = (widget.initialTabIndex >= 0 && widget.initialTabIndex < 4)
        ? widget.initialTabIndex
        : 0;
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: initialIdx,
    );
    _recalculateCalcCgpa();
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var r in _calcRows) {
      r.dispose();
    }
    super.dispose();
  }

  void _recalculateCalcCgpa() {
    int totalCreds = 0;
    double totalWeightedPts = 0.0;

    for (var r in _calcRows) {
      double sgpa = double.tryParse(r.sgpaController.text) ?? 0.0;
      int creds = int.tryParse(r.creditsController.text) ?? 0;
      if (creds > 0 && sgpa >= 0) {
        totalCreds += creds;
        totalWeightedPts += (sgpa.clamp(0.0, 10.0) * creds);
      }
    }

    final cgpa = totalCreds > 0 ? (totalWeightedPts / totalCreds).clamp(0.0, 10.0) : 0.0;

    setState(() {
      _computedCredits = totalCreds;
      _computedCgpa = cgpa;
      _computedPercentage = cgpa * 10.0;
    });
  }

  void _resetCalcRows() {
    setState(() {
      for (var r in _calcRows) {
        r.dispose();
      }
      _calcRows.clear();
      _calcRows.addAll([
        CalcSemInputRow(name: 'Sem 1', sgpa: 8.20, credits: 22),
        CalcSemInputRow(name: 'Sem 2', sgpa: 8.45, credits: 23),
        CalcSemInputRow(name: 'Sem 3', sgpa: 8.75, credits: 22),
        CalcSemInputRow(name: 'Sem 4', sgpa: 8.80, credits: 20),
      ]);
    });
    _recalculateCalcCgpa();
  }

  void _addCalcRow() {
    setState(() {
      _calcRows.add(CalcSemInputRow(
        name: 'Sem ${_calcRows.length + 1}',
        sgpa: 8.50,
        credits: 20,
      ));
    });
    _recalculateCalcCgpa();
  }

  void _removeCalcRow(int index) {
    if (_calcRows.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least 1 semester is required for calculation.')),
      );
      return;
    }
    setState(() {
      _calcRows.removeAt(index);
    });
    _recalculateCalcCgpa();
  }

  @override
  Widget build(BuildContext context) {
    final gradebookState = ref.watch(gradebookProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.maybePop(context);
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Academic Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              'Comprehensive academic analytics',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFF64748B),
              labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'CGPA'),
                Tab(text: 'Equivalent %'),
                Tab(text: 'Credits'),
                Tab(text: 'Current SGPA'),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildCgpaTab(gradebookState),
            _buildEquivalentScoreTab(gradebookState),
            _buildEligibleCreditsTab(gradebookState),
            _buildCurrentSgpaTab(gradebookState),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // TAB 0: OVERALL CGPA DETAILS
  // ===========================================================================

  Widget _buildCgpaTab(GradebookState gradebookState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverallSummaryCard(gradebookState),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Semester-wise Performance',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                '${gradebookState.semesters.length} Semesters',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSemesterList(gradebookState),
          const SizedBox(height: 24),
          _buildCalculationExplanationCard(gradebookState),
          const SizedBox(height: 24),
          _buildInteractiveCalculatorSection(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 1: EQUIVALENT SCORE DETAILS
  // ===========================================================================

  Widget _buildEquivalentScoreTab(GradebookState state) {
    final cgpa = state.overallCgpa;
    final percentage = state.overallPercentage;

    final gradeScale = [
      {'grade': 'O', 'title': 'Outstanding', 'points': '10', 'range': '91% – 100%', 'color': const Color(0xFF10B981)},
      {'grade': 'A+', 'title': 'Excellent', 'points': '9', 'range': '81% – 90%', 'color': const Color(0xFF059669)},
      {'grade': 'A', 'title': 'Very Good', 'points': '8', 'range': '71% – 80%', 'color': const Color(0xFF2563EB)},
      {'grade': 'B+', 'title': 'Good', 'points': '7', 'range': '61% – 70%', 'color': const Color(0xFF3B82F6)},
      {'grade': 'B', 'title': 'Above Average', 'points': '6', 'range': '56% – 60%', 'color': const Color(0xFF6366F1)},
      {'grade': 'C', 'title': 'Satisfactory', 'points': '5', 'range': '50% – 55%', 'color': const Color(0xFF8B5CF6)},
      {'grade': 'RA', 'title': 'Re-Appear', 'points': '0 (Excluded)', 'range': '< 50%', 'color': const Color(0xFFEF4444)},
      {'grade': 'SA', 'title': 'Shortage Att.', 'points': '0 (Excluded)', 'range': 'Att. < 75%', 'color': const Color(0xFFF59E0B)},
      {'grade': 'W', 'title': 'Withdrawn', 'points': '0 (Excluded)', 'range': 'Approved', 'color': const Color(0xFF64748B)},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Equivalent Score Prominent Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Equivalent Score Percentage',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFBFDBFE)),
                    ),
                    Icon(Icons.percent_rounded, color: Colors.white, size: 24),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${percentage.toStringAsFixed(2)}%',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'Converted from CGPA ${cgpa.toStringAsFixed(2)} using Formula: CGPA × 10',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Classification & Benchmark Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Degree Classification Benchmarks',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 12),
                _buildBenchmarkRow('First Class with Distinction', 'CGPA ≥ 9.00 (90%+)', cgpa >= 9.0),
                const Divider(height: 16, color: Color(0xFFF1F5F9)),
                _buildBenchmarkRow('First Class', 'CGPA 7.50 – 8.99 (75% – 89.9%)', cgpa >= 7.5 && cgpa < 9.0),
                const Divider(height: 16, color: Color(0xFFF1F5F9)),
                _buildBenchmarkRow('Second Class', 'CGPA 6.00 – 7.49 (60% – 74.9%)', cgpa >= 6.0 && cgpa < 7.5),
                const Divider(height: 16, color: Color(0xFFF1F5F9)),
                _buildBenchmarkRow('Pass Class', 'CGPA 5.00 – 5.99 (50% – 59.9%)', cgpa >= 5.0 && cgpa < 6.0),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Official VSBEC Grading Scale Reference Table
          const Text(
            'Official VSBEC Grading Scale Table',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: gradeScale.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
              itemBuilder: (context, index) {
                final item = gradeScale[index];
                final color = item['color'] as Color;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            item['grade'] as String,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'] as String,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Marks Range: ${item['range']}',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          'Point: ${item['points']}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildBenchmarkRow(String title, String range, bool isCurrent) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              isCurrent ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: isCurrent ? const Color(0xFF10B981) : const Color(0xFFCBD5E1),
              size: 20,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                    color: isCurrent ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                  ),
                ),
                Text(
                  range,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ],
        ),
        if (isCurrent)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: const Text(
              'Your Standing',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
            ),
          ),
      ],
    );
  }

  // ===========================================================================
  // TAB 2: ELIGIBLE CREDITS DETAILS
  // ===========================================================================

  Widget _buildEligibleCreditsTab(GradebookState state) {
    int totalEligible = state.overallEligibleCredits;
    int totalEarned = state.overallEarnedCredits;
    int degreeRequiredCredits = 160;

    // Compute registered vs excluded
    int totalRegistered = state.semesters.fold(0, (sum, sem) => sum + sem.registeredCredits);
    int totalExcluded = state.semesters.fold(0, (sum, sem) => sum + sem.excludedCount);

    // List of excluded courses across all semesters
    final excludedSubjects = <Map<String, String>>[];
    for (var sem in state.semesters) {
      for (var sub in sem.subjects) {
        if (sub.isExcluded) {
          excludedSubjects.add({
            'sem': sem.name,
            'code': sub.code,
            'name': sub.name,
            'credits': '${sub.credits}',
            'grade': sub.grade,
            'displayGrade': VsbecGradeCalculator.getGradeDisplay(sub.grade),
          });
        }
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Eligible Credits Banner Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0284C7), Color(0xFF0EA5E9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Eligible Academic Credits',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFE0F2FE)),
                    ),
                    Icon(Icons.school_rounded, color: Colors.white, size: 24),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$totalEligible',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '/ $totalRegistered Registered Credits',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFBAE6FD)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'Excludes $totalExcluded Course Credits (RA Re-Appear, SA Shortage, W Withdrawn)',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Degree Progress Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'B.Tech Degree Credit Completion',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    Text(
                      '${((totalEarned / degreeRequiredCredits) * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF0284C7)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: (totalEarned / degreeRequiredCredits).clamp(0.0, 1.0),
                    minHeight: 10,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0284C7)),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Earned: $totalEarned Credits',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0369A1)),
                    ),
                    Text(
                      'Target: $degreeRequiredCredits Credits',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Semester Credit Audit Breakdown List
          const Text(
            'Semester Credit Audit Breakdown',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.semesters.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final sem = state.semesters[index];

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F9FF),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFBAE6FD)),
                          ),
                          child: Text(
                            'Sem ${sem.number}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0369A1)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sem.name,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                            Text(
                              '${sem.subjects.length} Total Registered Courses',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${sem.eligibleCredits} / ${sem.registeredCredits} Creds',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                        ),
                        if (sem.excludedCount > 0)
                          Text(
                            '${sem.excludedCount} Excluded (RA/SA)',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                          )
                        else
                          const Text(
                            '100% Eligible',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Excluded Courses Registry Card
          const Text(
            'Excluded Arrear / Special Standing Registry',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 12),

          if (excludedSubjects.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_outline_rounded, color: Color(0xFF059669), size: 22),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No excluded subjects! All registered courses are active & eligible for CGPA calculation.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF064E3B)),
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: excludedSubjects.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final ex = excludedSubjects[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${ex['code']} • ${ex['name']}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                            Text(
                              '${ex['sem']} • ${ex['credits']} Credits',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFCD34D)),
                        ),
                        child: Text(
                          ex['displayGrade'] ?? '',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 3: CURRENT SGPA DETAILS
  // ===========================================================================

  Widget _buildCurrentSgpaTab(GradebookState state) {
    final sem = state.currentSemester;
    if (sem == null) {
      return const Center(child: Text('No active semester details found.'));
    }

    final sgpaVal = sem.sgpa;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current SGPA Banner Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                  blurRadius: 14,
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
                    Text(
                      '${sem.name} SGPA',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFFEF3C7)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'ACTIVE SEMESTER',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  sgpaVal.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${sem.eligibleCredits} Eligible Credits • ${sem.subjects.length} Registered Courses',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${sem.name} Course Breakdown',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              TextButton.icon(
                onPressed: () {
                  final idx = state.semesters.indexOf(sem);
                  if (idx != -1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SemesterGradeDetailsScreen(semesterIndex: idx),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.open_in_new_rounded, size: 14, color: Color(0xFF2563EB)),
                label: const Text(
                  'Full View',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Course Cards List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sem.subjects.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final sub = sem.subjects[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        sub.code,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sub.name,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                          Text(
                            '${sub.credits} Credits • W.Points: ${sub.weightedPoints.toInt()}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        VsbecGradeCalculator.getGradeDisplay(sub.grade),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFFD97706)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ===========================================================================
  // SHARED WIDGET HELPERS FOR TAB 0
  // ===========================================================================

  Widget _buildOverallSummaryCard(GradebookState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overall CGPA',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.overallCgpa.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF10B981),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Text(
                        state.academicStanding,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.emoji_events_rounded, color: Color(0xFF10B981), size: 24),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.percent_rounded, color: Color(0xFF3B82F6), size: 18),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Equivalent Score',
                          style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '${state.overallPercentage.toStringAsFixed(2)}%',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Formula: CGPA × 10',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterList(GradebookState state) {
    if (state.semesters.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: Text('No semesters available.')),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.semesters.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final sem = state.semesters[index];
        final sgpaVal = sem.sgpa;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SemesterGradeDetailsScreen(semesterIndex: index),
                ),
              );
            },
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                'S${sem.number}',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sem.name,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Credits: ${sem.eligibleCredits} • ${sem.subjects.length} Subjects',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'SGPA: ${sgpaVal.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: sem.isCurrent ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  sem.isCurrent ? 'Current' : 'Completed',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: sem.isCurrent ? const Color(0xFF059669) : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 22),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (sgpaVal / 10.0).clamp(0.0, 1.0),
                            minHeight: 6,
                            backgroundColor: const Color(0xFFE2E8F0),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              sgpaVal >= 8.5
                                  ? const Color(0xFF10B981)
                                  : (sgpaVal >= 7.5 ? const Color(0xFF3B82F6) : const Color(0xFFF59E0B)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${((sgpaVal / 10.0) * 100).toInt()}%',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalculationExplanationCard(GradebookState state) {
    final sumPoints = state.overallWeightedPoints;
    final sumCredits = state.overallEligibleCredits;
    final calcCgpa = state.overallCgpa;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.functions_rounded, color: Color(0xFF16A34A), size: 20),
          ),
          title: const Text(
            'How CGPA is Calculated',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          subtitle: const Text(
            'Institutional credit-weighted formula details',
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          'CGPA Formula',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'CGPA = Σ (Credit × Grade Point) / Σ Eligible Credits',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Rule Explanation:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Rather than simply averaging semester SGPAs, CGPA evaluates total weighted credit points earned across all registered eligible subjects divided by total eligible credits. Re-Appear (RA), Shortage (SA), and Withdrawn (W) grades are excluded.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'WORKED CALCULATION (YOUR ACTUAL DATA)',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Total Credit Points = ${sumPoints.toStringAsFixed(1)}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF064E3B)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Total Eligible Credits = $sumCredits',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF064E3B)),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'CGPA = ${sumPoints.toStringAsFixed(1)} / $sumCredits = ${calcCgpa.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF047857)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveCalculatorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _isCalculatorOpen = !_isCalculatorOpen;
              });
            },
            icon: Icon(
              _isCalculatorOpen ? Icons.keyboard_arrow_up_rounded : Icons.calculate_rounded,
              size: 20,
            ),
            label: Text(
              _isCalculatorOpen ? 'Hide CGPA Calculator' : 'Open CGPA Calculator',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        if (_isCalculatorOpen) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                  blurRadius: 14,
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
                    const Text(
                      'Interactive CGPA Calculator',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, size: 20, color: Color(0xFF64748B)),
                      onPressed: _resetCalcRows,
                      tooltip: 'Reset Rows',
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Dynamically estimate CGPA by modifying or adding semester SGPA and credits.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _calcRows.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final row = _calcRows[index];
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
                            onChanged: (val) => _recalculateCalcCgpa(),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                            decoration: InputDecoration(
                              labelText: 'SGPA',
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
                            onChanged: (val) => _recalculateCalcCgpa(),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              labelText: 'Credits',
                              labelStyle: const TextStyle(fontSize: 10),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.redAccent, size: 20),
                          onPressed: () => _removeCalcRow(index),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _addCalcRow,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add Semester Row', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2563EB),
                    side: const BorderSide(color: Color(0xFF2563EB)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
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
                          const Text('CALCULATED ESTIMATED CGPA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                          const SizedBox(height: 2),
                          Text('Total Credits: $_computedCredits', style: const TextStyle(fontSize: 12, color: Color(0xFF1E40AF))),
                          const SizedBox(height: 2),
                          Text('Equivalent Score: ${_computedPercentage.toStringAsFixed(2)}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8))),
                        ],
                      ),
                      Text(
                        _computedCgpa.toStringAsFixed(2),
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1D4ED8)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class CalcSemInputRow {
  TextEditingController nameController;
  TextEditingController sgpaController;
  TextEditingController creditsController;

  CalcSemInputRow({
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
