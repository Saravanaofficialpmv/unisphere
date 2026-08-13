import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unisphere/core/constants/app_colors.dart';
import 'package:unisphere/providers/gradebook_provider.dart';
import 'package:unisphere/screens/staff/modules/staff_marks_upload.dart';
import 'package:unisphere/widgets/common/unisphere_header_card.dart';

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

class _GradebookScreenState extends ConsumerState<GradebookScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedSemIndex = 3; // Default Sem 4
  String _selectedInternalFilter = 'All'; // 'All', 'IA-1', 'IA-2', 'Model'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.initialShowPlanner) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showCgpaCalculatorModal(context);
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleBack(BuildContext context) {
    if (!mounted) return;
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      context.go('/student');
    }
  }

  void _showCgpaCalculatorModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CgpaCalculatorModalSheet(),
    );
  }

  void _showStaffUploadModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.upload_file_rounded, color: Color(0xFF1D4ED8)),
                      SizedBox(width: 10),
                      Text('Faculty Internal Marks Upload Portal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Expanded(child: StaffMarksUploadModule()),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canPopRoute = ModalRoute.of(context)?.canPop ?? false;

    return PopScope(
      canPop: canPopRoute,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || !mounted) return;
        _handleBack(context);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildInternalMarksTab(),
                    _buildUniversityResultsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return UnisphereHeaderCard(
      title: 'Academic Marks & Results',
      subtitle: 'Internal Assessment & Official COE University Results',
      onBack: () => _handleBack(context),
      rightActions: [
        // Mini CGPA Calculator Button
        GestureDetector(
          onTap: () => _showCgpaCalculatorModal(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calculate_rounded, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  'CGPA Calc',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
      bottomWidget: _buildSegmentedTabBar(),
    );
  }

  Widget _buildSegmentedTabBar() {
    return Container(
      height: 42,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF1E3A8A),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFFBFDBFE),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_turned_in_rounded, size: 15),
                SizedBox(width: 5),
                Text('Internal Marks'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified_rounded, size: 15),
                SizedBox(width: 5),
                Flexible(
                  child: Text(
                    'University Results',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 1: INTERNAL MARKS (Uploaded by Subject Staff on Faculty Portal)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildInternalMarksTab() {
    final gradebookState = ref.watch(gradebookProvider);
    final currentSem = gradebookState.currentSemester;

    // Mock internal assessment data for subjects with Retest history
    final internalSubjectData = [
      {
        'code': 'CS401',
        'name': 'Advanced Data Structures',
        'faculty': 'Dr. Robert Vance (Subject Staff)',
        'ia1': '44 / 50',
        'ia1Conv': '13.2 / 15',
        'ia1Initial': '20 / 50',
        'ia1Retest': '44 / 50',
        'ia1RetestStatus': 'Retest Cleared (+24 Marks Improved)',
        'hasIa1Retest': 'true',
        'ia2': '46 / 50',
        'ia2Conv': '13.8 / 15',
        'ia2Initial': '46 / 50',
        'hasIa2Retest': 'false',
        'modelExam': '88 / 100',
        'modelConv': '17.6 / 20',
        'modelInitial': '88 / 100',
        'hasModelRetest': 'false',
        'attAssign': '9.5 / 10',
        'totalInternal': '54.1 / 60',
        'status': 'Finalized by Staff',
      },
      {
        'code': 'CS402',
        'name': 'Database Management Systems',
        'faculty': 'Prof. Sarah Jenkins (Subject Staff)',
        'ia1': '48 / 50',
        'ia1Conv': '14.4 / 15',
        'ia1Initial': '48 / 50',
        'hasIa1Retest': 'false',
        'ia2': '47 / 50',
        'ia2Conv': '14.1 / 15',
        'ia2Initial': '15 / 50 (Absent)',
        'ia2Retest': '47 / 50',
        'ia2RetestStatus': 'Retest Cleared (Absentee Retest)',
        'hasIa2Retest': 'true',
        'modelExam': '92 / 100',
        'modelConv': '18.4 / 20',
        'modelInitial': '92 / 100',
        'hasModelRetest': 'false',
        'attAssign': '10.0 / 10',
        'totalInternal': '56.9 / 60',
        'status': 'Finalized by Staff',
      },
      {
        'code': 'CS403',
        'name': 'Operating Systems',
        'faculty': 'Dr. Alan Turing (Subject Staff)',
        'ia1': '42 / 50',
        'ia1Conv': '12.6 / 15',
        'ia1Initial': '42 / 50',
        'hasIa1Retest': 'false',
        'ia2': '43 / 50',
        'ia2Conv': '12.9 / 15',
        'ia2Initial': '43 / 50',
        'hasIa2Retest': 'false',
        'modelExam': '84 / 100',
        'modelConv': '16.8 / 20',
        'modelInitial': '52 / 100 (Fail)',
        'modelRetest': '84 / 100',
        'modelRetestStatus': 'Model Retest Cleared (+32 Marks)',
        'hasModelRetest': 'true',
        'attAssign': '9.0 / 10',
        'totalInternal': '51.3 / 60',
        'status': 'Finalized by Staff',
      },
      {
        'code': 'CS404',
        'name': 'Computer Networks',
        'faculty': 'Prof. Michael Scott (Subject Staff)',
        'ia1': '38 / 50',
        'ia1Conv': '11.4 / 15',
        'ia1Initial': '14 / 50',
        'ia1Retest': '38 / 50',
        'ia1RetestStatus': 'Retest Cleared (+24 Marks Improved)',
        'hasIa1Retest': 'true',
        'ia2': '40 / 50',
        'ia2Conv': '12.0 / 15',
        'ia2Initial': '40 / 50',
        'hasIa2Retest': 'false',
        'modelExam': '78 / 100',
        'modelConv': '15.6 / 20',
        'modelInitial': '78 / 100',
        'hasModelRetest': 'false',
        'attAssign': '8.5 / 10',
        'totalInternal': '47.5 / 60',
        'status': 'Finalized by Staff',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Faculty Portal Info Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Color(0xFF2563EB), shape: BoxShape.circle),
                  child: const Icon(Icons.badge_outlined, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FACULTY UPLOADED INTERNAL MARKS',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF), letterSpacing: 0.8),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Internal marks are evaluated & uploaded directly by dedicated subject staff on their faculty portal.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF1E3A8A)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _showStaffUploadModal,
                  icon: const Icon(Icons.upload_file_rounded, size: 14),
                  label: const Text('Upload Sheet'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D4ED8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Current Active Term Indicator (Student Panel: Internal Marks for Current Term Only)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded, color: Color(0xFF60A5FA), size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'CURRENT SEMESTER 4 INTERNAL MARKS',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11.5,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Active Term Only',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Assessment Filter Buttons (All, IA-1, IA-2, Model Exam)
          _buildInternalFilterPills(),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _selectedInternalFilter == 'All'
                      ? 'Subject Internal Assessments (${currentSem?.name ?? 'Sem 4'})'
                      : '$_selectedInternalFilter Subject Marks & Retest History',
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(6)),
                child: const Text('Staff Verified', style: TextStyle(color: Color(0xFF059669), fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: internalSubjectData.length,
            itemBuilder: (context, index) {
              final sub = internalSubjectData[index];
              if (_selectedInternalFilter == 'All') {
                return _buildInternalSubjectCard(sub);
              } else {
                return _buildEventSubjectCard(sub, _selectedInternalFilter);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInternalFilterPills() {
    final filters = [
      {'id': 'All', 'label': '📊 All Summary'},
      {'id': 'IA-1', 'label': '📝 Internal 1 (IA-1)'},
      {'id': 'IA-2', 'label': '📝 Internal 2 (IA-2)'},
      {'id': 'Model', 'label': '🎓 Model Exam'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final id = f['id'] as String;
          final isSel = _selectedInternalFilter == id;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedInternalFilter = id;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSel ? const Color(0xFF1D4ED8) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSel ? const Color(0xFF1D4ED8) : const Color(0xFFE2E8F0),
                  width: 1.2,
                ),
                boxShadow: [
                  if (isSel)
                    BoxShadow(
                      color: const Color(0xFF1D4ED8).withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Text(
                f['label'] as String,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSel ? Colors.white : const Color(0xFF475569),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEventSubjectCard(Map<String, String> sub, String eventKey) {
    String scoreKey = 'ia1';
    String convKey = 'ia1Conv';
    String initialKey = 'ia1Initial';
    String retestKey = 'ia1Retest';
    String statusKey = 'ia1RetestStatus';
    String hasRetestKey = 'hasIa1Retest';

    if (eventKey == 'IA-2') {
      scoreKey = 'ia2';
      convKey = 'ia2Conv';
      initialKey = 'ia2Initial';
      retestKey = 'ia2Retest';
      statusKey = 'ia2RetestStatus';
      hasRetestKey = 'hasIa2Retest';
    } else if (eventKey == 'Model') {
      scoreKey = 'modelExam';
      convKey = 'modelConv';
      initialKey = 'modelInitial';
      retestKey = 'modelRetest';
      statusKey = 'modelRetestStatus';
      hasRetestKey = 'hasModelRetest';
    }

    final bool hasRetest = sub[hasRetestKey] == 'true';
    final String finalScore = sub[scoreKey] ?? 'N/A';
    final String initialScore = sub[initialKey] ?? finalScore;
    final String convScore = sub[convKey] ?? 'N/A';
    final String retestScore = sub[retestKey] ?? finalScore;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasRetest ? const Color(0xFF93C5FD) : const Color(0xFFE2E8F0),
          width: hasRetest ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Subject Code & Name + Final Event Score Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        sub['code'] ?? 'SUB',
                        style: const TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        sub['name'] ?? 'Subject Name',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: hasRetest ? const Color(0xFFECFDF5) : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: hasRetest ? const Color(0xFFA7F3D0) : const Color(0xFFBFDBFE),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      finalScore,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        color: hasRetest ? const Color(0xFF059669) : const Color(0xFF1D4ED8),
                      ),
                    ),
                    Text(
                      'Conv: $convScore',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: hasRetest ? const Color(0xFF047857) : const Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Uploaded by: ${sub['faculty'] ?? 'Subject Staff'}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),

          // Attempts Breakdown (Initial Attempt vs Retest)
          if (hasRetest) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.cancel_outlined, size: 14, color: Color(0xFFDC2626)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Initial Attempt: $initialScore',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFB91C1C),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Initial Fail / Low',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFDC2626),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Divider(height: 1),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.published_with_changes_rounded, size: 14, color: Color(0xFF059669)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Retest Attempt: $retestScore',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF047857),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            sub[statusKey] ?? 'Retest Cleared',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF059669),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline_rounded, size: 14, color: Color(0xFF059669)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Regular Attempt Passed: $finalScore (No Retest Required)',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInternalSubjectCard(Map<String, String> sub) {
    double ia1Val = _parseVal(sub['ia1'] ?? '0', 50);
    double ia2Val = _parseVal(sub['ia2'] ?? '0', 50);
    double modelVal = _parseVal(sub['modelExam'] ?? '0', 100);
    double attVal = _parseVal(sub['attAssign'] ?? '0', 10);
    double totalVal = _parseVal(sub['totalInternal'] ?? '0', 60);
    double totalPct = (totalVal / 60.0).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Subject Header Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        sub['code'] ?? 'SUB',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11.5,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        sub['name'] ?? 'Subject Name',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14.5,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 14, color: Color(0xFF059669)),
                          const SizedBox(width: 4),
                          Text(
                            sub['totalInternal'] ?? '0/60',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 13, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Faculty Lead: ${sub['faculty'] ?? 'Subject Staff'}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Middle Section: 4 Styled Assessment Component Cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildInternalMetricCard(
                        'IA-1 (50)',
                        sub['ia1'] ?? '0/50',
                        sub['ia1Conv'] ?? '0/15',
                        ia1Val / 50.0,
                        const Color(0xFF2563EB),
                        const Color(0xFFEEF2FF),
                        Icons.edit_note_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildInternalMetricCard(
                        'IA-2 (50)',
                        sub['ia2'] ?? '0/50',
                        sub['ia2Conv'] ?? '0/15',
                        ia2Val / 50.0,
                        const Color(0xFF3B82F6),
                        const Color(0xFFEFF6FF),
                        Icons.quiz_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildInternalMetricCard(
                        'Model (100)',
                        sub['modelExam'] ?? '0/100',
                        sub['modelConv'] ?? '0/20',
                        modelVal / 100.0,
                        const Color(0xFF10B981),
                        const Color(0xFFECFDF5),
                        Icons.assignment_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildInternalMetricCard(
                        'Attd / Assign',
                        sub['attAssign'] ?? '0/10',
                        'Score 10',
                        attVal / 10.0,
                        const Color(0xFFF59E0B),
                        const Color(0xFFFFFBEB),
                        Icons.verified_user_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Overall Internal Weightage Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Internal Weightage Progress',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      '${(totalPct * 100).toStringAsFixed(1)}% Weightage',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: totalPct,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInternalMetricCard(
    String label,
    String raw,
    String conv,
    double pct,
    Color accentColor,
    Color bgColor,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 14, color: accentColor),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
              Text(
                conv,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            raw,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct.clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: accentColor.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),
        ],
      ),
    );
  }

  double _parseVal(String text, double maxVal) {
    try {
      final parts = text.split('/');
      if (parts.isNotEmpty) {
        return double.parse(parts[0].trim());
      }
    } catch (_) {}
    return maxVal;
  }

  // ───────────────────────────────────────────────────────────────────────────
  // TAB 2: UNIVERSITY RESULTS (Published by Controller of Examinations - COE Team)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildUniversityResultsTab() {
    final gradebookState = ref.watch(gradebookProvider);
    final currentSem = gradebookState.currentSemester;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Official COE Publication Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_rounded, color: Color(0xFF38BDF8), size: 26),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'OFFICIAL COE UNIVERSITY RESULTS',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8), letterSpacing: 0.8),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.shield_rounded, color: Color(0xFF38BDF8), size: 14),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Published officially by the Controller of Examinations (COE) Office. Dedicated COE Portal handles revaluations & transcripts.',
                        style: TextStyle(fontSize: 12, color: Color(0xFFE2E8F0), height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Semester Pills Row
          _buildSemesterPills(gradebookState.semesters),
          const SizedBox(height: 16),

          // Official SGPA Badge Banner
          if (currentSem != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${currentSem.name} Official Result',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Credits Earned: ${currentSem.earnedCredits} / ${currentSem.registeredCredits}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${currentSem.sgpa.toStringAsFixed(2)} SGPA',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF059669)),
                        ),
                        const Text(
                          'COE Verified',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF047857)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          const Text(
            'Official End-Semester University Exam Grades',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 10),

          if (currentSem == null || currentSem.subjects.isEmpty)
            Container(
              padding: const EdgeInsets.all(30),
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: const Text('No published university results available for this semester yet.'),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: currentSem.subjects.length,
              itemBuilder: (context, index) {
                final sub = currentSem.subjects[index];
                return _buildUniversitySubjectCard(sub);
              },
            ),

          const SizedBox(height: 16),

          // Revaluation Info Footer Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'For paper revaluation, answer script copy requests, or mark sheet corrections, submit application through the COE Student Portal.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF92400E)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUniversitySubjectCard(SubjectModel sub) {
    final gp = sub.gradePoint;
    final isPassed = sub.isPassed;
    final bool isRA = sub.grade == 'RA';
    final Color gradeColor = isPassed ? const Color(0xFF059669) : const Color(0xFFDC2626);
    final Color gradeBg = isPassed ? const Color(0xFFECFDF5) : const Color(0xFFFEE2E2);

    final bool hasReExamHistory = isRA || sub.code == 'ME101' || sub.code == 'EE101';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRA ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0),
          width: isRA ? 1.5 : 1.0,
        ),
      ),
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            sub.code,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF475569)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            sub.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${sub.credits} Credits • Grade Point: ${gp != null ? gp.toInt() : 'N/A'}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: gradeBg, borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    Text(
                      sub.grade,
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: gradeColor),
                    ),
                    Text(
                      isPassed ? 'PASS' : 'RE-APPEAR',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: gradeColor),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Re-Exam & Arrear Attempt Banner
          if (isRA) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFFDC2626)),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Initial Attempt: RA (Fail) • Re-Exam Scheduled (Apr 2026 Arrear Session)',
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFFB91C1C)),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (hasReExamHistory) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.published_with_changes_rounded, size: 14, color: Color(0xFF059669)),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Re-Exam Cleared: Grade \'B+\' (Nov 2024 Arrear Session) • Initial Attempt: RA',
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF047857)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSemesterPills(List<SemesterModel> semesters) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(semesters.length, (index) {
          final sem = semesters[index];
          final isSel = index == _selectedSemIndex;
          final isCurrent = sem.isCurrent;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedSemIndex = index;
              });
              ref.read(gradebookProvider.notifier).selectSemester(index);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSel ? const Color(0xFF1D4ED8) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSel ? const Color(0xFF1D4ED8) : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
                boxShadow: [
                  if (isSel)
                    BoxShadow(
                      color: const Color(0xFF1D4ED8).withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Sem ${sem.number}',
                    style: TextStyle(
                      color: isSel ? Colors.white : const Color(0xFF334155),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  if (isCurrent) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSel ? const Color(0xFF34D399) : const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'ACTIVE',
                        style: TextStyle(
                          color: isSel ? const Color(0xFF064E3B) : const Color(0xFF15803D),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// CGPA CALCULATOR MODAL SHEET (Opened via Mini Button)
// ───────────────────────────────────────────────────────────────────────────
class _CgpaCalculatorModalSheet extends ConsumerStatefulWidget {
  @override
  ConsumerState<_CgpaCalculatorModalSheet> createState() => _CgpaCalculatorModalSheetState();
}

class _CgpaCalculatorModalSheetState extends ConsumerState<_CgpaCalculatorModalSheet> {
  final _sem1SgpaCtrl = TextEditingController(text: '8.50');
  final _sem1CredCtrl = TextEditingController(text: '14');
  final _sem2SgpaCtrl = TextEditingController(text: '8.60');
  final _sem2CredCtrl = TextEditingController(text: '15');
  final _sem3SgpaCtrl = TextEditingController(text: '8.33');
  final _sem3CredCtrl = TextEditingController(text: '18');
  final _sem4SgpaCtrl = TextEditingController(text: '8.80');
  final _sem4CredCtrl = TextEditingController(text: '20');

  double _calculatedCgpa = 8.56;

  void _calculateCgpa() {
    double s1 = double.tryParse(_sem1SgpaCtrl.text) ?? 0;
    int c1 = int.tryParse(_sem1CredCtrl.text) ?? 0;
    double s2 = double.tryParse(_sem2SgpaCtrl.text) ?? 0;
    int c2 = int.tryParse(_sem2CredCtrl.text) ?? 0;
    double s3 = double.tryParse(_sem3SgpaCtrl.text) ?? 0;
    int c3 = int.tryParse(_sem3CredCtrl.text) ?? 0;
    double s4 = double.tryParse(_sem4SgpaCtrl.text) ?? 0;
    int c4 = int.tryParse(_sem4CredCtrl.text) ?? 0;

    int totalCreds = c1 + c2 + c3 + c4;
    double totalPoints = (s1 * c1) + (s2 * c2) + (s3 * c3) + (s4 * c4);

    if (totalCreds > 0) {
      setState(() {
        _calculatedCgpa = (totalPoints / totalCreds).clamp(0.0, 10.0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.calculate_rounded, color: AppColors.primary, size: 24),
                  SizedBox(width: 10),
                  Text('CGPA & SGPA Calculator Tool', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                ],
              ),
              IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Interactive calculator for projecting cumulative grade point average based on semester SGPA & credits.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          const SizedBox(height: 16),

          // Output Result Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Calculated Cumulative CGPA', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(_calculatedCgpa.toStringAsFixed(2), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 28)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    'Percentage: ${(_calculatedCgpa * 10).toStringAsFixed(1)}%',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildCalcRow('Sem 1', _sem1SgpaCtrl, _sem1CredCtrl),
                  _buildCalcRow('Sem 2', _sem2SgpaCtrl, _sem2CredCtrl),
                  _buildCalcRow('Sem 3', _sem3SgpaCtrl, _sem3CredCtrl),
                  _buildCalcRow('Sem 4', _sem4SgpaCtrl, _sem4CredCtrl),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: _calculateCgpa,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Recalculate CGPA', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalcRow(String name, TextEditingController sgpaCtrl, TextEditingController credCtrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          SizedBox(width: 60, child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
          Expanded(
            child: TextField(
              controller: sgpaCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'SGPA (0-10)',
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (_) => _calculateCgpa(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: credCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Credits',
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (_) => _calculateCgpa(),
            ),
          ),
        ],
      ),
    );
  }
}
