import 'dart:math';
import 'package:flutter/material.dart';

class GradebookScreen extends StatefulWidget {
  final bool initialShowPlanner;
  final VoidCallback? onBack;
  const GradebookScreen({super.key, this.initialShowPlanner = true, this.onBack});

  @override
  State<GradebookScreen> createState() => _GradebookScreenState();
}

class _GradebookScreenState extends State<GradebookScreen> {
  late TextEditingController _targetCgpaController;
  late TextEditingController _expectedSgpaController;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _gpaPlannerKey = GlobalKey();

  final double _currentCgpa = 8.45;
  final double _sem4Sgpa = 8.67;
  final int _earnedCredits = 96;
  final int _totalCredits = 128;
  final String _academicStanding = 'Excellent';

  int _selectedSemesterIndex = 3; // 0: Sem 1, 1: Sem 2, 2: Sem 3, 3: Sem 4
  final List<String> _semesters = ['Sem 1', 'Sem 2', 'Sem 3', 'Sem 4 (Current)'];

  double _calculatedRequiredSgpa = 9.23;
  double _estimatedFinalCgpa = 9.07;
  bool _isTableExpanded = true;
  String _selectedOverviewMode = 'CGPA & SGPA';

  final List<Map<String, dynamic>> _subjectMarks = [
    {
      'code': 'CS401',
      'subject': 'Data Structures',
      'credits': 4,
      'faculty': 'Dr. Sarah Jenkins',
      'internal': '18/20',
      'internalVal': 18,
      'quiz': '9/10',
      'quizVal': 9,
      'exam': '45/50',
      'examVal': 45,
      'total': '72/80',
      'totalPct': 90.0,
      'grade': 'A',
      'gradePoint': '9.0',
      'attendance': '94%',
      'remarks': 'Excellent command over trees, graphs, and dynamic programming.',
    },
    {
      'code': 'CS402',
      'subject': 'Database Mgmt. Systems',
      'credits': 4,
      'faculty': 'Prof. Robert Miller',
      'internal': '17/20',
      'internalVal': 17,
      'quiz': '8/10',
      'quizVal': 8,
      'exam': '43/50',
      'examVal': 43,
      'total': '68/80',
      'totalPct': 85.0,
      'grade': 'A',
      'gradePoint': '9.0',
      'attendance': '90%',
      'remarks': 'Strong SQL query optimization skills and normalizations.',
    },
    {
      'code': 'CS403',
      'subject': 'Operating Systems',
      'credits': 4,
      'faculty': 'Dr. Alan Vance',
      'internal': '16/20',
      'internalVal': 16,
      'quiz': '9/10',
      'quizVal': 9,
      'exam': '41/50',
      'examVal': 41,
      'total': '66/80',
      'totalPct': 82.5,
      'grade': 'B+',
      'gradePoint': '8.0',
      'attendance': '88%',
      'remarks': 'Good understanding of memory management and process scheduling.',
    },
    {
      'code': 'CS404',
      'subject': 'Computer Networks',
      'credits': 3,
      'faculty': 'Prof. Elena Rostova',
      'internal': '15/20',
      'internalVal': 15,
      'quiz': '8/10',
      'quizVal': 8,
      'exam': '40/50',
      'examVal': 40,
      'total': '63/80',
      'totalPct': 78.75,
      'grade': 'B+',
      'gradePoint': '8.0',
      'attendance': '85%',
      'remarks': 'Solid performance on TCP/IP protocol stack and routing.',
    },
    {
      'code': 'CS405',
      'subject': 'Software Engineering',
      'credits': 3,
      'faculty': 'Dr. Michael Chang',
      'internal': '17/20',
      'internalVal': 17,
      'quiz': '9/10',
      'quizVal': 9,
      'exam': '44/50',
      'examVal': 44,
      'total': '70/80',
      'totalPct': 87.5,
      'grade': 'A',
      'gradePoint': '9.0',
      'attendance': '96%',
      'remarks': 'Outstanding Agile project architecture and documentation.',
    },
    {
      'code': 'HS401',
      'subject': 'Professional Ethics',
      'credits': 2,
      'faculty': 'Dr. Martha Stewart',
      'internal': '18/20',
      'internalVal': 18,
      'quiz': '10/10',
      'quizVal': 10,
      'exam': '46/50',
      'examVal': 46,
      'total': '74/80',
      'totalPct': 92.5,
      'grade': 'A+',
      'gradePoint': '10.0',
      'attendance': '98%',
      'remarks': 'Exceptional case study analysis and ethical reasoning.',
    },
  ];

