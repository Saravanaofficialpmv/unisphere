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

class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({super.key});

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<NavigatorState> _innerNavigatorKey = GlobalKey<NavigatorState>();

  final List<SidebarItem> _sidebarItems = [
    SidebarItem(label: 'Dashboard', icon: Icons.grid_view_rounded),
    SidebarItem(label: 'User Management', icon: Icons.people_outline_rounded),
    SidebarItem(label: 'Departments', icon: Icons.business_rounded, badge: 'New'),
    SidebarItem(label: 'Announcements', icon: Icons.campaign_outlined),
    SidebarItem(label: 'Institutional Academics', icon: Icons.school_outlined),
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
    const UserManagementModule(), // 1: Users
    const DepartmentManagementModule(), // 2: Departments
    const AnnouncementManagementModule(), // 3: Announcements
    const Center(child: Text('Institutional Academics')), // 4
    const Center(child: Text('Marks Center')), // 5
    const AttendanceManagementModule(), // 6: Attendance Monitoring
    const ReportManagementModule(), // 7: Performance Intelligence
    const RoleManagementModule(), // 8: Access & Governance
    const Center(child: Text('Performance Analytics')), // 9
    const Center(child: Text('General Settings')), // 10
  ];

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
        if (_selectedIndex != 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _selectedIndex = 0;
              });
            }
          });
        }
      },
      child: Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, isDesktop),
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
                    builder: (_) => Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: _screens[_selectedIndex < _screens.length ? _selectedIndex : 0],
                            ),
                          ),
                        ),
                      ],
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
                  _handleNavigation(0);
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

  void _handleNavigation(int index) {
    if (_innerNavigatorKey.currentState?.canPop() ?? false) {
      _innerNavigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
    setState(() => _selectedIndex = index);
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop(); 
    }
  }
}
