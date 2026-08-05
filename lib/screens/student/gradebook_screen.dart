import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:clg_application/core/constants/app_colors.dart';

class GradebookScreen extends StatefulWidget {
  const GradebookScreen({super.key});

  @override
  State<GradebookScreen> createState() => _GradebookScreenState();
}

class _GradebookScreenState extends State<GradebookScreen> {
  int _selectedSemesterIndex = 3; // Default to Current Sem 4
  double _targetCgpa = 9.00;
  bool _showGpaPlanner = false;
  String _searchQuery = '';

  final double _currentCgpa = 8.75;
  final int _completedCredits = 72;
  final int _totalDegreeCredits = 160;

  final List<Map<String, dynamic>> _semesters = [
    {
      'sem': 'Sem 1',
      'sgpa': 8.40,
      'credits': 20,
      'status': 'Completed',
      'courses': [
        {
          'code': '18MAT101T',
          'title': 'Calculus and Linear Algebra',
          'credits': 4,
          'grade': 'A+',
          'gradePoint': 9.0,
          'cat1': 21,
          'cat2': 23,
          'assignment': 9,
          'endSem': 42,
          'totalMark': 85,
        },
        {
          'code': '18PHY102J',
          'title': 'Engineering Physics',
          'credits': 4,
          'grade': 'A',
          'gradePoint': 8.0,
          'cat1': 19,
          'cat2': 21,
          'assignment': 8,
          'endSem': 39,
          'totalMark': 77,
        },
        {
          'code': '18CSE101J',
          'title': 'Programming in C',
          'credits': 4,
          'grade': 'O',
          'gradePoint': 10.0,
          'cat1': 24,
          'cat2': 25,
          'assignment': 10,
          'endSem': 47,
          'totalMark': 96,
        },
        {
          'code': '18ENG101T',
          'title': 'Technical Communication',
          'credits': 3,
          'grade': 'A+',
          'gradePoint': 9.0,
          'cat1': 22,
          'cat2': 22,
          'assignment': 9,
          'endSem': 43,
          'totalMark': 86,
        },
        {
          'code': '18EEE101T',
          'title': 'Basic Electrical Engineering',
          'credits': 5,
          'grade': 'B+',
          'gradePoint': 7.0,
          'cat1': 17,
          'cat2': 18,
          'assignment': 7,
          'endSem': 35,
          'totalMark': 67,
        },
      ],
    },
    {
      'sem': 'Sem 2',
      'sgpa': 8.65,
      'credits': 20,
      'status': 'Completed',
      'courses': [
        {
          'code': '18MAT201T',
          'title': 'Advanced Calculus & Complex Analysis',
          'credits': 4,
          'grade': 'A+',
          'gradePoint': 9.0,
          'cat1': 22,
          'cat2': 23,
          'assignment': 9,
          'endSem': 44,
          'totalMark': 88,
        },
        {
          'code': '18CSE201J',
          'title': 'Object Oriented Programming (Java)',
          'credits': 4,
          'grade': 'O',
          'gradePoint': 10.0,
          'cat1': 25,
          'cat2': 24,
          'assignment': 10,
          'endSem': 48,
          'totalMark': 97,
        },
        {
          'code': '18ECE202T',
          'title': 'Digital Logic & Circuit Design',
          'credits': 4,
          'grade': 'A',
          'gradePoint': 8.0,
          'cat1': 20,
          'cat2': 20,
          'assignment': 8,
          'endSem': 40,
          'totalMark': 78,
        },
        {
          'code': '18CHM201J',
          'title': 'Environmental Science & Chemistry',
          'credits': 3,
          'grade': 'A+',
          'gradePoint': 9.0,
          'cat1': 23,
          'cat2': 22,
          'assignment': 9,
          'endSem': 42,
          'totalMark': 86,
        },
        {
          'code': '18MEC201T',
          'title': 'Engineering Graphics & Modeling',
          'credits': 5,
          'grade': 'A',
          'gradePoint': 8.0,
          'cat1': 20,
          'cat2': 21,
          'assignment': 9,
          'endSem': 39,
          'totalMark': 79,
        },
      ],
    },
    {
      'sem': 'Sem 3',
      'sgpa': 8.80,
      'credits': 18,
      'status': 'Completed',
      'courses': [
        {
          'code': '18CSC301J',
          'title': 'Data Structures and Algorithms',
          'credits': 4,
          'grade': 'O',
          'gradePoint': 10.0,
          'cat1': 24,
          'cat2': 25,
          'assignment': 10,
          'endSem': 46,
          'totalMark': 95,
        },
        {
          'code': '18CSC302J',
          'title': 'Computer Organization & Architecture',
          'credits': 4,
          'grade': 'A+',
          'gradePoint': 9.0,
          'cat1': 22,
          'cat2': 23,
          'assignment': 9,
          'endSem': 43,
          'totalMark': 87,
        },
        {
          'code': '18CSC303T',
          'title': 'Discrete Mathematical Structures',
          'credits': 3,
          'grade': 'A',
          'gradePoint': 8.0,
          'cat1': 20,
          'cat2': 21,
          'assignment': 8,
          'endSem': 40,
          'totalMark': 79,
        },
        {
          'code': '18CSC304J',
          'title': 'Database Management Systems',
          'credits': 4,
          'grade': 'A+',
          'gradePoint': 9.0,
          'cat1': 23,
          'cat2': 22,
          'assignment': 10,
          'endSem': 44,
          'totalMark': 89,
        },
        {
          'code': '18PD103L',
          'title': 'Soft Skills & Personality Development',
          'credits': 3,
          'grade': 'O',
          'gradePoint': 10.0,
          'cat1': 25,
          'cat2': 25,
          'assignment': 10,
          'endSem': 49,
          'totalMark': 99,
        },
      ],
    },
    {
      'sem': 'Sem 4',
      'sgpa': 8.90,
      'credits': 14,
      'status': 'Ongoing',
      'courses': [
        {
          'code': '18CSC401J',
          'title': 'Operating Systems',
          'credits': 4,
          'grade': 'A+',
          'gradePoint': 9.0,
          'cat1': 23,
          'cat2': 24,
          'assignment': 9,
          'endSem': 0, // Pending
          'totalMark': 56, // Out of 60 internal
        },
        {
          'code': '18CSC402J',
          'title': 'Design & Analysis of Algorithms',
          'credits': 4,
          'grade': 'O',
          'gradePoint': 10.0,
          'cat1': 25,
          'cat2': 24,
          'assignment': 10,
          'endSem': 0, // Pending
          'totalMark': 59,
        },
        {
          'code': '18CSC403T',
          'title': 'Theory of Computation',
          'credits': 3,
          'grade': 'A',
          'gradePoint': 8.0,
          'cat1': 21,
          'cat2': 20,
          'assignment': 8,
          'endSem': 0, // Pending
          'totalMark': 49,
        },
        {
          'code': '18CSC404J',
          'title': 'Software Engineering',
          'credits': 3,
          'grade': 'A+',
          'gradePoint': 9.0,
          'cat1': 22,
          'cat2': 23,
          'assignment': 9,
          'endSem': 0, // Pending
          'totalMark': 54,
        },
      ],
    },
  ];