  final Map<int, List<Map<String, dynamic>>> _allSemestersData = {
    1: [
      {'code': 'CS101', 'subject': 'Intro to Programming', 'credits': 4, 'total': '70/80', 'grade': 'A', 'gradePoint': '9.0'},
      {'code': 'MA101', 'subject': 'Engineering Mathematics I', 'credits': 4, 'total': '58/80', 'grade': 'B', 'gradePoint': '7.0'},
      {'code': 'PH101', 'subject': 'Engineering Physics', 'credits': 4, 'total': '62/80', 'grade': 'B+', 'gradePoint': '8.0'},
      {'code': 'EE101', 'subject': 'Basic Electrical Engg', 'credits': 3, 'total': '54/80', 'grade': 'B', 'gradePoint': '7.0'},
      {'code': 'HS101', 'subject': 'Technical Communication', 'credits': 2, 'total': '72/80', 'grade': 'A+', 'gradePoint': '10.0'},
    ],
    2: [
      {'code': 'CS201', 'subject': 'Object Oriented Programming', 'credits': 4, 'total': '72/80', 'grade': 'A', 'gradePoint': '9.0'},
      {'code': 'MA201', 'subject': 'Engineering Mathematics II', 'credits': 4, 'total': '65/80', 'grade': 'B+', 'gradePoint': '8.0'},
      {'code': 'CS202', 'subject': 'Digital Logic & Circuitry', 'credits': 4, 'total': '68/80', 'grade': 'A', 'gradePoint': '9.0'},
      {'code': 'CS203', 'subject': 'Discrete Structures', 'credits': 3, 'total': '60/80', 'grade': 'B+', 'gradePoint': '8.0'},
      {'code': 'EV201', 'subject': 'Environmental Studies', 'credits': 2, 'total': '74/80', 'grade': 'A+', 'gradePoint': '10.0'},
    ],
    3: [
      {'code': 'CS301', 'subject': 'Design & Analysis of Algo', 'credits': 4, 'total': '71/80', 'grade': 'A', 'gradePoint': '9.0'},
      {'code': 'CS302', 'subject': 'Computer Architecture', 'credits': 4, 'total': '66/80', 'grade': 'B+', 'gradePoint': '8.0'},
      {'code': 'CS303', 'subject': 'Theory of Computation', 'credits': 4, 'total': '64/80', 'grade': 'B+', 'gradePoint': '8.0'},
      {'code': 'CS304', 'subject': 'Object-Oriented Design', 'credits': 3, 'total': '70/80', 'grade': 'A', 'gradePoint': '9.0'},
      {'code': 'MA301', 'subject': 'Probability & Statistics', 'credits': 3, 'total': '69/80', 'grade': 'A', 'gradePoint': '9.0'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _targetCgpaController = TextEditingController(text: '9.00');
    _expectedSgpaController = TextEditingController(text: '9.50');
    _calculateTargetGpa();
    _calculateWhatIf();

    if (widget.initialShowPlanner) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showInteractiveCgpaCalculatorModal(context);
        }
      });
    }
  }

  @override
  void dispose() {
    _targetCgpaController.dispose();
    _expectedSgpaController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _calculateTargetGpa() {
    final target = double.tryParse(_targetCgpaController.text) ?? 9.00;
    int remainingCredits = _totalCredits - _earnedCredits;
    if (remainingCredits <= 0) {
      setState(() => _calculatedRequiredSgpa = 0.0);
      return;
    }
    double currentPoints = _currentCgpa * _earnedCredits;
    double targetTotalPoints = target * _totalCredits;
    double neededPoints = targetTotalPoints - currentPoints;
    double required = neededPoints / remainingCredits;
    setState(() {
      _calculatedRequiredSgpa = required.clamp(0.0, 10.0);
    });
  }

  void _calculateWhatIf() {
    final expectedSgpa = double.tryParse(_expectedSgpaController.text) ?? 9.50;
    double totalPoints = (_currentCgpa * 4) + expectedSgpa;
    double estimated = totalPoints / 5.0;
    setState(() {
      _estimatedFinalCgpa = double.parse(estimated.toStringAsFixed(2));
    });
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A+':
        return const Color(0xFF10B981); // Emerald
      case 'A':
        return const Color(0xFF34D399); // Mint
      case 'B+':
        return const Color(0xFFFBBF24); // Amber
      case 'B':
        return const Color(0xFFF97316); // Orange
      default:
        return const Color(0xFF8B5CF6); // Purple
    }
  }

  Color _getGradeBgColor(String grade) {
    return _getGradeColor(grade).withValues(alpha: 0.15);
  }

  void _scrollToGpaPlanner() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final keyContext = _gpaPlannerKey.currentContext;
      if (keyContext != null && keyContext.mounted) {
        Scrollable.ensureVisible(
          keyContext,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // ── MODALS & BOTTOM SHEETS ────────────────────────────────────────────────

  // 1. View All Subjects Detail Screen / Modal
  void _showAllSubjectsDetailModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          int currentSemTab = _selectedSemesterIndex + 1;
          List<Map<String, dynamic>> displayedSubjects = currentSemTab == 4
              ? _subjectMarks
              : (_allSemestersData[currentSemTab] ?? []);

          return Container(
            height: MediaQuery.of(context).size.height * 0.88,
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Top Handle Bar & Title
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F172A),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'All Subject Marks & Assessment Details',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Semester Filter Chips inside Modal
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(4, (index) {
                            final semNum = index + 1;
                            final isSel = currentSemTab == semNum;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text('Sem $semNum ${semNum == 4 ? '(Current)' : ''}'),
                                selected: isSel,
                                onSelected: (val) {
                                  if (val) {
                                    setModalState(() {
                                      currentSemTab = semNum;
                                    });
                                  }
                                },
                                selectedColor: const Color(0xFF7C3AED),
                                backgroundColor: const Color(0xFF1E293B),
                                labelStyle: TextStyle(
                                  color: isSel ? Colors.white : const Color(0xFF94A3B8),
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                  fontSize: 11,
                                ),
                                showCheckmark: false,
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),

                // Subjects Content List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: displayedSubjects.length,
                    itemBuilder: (context, index) {
                      final item = displayedSubjects[index];
                      final grade = item['grade'] as String? ?? 'A';
                      final gradeColor = _getGradeColor(grade);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            _showSubjectDetailBottomSheet(context, item);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['code'] as String? ?? 'CS400',
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED)),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            item['subject'] as String,
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getGradeBgColor(grade),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Grade $grade (${item['gradePoint']} GP)',
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: gradeColor),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                                const SizedBox(height: 12),

                                // Details Row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildDetailChip('Internal', item['internal'] as String? ?? '18/20'),
                                    _buildDetailChip('Quiz', item['quiz'] as String? ?? '9/10'),
                                    _buildDetailChip('Exam', item['exam'] as String? ?? '45/50'),
                                    _buildDetailChip('Total', item['total'] as String? ?? '72/80', isHighlight: true),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailChip(String title, String val, {bool isHighlight = false}) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
        const SizedBox(height: 2),
        Text(
          val,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isHighlight ? const Color(0xFF2563EB) : const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  // 2. Subject Detail Bottom Sheet
  void _showSubjectDetailBottomSheet(BuildContext context, Map<String, dynamic> item) {
    final grade = item['grade'] as String? ?? 'A';
    final gradeColor = _getGradeColor(grade);
    final totalPct = item['totalPct'] as double? ?? 88.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['code'] as String? ?? 'CS401',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['subject'] as String,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getGradeBgColor(grade),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(grade, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: gradeColor)),
                      Text('${item['gradePoint']} GP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: gradeColor)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.person_outline_rounded, size: 16, color: Color(0xFF64748B)),
                const SizedBox(width: 6),
                Text(
                  'Faculty: ${item['faculty'] ?? 'Dr. Sarah Jenkins'}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                ),
                const Spacer(),
                const Icon(Icons.auto_stories_rounded, size: 16, color: Color(0xFF64748B)),
                const SizedBox(width: 6),
                Text(
                  '${item['credits'] ?? 4} Credits',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFF1F5F9)),
            const SizedBox(height: 12),

            const Text('Assessment Weightage & Progress', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 12),

            _buildAssessmentProgressBar('Internal Continuous Evaluation (20%)', item['internal'] as String? ?? '18/20', 0.90, const Color(0xFF7C3AED)),
            const SizedBox(height: 10),
            _buildAssessmentProgressBar('Quizzes & Assignments (10%)', item['quiz'] as String? ?? '9/10', 0.90, const Color(0xFF2563EB)),
            const SizedBox(height: 10),
            _buildAssessmentProgressBar('End Semester Examination (50%)', item['exam'] as String? ?? '45/50', 0.90, const Color(0xFF10B981)),
            const SizedBox(height: 10),
            _buildAssessmentProgressBar('Aggregated Total Score (100%)', item['total'] as String? ?? '72/80', totalPct / 100.0, const Color(0xFFD97706), isBold: true),

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.rate_review_outlined, color: Color(0xFF7C3AED), size: 18),
                      const SizedBox(width: 8),
                      const Text('Faculty Feedback & Remarks', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      const Spacer(),
                      Text('Att. ${item['attendance'] ?? '92%'}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['remarks'] as String? ?? 'Consistent attendance and strong problem-solving skills in coursework.',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF475569), height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Close Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentProgressBar(String label, String score, double progress, Color color, {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 11, fontWeight: isBold ? FontWeight.bold : FontWeight.w500, color: const Color(0xFF334155))),
            Text(score, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: isBold ? 8 : 6,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  // 3. Stat Card Modals
  void _showCgpaBreakdownModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.school_rounded, color: Color(0xFF7C3AED), size: 24),
                SizedBox(width: 10),
                Text('CGPA Breakdown & Calculation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFF3E8FF), borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Cumulative GPA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF7C3AED))),
                      const SizedBox(height: 4),
                      Text('$_currentCgpa / 10.0', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF7C3AED))),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                    child: const Text('Top 8% in Batch', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED))),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text('Formula: Σ (Grade Points × Credits) / Total Earned Credits', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
            const SizedBox(height: 12),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Sem 1 SGPA: 7.21 (24 Cr)', style: TextStyle(fontSize: 11, color: Color(0xFF334155))),
                Text('Sem 2 SGPA: 7.89 (24 Cr)', style: TextStyle(fontSize: 11, color: Color(0xFF334155))),
              ],
            ),
            const SizedBox(height: 6),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Sem 3 SGPA: 8.12 (24 Cr)', style: TextStyle(fontSize: 11, color: Color(0xFF334155))),
                Text('Sem 4 SGPA: 8.67 (24 Cr)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), padding: const EdgeInsets.symmetric(vertical: 12)),
                child: const Text('Got it', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSgpaBreakdownModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.trending_up_rounded, color: Color(0xFF2563EB), size: 24),
                SizedBox(width: 10),
                Text('Semester 4 SGPA Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Current SGPA (Sem 4)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2563EB))),
                      const SizedBox(height: 4),
                      Text('$_sem4Sgpa / 10.0', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF2563EB))),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                    child: const Text('Rank #4 in Class', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text('Highlights of Semester 4:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 6),
            const Text('• Highest grade earned in Professional Ethics (A+)', style: TextStyle(fontSize: 11, color: Color(0xFF475569))),
            const SizedBox(height: 4),
            const Text('• 6 out of 6 subjects passed with Grade B+ or higher', style: TextStyle(fontSize: 11, color: Color(0xFF475569))),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), padding: const EdgeInsets.symmetric(vertical: 12)),
                child: const Text('Close', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreditsBreakdownModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.menu_book_rounded, color: Color(0xFF059669), size: 24),
                SizedBox(width: 10),
                Text('Total Credit Distribution', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Earned Credits', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF059669))),
                      Text('$_earnedCredits / $_totalCredits Credits (75%)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: const LinearProgressIndicator(
                      value: 96 / 128,
                      minHeight: 8,
                      backgroundColor: Colors.white,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text('Category Breakdown:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 8),
            const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Core Departmental Courses', style: TextStyle(fontSize: 11, color: Color(0xFF334155))), Text('60 / 72 Credits', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))]),
            const SizedBox(height: 4),
            const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Professional Electives', style: TextStyle(fontSize: 11, color: Color(0xFF334155))), Text('18 / 24 Credits', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))]),
            const SizedBox(height: 4),
            const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Open Electives & Humanities', style: TextStyle(fontSize: 11, color: Color(0xFF334155))), Text('6 / 12 Credits', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))]),
            const SizedBox(height: 4),
            const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Labs & Capstone Projects', style: TextStyle(fontSize: 11, color: Color(0xFF334155))), Text('12 / 20 Credits', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))]),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), padding: const EdgeInsets.symmetric(vertical: 12)),
                child: const Text('Close', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAcademicStandingModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.workspace_premium_rounded, color: Color(0xFFD97706), size: 24),
                SizedBox(width: 10),
                Text('Academic Standing & Recognition', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: Color(0xFFF59E0B), shape: BoxShape.circle),
                    child: const Icon(Icons.star_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Current Standing: Excellent', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                      SizedBox(height: 2),
                      Text('Dean\'s Honor Roll Eligible (CGPA >= 8.5)', style: TextStyle(fontSize: 11, color: Color(0xFFB45309))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text('Standing Criteria Guidelines:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 6),
            const Text('• Excellent: CGPA >= 8.50 with 0 active backlogs', style: TextStyle(fontSize: 11, color: Color(0xFF475569))),
            const SizedBox(height: 4),
            const Text('• Very Good: CGPA 7.50 – 8.49', style: TextStyle(fontSize: 11, color: Color(0xFF475569))),
            const SizedBox(height: 4),
            const Text('• Good: CGPA 6.50 – 7.49', style: TextStyle(fontSize: 11, color: Color(0xFF475569))),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD97706), padding: const EdgeInsets.symmetric(vertical: 12)),
                child: const Text('Awesome', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 4. Quick Action Modals
  void _showReportDownloadPreviewModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.80,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.file_download_rounded, color: Color(0xFF2563EB), size: 24),
                SizedBox(width: 10),
                Text('Official Grade Report Preview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              ],
            ),
            const SizedBox(height: 16),

            // Digital Report Card Box
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('UNISPHERE ACADEMIC SERVICES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED))),
                              Text('OFFICIAL SEMESTER REPORT', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.verified_rounded, color: Color(0xFF2563EB), size: 20),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Color(0xFFE2E8F0)),
                      const SizedBox(height: 10),
                      const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Student Name: Alex Morgan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)), Text('ID: STU2024892', style: TextStyle(fontSize: 11))]),
                      const SizedBox(height: 4),
                      const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Program: B.Tech Computer Science', style: TextStyle(fontSize: 11)), Text('Sem: 4 (Spring 2026)', style: TextStyle(fontSize: 11))]),
                      const SizedBox(height: 12),
                      const Text('Semester Summary:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      ..._subjectMarks.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${item['code']} - ${item['subject']}', style: const TextStyle(fontSize: 11)),
                            Text('${item['total']} (${item['grade']})', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )),
                      const SizedBox(height: 12),
                      const Divider(color: Color(0xFFE2E8F0)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Semester SGPA: $_sem4Sgpa', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                          Text('Cumulative CGPA: $_currentCgpa', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Grade Report PDF Saved to Downloads!'), backgroundColor: Color(0xFF10B981)),
                      );
                    },
                    icon: const Icon(Icons.download_rounded, color: Colors.white, size: 18),
                    label: const Text('Download PDF', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAcademicHistoryModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.history_rounded, color: Color(0xFF7C3AED), size: 24),
                SizedBox(width: 10),
                Text('Complete Academic History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildHistorySemesterCard('Semester 4 (Current)', '8.67 SGPA', '8.45 CGPA', '24 Credits', const Color(0xFF10B981)),
                  _buildHistorySemesterCard('Semester 3', '8.30 SGPA', '8.12 CGPA', '24 Credits', const Color(0xFF7C3AED)),
                  _buildHistorySemesterCard('Semester 2', '8.10 SGPA', '7.89 CGPA', '24 Credits', const Color(0xFF2563EB)),
                  _buildHistorySemesterCard('Semester 1', '7.40 SGPA', '7.21 CGPA', '24 Credits', const Color(0xFF64748B)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorySemesterCard(String title, String sgpa, String cgpa, String credits, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(width: 4, height: 40, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text('$credits Earned', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(sgpa, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
              Text('Cum: $cgpa', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            ],
          ),
        ],
      ),
    );
  }

  void _showShareReportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('Share Academic Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(Icons.copy_rounded, 'Copy Text', const Color(0xFF7C3AED), () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Academic Summary Copied to Clipboard!')));
                }),
                _buildShareOption(Icons.qr_code_rounded, 'QR Code', const Color(0xFF2563EB), () {
                  Navigator.pop(context);
                  _showQrCodeDialog(context);
                }),
                _buildShareOption(Icons.email_outlined, 'Email', const Color(0xFF10B981), () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening Email Client...')));
                }),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showQrCodeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Digital Verification QR', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: const Icon(Icons.qr_code_2_rounded, size: 160, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 12),
            const Text('Scan to verify official transcript online.', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showPerformanceAnalyticsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.auto_graph_rounded, color: Color(0xFF7C3AED), size: 24),
                SizedBox(width: 10),
                Text('Performance Analytics & Trends', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              ],
            ),
            const SizedBox(height: 14),
            const Text('Grade Point Average Trajectory', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
              child: const Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Growth Rate (Sem 3 -> Sem 4)', style: TextStyle(fontSize: 11)), Text('+4.46%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981)))]),
                  SizedBox(height: 6),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Strongest Subject Domain', style: TextStyle(fontSize: 11)), Text('Ethics & Agile SE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED)))]),
                  SizedBox(height: 6),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Area for Improvement', style: TextStyle(fontSize: 11)), Text('Computer Networks', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFD97706)))]),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
            ),
          ],
        ),
      ),
    );
  }

  void _showGradeDistributionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            const Text('Grade Scale & Breakdown Rules', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 12),
            const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('A+ Grade (90% - 100%)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF10B981))), Text('10 Grade Points', style: TextStyle(fontSize: 12))]),
            const SizedBox(height: 6),
            const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('A Grade (80% - 89%)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF34D399))), Text('9 Grade Points', style: TextStyle(fontSize: 12))]),
            const SizedBox(height: 6),
            const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('B+ Grade (70% - 79%)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFBBF24))), Text('8 Grade Points', style: TextStyle(fontSize: 12))]),
            const SizedBox(height: 6),
            const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('B Grade (60% - 69%)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFF97316))), Text('7 Grade Points', style: TextStyle(fontSize: 12))]),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))),
          ],
        ),
      ),
    );
  }

  void _showProfileModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            const CircleAvatar(radius: 30, backgroundColor: Color(0xFF7C3AED), child: Icon(Icons.person_rounded, size: 36, color: Colors.white)),
            const SizedBox(height: 10),
            const Text('Alex Morgan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const Text('B.Tech CS - Roll No: 2024CS892', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))),
          ],
        ),
      ),
    );
  }

  void _showInteractiveCgpaCalculatorModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const InteractiveCgpaCalculatorSheet(),
    );
  }

  // ── BUILD MAIN SCREEN ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.onBack == null,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (widget.onBack != null) {
          widget.onBack!();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Bar with Back Button & Title
              _buildHeader(),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Semester Selector
                    _buildSemesterSelector(),
                    const SizedBox(height: 16),

                    // Interactive CGPA Calculator Launch Banner
                    InkWell(
                      onTap: () => _showInteractiveCgpaCalculatorModal(context),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.calculate_rounded, color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Interactive CGPA & SGPA Calculator', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                                  SizedBox(height: 2),
                                  Text('Simulate grade scenarios & calculate SGPA live', style: TextStyle(fontSize: 11, color: Colors.white70)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                              child: const Text('Open Tool 🧮', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED))),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Top 4 Summary Cards Row (TAPPABLE)
                    _buildTopSummaryCards(),
                    const SizedBox(height: 20),

                    // Subject Wise Marks Table Card
                    _buildSubjectWiseMarksCard(),
                    const SizedBox(height: 20),

                    // Quick Actions Row
                    _buildQuickActionsRow(),
                    const SizedBox(height: 20),

                    // Performance Overview Line Chart
                    _buildPerformanceOverviewCard(),
                    const SizedBox(height: 20),

                    // Grade Distribution & GPA Planning Tool Split
                    KeyedSubtree(
                      key: _gpaPlannerKey,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 700) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildGradeDistributionCard()),
                                const SizedBox(width: 16),
                                Expanded(child: _buildGpaPlanningCard()),
                              ],
                            );
                          }
                          return Column(
                            children: [
                              _buildGradeDistributionCard(),
                              const SizedBox(height: 16),
                              _buildGpaPlanningCard(),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // What-If Analysis Card
                    _buildWhatIfAnalysisCard(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  // ── Header Bar ─────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A), // Dark Slate Navy
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                onPressed: () {
                  if (widget.onBack != null) {
                    widget.onBack!();
                  } else if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              ),
              const Text(
                'Gradebook & CGPA Calculator',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 22),
                    onPressed: () => _showProfileModal(context),
                  ),
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 24),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No new notifications.')),
                          );
                        },
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              'Track. Analyze. Achieve.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Semester Selector Pills ────────────────────────────────
  Widget _buildSemesterSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_semesters.length, (index) {
          final isSelected = _selectedSemesterIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(_semesters[index]),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedSemesterIndex = index);
                }
              },
              selectedColor: const Color(0xFF7C3AED),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF475569),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF7C3AED) : const Color(0xFFE2E8F0),
                ),
              ),
              showCheckmark: false,
            ),
          );
        }),
      ),
    );
  }

  // ── Top Summary Stat Cards ─────────────────────────────────
  Widget _buildTopSummaryCards() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildStatCard(
            icon: Icons.school_rounded,
            iconBg: const Color(0xFFF3E8FF),
            iconColor: const Color(0xFF7C3AED),
            title: 'CGPA',
            titleColor: const Color(0xFF7C3AED),
            value: '$_currentCgpa ',
            totalMax: '/10',
            subtext: 'Cumulative',
            onTap: () => _showCgpaBreakdownModal(context),
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            icon: Icons.trending_up_rounded,
            iconBg: const Color(0xFFEFF6FF),
            iconColor: const Color(0xFF2563EB),
            title: 'SGPA (Sem 4)',
            titleColor: const Color(0xFF2563EB),
            value: '$_sem4Sgpa ',
            totalMax: '/10',
            subtext: 'Current Semester',
            onTap: () => _showSgpaBreakdownModal(context),
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            icon: Icons.menu_book_rounded,
            iconBg: const Color(0xFFECFDF5),
            iconColor: const Color(0xFF059669),
            title: 'Total Credits',
            titleColor: const Color(0xFF059669),
            value: '$_earnedCredits ',
            totalMax: '/$_totalCredits',
            subtext: 'Earned',
            onTap: () => _showCreditsBreakdownModal(context),
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            icon: Icons.workspace_premium_rounded,
            iconBg: const Color(0xFFFFFBEB),
            iconColor: const Color(0xFFD97706),
            title: 'Academic Standing',
            titleColor: const Color(0xFFD97706),
            value: _academicStanding,
            totalMax: '',
            subtext: 'Keep it up!',
            isValueText: true,
            onTap: () => _showAcademicStandingModal(context),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required Color titleColor,
    required String value,
    required String totalMax,
    required String subtext,
    bool isValueText = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 155,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                Icon(Icons.chevron_right_rounded, size: 16, color: titleColor.withValues(alpha: 0.6)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontSize: isValueText ? 15 : 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  if (totalMax.isNotEmpty)
                    TextSpan(
                      text: totalMax,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtext,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Subject Wise Marks Table Card ──────────────────────────
  Widget _buildSubjectWiseMarksCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Semester 4 – Subject Wise Marks',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              TextButton(
                onPressed: () => _showAllSubjectsDetailModal(context),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Row(
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4F46E5),
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF4F46E5)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Custom Flex Table with Clickable Rows
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(width: 150, child: Text('Subject', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                      SizedBox(width: 70, child: Text('Internal\n(20%)', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                      SizedBox(width: 65, child: Text('Quiz\n(10%)', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                      SizedBox(width: 65, child: Text('Exam\n(50%)', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                      SizedBox(width: 70, child: Text('Total\n(100%)', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF475569)))),
                      SizedBox(width: 65, child: Center(child: Text('Grade', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569))))),
                      SizedBox(width: 65, child: Center(child: Text('Grade Pt.', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569))))),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // Data Rows with InkWell Navigation to Subject Detail
                ...(_subjectMarks.take(_isTableExpanded ? _subjectMarks.length : 3).map((item) {
                  final grade = item['grade'] as String;
                  final gradePt = item['gradePoint'] as String;
                  final gradeColor = _getGradeColor(grade);
                  final gradeBg = _getGradeBgColor(grade);

                  return InkWell(
                    onTap: () => _showSubjectDetailBottomSheet(context, item),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 150,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item['subject'] as String,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded, size: 14, color: Color(0xFF94A3B8)),
                              ],
                            ),
                          ),
                          SizedBox(width: 70, child: Text(item['internal'] as String, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)))),
                          SizedBox(width: 65, child: Text(item['quiz'] as String, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)))),
                          SizedBox(width: 65, child: Text(item['exam'] as String, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)))),
                          SizedBox(
                            width: 70,
                            child: Text(
                              item['total'] as String,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                            ),
                          ),
                          SizedBox(
                            width: 65,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: gradeBg, borderRadius: BorderRadius.circular(6)),
                                child: Text(grade, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: gradeColor)),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 65,
                            child: Center(
                              child: Text(gradePt, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                })),
              ],
            ),
          ),

          const SizedBox(height: 8),
          IconButton(
            icon: Icon(
              _isTableExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
              color: const Color(0xFF64748B),
            ),
            onPressed: () {
              setState(() {
                _isTableExpanded = !_isTableExpanded;
              });
            },
          ),
        ],
      ),
    );
  }

  // ── Quick Actions Row ──────────────────────────────────────
  Widget _buildQuickActionsRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.file_download_rounded,
                label: 'Download Report',
                color: const Color(0xFF2563EB),
                bgColor: const Color(0xFFEFF6FF),
                onTap: () => _showReportDownloadPreviewModal(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.history_rounded,
                label: 'Academic History',
                color: const Color(0xFF7C3AED),
                bgColor: const Color(0xFFF3E8FF),
                onTap: () => _showAcademicHistoryModal(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.share_rounded,
                label: 'Share Report',
                color: const Color(0xFF10B981),
                bgColor: const Color(0xFFECFDF5),
                onTap: () => _showShareReportSheet(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Performance Overview Line Chart Card ───────────────────
  Widget _buildPerformanceOverviewCard() {
    return InkWell(
      onTap: () => _showPerformanceAnalyticsModal(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Text(
                      'Performance Overview',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF94A3B8)),
                  ],
                ),
                Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedOverviewMode,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF64748B)),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedOverviewMode = val);
                      },
                      items: const [
                        DropdownMenuItem(value: 'CGPA & SGPA', child: Text('CGPA & SGPA')),
                        DropdownMenuItem(value: 'SGPA Only', child: Text('SGPA Only')),
                        DropdownMenuItem(value: 'CGPA Only', child: Text('CGPA Only')),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Row(
                  children: [
                    Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF7C3AED), shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    const Text('CGPA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF475569))),
                  ],
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    const Text('SGPA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF475569))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 180,
              width: double.infinity,
              child: CustomPaint(
                painter: PerformanceLineChartPainter(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Grade Distribution Donut Chart Card ────────────────────
  Widget _buildGradeDistributionCard() {
    return InkWell(
      onTap: () => _showGradeDistributionModal(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Grade Distribution (Sem 4)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Icon(Icons.open_in_new_rounded, size: 16, color: Color(0xFF94A3B8)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 110,
                  height: 110,
                  child: CustomPaint(
                    painter: GradeDonutChartPainter(),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LegendItem(color: Color(0xFF10B981), label: 'A+ (10)', pct: '33.3%'),
                      SizedBox(height: 6),
                      _LegendItem(color: Color(0xFF34D399), label: 'A (9)', pct: '33.3%'),
                      SizedBox(height: 6),
                      _LegendItem(color: Color(0xFFFBBF24), label: 'B+ (8)', pct: '20.0%'),
                      SizedBox(height: 6),
                      _LegendItem(color: Color(0xFFF97316), label: 'B (7)', pct: '10.0%'),
                      SizedBox(height: 6),
                      _LegendItem(color: Color(0xFF8B5CF6), label: 'Below B (<7)', pct: '3.3%'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── GPA Planning Tool Card ────────────────────────────────
  Widget _buildGpaPlanningCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFF3E8FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.track_changes_outlined, color: Color(0xFF7C3AED), size: 18),
              ),
              const SizedBox(width: 8),
              const Text(
                'GPA Planning Tool',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Target CGPA',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
              ),
              SizedBox(
                width: 90,
                height: 36,
                child: TextField(
                  controller: _targetCgpaController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 1.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'You need an SGPA of',
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 2),
          Text(
            _calculatedRequiredSgpa.toStringAsFixed(2),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Color(0xFF7C3AED),
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'in remaining semesters to reach your target CGPA.',
            style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                _calculateTargetGpa();
                _scrollToGpaPlanner();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF7C3AED),
                side: const BorderSide(color: Color(0xFFDDD6FE), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: const Text('Calculate Again', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  // ── What-If Analysis Card ──────────────────────────────────
  Widget _buildWhatIfAnalysisCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 340;

          Widget inputColumn = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.query_stats_rounded, color: Color(0xFF7C3AED), size: 20),
                  SizedBox(width: 6),
                  Text(
                    'What-If Analysis',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Enter Expected SGPA',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  SizedBox(
                    width: 75,
                    height: 36,
                    child: TextField(
                      controller: _expectedSgpaController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      _calculateWhatIf();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Calculate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                ],
              ),
            ],
          );

          Widget resultColumn = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Estimated Final CGPA',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _estimatedFinalCgpa.toStringAsFixed(2),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF7C3AED)),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.trending_up_rounded, color: Color(0xFF10B981), size: 20),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'You will achieve your target! 🎉',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF10B981)),
              ),
            ],
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                inputColumn,
                const SizedBox(height: 14),
                const Divider(color: Color(0xFFF1F5F9), height: 1),
                const SizedBox(height: 14),
                resultColumn,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 6, child: inputColumn),
              Container(width: 1, height: 80, color: const Color(0xFFF1F5F9)),
              const SizedBox(width: 12),
              Expanded(flex: 5, child: resultColumn),
            ],
          );
        },
      ),
    );
  }
}

