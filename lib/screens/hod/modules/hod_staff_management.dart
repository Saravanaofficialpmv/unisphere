import 'package:flutter/material.dart';
import 'package:clg_application/core/constants/app_colors.dart';

class HodStaffManagement extends StatefulWidget {
  const HodStaffManagement({super.key});

  @override
  State<HodStaffManagement> createState() => _HodStaffManagementState();
}

class _HodStaffManagementState extends State<HodStaffManagement> {
  String _searchQuery = '';
  String _selectedDesignation = 'All';
  String _selectedStatus = 'All';

  final List<Map<String, dynamic>> _facultyList = [
    {
      'name': 'Dr. S. Meenakshi',
      'id': 'FAC-CSE-001',
      'designation': 'Professor',
      'department': 'CSE',
      'subjects': ['Distributed Systems', 'Cloud Computing'],
      'phone': '+91 98765 43210',
      'email': 'meenakshi.s@unisphere.edu',
      'attendance': 'Present',
      'leaveStatus': 'On Duty',
      'experience': '14 Years',
      'workload': '16 hrs/week',
      'rating': '4.9',
      'photo': 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150',
    },
    {
      'name': 'Prof. Rajesh Kumar',
      'id': 'FAC-CSE-004',
      'designation': 'Associate Professor',
      'department': 'CSE',
      'subjects': ['Data Structures', 'Algorithms'],
      'phone': '+91 98765 11223',
      'email': 'rajesh.k@unisphere.edu',
      'attendance': 'Present',
      'leaveStatus': 'Active',
      'experience': '9 Years',
      'workload': '18 hrs/week',
      'rating': '4.7',
      'photo': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
    },
    {
      'name': 'Dr. Anita Roy',
      'id': 'FAC-CSE-008',
      'designation': 'Assistant Professor',
      'department': 'CSE',
      'subjects': ['Machine Learning', 'AI Fundamentals'],
      'phone': '+91 98765 88990',
      'email': 'anita.roy@unisphere.edu',
      'attendance': 'On Leave',
      'leaveStatus': 'Casual Leave Approved',
      'experience': '6 Years',
      'workload': '14 hrs/week',
      'rating': '4.8',
      'photo': 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=150',
    },
    {
      'name': 'Prof. Vikram Sharma',
      'id': 'FAC-CSE-012',
      'designation': 'Assistant Professor',
      'department': 'CSE',
      'subjects': ['Database Management', 'SQL Labs'],
      'phone': '+91 98765 44332',
      'email': 'vikram.s@unisphere.edu',
      'attendance': 'Present',
      'leaveStatus': 'Active',
      'experience': '5 Years',
      'workload': '20 hrs/week',
      'rating': '4.6',
      'photo': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredStaff = _facultyList.where((faculty) {
      final matchesSearch = faculty['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          faculty['id'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          faculty['subjects'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesDesignation = _selectedDesignation == 'All' || faculty['designation'] == _selectedDesignation;
      final matchesStatus = _selectedStatus == 'All' || faculty['attendance'] == _selectedStatus;
      return matchesSearch && matchesDesignation && matchesStatus;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildFilterChips(),
            const SizedBox(height: 24),
            Text(
              'FACULTY DIRECTORY (${filteredStaff.length})',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.1),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredStaff.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = filteredStaff[index];
                return _buildFacultyCard(context, item);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddFacultyModal(context),
        icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
        label: const Text('Add New Faculty', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'DEPARTMENT ADMINISTRATION',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.2),
        ),
        SizedBox(height: 4),
        Text(
          'Staff & Faculty Management',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: TextField(
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: const InputDecoration(
          hintText: 'Search faculty by name, ID, or subject...',
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterDropdown('Designation', _selectedDesignation, ['All', 'Professor', 'Associate Professor', 'Assistant Professor'], (val) {
            setState(() => _selectedDesignation = val!);
          }),
          const SizedBox(width: 10),
          _buildFilterDropdown('Status', _selectedStatus, ['All', 'Present', 'On Leave'], (val) {
            setState(() => _selectedStatus = val!);
          }),
          const SizedBox(width: 10),
          _buildFilterChip('Year Coordinator', false, () {}),
          const SizedBox(width: 10),
          _buildFilterChip('Class Advisor', false, () {}),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary, size: 20),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          onChanged: onChanged,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text('$label: $e'))).toList(),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget _buildFacultyCard(BuildContext context, Map<String, dynamic> item) {
    final isPresent = item['attendance'] == 'Present';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                backgroundImage: NetworkImage(item['photo']),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item['name'],
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isPresent ? AppColors.success.withValues(alpha: 0.12) : AppColors.error.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item['attendance'],
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isPresent ? AppColors.success : AppColors.error),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item['designation']} • ${item['id']}',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (item['subjects'] as List<String>).map((sub) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
                child: Text(sub, style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.phone_outlined, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(item['phone'], style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showFacultyDetailsModal(context, item),
                icon: const Icon(Icons.badge_outlined, size: 16),
                label: const Text('View Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFacultyDetailsModal(BuildContext context, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DefaultTabController(
          length: 8,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.88,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(width: 40, height: 5, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      CircleAvatar(radius: 26, backgroundImage: NetworkImage(item['photo'])),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('${item['designation']} (${item['id']})', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const TabBar(
                  isScrollable: true,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  tabs: [
                    Tab(text: 'Basic Info'),
                    Tab(text: 'Teaching Schedule'),
                    Tab(text: 'Attendance'),
                    Tab(text: 'Assigned Subjects'),
                    Tab(text: 'Workload'),
                    Tab(text: 'Leave History'),
                    Tab(text: 'Documents'),
                    Tab(text: 'Performance'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildInfoTab(item),
                      const Center(child: Text('Weekly Class Timetable & Labs')),
                      const Center(child: Text('98.4% Monthly Presence Record')),
                      const Center(child: Text('Distributed Systems, Cloud Computing')),
                      const Center(child: Text('16 Hours/Week Teaching Workload')),
                      const Center(child: Text('Casual Leave: 2 Used / 12 Total')),
                      const Center(child: Text('PhD Degree, Joining Order, ID Proof')),
                      const Center(child: Text('Student Feedback Score: 4.9 / 5.0')),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.edit_outlined, size: 16), label: const Text('Edit Faculty')),
                      OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.menu_book_outlined, size: 16), label: const Text('Assign Subject')),
                      OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.lock_reset_outlined, size: 16), label: const Text('Reset Password')),
                      OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.download_rounded, size: 16), label: const Text('Generate Report')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoTab(Map<String, dynamic> item) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildDetailTile(Icons.email_outlined, 'Email Address', item['email']),
        _buildDetailTile(Icons.phone_outlined, 'Phone Number', item['phone']),
        _buildDetailTile(Icons.work_outline, 'Experience', item['experience']),
        _buildDetailTile(Icons.timer_outlined, 'Weekly Workload', item['workload']),
        _buildDetailTile(Icons.star_outline, 'Performance Rating', '${item['rating']} / 5.0'),
        _buildDetailTile(Icons.verified_user_outlined, 'Leave Status', item['leaveStatus']),
      ],
    );
  }

  Widget _buildDetailTile(IconData icon, String title, String val) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 2),
              Text(val, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddFacultyModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Add New Faculty Member', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(decoration: InputDecoration(labelText: 'Full Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
                const SizedBox(height: 12),
                TextField(decoration: InputDecoration(labelText: 'Email Address', border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
                const SizedBox(height: 12),
                TextField(decoration: InputDecoration(labelText: 'Designation (e.g. Assistant Professor)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
                const SizedBox(height: 12),
                TextField(decoration: InputDecoration(labelText: 'Subjects Handled', border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faculty Member Added Successfully!'), backgroundColor: AppColors.success));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Submit & Send Invitation', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
