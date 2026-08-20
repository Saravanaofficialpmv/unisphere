import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/core/constants/app_colors.dart';
import 'package:unisphere/services/auth_service.dart';
import 'package:unisphere/widgets/common/notification_sheet.dart';
import 'package:unisphere/widgets/common/department_vision_sheet.dart';
import 'package:unisphere/widgets/common/notification_bell_button.dart';
import 'package:unisphere/widgets/common/main_sidebar.dart';
import 'package:unisphere/screens/admin/admin_dashboard.dart';
import 'package:unisphere/screens/admin/modules/user_management.dart';
import 'package:unisphere/screens/admin/modules/announcement_management.dart';
import 'package:unisphere/screens/admin/modules/department_management.dart';
import 'package:unisphere/screens/admin/modules/attendance_management.dart';
import 'package:unisphere/screens/admin/modules/report_management.dart';
import 'package:unisphere/screens/admin/modules/role_management.dart';
import 'package:unisphere/screens/admin/modules/admin_notification_settings_screen.dart';
import 'package:unisphere/screens/admin/modules/admin_gallery_management_screen.dart';
import 'package:unisphere/screens/common/manual_notification_composer_screen.dart';
import 'package:unisphere/screens/staff/modules/staff_marks_upload.dart';
import 'package:unisphere/screens/hod/modules/hod_academic_management.dart';
import 'package:unisphere/screens/hod/modules/hod_settings.dart';
import 'package:unisphere/screens/hod/modules/hod_syllabus_management_screen.dart';
import 'package:unisphere/core/theme/app_animations.dart';