// ── Custom Donut Chart Legend Item ────────────────────────────────────────
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String pct;

  const _LegendItem({required this.color, required this.label, required this.pct});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
          ),
        ),
        Text(
          pct,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
        ),
      ],
    );
  }
}

// ── Performance Line Chart Custom Painter ──────────────────────────────────
class PerformanceLineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height - 24;

    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1.0;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i <= 5; i++) {
      double yVal = i * 2.0;
      double yPos = height - (yVal / 10.0 * height);

      canvas.drawLine(Offset(24, yPos), Offset(width, yPos), gridPaint);

      textPainter.text = TextSpan(
        text: yVal.toInt().toString(),
        style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8)),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(6, yPos - 6));
    }

    final List<String> sems = ['Sem 1', 'Sem 2', 'Sem 3', 'Sem 4'];
    final List<double> xPositions = [];
    double xPadding = 45.0;
    double xStep = (width - xPadding - 20) / (sems.length - 1);

    for (int i = 0; i < sems.length; i++) {
      double xPos = xPadding + (i * xStep);
      xPositions.add(xPos);

      textPainter.text = TextSpan(
        text: sems[i],
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(xPos - (textPainter.width / 2), height + 8));
    }

    final List<double> sgpaData = [7.40, 8.10, 8.30, 8.67];
    final List<double> cgpaData = [7.21, 7.89, 8.12, 8.45];

    final sgpaPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final cgpaPaint = Paint()
      ..color = const Color(0xFF7C3AED)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaintSgpa = Paint()..color = const Color(0xFF10B981);
    final dotPaintCgpa = Paint()..color = const Color(0xFF7C3AED);
    final whitePaint = Paint()..color = Colors.white;

    Path sgpaPath = Path();
    for (int i = 0; i < sgpaData.length; i++) {
      double x = xPositions[i];
      double y = height - (sgpaData[i] / 10.0 * height);
      if (i == 0) {
        sgpaPath.moveTo(x, y);
      } else {
        sgpaPath.lineTo(x, y);
      }
    }
    canvas.drawPath(sgpaPath, sgpaPaint);

    for (int i = 0; i < sgpaData.length; i++) {
      double x = xPositions[i];
      double y = height - (sgpaData[i] / 10.0 * height);

      canvas.drawCircle(Offset(x, y), 5, dotPaintSgpa);
      canvas.drawCircle(Offset(x, y), 2.5, whitePaint);

      textPainter.text = TextSpan(
        text: sgpaData[i].toStringAsFixed(2),
        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - (textPainter.width / 2), y - 16));
    }

    Path cgpaPath = Path();
    for (int i = 0; i < cgpaData.length; i++) {
      double x = xPositions[i];
      double y = height - (cgpaData[i] / 10.0 * height);
      if (i == 0) {
        cgpaPath.moveTo(x, y);
      } else {
        cgpaPath.lineTo(x, y);
      }
    }
    canvas.drawPath(cgpaPath, cgpaPaint);

    for (int i = 0; i < cgpaData.length; i++) {
      double x = xPositions[i];
      double y = height - (cgpaData[i] / 10.0 * height);

      canvas.drawCircle(Offset(x, y), 5, dotPaintCgpa);
      canvas.drawCircle(Offset(x, y), 2.5, whitePaint);

      textPainter.text = TextSpan(
        text: cgpaData[i].toStringAsFixed(2),
        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED)),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - (textPainter.width / 2), y + 6));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Grade Donut Chart Custom Painter ──────────────────────────────────────
class GradeDonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    const strokeWidth = 18.0;

    final slices = [
      {'pct': 0.333, 'color': const Color(0xFF10B981)},
      {'pct': 0.333, 'color': const Color(0xFF34D399)},
      {'pct': 0.200, 'color': const Color(0xFFFBBF24)},
      {'pct': 0.100, 'color': const Color(0xFFF97316)},
      {'pct': 0.034, 'color': const Color(0xFF8B5CF6)},
    ];

    double startAngle = -pi / 2;

    for (var slice in slices) {
      final sweepAngle = (slice['pct'] as double) * 2 * pi;
      final paint = Paint()
        ..color = slice['color'] as Color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - (strokeWidth / 2)),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Interactive CGPA & SGPA Calculator Sheet ──────────────────────────────
class InteractiveCgpaCalculatorSheet extends StatefulWidget {
  const InteractiveCgpaCalculatorSheet({super.key});

  @override
  State<InteractiveCgpaCalculatorSheet> createState() => _InteractiveCgpaCalculatorSheetState();
}

class _InteractiveCgpaCalculatorSheetState extends State<InteractiveCgpaCalculatorSheet> {
  int _activeTab = 0; // 0: Course Grade Calculator, 1: Marks to Grade Converter

  final List<Map<String, dynamic>> _calcCourses = [
    {'name': 'Data Structures', 'credits': 4, 'grade': 'A', 'gp': 9.0},
    {'name': 'Database Mgmt. Systems', 'credits': 4, 'grade': 'A', 'gp': 9.0},
    {'name': 'Operating Systems', 'credits': 4, 'grade': 'B+', 'gp': 8.0},
    {'name': 'Computer Networks', 'credits': 3, 'grade': 'B+', 'gp': 8.0},
    {'name': 'Software Engineering', 'credits': 3, 'grade': 'A', 'gp': 9.0},
    {'name': 'Professional Ethics', 'credits': 2, 'grade': 'A+', 'gp': 10.0},
  ];

