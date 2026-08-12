import 'package:flutter/material.dart';
import 'package:unisphere/widgets/common/unisphere_header_card.dart';

import 'package:unisphere/models/exam_model.dart';
import 'package:unisphere/services/exam_service.dart';
import 'package:unisphere/widgets/exams/exam_card.dart';
import 'package:unisphere/screens/exams/exam_detail_screen.dart';

class ExamsDetailScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const ExamsDetailScreen({super.key, this.onBack});

  @override
  State<ExamsDetailScreen> createState() => _ExamsDetailScreenState();
}

class _ExamsDetailScreenState extends State<ExamsDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedExamType = 'All';

  final List<Map<String, dynamic>> _examTypeOptions = const [
    {
      'type': 'All',
      'title': 'All',
      'subtitle': 'Show all exam types',
      'icon': Icons.grid_view_rounded,
      'color': Color(0xFF6366F1),
      'bgColor': Color(0xFFEEF2FF),
    },
    {
      'type': 'Unit Test',
      'title': 'Unit Test',
      'subtitle': 'Short tests & quizzes',
      'icon': Icons.edit_note_rounded,
      'color': Color(0xFF4F46E5),
      'bgColor': Color(0xFFEEF2FF),
    },
    {
      'type': 'Internal Assessment',
      'title': 'Internal Assessment',
      'subtitle': 'Internal assessments',
      'icon': Icons.assignment_rounded,
      'color': Color(0xFF0284C7),
      'bgColor': Color(0xFFE0F2FE),
    },
    {
      'type': 'Model Exam',
      'title': 'Model Exam',
      'subtitle': 'Model examinations',
      'icon': Icons.description_rounded,
      'color': Color(0xFF10B981),
      'bgColor': Color(0xFFD1FAE5),
    },
    {
      'type': 'Practical Exam',
      'title': 'Practical Exam',
      'subtitle': 'Practical examinations',
      'icon': Icons.science_rounded,
      'color': Color(0xFFF97316),
      'bgColor': Color(0xFFFFEDD5),
    },
    {
      'type': 'Lab Exam',
      'title': 'Lab Exam',
      'subtitle': 'Lab based exams',
      'icon': Icons.biotech_rounded,
      'color': Color(0xFF06B6D4),
      'bgColor': Color(0xFFCFFAFE),
    },
    {
      'type': 'End Semester',
      'title': 'End Semester',
      'subtitle': 'End semester exams',
      'icon': Icons.school_rounded,
      'color': Color(0xFF7C3AED),
      'bgColor': Color(0xFFF3E8FF),
    },
    {
      'type': 'Supplementary Exam',
      'title': 'Supplementary Exam',
      'subtitle': 'Supplementary exams',
      'icon': Icons.autorenew_rounded,
      'color': Color(0xFFEC4899),
      'bgColor': Color(0xFFFCE7F3),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else if (widget.onBack != null) {
      widget.onBack!();
    }
  }

  void _showExamTypeFilterModal(BuildContext context) {
    String tempSelected = _selectedExamType;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.88,
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Header Row
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Exam Type',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Select exam type to filter',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 2-Column Grid of Option Cards
                  Expanded(
                    child: SingleChildScrollView(
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.15,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _examTypeOptions.length,
                        itemBuilder: (context, index) {
                          final option = _examTypeOptions[index];
                          final isSelected = tempSelected == option['type'];

                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedExamType = option['type'] as String;
                              });
                              Navigator.pop(context);
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0),
                                  width: isSelected ? 1.8 : 1.0,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: option['bgColor'] as Color,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          option['icon'] as IconData,
                                          color: option['color'] as Color,
                                          size: 20,
                                        ),
                                      ),
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent,
                                          border: Border.all(
                                            color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFCBD5E1),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: isSelected
                                            ? const Icon(
                                                Icons.check_rounded,
                                                size: 13,
                                                color: Colors.white,
                                              )
                                            : null,
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        option['title'] as String,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: isSelected ? const Color(0xFF4338CA) : const Color(0xFF0F172A),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        option['subtitle'] as String,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF64748B),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Info Banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F3FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFDDD6FE)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.info_outline_rounded,
                            color: Color(0xFF6366F1),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Filtering helps you find faster',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Color(0xFF4338CA),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Choose the exam type and tap Apply Filter to view results.',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF6366F1),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.assignment_outlined,
                          color: Color(0xFFA5B4FC),
                          size: 28,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Apply Filter Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedExamType = tempSelected;
                        });
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.filter_list_rounded, size: 18),
                      label: const Text(
                        'Apply Filter',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4338CA),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final examService = ExamService();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            UnisphereHeaderCard(
              title: 'Exams & Schedule',
              subtitle: 'Internal Assessments, Model & Semester Exams',
              onBack: _handleBack,
              rightActions: [
                IconButton(
                  icon: const Icon(Icons.filter_list_rounded, color: Colors.white),
                  tooltip: 'Filter Exam Type',
                  onPressed: () => _showExamTypeFilterModal(context),
                ),
              ],
              bottomWidget: Container(
                height: 44,
                padding: const EdgeInsets.all(4),
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
                    Tab(text: 'Upcoming Exams'),
                    Tab(text: 'Completed Exams'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: AnimatedBuilder(
        animation: examService,
        builder: (context, child) {
          final upcoming = examService.getFilteredExams(
            examType: _selectedExamType,
            searchQuery: _searchController.text,
            showUpcomingOnly: true,
          );

          final completed = examService.getFilteredExams(
            examType: _selectedExamType,
            searchQuery: _searchController.text,
            showUpcomingOnly: false,
          ).where((e) => e.isCompleted).toList();

          return Column(
            children: [
              // Search & Filter Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Search exam subject, code, venue...',
                              hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                              prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Filter Modal Trigger Button
                        Material(
                          color: _selectedExamType != 'All' ? const Color(0xFFEEF2FF) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            onTap: () => _showExamTypeFilterModal(context),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _selectedExamType != 'All' ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.tune_rounded,
                                    size: 20,
                                    color: _selectedExamType != 'All' ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
                                  ),
                                  if (_selectedExamType != 'All') ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF4F46E5),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Active Filter Chip Display (Tap to open filter modal)
                    Row(
                      children: [
                        Material(
                          color: _selectedExamType != 'All' ? const Color(0xFFEEF2FF) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () => _showExamTypeFilterModal(context),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _selectedExamType != 'All' ? const Color(0xFF4F46E5) : const Color(0xFFCBD5E1),
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.tune_rounded, size: 14, color: Color(0xFF4F46E5)),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Exam Type: $_selectedExamType',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF475569)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (_selectedExamType != 'All')
                          GestureDetector(
                            onTap: () => setState(() => _selectedExamType = 'All'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFFCA5A5)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.close_rounded, size: 14, color: Color(0xFFDC2626)),
                                  SizedBox(width: 2),
                                  Text('Reset', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // TabBar View
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildExamList(context, upcoming, 'No upcoming exams scheduled.'),
                    _buildExamList(context, completed, 'No completed exams recorded.'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ),
            ],
          ),
        ),
      );
  }

  Widget _buildExamList(BuildContext context, List<ExamModel> list, String emptyMsg) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_available_rounded, size: 48, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 12),
            Text(emptyMsg, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final exam = list[index];
        return ExamCard(
          exam: exam,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ExamDetailScreen(exam: exam)),
            );
          },
        );
      },
    );
  }
}
