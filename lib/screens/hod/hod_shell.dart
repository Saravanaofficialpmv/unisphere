import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/core/constants/app_colors.dart';
import 'package:unisphere/services/auth_service.dart';
import 'package:unisphere/widgets/common/main_sidebar.dart';
import 'package:unisphere/widgets/common/notification_sheet.dart';
import 'package:unisphere/widgets/common/department_vision_sheet.dart';
import 'package:unisphere/widgets/common/notification_bell_button.dart';

import 'hod_home_dashboard.dart';
import 'modules/hod_staff_management.dart';
import 'modules/hod_student_management.dart';
import 'modules/hod_academic_management.dart';
import 'modules/hod_attendance_management.dart';
import 'modules/hod_exam_management.dart';
import 'modules/hod_timetable_management.dart';
import 'modules/hod_leave_management.dart';
import 'modules/hod_announcements.dart';
import 'modules/hod_reports_analytics.dart';
import 'modules/hod_settings.dart';
import 'modules/hod_charter_upload_screen.dart';
import 'modules/hod_album_management_screen.dart';

import '../staff/modules/staff_nptel_verification_screen.dart';
import '../staff/modules/class_advisor_edit_requests_screen.dart';
import '../gallery/full_photo_gallery_screen.dart';
import '../common/manual_notification_composer_screen.dart';
import 'modules/hod_academic_schedule_screen.dart';

class HodShell extends ConsumerStatefulWidget {
  const HodShell({super.key});

  @override
  ConsumerState<HodShell> createState() => _HodShellState();
}