  final Map<String, double> _gradePointsMap = {
    'A+': 10.0,
    'A': 9.0,
    'B+': 8.0,
    'B': 7.0,
    'C+': 6.0,
    'C': 5.0,
    'F': 0.0,
  };

  // Controllers for Tab 2
  final TextEditingController _internalController = TextEditingController(text: '18');
  final TextEditingController _quizController = TextEditingController(text: '9');
  final TextEditingController _examController = TextEditingController(text: '45');

  double _calculatedSgpa = 8.67;
  double _calculatedCgpa = 8.45;
  int _totalSemCredits = 20;

  double _mTotal = 72.0;
  double _mPct = 90.0;
  String _mGrade = 'A';
  double _mGp = 9.0;

  @override
  void initState() {
    super.initState();
    _recalculate();
    _recalculateMarks();
  }

  @override
  void dispose() {
    _internalController.dispose();
    _quizController.dispose();
    _examController.dispose();
    super.dispose();
  }

  void _recalculate() {
    double totalPoints = 0;
    int totalCredits = 0;

    for (var c in _calcCourses) {
      int creds = (c['credits'] as num).toInt();
      double gp = (c['gp'] as num).toDouble();
      totalPoints += (gp * creds);
      totalCredits += creds;
    }

    double sgpa = totalCredits > 0 ? totalPoints / totalCredits : 0.0;
    double pastPoints = 557.28; // Sem 1-3 earned points
    double overallCgpa = (totalCredits + 72) > 0 ? (pastPoints + totalPoints) / (72 + totalCredits) : 0.0;

    setState(() {
      _calculatedSgpa = double.parse(sgpa.toStringAsFixed(2));
      _calculatedCgpa = double.parse(overallCgpa.toStringAsFixed(2));
      _totalSemCredits = totalCredits;
    });
  }

