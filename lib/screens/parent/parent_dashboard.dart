import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clg_application/core/constants/app_colors.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'package:clg_application/widgets/common/main_sidebar.dart';

class ParentDashboard extends ConsumerStatefulWidget {
  const ParentDashboard({super.key});

  @override
  ConsumerState<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends ConsumerState<ParentDashboard> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<SidebarItem> _sidebarItems = [
    SidebarItem(label: 'Dashboard Home', icon: Icons.dashboard_outlined),
    SidebarItem(label: 'Attendance History', icon: Icons.calendar_month_outlined),
    SidebarItem(label: 'Performance Marks', icon: Icons.bar_chart_outlined),
    SidebarItem(label: 'Institutional Alerts', icon: Icons.campaign_outlined, badge: 'New'),
    SidebarItem(label: 'Parent Profile', icon: Icons.person_outline),
    SidebarItem.divider('CHILD SERVICES'),
    SidebarItem(label: 'Child Fee Status', icon: Icons.payments_outlined),
    SidebarItem(label: 'Transport Details', icon: Icons.bus_alert_outlined),
  ];

  final List<Widget> _screens = [
    const ParentHomeScreen(),
    const Center(child: Text('Complete Attendance Log')),
    const Center(child: Text('Academic Marks Breakdown')),
    const Center(child: Text('Primary Institution Alerts')),
    const Center(child: Text('Account Profile Settings')),
    const Center(child: Text('Fee Payment Status')),
    const Center(child: Text('School Transport Map')),
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
        title: const Text('Hello, Mr. Johnson 👋', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
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
      userName: 'Mr. Johnson',
      userEmail: 'parent.j@unisphere.edu',
    );
  }
}

class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildParentWelcome(),
          const SizedBox(height: 24),
          _buildChildOverviewCard(context),
          const SizedBox(height: 24),
          _buildQuickStats(),
          const SizedBox(height: 24),
          _buildSectionHeader('Recent Performance', () {}),
          const SizedBox(height: 12),
          _buildPerformanceList(),
          const SizedBox(height: 24),
          _buildSectionHeader('Upcoming Events', () {}),
          const SizedBox(height: 12),
          _buildEventList(),
        ],
      ),
    );
  }

  Widget _buildParentWelcome() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hello, Mr. Johnson',
          style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
        const Text(
          'Tracking Alex\'s Progress',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildChildOverviewCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 40, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Alex Johnson',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Semester 4 • B.Tech CS',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                LinearPercentIndicator(
                  padding: EdgeInsets.zero,
                  lineHeight: 6.0,
                  percent: 0.82,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  progressColor: Colors.white,
                  barRadius: const Radius.circular(3),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Overall Attendance: 82%',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        _buildStatItem('CGPA', '8.4', Icons.auto_graph_outlined, Colors.orange),
        const SizedBox(width: 12),
        _buildStatItem('Credits', '48', Icons.stars_outlined, Colors.purple),
        const SizedBox(width: 12),
        _buildStatItem('Rank', '12/60', Icons.emoji_events_outlined, Colors.blue),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
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

  Widget _buildPerformanceList() {
    return Column(
      children: [
        _buildPerformanceCard('Mathematics - Unit Test 2', '22/25', 0.88, AppColors.success),
        _buildPerformanceCard('Physics - Lab Internal', '18/20', 0.90, AppColors.primary),
      ],
    );
  }

  Widget _buildPerformanceCard(String title, String marks, double percent, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text('Score: $marks', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          CircularPercentIndicator(
            radius: 20.0,
            lineWidth: 3.0,
            percent: percent,
            progressColor: color,
            backgroundColor: color.withValues(alpha: 0.1),
          ),
        ],
      ),
    );
  }

  Widget _buildEventList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildEventItem('Parent-Teacher Meeting', 'Next Saturday, 10 AM', Icons.groups_outlined),
          const Divider(height: 32),
          _buildEventItem('Annual Sports Meet', 'Starts 20th April', Icons.sports_basketball_outlined),
        ],
      ),
    );
  }

  Widget _buildEventItem(String title, String time, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text(time, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }
}