class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({super.key});

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<NavigatorState> _innerNavigatorKey = GlobalKey<NavigatorState>();
  final List<int> _navigationHistory = [0];

  final List<SidebarItem> _sidebarItems = [
    SidebarItem(label: 'Dashboard', icon: Icons.grid_view_rounded),
    SidebarItem(label: 'Photo Gallery Governance', icon: Icons.collections_outlined, badge: 'Gallery'),
    SidebarItem(label: 'User Management', icon: Icons.people_outline_rounded),
    SidebarItem(label: 'Departments', icon: Icons.business_rounded, badge: 'New'),
    SidebarItem(label: 'Manual Notifications', icon: Icons.send_rounded, badge: 'Composer'),
    SidebarItem(label: 'Notification Rules', icon: Icons.notifications_active_rounded, badge: 'Auto'),
    SidebarItem(label: 'Announcements', icon: Icons.campaign_outlined),
    SidebarItem(label: 'Institutional Academics', icon: Icons.school_outlined),
    SidebarItem(label: 'Syllabus Management', icon: Icons.menu_book_rounded, badge: 'Syllabus'),
    SidebarItem(label: 'Marks Center', icon: Icons.star_outline_rounded),
    SidebarItem(label: 'Attendance Monitoring', icon: Icons.calendar_today_rounded),
    SidebarItem(label: 'Performance Intelligence', icon: Icons.assessment_outlined),
    SidebarItem(label: 'Access & Governance', icon: Icons.security_outlined),
    SidebarItem(label: 'Performance Analytics', icon: Icons.analytics_outlined),
    SidebarItem.divider('SYSTEM CONTROL'),
    SidebarItem(label: 'General Settings', icon: Icons.settings_outlined),
  ];

  final List<Widget> _screens = [
    const AdminDashboard(), // 0: Dashboard
    const AdminGalleryManagementScreen(), // 1: Photo Gallery Governance
    const UserManagementModule(), // 2: Users
    const DepartmentManagementModule(), // 3: Departments
    const ManualNotificationComposerScreen(), // 4: Manual Notifications
    const AdminNotificationSettingsScreen(), // 5: Automation Rules
    const AnnouncementManagementModule(), // 6: Announcements
    const HodAcademicManagement(), // 7: Institutional Academics
    const HodSyllabusManagementScreen(), // 8: Syllabus Management
    const StaffMarksUploadModule(), // 9: Marks Center
    const AttendanceManagementModule(), // 10: Attendance Monitoring
    const ReportManagementModule(), // 11: Performance Intelligence
    const RoleManagementModule(), // 12: Access & Governance
    const ReportManagementModule(), // 13: Performance Analytics
    const SizedBox.shrink(), // 14: Divider SYSTEM CONTROL
    const HodSettings(), // 15: General Settings
  ];


  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackNavigation();
      },
      child: Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: isDesktop ? null : _buildAppBar(context, isDesktop),
      drawer: isDesktop ? null : Drawer(child: _buildSidebar()),
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(),
          Expanded(
            child: ClipRect(
              child: Navigator(
                key: _innerNavigatorKey,
                onGenerateRoute: (settings) {
                  return MaterialPageRoute(
                    builder: (_) => Scaffold(
                      backgroundColor: AppColors.background,
                      appBar: isDesktop ? _buildAppBar(context, isDesktop) : null,
                      body: Row(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: FadeSlideTransition(
                                  transitionKey: ValueKey('admin_tab_$_selectedIndex'),
                                  child: _screens[_selectedIndex < _screens.length ? _selectedIndex : 0],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
    final currentUser = ref.watch(currentUserProvider).value ?? ref.watch(authServiceProvider).currentUser;
    final userName = (currentUser?.name != null && currentUser!.name.trim().isNotEmpty)
        ? currentUser.name
        : 'Admin User';
    final userEmail = (currentUser?.email != null && currentUser!.email.trim().isNotEmpty)
        ? currentUser.email
        : 'admin@unisphere.edu';

    return MainSidebar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _handleNavigation,
      items: _sidebarItems,
      userName: userName,
      userEmail: userEmail,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDesktop) {
    final currentUser = ref.watch(currentUserProvider).value ?? ref.watch(authServiceProvider).currentUser;
    final firstName = (currentUser?.name != null && currentUser!.name.trim().isNotEmpty)
        ? currentUser.name.split(' ').first
        : 'Admin';

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      title: Text('Hello, $firstName 👋', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
      leading: isDesktop 
        ? const Padding(padding: EdgeInsets.all(12), child: Icon(Icons.hub_rounded, color: AppColors.primary)) 
        : Builder(
            builder: (context) => IconButton(
              icon: Icon(
                _selectedIndex == 0 ? Icons.menu_rounded : Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary,
                size: _selectedIndex == 0 ? 24 : 20,
              ),
              onPressed: () {
                if (_selectedIndex == 0) {
                  _scaffoldKey.currentState?.openDrawer();
                } else {
                  _handleBackNavigation();
                }
              },
            ),
          ),
      actions: [
        IconButton(
          icon: const Icon(Icons.school_rounded, color: AppColors.primary, size: 22),
          tooltip: 'Dept Vision & POs',
          onPressed: () => showDepartmentVisionSheet(context),
        ),
        IconButton(icon: const Icon(Icons.help_outline_rounded, color: AppColors.textPrimary, size: 22), onPressed: () {}),
        NotificationBellButton(
          onTap: () => showNotificationSheet(context),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: AppColors.border.withValues(alpha: 0.5), height: 1),
      ),
    );
  }

  void _handleNavigation(int index, {bool isBack = false}) {
    if (_innerNavigatorKey.currentState?.canPop() ?? false) {
      _innerNavigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
    if (index == _selectedIndex) return;

    if (!isBack) {
      _navigationHistory.add(_selectedIndex);
    }

    setState(() => _selectedIndex = index);
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop(); 
    }
  }

  void _handleBackNavigation() {
    if (_innerNavigatorKey.currentState?.canPop() ?? false) {
      _innerNavigatorKey.currentState?.pop();
      return;
    }
    if (_navigationHistory.isNotEmpty) {
      final prev = _navigationHistory.removeLast();
      _handleNavigation(prev, isBack: true);
    } else if (_selectedIndex != 0) {
      _handleNavigation(0, isBack: true);
    }
  }
}
