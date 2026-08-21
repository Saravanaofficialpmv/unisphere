import 'package:flutter/material.dart';
import 'package:unisphere/core/constants/app_colors.dart';
import 'package:unisphere/widgets/student/student_full_detail_modal.dart';

class HodStudentManagement extends StatefulWidget {
  const HodStudentManagement({super.key});

  @override
  State<HodStudentManagement> createState() => _HodStudentManagementState();
}

class _HodStudentManagementState extends State<HodStudentManagement> {
  String _searchQuery = '';
  String _selectedYear = 'All';
  String _selectedSection = 'All';
  String _selectedType = 'All';

  final List<Map<String, String>> _pendingVerifications = [
    {
      'name': 'Alex Johnson',
      'regNo': 'RA2111003010001',
      'dept': 'Computer Science and Engineering',
      'section': 'Sec A',
      'semester': 'Semester 6 (3rd Year)',
      'phone': '+91 98765 43210',
      'status': 'Pending Verification',
    },
  ];

  final List<Map<String, dynamic>> _studentList = [
    {
      'name': 'Aravind Swamy',
      'regNo': '917721104012',
      'year': '3rd Year',
      'semester': 'Semester 6',
      'section': 'CS-A',
      'cgpa': '9.12',
      'attendance': '96.5%',
      'feeStatus': 'Paid',
      'advisor': 'Dr. S. Meenakshi',
      'gender': 'Male',
      'type': 'Day Scholar',
      'photo': 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=150',
    },
    {
      'name': 'Priya Dharshini',
      'regNo': '917721104045',
      'year': '3rd Year',
      'semester': 'Semester 6',
      'section': 'CS-A',
      'cgpa': '8.85',
      'attendance': '92.0%',
      'feeStatus': 'Paid',
      'advisor': 'Dr. S. Meenakshi',
      'gender': 'Female',
      'type': 'Hosteller',
      'photo': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
    },
    {
      'name': 'Karthik Raja',
      'regNo': '917722104022',
      'year': '2nd Year',
      'semester': 'Semester 4',
      'section': 'CS-B',
      'cgpa': '7.45',
      'attendance': '71.5%',
      'feeStatus': 'Pending (₹15,000)',
      'advisor': 'Prof. Rajesh Kumar',
      'gender': 'Male',
      'type': 'Day Scholar',
      'photo': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
    },
    {
      'name': 'Sneha Murali',
      'regNo': '917723104089',
      'year': '1st Year',
      'semester': 'Semester 2',
      'section': 'CS-C',
      'cgpa': '9.50',
      'attendance': '98.0%',
      'feeStatus': 'Paid',
      'advisor': 'Dr. Anita Roy',
      'gender': 'Female',
      'type': 'Hosteller',
      'photo': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _studentList.where((s) {
      final matchesSearch = s['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s['regNo'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesYear = _selectedYear == 'All' || s['year'] == _selectedYear;
      final matchesSection = _selectedSection == 'All' || s['section'] == _selectedSection;
      final matchesType = _selectedType == 'All' || s['type'] == _selectedType;
      return matchesSearch && matchesYear && matchesSection && matchesType;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ACADEMIC ROSTER',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.2),
            ),
            const SizedBox(height: 4),
            const Text(
              'Student Directory',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 20),
            _buildPendingVerificationsSection(),
            const SizedBox(height: 24),
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildFilters(),
            const SizedBox(height: 24),
            Text(
              'ENROLLED STUDENTS (${filtered.length})',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.1),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildStudentCard(context, filtered[index]);
              },
            ),
          ],
        ),
      ),
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
          hintText: 'Search by student name or register number...',
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterDropdown('Year', _selectedYear, ['All', '1st Year', '2nd Year', '3rd Year', '4th Year'], (v) => setState(() => _selectedYear = v!)),
          const SizedBox(width: 10),
          _buildFilterDropdown('Section', _selectedSection, ['All', 'CS-A', 'CS-B', 'CS-C'], (v) => setState(() => _selectedSection = v!)),
          const SizedBox(width: 10),
          _buildFilterDropdown('Type', _selectedType, ['All', 'Day Scholar', 'Hosteller'], (v) => setState(() => _selectedType = v!)),
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

  Widget _buildStudentCard(BuildContext context, Map<String, dynamic> item) {
    final double attVal = double.tryParse(item['attendance'].toString().replaceAll('%', '')) ?? 0.0;
    final isLowAtt = attVal < 75.0;

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
              CircleAvatar(radius: 26, backgroundImage: NetworkImage(item['photo'])),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text('${item['regNo']} • ${item['section']}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isLowAtt ? AppColors.error.withValues(alpha: 0.12) : AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item['attendance'],
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isLowAtt ? AppColors.error : AppColors.success),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniStat('CGPA', item['cgpa'], AppColors.primary),
              _buildMiniStat('Advisor', item['advisor'], AppColors.textPrimary),
              _buildMiniStat('Fee Status', item['feeStatus'], item['feeStatus'] == 'Paid' ? AppColors.success : AppColors.warning),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showStudentProfileModal(context, item),
              icon: const Icon(Icons.person_search_outlined, size: 18),
              label: const Text('View Full Student Profile'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                side: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  void _showStudentProfileModal(BuildContext context, Map<String, dynamic> item) {
    showStudentFullDetailModal(context, item);
  }

  Widget _buildPendingVerificationsSection() {
    if (_pendingVerifications.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFF59E0B),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STUDENT PROFILE VERIFICATION REQUESTS (${_pendingVerifications.length})',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFB45309), letterSpacing: 1.1),
                    ),
                    const Text(
                      'Review submitted academic profiles and approve for official campus roster.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _pendingVerifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final req = _pendingVerifications[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundColor: Color(0xFFFEF3C7),
                          child: Icon(Icons.person, color: Color(0xFFD97706), size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(req['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              Text('ID: ${req['regNo']} • ${req['section']} • ${req['semester']}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(10)),
                          child: const Text('Pending HOD Review', style: TextStyle(color: Color(0xFFB45309), fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text('Dept: ${req['dept']} • Contact: ${req['phone']}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() => _pendingVerifications.removeAt(index));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Verification rejected. Returned to student for editing.'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            },
                            icon: const Icon(Icons.close_rounded, size: 16),
                            label: const Text('Reject'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() => _pendingVerifications.removeAt(index));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('🎉 ${req['name']}\'s profile details verified & approved by HOD!'),
                                  backgroundColor: const Color(0xFF10B981),
                                ),
                              );
                            },
                            icon: const Icon(Icons.check_circle_rounded, size: 16),
                            label: const Text('Approve & Verify Student'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              minimumSize: const Size(0, 36),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
