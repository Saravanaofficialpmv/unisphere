import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clg_application/core/constants/app_colors.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:clg_application/widgets/common/main_sidebar.dart';

class StudentDashboard extends ConsumerStatefulWidget {
  const StudentDashboard({super.key});

  @override
  ConsumerState<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends ConsumerState<StudentDashboard> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<SidebarItem> _sidebarItems = [
    SidebarItem(label: 'Home Dashboard', icon: Icons.dashboard_outlined),
    SidebarItem(label: 'My Tasks', icon: Icons.assignment_outlined, badge: '3'),
    SidebarItem(label: 'Attendance', icon: Icons.calendar_today_outlined),
    SidebarItem(label: 'Academic Marks', icon: Icons.bar_chart_outlined),
    SidebarItem(label: 'My Profile', icon: Icons.person_outline),
    SidebarItem.divider('CAMPUS LIFE'),
    SidebarItem(label: 'Announcements', icon: Icons.campaign_outlined),
    SidebarItem(label: 'Library Status', icon: Icons.local_library_outlined),
  ];

  final List<Widget> _screens = [
    const StudentHomeScreen(),
    const Center(child: Text('Assignments & Tasks')),
    const Center(child: Text('Detailed Attendance')),
    const Center(child: Text('Marks & Grades')),
    const Center(child: Text('Student Profile')),
    const Center(child: Text('Announcements')),
    const Center(child: Text('Library')),
  ];

  void _handleNavigation(int index) {
    setState(() => _currentIndex = index);
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1200;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: isDesktop ? null : Drawer(child: _buildSidebar()),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Hello, Alex 👋', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary), onPressed: () {}),
        ],
      ),
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(),
          Expanded(child: _screens[_currentIndex < _screens.length ? _currentIndex : 0]),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return MainSidebar(
      selectedIndex: _currentIndex,
      onDestinationSelected: _handleNavigation,
      items: _sidebarItems,
      userName: 'Alex Johnson',
      userEmail: 'alex.j@unisphere.edu',
    );
  }
}

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(),
          const SizedBox(height: 24),
          _buildAttendanceOverview(context),
          const SizedBox(height: 24),
          _buildSectionHeader('Today\'s Classes', () {}),
          const SizedBox(height: 12),
          _buildClassList(),
          const SizedBox(height: 24),
          _buildSectionHeader('Recent Announcements', () {}),
          const SizedBox(height: 12),
          _buildAnnouncementList(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hello, Welcome Back! 👋',
          style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
        const Text(
          'Alex Johnson',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildAttendanceOverview(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 40.0,
            lineWidth: 8.0,
            percent: 0.85,
            center: const Text("85%", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            progressColor: Colors.white,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Average Attendance',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Your presence is great!',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        TextButton(onPressed: onSeeAll, child: const Text('See All')),
      ],
    );
  }

  Widget _buildClassList() {
    return Column(
      children: [
        _buildClassCard('Advanced Mathematics', '09:00 AM - 10:30 AM', 'Room 302', AppColors.primary),
        _buildClassCard('Computer Science', '11:00 AM - 12:30 PM', 'Lab 1', AppColors.success),
      ],
    );
  }

  Widget _buildClassCard(String title, String time, String room, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text('$time • $room', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.more_vert, color: AppColors.textTertiary),
        ],
      ),
    );
  }

  Widget _buildAnnouncementList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildAnnouncementItem('End Semester Exam Date Out!', 'The exams will start from 15th June. Check timetable.'),
          const Divider(height: 32),
          _buildAnnouncementItem('New Library Timings', 'Library will be open till 10 PM from Monday.'),
        ],
      ),
    );
  }

  Widget _buildAnnouncementItem(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      ],
    );
  }
}
