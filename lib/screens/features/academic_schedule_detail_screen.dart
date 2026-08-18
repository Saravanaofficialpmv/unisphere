import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:unisphere/models/academic_schedule_model.dart';
import 'package:unisphere/providers/academic_schedule_provider.dart';
import 'package:unisphere/services/academic_schedule_service.dart';
import 'package:unisphere/services/auth_service.dart';
import 'package:unisphere/widgets/common/unisphere_header_card.dart';

class AcademicScheduleDetailScreen extends ConsumerStatefulWidget {
  final AcademicScheduleModel? schedule;
  final VoidCallback? onBack;

  const AcademicScheduleDetailScreen({
    super.key,
    this.schedule,
    this.onBack,
  });

  @override
  ConsumerState<AcademicScheduleDetailScreen> createState() => _AcademicScheduleDetailScreenState();
}

class _AcademicScheduleDetailScreenState extends ConsumerState<AcademicScheduleDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedYearTab = 'I Year';
  bool _isUserYearInitialized = false;

  final List<String> _yearTabs = ['I Year', 'II Year', 'III Year', 'IV Year'];
  final List<String> _categories = ['All', 'Academic', 'Assessment', 'Examination', 'Holiday', 'Event'];

  @override
  void initState() {
    super.initState();
    if (widget.schedule != null) {
      _selectedYearTab = AcademicScheduleService.normalizeTargetYear(widget.schedule!.targetStudentYear);
      _isUserYearInitialized = true;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initUserYear(String? userYear) {
    if (!_isUserYearInitialized && userYear != null && userYear.isNotEmpty) {
      _selectedYearTab = AcademicScheduleService.normalizeTargetYear(userYear);
      _isUserYearInitialized = true;
    }
  }

  void _handleBack(BuildContext context) {
    if (!mounted) return;
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _downloadFile(AcademicScheduleModel schedule) async {
    final url = schedule.fileUrl;
    if (url.isNotEmpty) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text('Downloaded official "${schedule.fileName}"')),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showDocumentDetailsModal(BuildContext context, AcademicScheduleModel schedule) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.verified_user_rounded, color: Color(0xFF2563EB), size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Official Document Record',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        Text(
                          'Verified by Head of Department',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 16),
              _buildModalRow(Icons.description_outlined, 'File Name', schedule.fileName),
              _buildModalRow(Icons.category_outlined, 'Format', schedule.fileExtensionUpper),
              _buildModalRow(Icons.data_usage_outlined, 'File Size', schedule.formattedFileSize.isNotEmpty ? schedule.formattedFileSize : '184 KB'),
              _buildModalRow(Icons.layers_outlined, 'Version Release', 'v${schedule.version}.0 (${schedule.isActive ? 'Active / Latest' : 'Archived'})'),
              _buildModalRow(Icons.school_outlined, 'Academic Year', '${schedule.academicYear} • ${schedule.targetStudentYear}'),
              _buildModalRow(Icons.business_outlined, 'Department Scope', schedule.departmentName),
              _buildModalRow(Icons.person_outline, 'Published By', '${schedule.uploadedByName} (HOD)'),
              _buildModalRow(Icons.event_available_outlined, 'Publication Date', schedule.formattedUpdatedDate),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _downloadFile(schedule);
                  },
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: Text('Download Official .${schedule.fileType.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF2563EB)),
          const SizedBox(width: 10),
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF0F172A), fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value ?? ref.watch(authServiceProvider).currentUser;
    final userYear = user?.metadata?['year']?.toString();
    _initUserYear(userYear);

    // Fetch schedules
    final allDefaults = AcademicScheduleService.getDefaultInitialSchedules();
    final scheduleAsync = ref.watch(userAcademicScheduleProvider);

    AcademicScheduleModel currentSchedule = allDefaults.firstWhere(
      (s) => AcademicScheduleService.normalizeTargetYear(s.targetStudentYear) == _selectedYearTab,
      orElse: () => allDefaults.first,
    );

    // If fetched data is available for current year, use it
    scheduleAsync.whenData((fetched) {
      if (fetched != null && AcademicScheduleService.normalizeTargetYear(fetched.targetStudentYear) == _selectedYearTab) {
        currentSchedule = fetched;
      }
    });

    if (widget.schedule != null && AcademicScheduleService.normalizeTargetYear(widget.schedule!.targetStudentYear) == _selectedYearTab) {
      currentSchedule = widget.schedule!;
    }

    final events = currentSchedule.scheduleEvents;

    // Filter events
    final filteredEvents = events.where((event) {
      final matchesSearch = _searchQuery.isEmpty ||
          event.title.toLowerCase().contains(_searchQuery) ||
          event.dateString.toLowerCase().contains(_searchQuery) ||
          (event.description?.toLowerCase().contains(_searchQuery) ?? false);
      final matchesCategory = _selectedCategory == 'All' || event.category.toLowerCase() == _selectedCategory.toLowerCase();
      return matchesSearch && matchesCategory;
    }).toList();

    // Stats calculations
    final totalEvents = events.length;
    final totalAssessments = events.where((e) => e.category == 'Assessment').length;
    final totalExams = events.where((e) => e.category == 'Examination').length;
    final totalHolidays = events.where((e) => e.category == 'Holiday' || e.isHoliday).length;

    // Next upcoming milestone
    final now = DateTime.now();
    ScheduleEventItem? nextMilestone;
    for (final e in events) {
      if (e.date != null && (e.date!.isAfter(now) || e.date!.isAtSameMomentAs(now))) {
        nextMilestone = e;
        break;
      }
    }
    nextMilestone ??= events.isNotEmpty ? events.first : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            UnisphereHeaderCard(
              title: 'Important Days & Schedule',
              subtitle: 'Official Institution Calendar & Milestones',
              onBack: () => _handleBack(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Year Scope Switcher Tabs
                    _buildYearSelector(),
                    const SizedBox(height: 16),

                    // 2. Hero Schedule Highlights Card
                    _buildHeroCard(currentSchedule, nextMilestone),
                    const SizedBox(height: 18),

                    // 3. Stats Quick Metrics
                    _buildStatsGrid(totalEvents, totalAssessments, totalExams, totalHolidays),
                    const SizedBox(height: 20),

                    // 4. Search & Filter Bar
                    _buildSearchAndFilters(events),
                    const SizedBox(height: 16),

                    // 5. Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ACADEMIC TIMELINE & MILESTONES (${filteredEvents.length})',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty || _selectedCategory != 'All')
                          InkWell(
                            onTap: () => setState(() {
                              _searchQuery = '';
                              _selectedCategory = 'All';
                              _searchController.clear();
                            }),
                            child: const Text(
                              'Reset Filters',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 6. Chronological Events Timeline List
                    if (filteredEvents.isEmpty)
                      _buildEmptyState()
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredEvents.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) => _buildTimelineCard(filteredEvents[index]),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Year Scope Selector ──────────────────────
  Widget _buildYearSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
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
      child: Row(
        children: _yearTabs.map((year) {
          final isSelected = _selectedYearTab == year;
          return Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedYearTab = year),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  year,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Hero Highlights Card ─────────────────────
  Widget _buildHeroCard(AcademicScheduleModel schedule, ScheduleEventItem? nextMilestone) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E3A8A),
            Color(0xFF2563EB),
            Color(0xFF3B82F6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
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
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, color: Colors.white, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'OFFICIAL / LATEST',
                      style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'v${schedule.version}.0 Release',
                  style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            schedule.title,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5),
          ),
          const SizedBox(height: 4),
          Text(
            'Academic Year: ${schedule.academicYear} • ${schedule.semester}',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),

          // Next Milestone Highlight Box
          if (nextMilestone != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.flag_rounded, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NEXT UPCOMING MILESTONE',
                          style: TextStyle(color: Color(0xFFFDE047), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          nextMilestone.title,
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          nextMilestone.dateString,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Action Buttons
          Row(
            children: [
              Expanded(
                flex: 6,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1E3A8A),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => _downloadFile(schedule),
                  icon: const Icon(Icons.file_download_rounded, size: 18),
                  label: Text(
                    schedule.fileType.isNotEmpty ? 'Download .${schedule.fileType.toUpperCase()}' : 'Download Document',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 4,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => _showDocumentDetailsModal(context, schedule),
                  icon: const Icon(Icons.info_outline_rounded, size: 16),
                  label: const Text('Info', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Stats Grid ───────────────────────────────
  Widget _buildStatsGrid(int total, int assessments, int exams, int holidays) {
    return Row(
      children: [
        _buildStatCard('Total Events', '$total', Icons.event_available_rounded, const Color(0xFF2563EB), const Color(0xFFEFF6FF)),
        const SizedBox(width: 8),
        _buildStatCard('CAT Cycles', '$assessments', Icons.assessment_outlined, const Color(0xFFD97706), const Color(0xFFFEF3C7)),
        const SizedBox(width: 8),
        _buildStatCard('Exams', '$exams', Icons.badge_outlined, const Color(0xFF7C3AED), const Color(0xFFF3E8FF)),
        const SizedBox(width: 8),
        _buildStatCard('Holidays', '$holidays', Icons.beach_access_rounded, const Color(0xFFDC2626), const Color(0xFFFEE2E2)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ── Search & Filter Controls ─────────────────
  Widget _buildSearchAndFilters(List<ScheduleEventItem> allEvents) {
    return Column(
      children: [
        // Search bar
        Container(
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
            style: const TextStyle(fontSize: 13.5, color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              hintText: 'Search milestones, exams, holidays...',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF2563EB), size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Category Filter Pills
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = _selectedCategory == cat;
              return InkWell(
                onTap: () => setState(() => _selectedCategory = cat),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0)),
                  ),
                  child: Center(
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Timeline Event Card ──────────────────────
  Widget _buildTimelineCard(ScheduleEventItem item) {
    Color badgeColor = const Color(0xFF2563EB);
    Color badgeBg = const Color(0xFFEFF6FF);
    IconData categoryIcon = Icons.school_rounded;

    switch (item.category.toLowerCase()) {
      case 'holiday':
        badgeColor = const Color(0xFFDC2626);
        badgeBg = const Color(0xFFFEE2E2);
        categoryIcon = Icons.beach_access_rounded;
        break;
      case 'assessment':
        badgeColor = const Color(0xFFD97706);
        badgeBg = const Color(0xFFFEF3C7);
        categoryIcon = Icons.assignment_rounded;
        break;
      case 'examination':
        badgeColor = const Color(0xFF7C3AED);
        badgeBg = const Color(0xFFF3E8FF);
        categoryIcon = Icons.badge_outlined;
        break;
      case 'event':
        badgeColor = const Color(0xFF0284C7);
        badgeBg = const Color(0xFFE0F2FE);
        categoryIcon = Icons.emoji_events_rounded;
        break;
      default:
        badgeColor = const Color(0xFF059669);
        badgeBg = const Color(0xFFD1FAE5);
        categoryIcon = Icons.school_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Stamp Column
          Container(
            width: 82,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(categoryIcon, color: badgeColor, size: 18),
                const SizedBox(height: 4),
                Text(
                  item.dateString,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.category.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: badgeColor,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    if (item.isHoliday) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'No Classes',
                          style: TextStyle(color: Color(0xFFDC2626), fontSize: 9.5, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    height: 1.25,
                  ),
                ),
                if (item.description != null && item.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.description!,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.3),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty Search / Filter State ──────────────
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
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
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.event_busy_rounded, color: Color(0xFF94A3B8), size: 36),
          ),
          const SizedBox(height: 14),
          const Text(
            'No matching milestones found',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Try clearing your search query or switching category filters.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => setState(() {
              _searchQuery = '';
              _selectedCategory = 'All';
              _searchController.clear();
            }),
            child: const Text('Reset Search & Filter'),
          ),
        ],
      ),
    );
  }
}