class _HodShellState extends ConsumerState<HodShell> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<NavigatorState> _innerNavigatorKey = GlobalKey<NavigatorState>();

  final List<SidebarItem> _sidebarItems = [
    SidebarItem(label: 'Home Dashboard', icon: Icons.dashboard_outlined),
    SidebarItem(label: 'Dept Notifications', icon: Icons.send_rounded, badge: 'HOD'),
    SidebarItem(label: 'Photo Albums Manager', icon: Icons.collections_outlined, badge: 'Gallery'),
    SidebarItem(label: 'Staff Management', icon: Icons.badge_outlined),
    SidebarItem(label: 'Student Management', icon: Icons.school_outlined),
    SidebarItem(label: 'Profile Edit Requests', icon: Icons.edit_note_rounded, badge: 'Requests'),
    SidebarItem(label: 'NPTEL Cert. Verification', icon: Icons.verified_user_outlined, badge: 'NPTEL'),
    SidebarItem(label: 'Reports & Analytics', icon: Icons.insights_outlined),
    SidebarItem(label: 'Department Settings', icon: Icons.settings_outlined),
    SidebarItem.divider('ACADEMIC MODULES'),
    SidebarItem(label: 'Attendance Management', icon: Icons.fact_check_outlined),
    SidebarItem(label: 'Academic Administration', icon: Icons.menu_book_outlined),
    SidebarItem(label: 'Timetable Management', icon: Icons.calendar_month_outlined),
    SidebarItem(label: 'Examination & Marks', icon: Icons.assessment_outlined),
    SidebarItem(label: 'Academic Schedule & Days', icon: Icons.event_note_rounded, badge: 'Official'),
    SidebarItem(label: 'Leave & OD Approvals', icon: Icons.pending_actions_outlined, badge: '5'),
    SidebarItem(label: 'CO / PO / PSO Uploads', icon: Icons.upload_file_rounded, badge: 'New'),
    SidebarItem(label: 'Announcements', icon: Icons.campaign_outlined),
    SidebarItem(label: 'Campus Photo Gallery', icon: Icons.collections_bookmark_outlined),
  ];

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HodHomeDashboard(onNavigate: _handleNavigation), // 0
      const ManualNotificationComposerScreen(), // 1
      const HodAlbumManagementScreen(), // 2
      const HodStaffManagement(), // 3
      const HodStudentManagement(), // 4
      const ClassAdvisorEditRequestsScreen(), // 5
      const StaffNptelVerificationScreen(), // 6
      const HodReportsAnalytics(), // 7
      const HodSettings(), // 8
      const SizedBox.shrink(), // 9: Divider ACADEMIC MODULES
      const HodAttendanceManagement(), // 10
      const HodAcademicManagement(), // 11
      const HodTimetableManagement(), // 12
      const HodExamManagement(), // 13
      const HodAcademicScheduleScreen(), // 14: Academic Schedule Manager
      const HodLeaveManagement(), // 15
      const HodCharterUploadScreen(), // 16
      const HodAnnouncements(), // 17
      const FullPhotoGalleryScreen(), // 18
    ];
  }



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
        title: Row(
          children: const [
            Icon(Icons.shield_outlined, color: AppColors.primary, size: 22),
            SizedBox(width: 8),
            Text(
              'CSE Department Portal',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.textPrimary),
            ),
          ],
        ),
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
            icon: const Icon(Icons.school_rounded, color: AppColors.primary),
            tooltip: 'My Dept Vision & Outcomes',
            onPressed: () => showDepartmentVisionSheet(context),
          ),
          NotificationBellButton(
            onTap: () => showNotificationSheet(context),
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
      bottomNavigationBar: isDesktop ? null : _buildBottomNavBar(),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _showQuickActionsModal(context),
        icon: const Icon(Icons.flash_on_rounded, color: Colors.white),
        label: const Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    ),
  );
}

  Widget _buildSidebar() {
    final currentUser = ref.watch(currentUserProvider).value ?? ref.watch(authServiceProvider).currentUser;
    final userName = (currentUser?.name != null && currentUser!.name.trim().isNotEmpty)
        ? currentUser.name
        : 'Dr. R. Kumar';
    final userEmail = (currentUser?.email != null && currentUser!.email.trim().isNotEmpty)
        ? currentUser.email
        : 'hod.cse@unisphere.edu';

    return MainSidebar(
      selectedIndex: _currentIndex,
      onDestinationSelected: _handleNavigation,
      items: _sidebarItems,
      userName: userName,
      userEmail: userEmail,
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, -4))],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex < 5 ? _currentIndex : 0,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.badge_outlined), activeIcon: Icon(Icons.badge_rounded), label: 'Staff'),
          BottomNavigationBarItem(icon: Icon(Icons.school_outlined), activeIcon: Icon(Icons.school_rounded), label: 'Students'),
          BottomNavigationBarItem(icon: Icon(Icons.insights_outlined), activeIcon: Icon(Icons.insights_rounded), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
      ),
    );
  }

  void _showQuickActionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Quick Department Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildModalAction(context, Icons.person_add_alt_1_outlined, 'Add New Faculty', () {
                    Navigator.pop(context);
                    setState(() => _currentIndex = 1);
                  }),
                  _buildModalAction(context, Icons.campaign_outlined, 'Broadcast Notice', () {
                    Navigator.pop(context);
                    setState(() => _currentIndex = 10);
                  }),
                  _buildModalAction(context, Icons.pending_actions_outlined, 'Approve Leaves', () {
                    Navigator.pop(context);
                    setState(() => _currentIndex = 9);
                  }),
                  _buildModalAction(context, Icons.calendar_month_outlined, 'View Timetable', () {
                    Navigator.pop(context);
                    setState(() => _currentIndex = 7);
                  }),
                  _buildModalAction(context, Icons.assessment_outlined, 'Approve Marks', () {
                    Navigator.pop(context);
                    setState(() => _currentIndex = 8);
                  }),
                  _buildModalAction(context, Icons.file_download_outlined, 'Export Analytics', () {
                    Navigator.pop(context);
                    setState(() => _currentIndex = 3);
                  }),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalAction(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: (MediaQuery.of(context).size.width - 52) / 2,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
            ],
          ),
        ),
      ),
    );
  }
}