  void _recalculateMarks() {
    final internal = double.tryParse(_internalController.text) ?? 0.0;
    final quiz = double.tryParse(_quizController.text) ?? 0.0;
    final exam = double.tryParse(_examController.text) ?? 0.0;

    double total = internal.clamp(0, 20) + quiz.clamp(0, 10) + exam.clamp(0, 50);
    double pct = (total / 80.0) * 100.0;

    String grade = 'F';
    double gp = 0.0;
    if (pct >= 90) {
      grade = 'A+';
      gp = 10.0;
    } else if (pct >= 80) {
      grade = 'A';
      gp = 9.0;
    } else if (pct >= 70) {
      grade = 'B+';
      gp = 8.0;
    } else if (pct >= 60) {
      grade = 'B';
      gp = 7.0;
    } else if (pct >= 50) {
      grade = 'C+';
      gp = 6.0;
    } else if (pct >= 40) {
      grade = 'C';
      gp = 5.0;
    }

    setState(() {
      _mTotal = total;
      _mPct = double.parse(pct.toStringAsFixed(1));
      _mGrade = grade;
      _mGp = gp;
    });
  }

  void _addCourse() {
    setState(() {
      _calcCourses.add({
        'name': 'Elective ${_calcCourses.length + 1}',
        'credits': 3,
        'grade': 'A',
        'gp': 9.0,
      });
      _recalculate();
    });
  }

