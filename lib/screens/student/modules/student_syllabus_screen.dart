import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/core/constants/app_colors.dart';
import 'package:unisphere/models/syllabus_model.dart';
import 'package:unisphere/screens/student/modules/subject_details_screen.dart';
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

  String _selectedYear = 'I Year';
  String _selectedSemester = 'Semester 1';
  String _selectedTypeFilter = 'All';
  final String _academicYear = '2026–2027';
  String _studentDepartment = 'Computer Science & Engineering';

  bool _isLoading = true;
  List<SyllabusSubjectModel> _allPublishedSubjects = [];

  final List<String> _availableYears = ['I Year', 'II Year', 'III Year', 'IV Year'];
  
  List<String> get _availableSemesters {
    switch (_selectedYear) {
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
      _automaticallyIdentifyStudentDetails();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Automatically identifies student academic information from authenticated profile
  void _automaticallyIdentifyStudentDetails() {
    final user = ref.read(currentUserProvider).value ?? ref.read(authServiceProvider).currentUser;
    final meta = user?.metadata ?? {};

    // Department
    final deptVal = meta['department']?.toString() ?? meta['dept']?.toString() ?? 'Computer Science & Engineering';
    _studentDepartment = deptVal;

    // Year Identification e.g., "1st Year", "I Year", "3rd Year"
    final rawYear = meta['academicYear']?.toString() ?? meta['year']?.toString() ?? 'I Year';
    final identifiedYear = _normalizeYear(rawYear);

    // Semester Identification e.g., "Semester 1", "1", "Semester 5"
    final rawSem = meta['semester']?.toString() ?? meta['sem']?.toString() ?? 'Semester 1';
    final identifiedSem = _normalizeSemester(rawSem, identifiedYear);

    setState(() {
      _selectedYear = identifiedYear;
      _selectedSemester = identifiedSem;
    });

    _loadPublishedSyllabus();
  }

  String _normalizeYear(String raw) {
    final s = raw.toLowerCase().trim();
    if (s.contains('2nd') || s.contains('ii year') || s.contains('2') || s == 'ii') return 'II Year';
    if (s.contains('3rd') || s.contains('iii year') || s.contains('3') || s == 'iii') return 'III Year';
    if (s.contains('4th') || s.contains('iv year') || s.contains('4') || s == 'iv') return 'IV Year';
    return 'I Year';
  }

  String _normalizeSemester(String rawSem, String year) {
    final numMatch = RegExp(r'\d+').firstMatch(rawSem);
    if (numMatch != null) {
      final semNum = int.tryParse(numMatch.group(0)!) ?? 1;
      return 'Semester $semNum';
    }
    // Default semester for year
    if (year == 'II Year') return 'Semester 3';
    if (year == 'III Year') return 'Semester 5';
    if (year == 'IV Year') return 'Semester 7';
    return 'Semester 1';
  }

  Future<void> _loadPublishedSyllabus() async {
    setState(() => _isLoading = true);

    final results = await _syllabusService.getPublishedSyllabus(
      department: _studentDepartment,
      year: _selectedYear,
      semester: _selectedSemester,
      academicYear: _academicYear,
    );

    if (mounted) {
      setState(() {
        _allPublishedSubjects = results;
        _isLoading = false;
      });
    }
  }

  List<SyllabusSubjectModel> get _filteredSubjects {
    final query = _searchController.text.trim().toLowerCase();
    return _allPublishedSubjects.where((subject) {
      // Must be published
      if (!subject.isPublished) return false;

      final matchesQuery = query.isEmpty ||
          subject.subjectName.toLowerCase().contains(query) ||
          subject.subjectCode.toLowerCase().contains(query);

      final matchesType = _selectedTypeFilter == 'All' ||
          subject.subjectType.toLowerCase() == _selectedTypeFilter.toLowerCase();

      return matchesQuery && matchesType;
    }).toList();
  }

  void _onYearChanged(String newYear) {
    setState(() {
      _selectedYear = newYear;
      final semList = _availableSemesters;
      _selectedSemester = semList.first;
    });
    _loadPublishedSyllabus();
  }

  void _onSemesterChanged(String newSem) {
    setState(() {
      _selectedSemester = newSem;
    });
    _loadPublishedSyllabus();
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
              subtitle: 'Official Published Course Syllabi',
              onBack: widget.onBack,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadPublishedSyllabus,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Academic Year & Student Identification Banner
                      _buildIdentificationHeaderBanner(),
                      const SizedBox(height: 16),

                      // Academic Navigation: Year Selector Pills
                      const Text(
                        'Select Academic Year:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 8),
                      _buildYearSelectorRow(),
                      const SizedBox(height: 12),

                      // Semester Selector Pills
                      const Text(
                        'Select Semester:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 8),
                      _buildSemesterSelectorRow(),
                      const SizedBox(height: 20),

                      // Search Bar & Filter Chips
                      _buildSearchAndFilterSection(),
                      const SizedBox(height: 20),

                      // Content Area: Subject List or Empty State or Skeleton
                      if (_isLoading)
                        _buildLoadingSkeleton()
                      else if (_filteredSubjects.isEmpty)
                        _buildEmptyState()
                      else
                        ..._filteredSubjects.map((subject) => _buildSubjectCard(subject)),
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

  Widget _buildIdentificationHeaderBanner() {
    final user = ref.watch(currentUserProvider).value ?? ref.watch(authServiceProvider).currentUser;
    final userName = (user?.name != null && user!.name.isNotEmpty) ? user.name : 'Student';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF312E81).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 12),
                    const SizedBox(width: 6),
                    Text(
                      _academicYear,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'PUBLISHED SYLLABUS',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$userName\'s Syllabus',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.verified_user_rounded, color: Color(0xFFA5B4FC), size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Auto-Identified: $_studentDepartment  ·  $_selectedYear  ·  $_selectedSemester',
                  style: const TextStyle(fontSize: 12, color: Color(0xFFA5B4FC), fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildYearSelectorRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _availableYears.map((yr) {
          final isSelected = yr == _selectedYear;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(yr),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF475569),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 13,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primary : const Color(0xFFCBD5E1),
              ),
              onSelected: (_) => _onYearChanged(yr),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSemesterSelectorRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _availableSemesters.map((sem) {
          final isSelected = sem == _selectedSemester;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(sem),
              selected: isSelected,
              selectedColor: const Color(0xFF4F46E5),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF475569),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 12,
              ),
              side: BorderSide(
                color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFCBD5E1),
              ),
              onSelected: (_) => _onSemesterChanged(sem),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    final typeFilters = ['All', 'Theory', 'Practical', 'Elective'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Input
        TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Search subjects by name or code (e.g. CS101, C Programming)...',
            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: () => setState(() => _searchController.clear()),
                  )
                : null,
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
        const SizedBox(height: 12),

        // Type Filter Pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: typeFilters.map((tf) {
              final isSelected = tf == _selectedTypeFilter;
              return Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: FilterChip(
                  label: Text(tf),
                  selected: isSelected,
                  selectedColor: const Color(0xFF0F172A),
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                  ),
                  onSelected: (_) => setState(() => _selectedTypeFilter = tf),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectCard(SyllabusSubjectModel subject) {
    Color typeColor;
    Color typeBg;
    switch (subject.subjectType.toLowerCase()) {
      case 'practical':
      case 'lab':
        typeColor = const Color(0xFF0D9488);
        typeBg = const Color(0xFFCCFBF1);
        break;
      case 'elective':
        typeColor = const Color(0xFF7C3AED);
        typeBg = const Color(0xFFF3E8FF);
        break;
      default:
        typeColor = const Color(0xFF2563EB);
        typeBg = const Color(0xFFEFF6FF);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SubjectDetailsScreen(subject: subject),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Code, Type Badge, Credits
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        subject.subjectCode,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: typeBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        subject.subjectType,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: typeColor,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${subject.credits} Credits',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Subject Name
                Text(
                  subject.subjectName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),

                // Department & Units Count
                Row(
                  children: [
                    Text(
                      '${subject.year} · ${subject.semester}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(width: 8),
                    const Text('•', style: TextStyle(color: Color(0xFFCBD5E1))),
                    const SizedBox(width: 8),
                    Text(
                      '${subject.units.length} Units Covered',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Action Link Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'View Syllabus →',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
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

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.menu_book_outlined,
              size: 48,
              color: Color(0xFFD97706),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Syllabus Not Available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your syllabus has not been published yet for the selected academic period. Please check again later or switch your semester view above.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Column(
      children: List.generate(
        3,
        (index) => Container(
          height: 130,
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      ),
    );
  }
}
