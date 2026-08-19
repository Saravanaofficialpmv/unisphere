import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/core/constants/app_colors.dart';
import 'package:unisphere/models/syllabus_model.dart';
import 'package:unisphere/screens/student/modules/subject_details_screen.dart';
import 'package:unisphere/screens/student/modules/syllabus_document_viewer_screen.dart';
import 'package:unisphere/services/auth_service.dart';
import 'package:unisphere/services/syllabus_service.dart';
import 'package:unisphere/widgets/common/unisphere_header_card.dart';

class StudentSyllabusScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;

  const StudentSyllabusScreen({
    super.key,
    this.onBack,
  });

  @override
  ConsumerState<StudentSyllabusScreen> createState() => _StudentSyllabusScreenState();
}

class _StudentSyllabusScreenState extends ConsumerState<StudentSyllabusScreen> {
  final SyllabusService _syllabusService = SyllabusService();
  final TextEditingController _searchController = TextEditingController();

  // Student Profile Identification
  String _studentDepartment = 'Computer Science & Engineering';
  String _currentAcademicYear = '2026–2027'; // Current applicable academic year
  int get _currentStartYear => SyllabusService.parseStartYear(_currentAcademicYear);

  // Current Syllabus Controls
  String _currentSelectedYear = 'I Year';
  String _currentSelectedSemester = 'Semester 1';
  String _selectedTypeFilter = 'All';

  // Previous Syllabus Controls
  String? _previousSelectedAcademicYear = '2025–2026';
  String _previousSelectedYear = 'I Year';
  String _previousSelectedSemester = 'Semester 1';

  bool _isLoading = true;
  List<SyllabusSubjectModel> _studentSyllabi = [];

  final List<String> _availableYears = ['I Year', 'II Year', 'III Year', 'IV Year'];