  double _calculateRequiredSgpa() {
    // Current completed credits: 72, Current CGPA: 8.75
    // Total degree credits: 160. Remaining credits: 88 (approx 4 semesters remaining)
    double currentPoints = _currentCgpa * _completedCredits;
    double targetTotalPoints = _targetCgpa * _totalDegreeCredits;
    double neededPoints = targetTotalPoints - currentPoints;
    double remainingCredits = (_totalDegreeCredits - _completedCredits).toDouble();
    if (remainingCredits <= 0) return 0;
    return neededPoints / remainingCredits;
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'O':
        return const Color(0xFF4CAF50);
      case 'A+':
        return const Color(0xFF3F51B5);
      case 'A':
        return const Color(0xFF00ACC1);
      case 'B+':
        return const Color(0xFFFF9800);
      case 'B':
        return const Color(0xFFFF5722);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentSem = _semesters[_selectedSemesterIndex];
    final List<Map<String, dynamic>> allCourses = currentSem['courses'] as List<Map<String, dynamic>>;
    final filteredCourses = allCourses.where((c) {
      final title = (c['title'] as String).toLowerCase();
      final code = (c['code'] as String).toLowerCase();
      final query = _searchQuery.toLowerCase();
      return title.contains(query) || code.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Academic Gradebook',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Real-time CGPA, SGPA & Exam Marks Breakdown',
                      style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _showGpaPlanner = !_showGpaPlanner;
                    });
                  },
                  icon: Icon(
                    _showGpaPlanner ? Icons.analytics_outlined : Icons.calculate_outlined,
                    size: 18,
                  ),
                  label: Text(_showGpaPlanner ? 'Hide Calculator' : 'GPA Planner'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Top CGPA Summary Cards Row
            _buildCgpaSummaryCard(),
            const SizedBox(height: 16),

            // Target GPA Planning Tool (If Toggled)
            if (_showGpaPlanner) ...[
              _buildGpaPlannerWidget(),
              const SizedBox(height: 16),
            ],

            // Semester Progression Trend Graph Bar
            _buildSemesterTrendWidget(),
            const SizedBox(height: 20),

            // Semester Selector Pills
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Semester Grades',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3142)),
                ),
                Text(
                  '${currentSem['sem']} SGPA: ${currentSem['sgpa']}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Semester Pills Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_semesters.length, (index) {
                  final sem = _semesters[index];
                  final isSelected = _selectedSemesterIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text('${sem['sem']} (${sem['sgpa']})'),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedSemesterIndex = index;
                          });
                        }
                      },
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF616161),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : const Color(0xFFE0E0E0),
                        ),
                      ),
                      showCheckmark: false,
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),

            // Search Bar for Courses
            TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search course by name or code...',
                hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
                prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF9E9E9E)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFEFEFEF)),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Course Cards List
            filteredCourses.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text('No courses found matching your query.', style: TextStyle(color: Color(0xFF9E9E9E))),
                    ),
                  )
                : Column(
                    children: filteredCourses.map((c) => _buildCourseCard(c)).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  // ── Top Summary Header ────────────────────────
  Widget _buildCgpaSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3F51B5), Color(0xFF1A237E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3F51B5).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              CircularPercentIndicator(
                radius: 44.0,
                lineWidth: 8.0,
                percent: _currentCgpa / 10.0,
                center: Text(
                  _currentCgpa.toStringAsFixed(2),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                progressColor: const Color(0xFF69F0AE),
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                circularStrokeCap: CircularStrokeCap.round,
                animation: true,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text(
                          'Cumulative GPA (CGPA)',
                          style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.verified_rounded, color: Color(0xFF69F0AE), size: 14),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'First Class with Distinction',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildBadgeChip('Credits: $_completedCredits / $_totalDegreeCredits', Colors.white24),
                        const SizedBox(width: 8),
                        _buildBadgeChip('Sem 4 SGPA: 8.90', const Color(0xFF69F0AE).withValues(alpha: 0.3)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Total Courses', '19 Passed'),
              _buildStatItem('Highest Grade', 'O (9 Courses)'),
              _buildStatItem('Academic Standing', 'Top 5%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeChip(String label, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildStatItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white60, fontSize: 10)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }

  // ── GPA Planning Calculator Tool ──────────────────────
  Widget _buildGpaPlannerWidget() {
    final requiredSgpa = _calculateRequiredSgpa();
    final isPossible = requiredSgpa <= 10.0;
    final isAlreadyAchieved = requiredSgpa <= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.calculate_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Target CGPA Estimator (What-If Tool)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2D3142)),
                  ),
                  Text(
                    'Estimate required SGPA for remaining 4 semesters',
                    style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Target Goal CGPA:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              Text(
                _targetCgpa.toStringAsFixed(2),
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.primary),
              ),
            ],
          ),
          Slider(
            value: _targetCgpa,
            min: 7.0,
            max: 10.0,
            divisions: 30,
            activeColor: AppColors.primary,
            label: _targetCgpa.toStringAsFixed(2),
            onChanged: (val) {
              setState(() {
                _targetCgpa = val;
              });
            },
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPossible
                  ? (isAlreadyAchieved ? const Color(0xFFE8F5E9) : const Color(0xFFE3F2FD))
                  : const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  isPossible
                      ? (isAlreadyAchieved ? Icons.check_circle_rounded : Icons.info_rounded)
                      : Icons.warning_rounded,
                  color: isPossible
                      ? (isAlreadyAchieved ? const Color(0xFF2E7D32) : const Color(0xFF1565C0))
                      : const Color(0xFFC62828),
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isPossible
                            ? (isAlreadyAchieved
                                ? 'Target Already Achieved!'
                                : 'Required SGPA per remaining semester: ${requiredSgpa.toStringAsFixed(2)}')
                            : 'Target Unattainable (Max 10.00 SGPA required)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: isPossible
                              ? (isAlreadyAchieved ? const Color(0xFF2E7D32) : const Color(0xFF1565C0))
                              : const Color(0xFFC62828),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isPossible
                            ? 'Based on 88 remaining credits across Semesters 5, 6, 7 & 8.'
                            : 'Try adjusting target CGPA.',
                        style: const TextStyle(fontSize: 10, color: Color(0xFF616161)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Semester Trend Bar Progress Widget ────────────────
  Widget _buildSemesterTrendWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SGPA Performance Trajectory',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2D3142)),
              ),
              Text('Sem 1 to Sem 4', style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(_semesters.length, (idx) {
              final sem = _semesters[idx];
              final sgpa = sem['sgpa'] as double;
              final heightPct = sgpa / 10.0;
              final isSelected = _selectedSemesterIndex == idx;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedSemesterIndex = idx;
                  });
                },
                child: Column(
                  children: [
                    Text(
                      sgpa.toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppColors.primary : const Color(0xFF757575),
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 28,
                      height: 80 * heightPct,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sem['sem'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? AppColors.primary : const Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Course Card Component ─────────────────────────────
  Widget _buildCourseCard(Map<String, dynamic> course) {
    final grade = course['grade'] as String;
    final gradeColor = _getGradeColor(grade);
    final cat1 = course['cat1'] as int;
    final cat2 = course['cat2'] as int;
    final assignment = course['assignment'] as int;
    final endSem = course['endSem'] as int;
    final totalMark = course['totalMark'] as int;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: gradeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: gradeColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              grade,
              style: TextStyle(fontWeight: FontWeight.w900, color: gradeColor, fontSize: 16),
            ),
          ),
          title: Text(
            course['title'] as String,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2D3142)),
          ),
          subtitle: Text(
            '${course['code']} • ${course['credits']} Credits • Points: ${course['gradePoint']}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$totalMark / 100',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2D3142)),
              ),
              const Text('Overall Score', style: TextStyle(fontSize: 9, color: Color(0xFF9E9E9E))),
            ],
          ),
          children: [
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 12),
            const Text(
              'Detailed Evaluation Breakdown',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF616161)),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildMarkProgressItem('CAT-1', cat1, 25, const Color(0xFF5C6BC0))),
                const SizedBox(width: 8),
                Expanded(child: _buildMarkProgressItem('CAT-2', cat2, 25, const Color(0xFF26A69A))),
                const SizedBox(width: 8),
                Expanded(child: _buildMarkProgressItem('Assignment', assignment, 10, const Color(0xFFFFA726))),
                const SizedBox(width: 8),
                Expanded(child: _buildMarkProgressItem('End Sem', endSem, 50, const Color(0xFFAB47BC))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarkProgressItem(String label, int mark, int maxMark, Color color) {
    final pct = mark / maxMark;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF616161))),
          const SizedBox(height: 4),
          Text(
            '$mark/$maxMark',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          LinearPercentIndicator(
            lineHeight: 4.0,
            percent: pct > 1.0 ? 1.0 : pct,
            progressColor: color,
            backgroundColor: color.withValues(alpha: 0.2),
            barRadius: const Radius.circular(4),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
