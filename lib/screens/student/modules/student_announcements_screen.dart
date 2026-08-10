import 'package:flutter/material.dart';

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

  final List<Map<String, dynamic>> _announcements = [
    {
      'id': 'ann_1',
      'title': 'End-Semester Exam Schedule & Hall Ticket Download',
      'subtitle': 'The final exam schedule for May 2026 is published. Download hall tickets from student portal before 12th May.',
      'category': 'Exams',
      'time': '2 hours ago',
      'publisher': 'Office of Controller of Examinations',
      'isPinned': true,
      'isNew': true,
      'color': const Color(0xFFDC2626),
      'bgColor': const Color(0xFFFEF2F2),
      'icon': Icons.assignment_late_rounded,
    },
    {
      'id': 'ann_2',
      'title': 'National Hackathon 2026 Registration Open',
      'subtitle': 'Represent UNISPHERE SRM in the grand tech hackathon. Cash prizes up to ₹5,000,000. Registration closes this Friday.',
      'category': 'Events',
      'time': '5 hours ago',
      'publisher': 'Department of Computer Science',
      'isPinned': true,
      'isNew': true,
      'color': const Color(0xFF7C3AED),
      'bgColor': const Color(0xFFF3E8FF),
      'icon': Icons.emoji_events_rounded,
    },
    {
      'id': 'ann_3',
      'title': 'Revised Library Timings for Exam Season',
      'subtitle': 'Central Library will remain open 24/7 starting Monday to support student examination preparation.',
      'category': 'Campus Life',
      'time': '1 day ago',
      'publisher': 'Central Library Administration',
      'isPinned': false,
      'isNew': false,
      'color': const Color(0xFF059669),
      'bgColor': const Color(0xFFECFDF5),
      'icon': Icons.local_library_rounded,
    },
    {
      'id': 'ann_4',
      'title': 'Campus Placement Drive: Google & Microsoft',
      'subtitle': 'Pre-placement talk for 3rd and 4th year B.Tech students on 15th May at Main Auditorium.',
      'category': 'Placements',
      'time': '2 days ago',
      'publisher': 'Career Guidance & Placement Cell',
      'isPinned': false,
      'isNew': false,
      'color': const Color(0xFF2563EB),
      'bgColor': const Color(0xFFEFF6FF),
      'icon': Icons.work_rounded,
    },
    {
      'id': 'ann_5',
      'title': 'Curriculum Update: AI & Ethics Seminar',
      'subtitle': 'Guest lecture by Industry Expert Dr. Andrew Ng scheduled for Wednesday at 10 AM.',
      'category': 'Academic',
      'time': '3 days ago',
      'publisher': 'HOD Computer Engineering',
      'isPinned': false,
      'isNew': false,
      'color': const Color(0xFFD97706),
      'bgColor': const Color(0xFFFEF3C7),
      'icon': Icons.school_rounded,
    },
  ];

  List<Map<String, dynamic>> get _filteredAnnouncements {
    final query = _searchController.text.trim().toLowerCase();
    return _announcements.where((ann) {
      final matchesQuery = query.isEmpty ||
          ann['title'].toLowerCase().contains(query) ||
          ann['subtitle'].toLowerCase().contains(query) ||
          ann['publisher'].toLowerCase().contains(query);

      final matchesCategory = _selectedCategory == 'All' || ann['category'] == _selectedCategory;

      return matchesQuery && matchesCategory;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleBack(BuildContext context) {
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['All', 'Academic', 'Exams', 'Events', 'Placements', 'Campus Life'];

    return PopScope(
      canPop: widget.onBack == null,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack(context);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.black12,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
            onPressed: () => _handleBack(context),
          ),
          title: const Text(
            'Campus Announcements',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
        ),
      body: Column(
        children: [
          // Search & Filter Bar Container
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search announcements, notices, events...',
                    hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () => setState(() => _searchController.clear()),
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) setState(() => _selectedCategory = cat);
                          },
                          selectedColor: const Color(0xFF0F172A),
                          backgroundColor: const Color(0xFFF1F5F9),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF475569),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          showCheckmark: false,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Announcements List
          Expanded(
            child: _filteredAnnouncements.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.campaign_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'No announcements found',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredAnnouncements.length,
                    itemBuilder: (context, index) {
                      final item = _filteredAnnouncements[index];
                      final Color color = item['color'];
                      final Color bgColor = item['bgColor'];
                      final bool isPinned = item['isPinned'];
                      final bool isNew = item['isNew'];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isPinned ? color.withValues(alpha: 0.4) : const Color(0xFFE2E8F0),
                            width: isPinned ? 1.5 : 1.0,
                          ),
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
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(item['icon'] as IconData, color: color, size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: color.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              item['category'],
                                              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          if (isPinned)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFEF3C7),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.push_pin_rounded, size: 10, color: Color(0xFFD97706)),
                                                  SizedBox(width: 2),
                                                  Text(
                                                    'PINNED',
                                                    style: TextStyle(color: Color(0xFFD97706), fontSize: 9, fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          if (isNew)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFDC2626),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: const Text(
                                                'NEW',
                                                style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        item['title'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Color(0xFF0F172A),
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item['subtitle'],
                              style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
                            ),
                            const SizedBox(height: 12),
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item['publisher'],
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                                ),
                                Text(
                                  item['time'],
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    ),
  );
}
}