  List<String> _getAvailableSemesters(String year) {
    switch (year) {
      case 'I Year':
        return ['Semester 1', 'Semester 2'];
      case 'II Year':
        return ['Semester 3', 'Semester 4'];
      case 'III Year':
        return ['Semester 5', 'Semester 6'];
      case 'IV Year':
        return ['Semester 7', 'Semester 8'];
      default:
        return ['Semester 1', 'Semester 2'];
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _identifyStudentAndLoadSyllabus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _identifyStudentAndLoadSyllabus() {
    final user = ref.read(currentUserProvider).value ?? ref.read(authServiceProvider).currentUser;
    final meta = user?.metadata ?? {};

    final deptVal = meta['department']?.toString() ?? meta['dept']?.toString() ?? 'Computer Science & Engineering';
    _studentDepartment = deptVal;

    final rawAcYear = meta['currentAcademicYear']?.toString() ?? meta['academicYear']?.toString() ?? '2026–2027';
    _currentAcademicYear = rawAcYear;

    final rawYear = meta['year']?.toString() ?? 'I Year';
    final identifiedYear = _normalizeYear(rawYear);

    final rawSem = meta['semester']?.toString() ?? 'Semester 1';
    final identifiedSem = _normalizeSemester(rawSem, identifiedYear);

    setState(() {
      _currentSelectedYear = identifiedYear;
      _currentSelectedSemester = identifiedSem;
    });

    _loadSyllabiData();
  }

  String _normalizeYear(String raw) {
    final s = raw.toLowerCase().trim();
    if (s.contains('2nd') || s.contains('ii year') || s.contains('2') || s == 'ii') return 'II Year';
    if (s.contains('3rd') || s.contains('iii year') || s.contains('3') || s == 'iii') return 'III Year';
    if (s.contains('4th') || s.contains('iv year') || s.contains('4') || s == 'iv') return 'IV Year';
    return 'I Year';
  }

  String _normalizeSemester(String rawSem, [String? year]) {
    final numMatch = RegExp(r'\d+').firstMatch(rawSem);
    if (numMatch != null) {
      final semNum = int.tryParse(numMatch.group(0)!) ?? 1;
      return 'Semester $semNum';
    }
    if (year == 'II Year') return 'Semester 3';
    if (year == 'III Year') return 'Semester 5';
    if (year == 'IV Year') return 'Semester 7';
    return 'Semester 1';
  }

  Future<void> _loadSyllabiData() async {
    setState(() => _isLoading = true);

    // Fetch published syllabus records where effectiveStartYear <= studentCurrentStartYear
    final results = await _syllabusService.getStudentSyllabus(
      department: _studentDepartment,
      studentAcademicYear: _currentAcademicYear,
      includePreviousYears: true,
    );

    if (mounted) {
      setState(() {
        _studentSyllabi = results;
        _isLoading = false;

        // Set default previous academic year if available
        final prevYears = _previousAcademicYearsList;
        if (prevYears.isNotEmpty && (_previousSelectedAcademicYear == null || !prevYears.contains(_previousSelectedAcademicYear))) {
          _previousSelectedAcademicYear = prevYears.first;
        }
      });
    }
  }

  /// Current Syllabus Records (effectiveStartYear == _currentStartYear)
  List<SyllabusSubjectModel> get _currentSyllabusSubjects {
    final query = _searchController.text.trim().toLowerCase();
    return _studentSyllabi.where((s) {
      // 1. MUST be for the current academic year
      final isCurrent = s.effectiveStartYear == _currentStartYear;
      if (!isCurrent) return false;

      // 2. Year & Semester match
      final matchesYear = _normalizeYear(s.year) == _currentSelectedYear;
      final matchesSem = _normalizeSemester(s.semester) == _currentSelectedSemester;

      // 3. Search & Type filter
      final matchesQuery = query.isEmpty ||
          s.subjectName.toLowerCase().contains(query) ||
          s.subjectCode.toLowerCase().contains(query);
      final matchesType = _selectedTypeFilter == 'All' || s.subjectType.toLowerCase() == _selectedTypeFilter.toLowerCase();

      return matchesYear && matchesSem && matchesQuery && matchesType;
    }).toList();
  }

  /// Available previous academic years list e.g. ["2025–2026", "2024–2025"]
  List<String> get _previousAcademicYearsList {
    final prevYears = _studentSyllabi
        .where((s) => s.effectiveStartYear < _currentStartYear)
        .map((s) => s.academicYear)
        .toSet()
        .toList();
    prevYears.sort((a, b) => b.compareTo(a)); // Descending order
    return prevYears.isEmpty ? ['2025–2026', '2024–2025'] : prevYears;
  }

  /// Previous Syllabus Records (effectiveStartYear < _currentStartYear for selected previous academic year)
  List<SyllabusSubjectModel> get _previousSyllabusSubjects {
    if (_previousSelectedAcademicYear == null) return [];
    return _studentSyllabi.where((s) {
      final isPrevious = s.effectiveStartYear < _currentStartYear;
      final matchesSelectedYear = s.academicYear == _previousSelectedAcademicYear;
      final matchesYear = _normalizeYear(s.year) == _previousSelectedYear;
      final matchesSem = _normalizeSemester(s.semester) == _previousSelectedSemester;
      return isPrevious && matchesSelectedYear && matchesYear && matchesSem;
    }).toList();
  }

  /// Validates and opens syllabus document in viewer or shows unavailable alert
  void _handleViewDocument(SyllabusSubjectModel subject) {
    if (subject.documentUrl.isEmpty || !subject.documentUrl.startsWith('http')) {
      _showDocumentUnavailableAlert(subject);
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SyllabusDocumentViewerScreen(subject: subject),
      ),
    );
  }

  void _showDocumentUnavailableAlert(SyllabusSubjectModel subject) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Syllabus document unavailable for ${subject.subjectCode}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            UnisphereHeaderCard(
              title: 'Academic Syllabus',
              subtitle: 'Official Course Syllabi & Academic History',
              onBack: widget.onBack,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadSyllabiData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─────────────────────────────────────────
                      // 1. CURRENT SYLLABUS SECTION
                      // ─────────────────────────────────────────
                      _buildCurrentSyllabusSection(),
                      const SizedBox(height: 32),

                      // ─────────────────────────────────────────
                      // 2. PREVIOUS SYLLABUS SECTION
                      // ─────────────────────────────────────────
                      _buildPreviousSyllabusSection(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Current Syllabus Card & Controls Section
  Widget _buildCurrentSyllabusSection() {
    final user = ref.watch(currentUserProvider).value ?? ref.watch(authServiceProvider).currentUser;
    final userName = (user?.name != null && user!.name.isNotEmpty) ? user.name : 'Student';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.stars_rounded, color: Colors.white, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'CURRENT SYLLABUS',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF16A34A).withValues(alpha: 0.3)),
                ),
                child: Text(
                  _currentAcademicYear,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Title & Identified Student Meta
          Text(
            '$userName\'s Applicable Syllabus',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 4),
          Text(
            '$_studentDepartment  ·  $_currentSelectedYear  ·  $_currentSelectedSemester',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 14),

          // Academic Year & Semester Selector Controls
          const Text('Select Academic Year:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _availableYears.map((yr) {
                final isSelected = yr == _currentSelectedYear;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(yr),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: const Color(0xFFF1F5F9),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF475569),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      fontSize: 12,
                    ),
                    onSelected: (_) => setState(() {
                      _currentSelectedYear = yr;
                      _currentSelectedSemester = _getAvailableSemesters(yr).first;
                    }),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),

