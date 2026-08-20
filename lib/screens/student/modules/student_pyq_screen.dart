import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:unisphere/core/constants/app_colors.dart';
import 'package:unisphere/controllers/question_paper_controller.dart';
import 'package:unisphere/models/question_paper_model.dart';
import 'package:unisphere/widgets/common/unisphere_header_card.dart';
import 'package:unisphere/widgets/common/custom_loader.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentPyqScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;
  final String? initialSubjectCode;
  final String? initialSubjectName;

  const StudentPyqScreen({
    super.key,
    this.onBack,
    this.initialSubjectCode,
    this.initialSubjectName,
  });

  @override
  ConsumerState<StudentPyqScreen> createState() => _StudentPyqScreenState();
}

class _StudentPyqScreenState extends ConsumerState<StudentPyqScreen> {
  final TextEditingController _searchController = TextEditingController();
  QuestionPaperType? _selectedPaperType;
  String _selectedSemester = 'All';
  String _selectedRegulation = 'All';
  String _selectedDepartment = 'All';
  bool _onlySolved = false;

  final List<String> _semesters = [
    'All',
    'Semester 1',
    'Semester 2',
    'Semester 3',
    'Semester 4',
    'Semester 5',
    'Semester 6',
    'Semester 7',
    'Semester 8',
  ];

  final List<String> _regulations = [
    'All',
    'Regulation 2021',
    'Regulation 2023',
    'Regulation 2017',
  ];

