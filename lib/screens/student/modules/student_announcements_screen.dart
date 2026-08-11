import 'package:flutter/material.dart';
import 'package:clg_application/services/announcement_service.dart';
import 'package:clg_application/widgets/announcements/announcement_card.dart';
import 'package:clg_application/widgets/announcements/create_announcement_dialog.dart';
import 'package:clg_application/screens/announcements/announcement_detail_screen.dart';

class StudentAnnouncementsScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const StudentAnnouncementsScreen({
    super.key,
    this.onBack,
  });

  @override
  State<StudentAnnouncementsScreen> createState() => _StudentAnnouncementsScreenState();
}

class _StudentAnnouncementsScreenState extends State<StudentAnnouncementsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  bool _unreadOnly = false;
  bool _importantOnly = false;

  final List<Map<String, dynamic>> _categoryOptions = const [
    {
      'cat': 'All',
      'title': 'All',
      'subtitle': 'Show all announcements',
      'icon': Icons.grid_view_rounded,
      'color': Color(0xFFF97316),
      'bgColor': Color(0xFFFFEDD5),
    },
    {
      'cat': 'General',
      'title': 'General',
      'subtitle': 'General campus updates',
      'icon': Icons.campaign_rounded,
      'color': Color(0xFF2563EB),
      'bgColor': Color(0xFFEFF6FF),
    },
    {
      'cat': 'Academic',
      'title': 'Academic',
      'subtitle': 'Classes & syllabus',
      'icon': Icons.school_rounded,
      'color': Color(0xFF4F46E5),
      'bgColor': Color(0xFFEEF2FF),
    },
    {
      'cat': 'Examination',
      'title': 'Examination',
      'subtitle': 'Exams & hall tickets',
      'icon': Icons.assignment_late_rounded,
      'color': Color(0xFFDC2626),
      'bgColor': Color(0xFFFEF2F2),
    },
    {
      'cat': 'Department',
      'title': 'Department',
      'subtitle': 'Department circulars',
      'icon': Icons.business_rounded,
      'color': Color(0xFF0D9488),
      'bgColor': Color(0xFFCCFBF1),
    },
    {
      'cat': 'Placement',
      'title': 'Placement',
      'subtitle': 'Jobs & campus drives',
      'icon': Icons.work_rounded,
      'color': Color(0xFF0284C7),
      'bgColor': Color(0xFFE0F2FE),
    },
    {
      'cat': 'Internship',
      'title': 'Internship',
      'subtitle': 'Internship roles',
      'icon': Icons.badge_rounded,
      'color': Color(0xFF06B6D4),
      'bgColor': Color(0xFFCFFAFE),
    },
    {
      'cat': 'Event',
      'title': 'Event',
      'subtitle': 'Fests & competitions',
      'icon': Icons.emoji_events_rounded,
      'color': Color(0xFF7C3AED),
      'bgColor': Color(0xFFF3E8FF),
    },
    {
      'cat': 'Holiday',
      'title': 'Holiday',
      'subtitle': 'Holidays & closures',
      'icon': Icons.beach_access_rounded,
      'color': Color(0xFFD97706),
      'bgColor': Color(0xFFFEF3C7),
    },
    {
      'cat': 'Emergency',
      'title': 'Emergency',
      'subtitle': 'Urgent campus alerts',
      'icon': Icons.priority_high_rounded,
      'color': Color(0xFFEF4444),
      'bgColor': Color(0xFFFEE2E2),
    },
    {
      'cat': 'Fee / Administration',
      'title': 'Fee / Admin',
      'subtitle': 'Payments & admin',
      'icon': Icons.account_balance_rounded,
      'color': Color(0xFF059669),
      'bgColor': Color(0xFFD1FAE5),
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleBack(BuildContext context) {
    if (!mounted) return;
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else if (widget.onBack != null) {
      widget.onBack!();
    }
  }

  int get _activeFilterCount {
    int count = 0;
    if (_selectedCategory != 'All') count++;
    if (_unreadOnly) count++;
    if (_importantOnly) count++;
    return count;
  }

  void _showCategoryFilterModal(BuildContext context) {
    String tempCategory = _selectedCategory;
    bool tempUnread = _unreadOnly;
    bool tempImportant = _importantOnly;

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
                            'Announcement Category',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Select category to filter announcements',
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
                  const SizedBox(height: 16),

                  // Quick Toggles
                  Row(
                    children: [
                      FilterChip(
                        label: const Text('Unread Only'),
                        selected: tempUnread,
                        onSelected: (val) {
                          setModalState(() => tempUnread = val);
                        },
                        selectedColor: const Color(0xFFFEF3C7),
                        checkmarkColor: const Color(0xFFD97706),
                        labelStyle: TextStyle(
                          color: tempUnread ? const Color(0xFFD97706) : const Color(0xFF475569),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Urgent / Important'),
                        selected: tempImportant,
                        onSelected: (val) {
                          setModalState(() => tempImportant = val);
                        },
                        selectedColor: const Color(0xFFFEE2E2),
                        checkmarkColor: const Color(0xFFDC2626),
                        labelStyle: TextStyle(
                          color: tempImportant ? const Color(0xFFDC2626) : const Color(0xFF475569),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 2-Column Grid of Category Cards
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
                        itemCount: _categoryOptions.length,
                        itemBuilder: (context, index) {
                          final option = _categoryOptions[index];
                          final isSelected = tempCategory == option['cat'];

                          return InkWell(
                            onTap: () {
                              setModalState(() {
                                tempCategory = option['cat'] as String;
                              });
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFFFF7ED) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFFF97316) : const Color(0xFFE2E8F0),
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
                                          color: isSelected ? const Color(0xFFF97316) : Colors.transparent,
                                          border: Border.all(
                                            color: isSelected ? const Color(0xFFF97316) : const Color(0xFFCBD5E1),
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
                                          color: isSelected ? const Color(0xFFC2410C) : const Color(0xFF0F172A),
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
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFFEDD5)),
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
                            color: Color(0xFFF97316),
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
                                  color: Color(0xFFC2410C),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Choose category and tap Apply Filter to view updates.',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFFEA580C),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.campaign_outlined,
                          color: Color(0xFFFDBA74),
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
                          _selectedCategory = tempCategory;
                          _unreadOnly = tempUnread;
                          _importantOnly = tempImportant;
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
                        backgroundColor: const Color(0xFFF97316),
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
    final annService = AnnouncementService();
    final bool canPopRoute = ModalRoute.of(context)?.canPop ?? false;
    return PopScope(
      canPop: canPopRoute,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || !mounted) return;
        if (widget.onBack != null) {
          widget.onBack!();
        }
      },
      child: Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black12,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () => _handleBack(context),
        ),
        title: AnimatedBuilder(
          animation: annService,
          builder: (context, _) {
            final unread = annService.unreadCount;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Flexible(
                  child: Text(
                    'Announcements',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                ),
                if (unread > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$unread UNREAD',
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_alert_rounded, color: Color(0xFFF97316)),
            tooltip: 'Publish Announcement (Admin/HOD)',
            onPressed: () => CreateAnnouncementDialog.show(context),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: annService,
        builder: (context, child) {
          final announcements = annService.getFilteredAnnouncements(
            category: _selectedCategory,
            unreadOnly: _unreadOnly,
            importantOnly: _importantOnly,
            searchQuery: _searchController.text,
          );

          return Column(
            children: [
              // Search & Filter Header Section
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
                              hintText: 'Search announcements, publishers...',
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
                          color: _activeFilterCount > 0 ? const Color(0xFFFFF7ED) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            onTap: () => _showCategoryFilterModal(context),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _activeFilterCount > 0 ? const Color(0xFFF97316) : const Color(0xFFE2E8F0),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.tune_rounded,
                                    size: 20,
                                    color: _activeFilterCount > 0 ? const Color(0xFFF97316) : const Color(0xFF64748B),
                                  ),
                                  if (_activeFilterCount > 0) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF97316),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '$_activeFilterCount',
                                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
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

                    // Active Filter Bar
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.campaign_rounded, size: 14, color: Color(0xFFF97316)),
                              const SizedBox(width: 6),
                              Text(
                                'Category: $_selectedCategory',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        if (_activeFilterCount > 0)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = 'All';
                                _unreadOnly = false;
                                _importantOnly = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
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

              // Announcement List
              Expanded(
                child: announcements.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.mark_email_read_rounded, size: 48, color: Color(0xFFCBD5E1)),
                            const SizedBox(height: 12),
                            const Text('No announcements found', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                            const SizedBox(height: 4),
                            Text(
                              _activeFilterCount > 0 ? 'Try clearing active filters.' : 'Check back later for new updates!',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: announcements.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final ann = announcements[index];
                          return AnnouncementCard(
                            announcement: ann,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => AnnouncementDetailScreen(announcement: ann)),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    ),
  );
}
}