          const Text('Select Semester:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _getAvailableSemesters(_currentSelectedYear).map((sem) {
                final isSelected = sem == _currentSelectedSemester;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(sem),
                    selected: isSelected,
                    selectedColor: const Color(0xFF2563EB),
                    backgroundColor: const Color(0xFFF1F5F9),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF475569),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      fontSize: 12,
                    ),
                    onSelected: (_) => setState(() => _currentSelectedSemester = sem),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 16),

          // Search Input & Type Filter Chips
          _buildSearchAndFilterRow(),
          const SizedBox(height: 16),

          // Current Syllabus Subject Cards List
          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
          else if (_currentSyllabusSubjects.isEmpty)
            _buildEmptyCurrentSyllabusCard()
          else
            ..._currentSyllabusSubjects.map((s) => _buildSyllabusItemCard(s, isCurrent: true)),
        ],
      ),
    );
  }

  /// Previous Syllabus Section
  Widget _buildPreviousSyllabusSection() {
    final prevYearsList = _previousAcademicYearsList;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF64748B),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.history_rounded, color: Colors.white, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'PREVIOUS SYLLABUS',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Text(
                'Academic History',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Past Syllabus Versions & Regulations',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Access archived syllabus documents from previous academic years.',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),

          // Select Previous Academic Year Pills
          const Text('Select Academic Year:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: prevYearsList.map((acYr) {
                final isSelected = acYr == _previousSelectedAcademicYear;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(acYr),
                    selected: isSelected,
                    selectedColor: const Color(0xFF0F172A),
                    backgroundColor: const Color(0xFFF1F5F9),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF475569),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      fontSize: 12,
                    ),
                    onSelected: (_) => setState(() => _previousSelectedAcademicYear = acYr),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Previous Year & Semester Pills
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Year:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                    const SizedBox(height: 4),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _availableYears.map((yr) {
                          final isSelected = yr == _previousSelectedYear;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: ChoiceChip(
                              label: Text(yr, style: const TextStyle(fontSize: 11)),
                              selected: isSelected,
                              selectedColor: const Color(0xFF475569),
                              backgroundColor: const Color(0xFFF8FAFC),
                              labelStyle: TextStyle(color: isSelected ? Colors.white : const Color(0xFF475569)),
                              onSelected: (_) => setState(() {
                                _previousSelectedYear = yr;
                                _previousSelectedSemester = _getAvailableSemesters(yr).first;
                              }),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Previous Syllabus Subject Cards
          if (_previousSyllabusSubjects.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Color(0xFF64748B), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No archived syllabus records for the selected previous period.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
            )
          else
            ..._previousSyllabusSubjects.map((s) => _buildSyllabusItemCard(s, isCurrent: false)),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterRow() {
    final filters = ['All', 'Theory', 'Practical', 'Elective'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Search current syllabus (e.g. CS101, C Programming)...',
            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 20),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filters.map((f) {
              final isSelected = f == _selectedTypeFilter;
              return Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: FilterChip(
                  label: Text(f, style: const TextStyle(fontSize: 11)),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: const Color(0xFFF1F5F9),
                  labelStyle: TextStyle(color: isSelected ? Colors.white : const Color(0xFF64748B)),
                  onSelected: (_) => setState(() => _selectedTypeFilter = f),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSyllabusItemCard(SyllabusSubjectModel subject, {required bool isCurrent}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isCurrent ? const Color(0xFFF8FAFC) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SubjectDetailsScreen(subject: subject),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        subject.subjectCode,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        subject.subjectType,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${subject.credits} Credits',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  subject.subjectName,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 4),
                Text(
                  '${subject.subjectCode} · ${subject.subjectType} · ${subject.credits} Credits',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
                const SizedBox(height: 2),
                Text(
                  '${subject.year} · ${subject.semester}  ·  Regulation ${subject.applicableBatch}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.info_outline_rounded, size: 16),
                      label: const Text('Subject Info', style: TextStyle(fontSize: 12)),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SubjectDetailsScreen(subject: subject),
                          ),
                        );
                      },
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.picture_as_pdf_rounded, size: 16, color: Colors.white),
                      label: const Text('View Syllabus →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCurrent ? AppColors.primary : const Color(0xFF475569),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _handleViewDocument(subject),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCurrentSyllabusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: const Column(
        children: [
          Icon(Icons.menu_book_outlined, size: 36, color: Color(0xFFD97706)),
          SizedBox(height: 10),
          Text(
            'Syllabus Not Available',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
          ),
          SizedBox(height: 4),
          Text(
            'Your syllabus has not been published yet. Please check again later.',
            style: TextStyle(fontSize: 12, color: Color(0xFFB45309)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