  final List<String> _departments = [
    'All',
    'Computer Science & Engineering',
    'Artificial Intelligence & Data Science',
    'Information Technology',
    'Electronics & Communication Engg',
    'Mechanical Engineering',
    'Civil Engineering',
    'Electrical & Electronics Engg',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialSubjectCode != null && widget.initialSubjectCode!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(questionPaperControllerProvider.notifier).setSubjectFilter(widget.initialSubjectCode);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _applyFilterChanges() {
    ref.read(questionPaperControllerProvider.notifier).updateFilters(
      QuestionPaperFilterState(
        department: _selectedDepartment,
        semester: _selectedSemester,
        subjectCode: widget.initialSubjectCode,
        paperType: _selectedPaperType,
        regulation: _selectedRegulation,
        searchQuery: _searchController.text.trim(),
        onlyWithAnswerKey: _onlySolved,
      ),
    );
  }

  void _clearSubjectFilter() {
    ref.read(questionPaperControllerProvider.notifier).setSubjectFilter(null);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(questionPaperControllerProvider);
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            UnisphereHeaderCard(
              title: widget.initialSubjectCode != null
                  ? '${widget.initialSubjectCode} Question Papers'
                  : 'PYQ & Question Banks',
              subtitle: widget.initialSubjectName != null
                  ? widget.initialSubjectName!
                  : 'University End-Sem, IATs & Solved Question Banks',
              onBack: _handleBack,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 32 : 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Metrics & Quick Stats Banner
                    _buildOverviewMetricsBanner(state.papers),
                    const SizedBox(height: 16),

                    // Active Specific Subject Filter Indicator
                    if (state.filters.subjectCode != null && state.filters.subjectCode!.isNotEmpty) ...[
                      _buildActiveSubjectBanner(state.filters.subjectCode!),
                      const SizedBox(height: 14),
                    ],

                    // Universal Search Input
                    _buildSearchBar(),
                    const SizedBox(height: 14),

                    // Exam Type Filter Tabs
                    _buildPaperTypeFilterRow(),
                    const SizedBox(height: 14),

                    // Dropdown Filters Row (Semester, Regulation, Department, Solved toggle)
                    _buildSecondaryFilterBar(),
                    const SizedBox(height: 20),

                    // Section Heading & Results Count
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Available Papers & Materials (${state.papers.length})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        if (_selectedPaperType != null ||
                            _selectedSemester != 'All' ||
                            _selectedRegulation != 'All' ||
                            _selectedDepartment != 'All' ||
                            _onlySolved ||
                            _searchController.text.isNotEmpty)
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedPaperType = null;
                                _selectedSemester = 'All';
                                _selectedRegulation = 'All';
                                _selectedDepartment = 'All';
                                _onlySolved = false;
                                _searchController.clear();
                              });
                              _applyFilterChanges();
                              _clearSubjectFilter();
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.primary),
                            label: const Text(
                              'Reset Filters',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Main Content List
                    if (state.isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 48),
                          child: Loader.page(label: 'Loading question papers & PYQ...'),
                        ),
                      )
                    else if (state.papers.isEmpty)
                      _buildEmptyState()
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.papers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return _buildQuestionPaperCard(state.papers[index]);
                        },
                      ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewMetricsBanner(List<QuestionPaperModel> papers) {
    final totalSolved = papers.where((p) => p.hasAnswerKey).length;
    final totalUniversityPyq = papers.where((p) => p.paperType == QuestionPaperType.universityPyq).length;
    final totalBanks = papers.where((p) => p.paperType == QuestionPaperType.questionBankWithSolutions).length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
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
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.school_rounded, color: Color(0xFF38BDF8), size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Official Question Paper Repository',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Uploaded & verified by respective department faculties',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn('Total Papers', '${papers.length}', Icons.library_books_rounded, const Color(0xFF38BDF8)),
                _buildStatDivider(),
                _buildStatColumn('Solved Keys', '$totalSolved', Icons.verified_rounded, const Color(0xFF34D399)),
                _buildStatDivider(),
                _buildStatColumn('Univ. PYQs', '$totalUniversityPyq', Icons.badge_outlined, const Color(0xFFA78BFA)),
                _buildStatDivider(),
                _buildStatColumn('QB Solved', '$totalBanks', Icons.collections_bookmark_rounded, const Color(0xFFFBBF24)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 24,
      width: 1,
      color: Colors.white.withValues(alpha: 0.12),
    );
  }

  Widget _buildActiveSubjectBanner(String subjectCode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          const Icon(Icons.filter_alt_rounded, size: 18, color: Color(0xFF2563EB)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Showing papers filtered for Subject: $subjectCode',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E40AF),
              ),
            ),
          ),
          InkWell(
            onTap: _clearSubjectFilter,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Text(
                    'Clear',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF)),
                  ),
                  SizedBox(width: 2),
                  Icon(Icons.close_rounded, size: 14, color: Color(0xFF1E40AF)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => _applyFilterChanges(),
        decoration: InputDecoration(
          hintText: 'Search by subject code, title, topic or faculty...',
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF94A3B8)),
                  onPressed: () {
                    _searchController.clear();
                    _applyFilterChanges();
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildPaperTypeFilterRow() {
    final types = [
      null, // All
      QuestionPaperType.universityPyq,
      QuestionPaperType.questionBankWithSolutions,
      QuestionPaperType.modelExam,
      QuestionPaperType.internalAssessment1,
      QuestionPaperType.internalAssessment2,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: types.map((type) {
          final isSelected = _selectedPaperType == type;
          String label;
          IconData icon;

          if (type == null) {
            label = 'All Types';
            icon = Icons.grid_view_rounded;
          } else {
            label = type.shortLabel;
            switch (type) {
              case QuestionPaperType.universityPyq:
                icon = Icons.badge_outlined;
                break;
              case QuestionPaperType.questionBankWithSolutions:
                icon = Icons.collections_bookmark_rounded;
                break;
              case QuestionPaperType.modelExam:
                icon = Icons.assignment_outlined;
                break;
              case QuestionPaperType.internalAssessment1:
              case QuestionPaperType.internalAssessment2:
                icon = Icons.edit_note_rounded;
                break;
            }
          }

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              avatar: Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
              label: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF334155),
                ),
              ),
              selected: isSelected,
              selectedColor: const Color(0xFF1E293B),
              backgroundColor: Colors.white,
              elevation: isSelected ? 2 : 0,
              side: BorderSide(
                color: isSelected ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (_) {
                setState(() {
                  _selectedPaperType = type;
                });
                _applyFilterChanges();
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSecondaryFilterBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Semester Dropdown Filter
              Expanded(
                child: _buildFilterDropdown(
                  label: 'Semester',
                  value: _selectedSemester,
                  items: _semesters,
                  onChanged: (val) {
                    setState(() => _selectedSemester = val!);
                    _applyFilterChanges();
                  },
                ),
              ),
              const SizedBox(width: 10),
              // Regulation Dropdown Filter
              Expanded(
                child: _buildFilterDropdown(
                  label: 'Regulation',
                  value: _selectedRegulation,
                  items: _regulations,
                  onChanged: (val) {
                    setState(() => _selectedRegulation = val!);
                    _applyFilterChanges();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Department Filter
              Expanded(
                child: _buildFilterDropdown(
                  label: 'Department',
                  value: _selectedDepartment,
                  items: _departments,
                  onChanged: (val) {
                    setState(() => _selectedDepartment = val!);
                    _applyFilterChanges();
                  },
                ),
              ),
              const SizedBox(width: 10),
              // Only Solved Filter Toggle
              InkWell(
                onTap: () {
                  setState(() => _onlySolved = !_onlySolved);
                  _applyFilterChanges();
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: _onlySolved ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _onlySolved ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _onlySolved ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                        size: 18,
                        color: _onlySolved ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Solved Key Only',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: _onlySolved ? const Color(0xFF15803D) : const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down_rounded, size: 20, color: Color(0xFF64748B)),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item == 'All' ? 'All ${label}s' : item,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildQuestionPaperCard(QuestionPaperModel paper) {
    Color typeColor;
    Color typeBg;
    switch (paper.paperType) {
      case QuestionPaperType.universityPyq:
        typeColor = const Color(0xFF7C3AED);
        typeBg = const Color(0xFFF3E8FF);
        break;
      case QuestionPaperType.questionBankWithSolutions:
        typeColor = const Color(0xFFD97706);
        typeBg = const Color(0xFFFEF3C7);
        break;
      case QuestionPaperType.modelExam:
        typeColor = const Color(0xFF0D9488);
        typeBg = const Color(0xFFCCFBF1);
        break;
      case QuestionPaperType.internalAssessment1:
      case QuestionPaperType.internalAssessment2:
        typeColor = const Color(0xFF2563EB);
        typeBg = const Color(0xFFEFF6FF);
        break;
    }

    final formattedDate = DateFormat('MMM dd, yyyy').format(paper.uploadedAt);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header Bar of the Card
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                // Subject Code Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    paper.subjectCode,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Paper Type Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: typeColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    paper.paperType.displayName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: typeColor,
                    ),
                  ),
                ),
                const Spacer(),
                // Exam Session / Year Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_note_rounded, size: 13, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text(
                        paper.examSession,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Card Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  paper.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${paper.subjectName} · ${paper.department}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),

                // Tags & Attributes Row
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildPill(paper.regulation, const Color(0xFF334155), const Color(0xFFF1F5F9)),
                    _buildPill(paper.semester, const Color(0xFF334155), const Color(0xFFF1F5F9)),
                    _buildPill(paper.year, const Color(0xFF334155), const Color(0xFFF1F5F9)),
                    if (paper.hasAnswerKey)
                      _buildPill(
                        '✓ Solved / Answer Key Available',
                        const Color(0xFF15803D),
                        const Color(0xFFDCFCE7),
                      ),
                    ...paper.tags.take(3).map((tag) => _buildPill('#$tag', const Color(0xFF475569), const Color(0xFFF8FAFC))),
                  ],
                ),
                const SizedBox(height: 14),

                // Faculty Uploader & Download Info
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: const Icon(Icons.person_rounded, size: 16, color: AppColors.primary),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              paper.uploadedByStaffName,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${paper.uploadedByStaffDesignation} · $formattedDate',
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: Color(0xFF64748B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.download_rounded, size: 14, color: Color(0xFF64748B)),
                          const SizedBox(width: 3),
                          Text(
                            '${paper.downloadCount}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${paper.fileSize})',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Action Buttons
                Row(
                  children: [
                    // View Paper PDF Button
                    Expanded(
                      flex: 3,
                      child: ElevatedButton.icon(
                        onPressed: () => _openQuestionPaperViewer(paper, isAnswerKey: false),
                        icon: const Icon(Icons.description_outlined, size: 16),
                        label: const Text(
                          'View Question Paper',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E293B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // View Answer Key Button (if available)
                    if (paper.hasAnswerKey) ...[
                      Expanded(
                        flex: 3,
                        child: OutlinedButton.icon(
                          onPressed: () => _openQuestionPaperViewer(paper, isAnswerKey: true),
                          icon: const Icon(Icons.verified_rounded, size: 16, color: Color(0xFF16A34A)),
                          label: const Text(
                            'Answer Key',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFF0FDF4),
                            side: const BorderSide(color: Color(0xFF86EFAC)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    // Direct Download Trigger
                    IconButton.filledTonal(
                      onPressed: () => _handleDirectDownload(paper),
                      icon: const Icon(Icons.file_download_outlined, size: 18),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFEFF6FF),
                        foregroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
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

  Widget _buildPill(String text, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.menu_book_outlined, size: 36, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Question Papers Found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try adjusting your semester, regulation or search keyword.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              setState(() {
                _selectedPaperType = null;
                _selectedSemester = 'All';
                _selectedRegulation = 'All';
                _selectedDepartment = 'All';
                _onlySolved = false;
                _searchController.clear();
              });
              _applyFilterChanges();
              _clearSubjectFilter();
            },
            child: const Text('Clear All Filters'),
          ),
        ],
      ),
    );
  }

  void _handleDirectDownload(QuestionPaperModel paper) async {
    ref.read(questionPaperControllerProvider.notifier).incrementDownload(paper.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text('Downloading ${paper.fileName}...')),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    if (paper.fileUrl.isNotEmpty) {
      final uri = Uri.parse(paper.fileUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  void _openQuestionPaperViewer(QuestionPaperModel paper, {required bool isAnswerKey}) {
    ref.read(questionPaperControllerProvider.notifier).incrementDownload(paper.id);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuestionPaperDocumentViewerScreen(
          paper: paper,
          isAnswerKey: isAnswerKey,
        ),
      ),
    );
  }
}

/// Integrated In-App Document Viewer Screen for Question Papers and Answer Keys
class QuestionPaperDocumentViewerScreen extends StatefulWidget {
  final QuestionPaperModel paper;
  final bool isAnswerKey;

  const QuestionPaperDocumentViewerScreen({
    super.key,
    required this.paper,
    this.isAnswerKey = false,
  });

  @override
  State<QuestionPaperDocumentViewerScreen> createState() =>
      _QuestionPaperDocumentViewerScreenState();
}

class _QuestionPaperDocumentViewerScreenState
    extends State<QuestionPaperDocumentViewerScreen> {
  int _currentPage = 1;
  final int _totalPages = 8;
  double _zoomScale = 1.0;
  bool _isDownloading = false;

  void _zoomIn() {
    setState(() {
      if (_zoomScale < 2.5) _zoomScale += 0.25;
    });
  }

  void _zoomOut() {
    setState(() {
      if (_zoomScale > 0.75) _zoomScale -= 0.25;
    });
  }

  void _nextPage() {
    if (_currentPage < _totalPages) {
      setState(() => _currentPage++);
    }
  }

  void _prevPage() {
    if (_currentPage > 1) {
      setState(() => _currentPage--);
    }
  }

  Future<void> _handleDownload() async {
    setState(() => _isDownloading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => _isDownloading = false);

    final targetUrl = widget.isAnswerKey
        ? (widget.paper.answerKeyUrl ?? widget.paper.fileUrl)
        : widget.paper.fileUrl;

    if (targetUrl.isNotEmpty) {
      final uri = Uri.parse(targetUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Downloading ${widget.isAnswerKey ? widget.paper.answerKeyFileName ?? "Answer_Key.pdf" : widget.paper.fileName}...',
          ),
          backgroundColor: const Color(0xFF1E293B),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isAnswerKey
        ? '${widget.paper.subjectCode} - Model Answer Key & Solutions'
        : '${widget.paper.subjectCode} - ${widget.paper.paperType.displayName}';

    final fileName = widget.isAnswerKey
        ? (widget.paper.answerKeyFileName ?? 'Answer_Key_Solved.pdf')
        : widget.paper.fileName;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${widget.paper.subjectName} · ${widget.paper.examSession}',
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: _isDownloading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.download_rounded, color: Colors.white),
            tooltip: 'Download PDF',
            onPressed: _isDownloading ? null : _handleDownload,
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFF1E293B),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Page Controls
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded, color: Colors.white),
                  onPressed: _currentPage > 1 ? _prevPage : null,
                ),
                Text(
                  'Page $_currentPage of $_totalPages',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded, color: Colors.white),
                  onPressed: _currentPage < _totalPages ? _nextPage : null,
                ),
              ],
            ),
            // Zoom Controls
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.zoom_out_rounded, color: Colors.white, size: 20),
                  onPressed: _zoomOut,
                ),
                Text(
                  '${(_zoomScale * 100).toInt()}%',
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
                IconButton(
                  icon: const Icon(Icons.zoom_in_rounded, color: Colors.white, size: 20),
                  onPressed: _zoomIn,
                ),
              ],
            ),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Transform.scale(
            scale: _zoomScale,
            child: Container(
              width: 600,
              constraints: const BoxConstraints(minHeight: 800),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mock Document Header
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'ANNA UNIVERSITY / AUTONOMOUS EXAMINATIONS',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                            color: Colors.grey.shade900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'DEPARTMENT OF ${widget.paper.department.toUpperCase()}',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 1.2),
                          ),
                          child: Text(
                            widget.isAnswerKey ? 'OFFICIAL MODEL ANSWER KEY & SCHEME OF EVALUATION' : widget.paper.paperType.displayName.toUpperCase(),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.paper.subjectCode} — ${widget.paper.subjectName.toUpperCase()}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '(${widget.paper.regulation} · ${widget.paper.semester} · ${widget.paper.examSession})',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                  const Divider(thickness: 1.5, color: Colors.black, height: 24),

                  // Metadata Row (Time, Max Marks, Date)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Time: 3 Hours', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                      Text('Maximum Marks: 100', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                    ],
                  ),
                  const Divider(color: Colors.black54, height: 16),
                  const SizedBox(height: 10),

                  // PART A Section
                  Center(
                    child: Text(
                      'PART A — (10 × 2 = 20 Marks)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade900),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildQuestionItem('1.', 'Define the asymptotic notations Big-O, Big-Omega and Big-Theta with mathematical definitions.', widget.isAnswerKey ? 'Ans: Big-O (f(n) <= c*g(n) for n >= n0) denotes asymptotic upper bound. Big-Omega gives lower bound, Big-Theta gives tight bound.' : null),
                  _buildQuestionItem('2.', 'What is an Abstract Data Type (ADT)? State two examples.', widget.isAnswerKey ? 'Ans: An ADT is a mathematical model for data types where behavior is defined by operations rather than implementation (e.g., Stack ADT, Queue ADT).' : null),
                  _buildQuestionItem('3.', 'Convert the infix expression (A + B) * (C - D) / E into equivalent postfix notation.', widget.isAnswerKey ? 'Ans: Postfix = AB+CD-*E/' : null),
                  _buildQuestionItem('4.', 'State the condition for a binary tree to be considered a strictly binary tree.', widget.isAnswerKey ? 'Ans: Every internal node has exactly two children (0 or 2 children).' : null),
                  _buildQuestionItem('5.', 'What is the balance factor of an AVL Tree node? What rotations are performed for RL imbalance?', widget.isAnswerKey ? 'Ans: Balance Factor = Height(Left Subtree) - Height(Right Subtree) ∈ {-1, 0, 1}. For RL imbalance: Right rotation on right child followed by Left rotation on root.' : null),

                  const SizedBox(height: 18),
                  // PART B Section
                  Center(
                    child: Text(
                      'PART B — (5 × 13 = 65 Marks)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade900),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildQuestionItem('11. (a)', 'Explain the operations on Singly Linked List: Insertion at beginning, deletion of a specific node, and reversing the list with complete algorithm & C/Java code snippets.', widget.isAnswerKey ? 'Ans: Step 1: Traversal using pointer. Step 2: Node rearrangement. Time Complexity: O(n). [Diagram + 4 Marks for Algorithm, 4 Marks for Code, 5 Marks for Analysis]' : null),
                  _buildQuestionItem('11. (b) (OR)', 'Describe Dijkstra\'s Shortest Path algorithm with a detailed trace on a directed graph with 6 vertices.', widget.isAnswerKey ? 'Ans: Greedy approach using priority queue. Distance array initialization, relaxation step d[v] = min(d[v], d[u] + w(u,v)). [Trace Table + Step Matrix]' : null),

                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_user_rounded, color: Color(0xFF16A34A), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Uploaded by Faculty: ${widget.paper.uploadedByStaffName}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Document: $fileName (${widget.paper.fileSize})',
                                style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
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
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionItem(String qNum, String question, String? solution) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 48,
                child: Text(
                  qNum,
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(fontSize: 11.5, height: 1.4, color: Colors.black87),
                ),
              ),
            ],
          ),
          if (solution != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 48),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                ),
                child: Text(
                  solution,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF166534), fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
