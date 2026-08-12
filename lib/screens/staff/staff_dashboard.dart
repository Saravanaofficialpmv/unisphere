import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/core/constants/app_colors.dart';
import 'package:unisphere/widgets/common/notification_sheet.dart';

import 'package:unisphere/screens/staff/modules/staff_assignment_creation.dart';
import 'package:unisphere/screens/staff/modules/staff_submission_review.dart';
import 'package:unisphere/widgets/common/main_sidebar.dart';

class StaffDashboard extends ConsumerStatefulWidget {
  const StaffDashboard({super.key});

  @override
  ConsumerState<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends ConsumerState<StaffDashboard> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<NavigatorState> _innerNavigatorKey = GlobalKey<NavigatorState>();

  final List<SidebarItem> _sidebarItems = [
    SidebarItem(label: 'Home Dashboard', icon: Icons.dashboard_outlined),
    SidebarItem(label: 'Give Assignment', icon: Icons.add_task_outlined),
    SidebarItem(label: 'Review Submissions', icon: Icons.checklist_outlined, badge: '12'),
    SidebarItem(label: 'Upload Marks', icon: Icons.upload_file_outlined),
    SidebarItem(label: 'Staff Profile', icon: Icons.person_outline),
    SidebarItem.divider('FACULTY TOOLS'),
    SidebarItem(label: 'Take Attendance', icon: Icons.how_to_reg_outlined),
    SidebarItem(label: 'Library Access', icon: Icons.local_library_outlined),
  ];

  late final List<Widget> _screens = [
    StaffHomeScreen(onNavigate: _handleNavigation),
    StaffAssignmentCreation(onCreated: () => setState(() => _currentIndex = 2)),
    const StaffSubmissionReview(),
    const Center(child: Text('Institutional Marks Upload')),
    const Center(child: Text('Faculty Profile Details')),
    const Center(child: Text('Electronic Attendance Record')),
    const Center(child: Text('Faculty Library Access')),
  ];