  void _removeCourse(int index) {
    if (_calcCourses.length <= 1) return;
    setState(() {
      _calcCourses.removeAt(index);
      _recalculate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.calculate_rounded, color: Color(0xFF69F0AE), size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Interactive CGPA & SGPA Calculator',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Live Calculation Dashboard Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('CALCULATED SGPA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                          const SizedBox(height: 2),
                          Text(
                            _calculatedSgpa.toStringAsFixed(2),
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF69F0AE)),
                          ),
                        ],
                      ),
                      Container(width: 1, height: 30, color: const Color(0xFF334155)),
                      Column(
                        children: [
                          const Text('ESTIMATED CGPA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                          const SizedBox(height: 2),
                          Text(
                            _calculatedCgpa.toStringAsFixed(2),
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF818CF8)),
                          ),
                        ],
                      ),
                      Container(width: 1, height: 30, color: const Color(0xFF334155)),
                      Column(
                        children: [
                          const Text('TOTAL CREDITS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                          const SizedBox(height: 2),
                          Text(
                            '$_totalSemCredits Cr',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab Switcher
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Course Grades SGPA/CGPA')),
                    selected: _activeTab == 0,
                    onSelected: (val) {
                      if (val) setState(() => _activeTab = 0);
                    },
                    selectedColor: const Color(0xFF7C3AED),
                    backgroundColor: const Color(0xFFF1F5F9),
                    labelStyle: TextStyle(
                      color: _activeTab == 0 ? Colors.white : const Color(0xFF475569),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                    showCheckmark: false,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Marks to Grade Converter')),
                    selected: _activeTab == 1,
                    onSelected: (val) {
                      if (val) setState(() => _activeTab = 1);
                    },
                    selectedColor: const Color(0xFF7C3AED),
                    backgroundColor: const Color(0xFFF1F5F9),
                    labelStyle: TextStyle(
                      color: _activeTab == 1 ? Colors.white : const Color(0xFF475569),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                    showCheckmark: false,
                  ),
                ),
              ],
            ),
          ),

          // Body Content
          Expanded(
            child: _activeTab == 0 ? _buildCourseGradeTab() : _buildMarksConverterTab(),
          ),

          // Footer Action Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Apply & Done', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseGradeTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Adjust Grades & Credits:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              TextButton.icon(
                onPressed: _addCourse,
                icon: const Icon(Icons.add_circle_outline_rounded, size: 16, color: Color(0xFF7C3AED)),
                label: const Text('Add Course', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED))),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _calcCourses.length,
            itemBuilder: (context, index) {
              final course = _calcCourses[index];
              final String currentGrade = course['grade'] as String;
              final int currentCredits = (course['credits'] as num).toInt();

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Course Name / Index
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course['name'] as String,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${course['gp']} Grade Points',
                              style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Credits Dropdown
                      Container(
                        height: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: currentCredits,
                            items: [1, 2, 3, 4, 5].map((c) => DropdownMenuItem(value: c, child: Text('$c Cr', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)))).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  course['credits'] = val;
                                  _recalculate();
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Grade Dropdown
                      Container(
                        height: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFDDD6FE)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: currentGrade,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED)),
                            items: _gradePointsMap.keys.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  course['grade'] = val;
                                  course['gp'] = _gradePointsMap[val] ?? 0.0;
                                  _recalculate();
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Delete
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline_rounded, color: Color(0xFFEF4444), size: 18),
                        onPressed: () => _removeCourse(index),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMarksConverterTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Enter Subject Test Scores:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Internal (out of 20)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _internalController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (_) => _recalculateMarks(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Quiz (out of 10)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _quizController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (_) => _recalculateMarks(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Exam (out of 50)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _examController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (_) => _recalculateMarks(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Converter Output Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text('CONVERTED RESULT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED))),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text('Total Score', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                        const SizedBox(height: 2),
                        Text('$_mTotal / 80', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        Text('$_mPct%', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('Letter Grade', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                        const SizedBox(height: 2),
                        Text(_mGrade, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF10B981))),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('Grade Points', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                        const SizedBox(height: 2),
                        Text('$_mGp GP', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED))),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