  void _handleNavigation(int index) {
    if (_innerNavigatorKey.currentState?.canPop() ?? false) {
      _innerNavigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
    setState(() => _currentIndex = index);
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_innerNavigatorKey.currentState?.canPop() ?? false) {
          _innerNavigatorKey.currentState?.pop();
          return;
        }
        if (_currentIndex != 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _currentIndex = 0;
              });
            }
          });
        }
      },
      child: Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: isDesktop ? null : Drawer(child: _buildSidebar()),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: _currentIndex == 0 
          ? null 
          : Text(_sidebarItems[_currentIndex].label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary)),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(
              _currentIndex == 0 ? Icons.menu_rounded : Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary,
              size: _currentIndex == 0 ? 24 : 20,
            ),
            onPressed: () {
              if (_currentIndex == 0) {
                _scaffoldKey.currentState?.openDrawer();
              } else {
                _handleNavigation(0);
              }
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary),
            onPressed: () => showNotificationSheet(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(),
          Expanded(
            child: ClipRect(
              child: Navigator(
                key: _innerNavigatorKey,
                onGenerateRoute: (settings) {
                  return MaterialPageRoute(
                    builder: (_) => _screens[_currentIndex < _screens.length ? _currentIndex : 0],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildSidebar() {
    return MainSidebar(
      selectedIndex: _currentIndex,
      onDestinationSelected: _handleNavigation,
      items: _sidebarItems,
      userName: 'Prof. Emily Carter',
      userEmail: 'e.carter@unisphere.edu',
    );
  }
}

class StaffHomeScreen extends StatelessWidget {
  final Function(int)? onNavigate;
  const StaffHomeScreen({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isMobile),
          SizedBox(height: isMobile ? 32 : 48),
          _buildActionCards(context, isMobile),
          SizedBox(height: isMobile ? 32 : 48),
          _buildRecentActionsHeader(),
          const SizedBox(height: 24),
          _buildRecentActionsList(),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ADMINISTRATIVE HUB',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.black.withValues(alpha: 0.5),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Staff Panel',
          style: TextStyle(
            fontSize: isMobile ? 24 : 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCards(BuildContext context, bool isMobile) {
    return LayoutBuilder(builder: (context, constraints) {
      int crossAxisCount = 4;
      if (constraints.maxWidth < 650) {
        crossAxisCount = 1;
      } else if (constraints.maxWidth < 1100) {
        crossAxisCount = 2;
      }

      double itemHeight = 180; // Unified height to prevent overflow across all screen sizes
      
      // Calculate childAspectRatio based on constraints
      final double crossAxisSpacing = 24.0;
      final double totalSpacing = crossAxisSpacing * (crossAxisCount - 1);
      final double itemWidth = (constraints.maxWidth - totalSpacing) / crossAxisCount;
      final double childAspectRatio = itemWidth / itemHeight;

      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 24,
        crossAxisSpacing: 24,
        childAspectRatio: childAspectRatio,
        children: [
          _buildActionCard(
            'Create Announcement',
            'Broadcast to all students or specific departments.',
            Icons.campaign_rounded,
            const Color(0xFFE0E7FF),
            const Color(0xFF4338CA),
          ),
          _buildActionCard(
            'Assign Task',
            'Delegating work to faculty members and staff.',
            Icons.assignment_turned_in_rounded,
            const Color(0xFFEEF2FF),
            const Color(0xFF3730A3),
          ),
          _buildActionCard(
            'Upload Marks',
            'Bulk process student assessment records.',
            Icons.upload_file_rounded,
            const Color(0xFFFEF3C7),
            const Color(0xFF92400E),
          ),
          _buildActionCard(
            'View Reports',
            'Analyze institution-wide performance data.',
            Icons.bar_chart_rounded,
            const Color(0xFFF3F4F6),
            const Color(0xFF374151),
          ),
        ],
      );
    });
  }

  Widget _buildActionCard(
    String title,
    String description,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black.withValues(alpha: 0.6),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActionsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          children: [
            Icon(Icons.history_rounded, color: Color(0xFF3730A3), size: 24),
            SizedBox(width: 8),
            Text(
              'Recent Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            'VIEW ALL',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4338CA),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActionsList() {
    return Column(
      children: [
        _buildRecentActionItem(
          'Prof. Alan Turing assigned a new task: ',
          "\"Final Exam Review\"",
          ' to Science Dept.',
          '24 MINUTES AGO • HIGH PRIORITY',
          'AT',
          const Color(0xFF4338CA),
        ),
        const SizedBox(height: 16),
        _buildRecentActionItem(
          'Dr. Marie Curie uploaded marks for ',
          'Organic Chemistry II.',
          '',
          '1 HOUR AGO • ACADEMIC RECORDS',
          'MC',
          const Color(0xFF065F46),
          statusChip: 'PROCESSING',
        ),
        const SizedBox(height: 16),
        _buildRecentActionItem(
          'Admin Panel published an announcement: ',
          'Campus Network Maintenance at 22:00.',
          '',
          '3 HOURS AGO • SYSTEM',
          'AP',
          const Color(0xFF991B1B),
          isAnnouncement: true,
        ),
      ],
    );
  }

  Widget _buildRecentActionItem(
    String prefix,
    String highlight,
    String suffix,
    String subtitle,
    String initials,
    Color avatarColor, {
    String? statusChip,
    bool isAnnouncement = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: avatarColor.withValues(alpha: 0.1),
            child: Text(
              initials,
              style: TextStyle(
                color: avatarColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            height: 1.4,
                          ),
                          children: [
                            TextSpan(text: prefix),
                            TextSpan(
                              text: highlight,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isAnnouncement ? const Color(0xFF991B1B) : const Color(0xFF4338CA),
                              ),
                            ),
                            TextSpan(text: suffix),
                          ],
                        ),
                      ),
                    ),
                    if (statusChip != null)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          statusChip,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4338CA),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black.withValues(alpha: 0.4),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

