import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unisphere/core/constants/app_colors.dart';
import 'package:unisphere/services/auth_service.dart';
import 'package:unisphere/services/parent_service.dart';
import 'package:unisphere/models/parent_portal_types.dart';
import 'package:unisphere/widgets/common/notification_sheet.dart';
import 'package:unisphere/widgets/common/department_vision_sheet.dart';
import 'package:unisphere/widgets/common/main_sidebar.dart';
import 'package:unisphere/widgets/parent/parent_floating_nav_bar.dart';
import 'package:unisphere/widgets/parent/parent_navigation_sheet.dart';
import 'package:unisphere/widgets/common/sign_out_confirmation_sheet.dart';
import 'package:unisphere/screens/features/fees_screen.dart';
import 'package:unisphere/screens/profile/profile_screen.dart';
import 'package:unisphere/widgets/common/recent_photos_section.dart';
import 'package:unisphere/screens/gallery/full_photo_gallery_screen.dart';
import 'package:unisphere/screens/student/modules/student_announcements_screen.dart';
import 'package:unisphere/screens/features/events_screen.dart';
import 'package:unisphere/core/theme/app_animations.dart';


class StudentWard {
  final String id;
  final String name;
  final String regNo;
  final String department;
  final String yearSection;
  final String attendance;
  final double attendancePercent;
  final String cgpa;
  final String feesDue;
  final String academicStatus;
  final Color statusColor;
  final String avatarInitials;

  StudentWard({
    required this.id,
    required this.name,
    required this.regNo,
    required this.department,
    required this.yearSection,
    required this.attendance,
    required this.attendancePercent,
    required this.cgpa,
    required this.feesDue,
    required this.academicStatus,
    required this.statusColor,
    required this.avatarInitials,
  });
}

class ParentDashboard extends ConsumerStatefulWidget {
  const ParentDashboard({super.key});

  @override
  ConsumerState<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends ConsumerState<ParentDashboard> {
  int _currentIndex = 0;
  bool _isNavigationSheetOpen = false;
  bool _isDockVisible = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<NavigatorState> _innerNavigatorKey = GlobalKey<NavigatorState>();

  static final List<SidebarItem> parentSidebarItems = [
    SidebarItem(label: 'Dashboard Home', icon: Icons.dashboard_outlined),
    SidebarItem(label: 'Attendance History', icon: Icons.calendar_month_outlined),
    SidebarItem(label: 'Performance Marks', icon: Icons.bar_chart_outlined),
    SidebarItem(label: 'Institutional Alerts', icon: Icons.campaign_outlined, badge: 'New'),
    SidebarItem(label: 'Parent Profile', icon: Icons.person_outline),
    SidebarItem.divider('CAMPUS & CHILD SERVICES'),
    SidebarItem(label: 'Child Fee Status', icon: Icons.payments_outlined),
    SidebarItem(label: 'Campus Photo Gallery', icon: Icons.collections_outlined, badge: 'Gallery'),
    SidebarItem(label: 'Events & Fests', icon: Icons.event_outlined),
    SidebarItem(label: 'Transport Details', icon: Icons.bus_alert_outlined),
  ];

  List<SidebarItem> get _sidebarItems => parentSidebarItems;

  final List<int> _navigationHistory = [0];

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return ParentHomeScreen(
          onNavigateToTab: _handleNavigation,
          onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
        );
      case 1:
        return ParentAttendanceDetailTab(onNavigateToTab: _handleNavigation);
      case 2:
        return ParentAcademicPerformanceTab(onNavigateToTab: _handleNavigation);
      case 3:
        return StudentAnnouncementsScreen(onBack: _handleBackNavigation);
      case 4:
        return ProfileScreen(onBack: _handleBackNavigation);
      case 6:
        return FeesScreen(onBack: _handleBackNavigation);
      case 7:
        return FullPhotoGalleryScreen(onBack: _handleBackNavigation);
      case 8:
        return EventsScreen(onBack: _handleBackNavigation);
      case 9:
        return const Center(child: Text('School Transport Map'));
      default:
        return ParentHomeScreen(
          onNavigateToTab: _handleNavigation,
          onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
        );
    }
  }

  void _handleNavigation(int index, {bool isBack = false}) {
    if (_innerNavigatorKey.currentState?.canPop() ?? false) {
      _innerNavigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
    if (index == _currentIndex) return;

    if (!isBack) {
      _navigationHistory.add(_currentIndex);
    }

    setState(() => _currentIndex = index);
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
    } else if (_currentIndex != 0) {
      _handleNavigation(0, isBack: true);
    }
  }

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
        backgroundColor: const Color(0xFFF8FAFC),
        drawer: isDesktop ? null : Drawer(child: _buildSidebar()),
        appBar: null,
        body: Stack(
          children: [
            NotificationListener<UserScrollNotification>(
              onNotification: (notification) {
                if (notification.direction == ScrollDirection.reverse && _isDockVisible) {
                  if (notification.metrics.pixels > 35) {
                    setState(() => _isDockVisible = false);
                  }
                } else if (notification.direction == ScrollDirection.forward && !_isDockVisible) {
                  setState(() => _isDockVisible = true);
                }
                return false;
              },
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    if (isDesktop) _buildSidebar(),
                    Expanded(
                      child: ClipRect(
                        child: Navigator(
                          key: _innerNavigatorKey,
                          onGenerateRoute: (settings) {
                            return MaterialPageRoute(
                              builder: (_) => FadeSlideTransition(
                                transitionKey: ValueKey('parent_tab_$_currentIndex'),
                                duration: const Duration(milliseconds: 180),
                                child: _buildScreen(_currentIndex),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Floating Capsule Bottom Navigation Bar (Mobile / Tablet)
            if (!isDesktop)
              Positioned(
                bottom: math.max(16.0, MediaQuery.of(context).padding.bottom + 10.0),
                left: 0,
                right: 0,
                child: Center(
                  child: ParentFloatingNavBar(
                    currentIndex: _currentIndex,
                    isMenuOpen: _isNavigationSheetOpen,
                    isVisible: _isDockVisible && !_isNavigationSheetOpen,
                    onSidebarTap: () async {
                      setState(() => _isNavigationSheetOpen = true);
                      await showParentNavigationSheet(
                        context: context,
                        selectedIndex: _currentIndex,
                        onDestinationSelected: _handleNavigation,
                        items: _sidebarItems,
                      );
                      if (mounted) {
                        setState(() => _isNavigationSheetOpen = false);
                      }
                    },
                    onAttendanceTap: () => _handleNavigation(1),
                    onHomeTap: () => _handleNavigation(0),
                    onProfileTap: () => _handleNavigation(4),
                    onLogoutTap: () => showSignOutConfirmationSheet(context, ref),
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
        : 'Parent User';
    final userEmail = (currentUser?.email != null && currentUser!.email.trim().isNotEmpty)
        ? currentUser.email
        : 'parent@unisphere.edu';

    return MainSidebar(
      selectedIndex: _currentIndex,
      onDestinationSelected: _handleNavigation,
      items: _sidebarItems,
      userName: userName,
      userEmail: userEmail,
    );
  }
}

class ParentHomeScreen extends ConsumerStatefulWidget {
  final Function(int index)? onNavigateToTab;
  final VoidCallback? onOpenDrawer;

  const ParentHomeScreen({
    super.key,
    this.onNavigateToTab,
    this.onOpenDrawer,
  });

  @override
  ConsumerState<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends ConsumerState<ParentHomeScreen> {
  late List<ParentStudentWard> _wards;
  late ParentStudentWard _selectedWard;
  String _selectedTrendMode = 'CGPA'; // 'CGPA' or 'SGPA'

  @override
  void initState() {
    super.initState();
    final parentService = ref.read(parentServiceProvider);
    _wards = parentService.getDefaultStudentWards();
    _selectedWard = _wards.first;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 28 : 16,
        vertical: 12,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TOP PARENT WELCOME & NOTIFICATION BAR
              _buildParentTopWelcomeBar(context),

              const SizedBox(height: 16),

              // 2. SEARCH & QUICK ACTION BAR
              _buildSearchBarAndQuickAction(context),

              const SizedBox(height: 18),

              // 3. STUDENT IDENTITY PROFILE CARD (ALEX JOHNSON)
              _buildStudentIdentityCard(context),

              const SizedBox(height: 16),

              // 4. 3-COLUMN KEY METRICS STRIP (STUDENT / PRESENCE / INTERNAL SCORE)
              _buildThreeColumnKeyMetricsStrip(context),

              const SizedBox(height: 20),

              // 5. 5 CIRCULAR QUICK LAUNCHER ACTION BUTTONS
              _buildFiveQuickLauncherIcons(context),

              const SizedBox(height: 22),

              // 6. UPCOMING (EXAMS & MEETINGS) & RECENT UPDATES
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildUpcomingCard(context)),
                    const SizedBox(width: 18),
                    Expanded(child: _buildRecentUpdatesCard(context)),
                  ],
                )
              else ...[
                _buildUpcomingCard(context),
                const SizedBox(height: 18),
                _buildRecentUpdatesCard(context),
              ],

              const SizedBox(height: 22),

              // 7. ACADEMIC PERFORMANCE TREND & INSIGHT CARD
              _buildAcademicPerformanceTrendSection(context, isDesktop),

              const SizedBox(height: 28),

              // 8. CAMPUS RECENT PHOTO GALLERY
              const RecentPhotosSection(),

              // Clearance for floating bottom navigation bar
              const SizedBox(height: 96),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 1. TOP PARENT HEADER (WELCOME BAR)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildParentTopWelcomeBar(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Parent Profile Avatar
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFDBEAFE), width: 1.5),
          ),
          child: const Center(
            child: Icon(Icons.person_rounded, color: AppColors.primary, size: 28),
          ),
        ),
        const SizedBox(width: 12),

        // Welcome Text & Ward Connection
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'Hello, Welcome Back!',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('👋', style: TextStyle(fontSize: 12)),
                ],
              ),
              const SizedBox(height: 1),
              Text(
                'Mrs. Rajesh',
                style: GoogleFonts.manrope(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 1),
              InkWell(
                onTap: () => _showStudentSelectorSheet(context),
                borderRadius: BorderRadius.circular(4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Parent of ',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      _selectedWard.name,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 15, color: AppColors.primary),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Right Action Buttons: Academic Vision & Notifications
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Department Vision / Academics button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => showDepartmentVisionSheet(context),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFDBEAFE)),
                  ),
                  child: const Icon(Icons.school_rounded, color: AppColors.primary, size: 20),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Notification Bell with Badge
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => showNotificationSheet(context),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFDBEAFE)),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.notifications_rounded, color: AppColors.primary, size: 20),
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.all(3.5),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '3',
                            style: GoogleFonts.manrope(
                              color: Colors.white,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 2. SEARCH & QUICK ACTION PILL
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildSearchBarAndQuickAction(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search updates, exams, fees, timetable...',
                hintStyle: GoogleFonts.manrope(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF94A3B8),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: GoogleFonts.manrope(fontSize: 13, color: const Color(0xFF0F172A)),
            ),
          ),
          const SizedBox(width: 8),

          // Lightning bolt quick action button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                showParentNavigationSheet(
                  context: context,
                  selectedIndex: 0,
                  onDestinationSelected: (idx) => widget.onNavigateToTab?.call(idx),
                  items: _ParentDashboardState.parentSidebarItems,
                  userName: 'Mrs. Rajesh',
                  userEmail: 'parent.rajesh@gmail.com',
                );
              },
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 3. STUDENT IDENTITY PROFILE CARD (ALEX JOHNSON)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildStudentIdentityCard(BuildContext context) {
    return InkWell(
      onTap: () => _showStudentSelectorSheet(context),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Student Photo Avatar with Active Green Dot
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                  ),
                  child: ClipOval(
                    child: _selectedWard.photoUrl != null
                        ? Image.network(
                            _selectedWard.photoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildAvatarFallback(),
                          )
                        : _buildAvatarFallback(),
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 13,
                    height: 13,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),

            // Name, RegNo, and Tag Chips
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          _selectedWard.name,
                          style: GoogleFonts.manrope(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Active',
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF15803D),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Reg No: ${_selectedWard.regNo}',
                    style: GoogleFonts.manrope(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _buildSmallTag(Icons.computer_rounded, 'Computer Science', const Color(0xFFEFF6FF), const Color(0xFF2563EB)),
                      _buildSmallTag(Icons.calendar_today_rounded, '3rd Year', const Color(0xFFF5F3FF), const Color(0xFF7C3AED)),
                      _buildSmallTag(Icons.shield_outlined, 'Sec B', const Color(0xFFF1F5F9), const Color(0xFF475569)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // College / Institution Branding
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Icon(Icons.account_balance_rounded, color: Color(0xFF6366F1), size: 26),
                const SizedBox(height: 4),
                Text(
                  'SRI ECT College\nof Engineering',
                  style: GoogleFonts.manrope(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                    height: 1.15,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallTag(IconData icon, String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: textColor),
          const SizedBox(width: 3.5),
          Text(
            text,
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback() {
    return Container(
      color: const Color(0xFF2563EB),
      child: Center(
        child: Text(
          _selectedWard.avatarInitials,
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showStudentSelectorSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) => SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select Active Student Ward',
                style: GoogleFonts.manrope(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Switch profile view to monitor another student ward',
                style: GoogleFonts.manrope(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ..._wards.map((ward) {
                final isSelected = ward.id == _selectedWard.id;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withValues(alpha: 0.06) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                      child: Text(
                        ward.avatarInitials,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      ward.name,
                      style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    subtitle: Text(
                      '${ward.department} • ${ward.yearSection}',
                      style: GoogleFonts.manrope(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                        : null,
                    onTap: () {
                      setState(() => _selectedWard = ward);
                      Navigator.of(ctx).pop();
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 4. 3-COLUMN KEY METRIC STRIP
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildThreeColumnKeyMetricsStrip(BuildContext context) {
    final presencePercent = (_selectedWard.attendancePercent * 100).toInt();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. Student
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student',
                  style: GoogleFonts.manrope(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.school_outlined, size: 16, color: Color(0xFF0F172A)),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        _selectedWard.currentYear.isNotEmpty ? _selectedWard.currentYear : '2nd Year',
                        style: GoogleFonts.manrope(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(height: 34, width: 1, color: const Color(0xFFE2E8F0)),

          // 2. Presence
          Expanded(
            child: InkWell(
              onTap: () => widget.onNavigateToTab?.call(1),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Presence',
                          style: GoogleFonts.manrope(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(Icons.info_outline_rounded, size: 12, color: Color(0xFF94A3B8)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded, size: 16, color: Color(0xFF0F172A)),
                        const SizedBox(width: 4),
                        Text(
                          '$presencePercent%',
                          style: GoogleFonts.manrope(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          Container(height: 34, width: 1, color: const Color(0xFFE2E8F0)),

          // 3. Internal Score
          Expanded(
            child: InkWell(
              onTap: () => widget.onNavigateToTab?.call(2),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Internal Score',
                      style: GoogleFonts.manrope(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.menu_book_rounded, size: 15, color: Color(0xFF0F172A)),
                        const SizedBox(width: 4),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '85',
                                style: GoogleFonts.manrope(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              TextSpan(
                                text: '/100',
                                style: GoogleFonts.manrope(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 5. 5 CIRCULAR QUICK LAUNCHER ACTION BUTTONS
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildFiveQuickLauncherIcons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLauncherItem(
            label: 'Classes',
            icon: Icons.school_outlined,
            bgColor: const Color(0xFFF3E8FF),
            iconColor: const Color(0xFF7C3AED),
            onTap: () => widget.onNavigateToTab?.call(8),
          ),
          _buildLauncherItem(
            label: 'Exam',
            icon: Icons.description_outlined,
            bgColor: const Color(0xFFEFF6FF),
            iconColor: const Color(0xFF2563EB),
            onTap: () => widget.onNavigateToTab?.call(8),
          ),
          _buildLauncherItem(
            label: 'Assignment',
            icon: Icons.auto_stories_outlined,
            bgColor: const Color(0xFFFFF7ED),
            iconColor: const Color(0xFFEA580C),
            onTap: () => widget.onNavigateToTab?.call(2),
          ),
          _buildLauncherItem(
            label: 'Presence',
            icon: Icons.how_to_reg_outlined,
            bgColor: const Color(0xFFF0FDF4),
            iconColor: const Color(0xFF16A34A),
            onTap: () => widget.onNavigateToTab?.call(1),
          ),
          _buildLauncherItem(
            label: 'More',
            icon: Icons.grid_view_rounded,
            bgColor: const Color(0xFFF8FAFC),
            iconColor: const Color(0xFF0F172A),
            onTap: () {
              showParentNavigationSheet(
                context: context,
                selectedIndex: 0,
                onDestinationSelected: (idx) => widget.onNavigateToTab?.call(idx),
                items: _ParentDashboardState.parentSidebarItems,
                userName: 'Mrs. Rajesh',
                userEmail: 'parent.rajesh@gmail.com',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLauncherItem({
    required String label,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: Border.all(color: iconColor.withValues(alpha: 0.15)),
              ),
              child: Center(
                child: Icon(icon, color: iconColor, size: 23),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 6. UPCOMING CARD (EXAMS & MEETINGS)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildUpcomingCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upcoming',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F172A),
                ),
              ),
              InkWell(
                onTap: () => widget.onNavigateToTab?.call(8),
                child: Text(
                  'View All',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Item 1: Data Structures Exam
          _buildUpcomingRow(
            icon: Icons.calendar_month_rounded,
            iconBg: const Color(0xFFF3E8FF),
            iconColor: const Color(0xFF7C3AED),
            title: 'Data Structures Exam',
            subtitle: '15 May 2025',
            badgeText: '12 Days Left',
            badgeBg: const Color(0xFFF5F3FF),
            badgeColor: const Color(0xFF7C3AED),
          ),
          const SizedBox(height: 12),

          // Item 2: Operating Systems Exam
          _buildUpcomingRow(
            icon: Icons.calendar_month_rounded,
            iconBg: const Color(0xFFDCFCE7),
            iconColor: const Color(0xFF16A34A),
            title: 'Operating Systems Exam',
            subtitle: '20 May 2025',
            badgeText: '17 Days Left',
            badgeBg: const Color(0xFFECFDF5),
            badgeColor: const Color(0xFF059669),
          ),
          const SizedBox(height: 12),

          // Item 3: Parent Meeting
          _buildUpcomingRow(
            icon: Icons.group_rounded,
            iconBg: const Color(0xFFEFF6FF),
            iconColor: const Color(0xFF2563EB),
            title: 'Parent Meeting',
            subtitle: '24 May 2025 • 10:00 AM',
            badgeText: '21 Days Left',
            badgeBg: const Color(0xFFEFF6FF),
            badgeColor: const Color(0xFF2563EB),
          ),
          const SizedBox(height: 14),

          // View Calendar Link
          Center(
            child: InkWell(
              onTap: () => widget.onNavigateToTab?.call(8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View Calendar',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeBg,
    required Color badgeColor,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(icon, color: iconColor, size: 20),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitle,
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            badgeText,
            style: GoogleFonts.manrope(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 6B. RECENT UPDATES CARD
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildRecentUpdatesCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Updates',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F172A),
                ),
              ),
              InkWell(
                onTap: () => widget.onNavigateToTab?.call(3),
                child: Text(
                  'View All',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 1. Internal Marks Published
          _buildRecentUpdateRow(
            icon: Icons.campaign_rounded,
            iconBg: const Color(0xFFFFF7ED),
            iconColor: const Color(0xFFEA580C),
            title: 'Internal marks published',
            time: 'Today, 10:30 AM',
            onTap: () => widget.onNavigateToTab?.call(2),
          ),
          const SizedBox(height: 12),

          // 2. Exam Timetable Updated
          _buildRecentUpdateRow(
            icon: Icons.calendar_month_rounded,
            iconBg: const Color(0xFFF3E8FF),
            iconColor: const Color(0xFF7C3AED),
            title: 'Exam timetable updated',
            time: 'Yesterday, 04:15 PM',
            onTap: () => widget.onNavigateToTab?.call(8),
          ),
          const SizedBox(height: 12),

          // 3. Assignment Uploaded
          _buildRecentUpdateRow(
            icon: Icons.description_outlined,
            iconBg: const Color(0xFFF0FDF4),
            iconColor: const Color(0xFF16A34A),
            title: 'Assignment uploaded',
            time: '2 May 2025',
            onTap: () => widget.onNavigateToTab?.call(2),
          ),
          const SizedBox(height: 12),

          // 4. College Announcement
          _buildRecentUpdateRow(
            icon: Icons.info_outline_rounded,
            iconBg: const Color(0xFFEFF6FF),
            iconColor: const Color(0xFF2563EB),
            title: 'College announcement',
            time: '1 May 2025',
            onTap: () => widget.onNavigateToTab?.call(3),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentUpdateRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(icon, color: iconColor, size: 20),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  time,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 7. ACADEMIC PERFORMANCE TREND & INSIGHT CARD
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildAcademicPerformanceTrendSection(BuildContext context, bool isDesktop) {
    final chartWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Academic Performance Trend',
              style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF0F172A),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedTrendMode,
                  isDense: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF64748B)),
                  items: const [
                    DropdownMenuItem(value: 'CGPA', child: Text('CGPA', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold))),
                    DropdownMenuItem(value: 'SGPA', child: Text('SGPA', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold))),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedTrendMode = val);
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Custom Smooth Bezier Trend Chart
        SizedBox(
          height: 160,
          width: double.infinity,
          child: CustomPaint(
            painter: _AcademicTrendChartPainter(
              values: _selectedTrendMode == 'CGPA'
                  ? const [7.80, 8.12, 8.45, 8.72]
                  : const [8.20, 8.50, 8.60, 8.90],
              labels: const ['Sem 2', 'Sem 3', 'Sem 4', 'Sem 5'],
              lineColor: const Color(0xFF6366F1),
              fillGradientStart: const Color(0xFF6366F1).withValues(alpha: 0.28),
            ),
          ),
        ),
      ],
    );

    final insightCard = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDE9FE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: Color(0xFF7C3AED), size: 18),
              const SizedBox(width: 6),
              Text(
                'Performance Insight',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF7C3AED),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Alex\'s academic performance is consistently improving.',
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Great job! Keep it up! ',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6D28D9),
                  ),
                ),
                const TextSpan(text: '💪', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: () => widget.onNavigateToTab?.call(2),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDDD6FE)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View Details',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF7C3AED),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Color(0xFF7C3AED)),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 6, child: chartWidget),
                const SizedBox(width: 20),
                Expanded(flex: 4, child: insightCard),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                chartWidget,
                const SizedBox(height: 16),
                insightCard,
              ],
            ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// CUSTOM PAINTER: SMOOTH BEZIER ACADEMIC TREND LINE CHART
// ───────────────────────────────────────────────────────────────────────────
class _AcademicTrendChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final Color lineColor;
  final Color fillGradientStart;

  _AcademicTrendChartPainter({
    required this.values,
    required this.labels,
    required this.lineColor,
    required this.fillGradientStart,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    const double paddingLeft = 32.0;
    const double paddingRight = 32.0;
    const double paddingTop = 28.0;
    const double paddingBottom = 26.0;

    final double chartWidth = size.width - paddingLeft - paddingRight;
    final double chartHeight = size.height - paddingTop - paddingBottom;

    final double minVal = values.reduce(math.min) - 0.5;
    final double maxVal = values.reduce(math.max) + 0.5;
    final double range = (maxVal - minVal) <= 0 ? 1.0 : (maxVal - minVal);

    // Compute coordinate points
    final List<Offset> points = [];
    for (int i = 0; i < values.length; i++) {
      final double x = paddingLeft + (i * chartWidth / (values.length - 1));
      final double normalizedY = (values[i] - minVal) / range;
      final double y = paddingTop + chartHeight - (normalizedY * chartHeight);
      points.add(Offset(x, y));
    }

    // Build smooth cubic Bezier path
    final Path path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final Offset p0 = i > 0 ? points[i - 1] : points[i];
      final Offset p1 = points[i];
      final Offset p2 = points[i + 1];
      final Offset p3 = i < points.length - 2 ? points[i + 2] : p2;

      final double cp1x = p1.dx + (p2.dx - p0.dx) / 6;
      final double cp1y = p1.dy + (p2.dy - p0.dy) / 6;

      final double cp2x = p2.dx - (p3.dx - p1.dx) / 6;
      final double cp2y = p2.dy - (p3.dy - p1.dy) / 6;

      path.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
    }

    // Paint Area Gradient Fill underneath
    final Path fillPath = Path.from(path);
    fillPath.lineTo(points.last.dx, paddingTop + chartHeight);
    fillPath.lineTo(points.first.dx, paddingTop + chartHeight);
    fillPath.close();

    final Paint fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [fillGradientStart, fillGradientStart.withValues(alpha: 0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, paddingTop, size.width, chartHeight))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Paint Smooth Line Stroke
    final Paint linePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFF818CF8)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 3.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);

    // Draw Data Point Nodes & Value Callouts
    for (int i = 0; i < points.length; i++) {
      final p = points[i];

      // Outer glow circle
      canvas.drawCircle(
        p,
        6.5,
        Paint()..color = const Color(0xFF6366F1).withValues(alpha: 0.25),
      );

      // Node ring
      canvas.drawCircle(
        p,
        4.5,
        Paint()
          ..color = const Color(0xFF4F46E5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );

      // White inner dot
      canvas.drawCircle(
        p,
        3.0,
        Paint()..color = Colors.white,
      );

      // Value label text above node
      final textSpan = TextSpan(
        text: values[i].toStringAsFixed(2),
        style: GoogleFonts.manrope(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF0F172A),
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(p.dx - (textPainter.width / 2), p.dy - 20));

      // X-Axis Semester Label below
      final labelSpan = TextSpan(
        text: labels[i],
        style: GoogleFonts.manrope(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF64748B),
        ),
      );
      final labelPainter = TextPainter(
        text: labelSpan,
        textDirection: TextDirection.ltr,
      );
      labelPainter.layout();
      labelPainter.paint(canvas, Offset(p.dx - (labelPainter.width / 2), paddingTop + chartHeight + 8));
    }
  }

  @override
  bool shouldRepaint(covariant _AcademicTrendChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.lineColor != lineColor;
  }
}

// FULL TAB VIEW FOR ATTENDANCE HISTORY (TAB 1)
class ParentAttendanceDetailTab extends StatelessWidget {
  final Function(int index)? onNavigateToTab;

  const ParentAttendanceDetailTab({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> subjects = [
      {'code': 'CS301', 'name': 'Data Structures & Algorithms', 'attended': 32, 'total': 35, 'percent': 0.914, 'status': 'SAFE'},
      {'code': 'CS302', 'name': 'Operating Systems Concepts', 'attended': 28, 'total': 33, 'percent': 0.848, 'status': 'SAFE'},
      {'code': 'CS303', 'name': 'Database Management Systems', 'attended': 28, 'total': 32, 'percent': 0.875, 'status': 'SAFE'},
      {'code': 'MA301', 'name': 'Discrete Mathematics & Logic', 'attended': 27, 'total': 30, 'percent': 0.900, 'status': 'SAFE'},
      {'code': 'CS304', 'name': 'Web Technology Practical Lab', 'attended': 16, 'total': 17, 'percent': 0.941, 'status': 'EXCELLENT'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () {
                  if (onNavigateToTab != null) onNavigateToTab!(0);
                },
              ),
              Text(
                'Complete Attendance Log',
                style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Overall Gauge Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF059669), Color(0xFF10B981)]),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                AppCircularGauge(
                  radius: 40.0,
                  lineWidth: 8.0,
                  percent: 0.885,
                  center: Text('88.5%', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
                  progressColor: Colors.white,
                  backgroundColor: Colors.white24,
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('OVERALL ATTENDANCE', style: GoogleFonts.manrope(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.bold)),
                      Text('Alex Johnson • B.Tech CSE', style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('131 / 147 Total Classes Attended (8.5% above cutoff)', style: GoogleFonts.manrope(fontSize: 12, color: Colors.white.withValues(alpha: 0.9))),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Text('Subject-wise Attendance', style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 12),

          Column(
            children: subjects.map((s) {
              final double p = s['percent'];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('${s['code']} - ${s['name']}', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(s['status'], style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF059669))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${s['attended']} attended out of ${s['total']} classes', style: GoogleFonts.manrope(fontSize: 12, color: AppColors.textSecondary)),
                        Text('${(p * 100).toStringAsFixed(1)}%', style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF059669))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AppLinearProgressBar(
                      lineHeight: 8.0,
                      percent: p,
                      backgroundColor: const Color(0xFFF1F5F9),
                      progressColor: const Color(0xFF059669),
                      borderRadius: 4.0,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 90),
        ],
      ),
    );
  }
}

// FULL TAB VIEW FOR PERFORMANCE MARKS & CGPA (TAB 2)
class ParentAcademicPerformanceTab extends StatelessWidget {
  final Function(int index)? onNavigateToTab;

  const ParentAcademicPerformanceTab({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () {
                  if (onNavigateToTab != null) onNavigateToTab!(0);
                },
              ),
              Text(
                'Academic Performance Marks',
                style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)]),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CUMULATIVE GRADE POINT AVERAGE', style: GoogleFonts.manrope(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.bold)),
                    Text('8.92', style: GoogleFonts.manrope(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white)),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(14)),
                      child: Text('Rank: #12 in Dept', style: GoogleFonts.manrope(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 6),
                    Text('48 / 160 Credits Earned', style: GoogleFonts.manrope(color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Text('Semester Grades & SGPA Summary', style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 12),

          _buildSemesterCard('Semester 4 (Autumn 2025)', '9.12', 'O Grade', [
            {'subject': 'Advanced Algorithms', 'marks': '94/100', 'grade': 'O'},
            {'subject': 'Computer Networks', 'marks': '88/100', 'grade': 'A+'},
            {'subject': 'Software Engineering', 'marks': '90/100', 'grade': 'O'},
          ]),
          const SizedBox(height: 14),
          _buildSemesterCard('Semester 3 (Spring 2025)', '8.75', 'A+ Grade', [
            {'subject': 'Object Oriented Prog.', 'marks': '85/100', 'grade': 'A+'},
            {'subject': 'Digital Logic Design', 'marks': '86/100', 'grade': 'A+'},
            {'subject': 'Linear Algebra', 'marks': '89/100', 'grade': 'A+'},
          ]),
          const SizedBox(height: 90),
        ],
      ),
    );
  }

  Widget _buildSemesterCard(String title, String sgpa, String overall, List<Map<String, String>> subs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 14)),
              Text('SGPA: $sgpa', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary)),
            ],
          ),
          const Divider(height: 20),
          ...subs.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(s['subject']!, style: GoogleFonts.manrope(fontSize: 12, color: AppColors.textSecondary)),
                    Text('${s['marks']} (${s['grade']})', style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// NATIVE STABLE FLUTTER GAUGE WIDGET (REPLACES PERCENT_INDICATOR TO PREVENT SEMANTICS ASSERTIONS)
class AppCircularGauge extends StatelessWidget {
  final double radius;
  final double lineWidth;
  final double percent;
  final Widget center;
  final Color progressColor;
  final Color backgroundColor;

  const AppCircularGauge({
    super.key,
    required this.radius,
    required this.lineWidth,
    required this.percent,
    required this.center,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: percent.clamp(0.0, 1.0),
              strokeWidth: lineWidth,
              strokeAlign: CircularProgressIndicator.strokeAlignInside,
              color: progressColor,
              backgroundColor: backgroundColor,
              strokeCap: StrokeCap.round,
            ),
          ),
          center,
        ],
      ),
    );
  }
}

// NATIVE STABLE FLUTTER PROGRESS BAR (REPLACES PERCENT_INDICATOR TO PREVENT SEMANTICS ASSERTIONS)
class AppLinearProgressBar extends StatelessWidget {
  final double lineHeight;
  final double percent;
  final Color progressColor;
  final Color backgroundColor;
  final double borderRadius;

  const AppLinearProgressBar({
    super.key,
    required this.lineHeight,
    required this.percent,
    required this.progressColor,
    required this.backgroundColor,
    this.borderRadius = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        height: lineHeight,
        child: LinearProgressIndicator(
          value: percent.clamp(0.0, 1.0),
          color: progressColor,
          backgroundColor: backgroundColor,
        ),
      ),
    );
  }
}

// =============================================================================
// STANDALONE DIALOG & CARD WIDGETS WITH ISOLATED WIDGET TREE IDENTITY
// PREVENTS PARENTDATA AND SEMANTICS DISCREPANCIES IN FLUTTER RENDERFLEX PASSES
// =============================================================================

class MiniStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String val;
  final String label;

  const MiniStatCard({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.val,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 14),
            ),
            const SizedBox(height: 4),
            Text(val, style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
            Text(label, textAlign: TextAlign.center, style: GoogleFonts.manrope(fontSize: 9, color: const Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }
}

class AttendanceSubjectCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String code;
  final String name;
  final String faculty;
  final String ratio;
  final String percentStr;
  final String status;
  final Color statusColor;
  final double progress;
  final Color barColor;

  const AttendanceSubjectCard({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.code,
    required this.name,
    required this.faculty,
    required this.ratio,
    required this.percentStr,
    required this.status,
    required this.statusColor,
    required this.progress,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$code $name',
                      style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      faculty,
                      style: GoogleFonts.manrope(fontSize: 11, color: const Color(0xFF64748B)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(ratio, style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF2563EB))),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
                        child: Text(percentStr, style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF2563EB))),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF94A3B8)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 6, height: 6, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      Text(status, style: GoogleFonts.manrope(fontSize: 10, color: const Color(0xFF64748B))),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          AppLinearProgressBar(
            lineHeight: 6.0,
            percent: progress,
            backgroundColor: const Color(0xFFF1F5F9),
            progressColor: barColor,
            borderRadius: 4.0,
          ),
        ],
      ),
    );
  }
}

class AttendanceOverviewDialog extends StatelessWidget {
  final String studentName;
  final String registerNum;
  final Function(int)? onNavigateToTab;

  const AttendanceOverviewDialog({
    super.key,
    required this.studentName,
    required this.registerNum,
    this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        padding: const EdgeInsets.all(22),
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TOP HEADER ROW
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFDCFCE7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.pie_chart_rounded, color: Color(0xFF059669), size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Attendance Overview',
                          style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                        ),
                        Text(
                          '$studentName ($registerNum)',
                          style: GoogleFonts.manrope(fontSize: 13, color: const Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: Color(0xFF15803D), size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Good Standing',
                                    style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF15803D)),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.calendar_month_rounded, color: Color(0xFF2563EB), size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Semester: Jan – May 2025',
                                    style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF2563EB)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // OVERALL ATTENDANCE SUMMARY CONTAINER
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    AppCircularGauge(
                      radius: 44.0,
                      lineWidth: 9.0,
                      percent: 0.885,
                      center: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '88.5%',
                            style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 18, color: const Color(0xFF0F172A)),
                          ),
                          Text(
                            'Overall\nAttendance',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.manrope(fontSize: 9, color: const Color(0xFF64748B), height: 1.1),
                          ),
                        ],
                      ),
                      progressColor: const Color(0xFF059669),
                      backgroundColor: const Color(0xFFD1FAE5),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle_rounded, color: Color(0xFF15803D), size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  'SAFE • ABOVE 80%',
                                  style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF15803D)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'You\'re maintaining excellent attendance!',
                            style: GoogleFonts.manrope(fontSize: 11, color: const Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 12),
                          const Row(
                            children: [
                              MiniStatCard(
                                icon: Icons.calendar_month_rounded,
                                iconBg: Color(0xFFEFF6FF),
                                iconColor: Color(0xFF2563EB),
                                val: '131',
                                label: 'Classes Attended',
                              ),
                              SizedBox(width: 8),
                              MiniStatCard(
                                icon: Icons.edit_calendar_rounded,
                                iconBg: Color(0xFFFCE7F3),
                                iconColor: Color(0xFFDB2777),
                                val: '147',
                                label: 'Total Classes',
                              ),
                              SizedBox(width: 8),
                              MiniStatCard(
                                icon: Icons.percent_rounded,
                                iconBg: Color(0xFFFFEDD5),
                                iconColor: Color(0xFFEA580C),
                                val: '88.5%',
                                label: 'Overall Percentage',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // NOTIFICATION ALERT BANNER BOX
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFC7D2FE)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE0E7FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.notifications_active_rounded, color: Color(0xFF4338CA), size: 16),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Great job! Keep your attendance above 80% to maintain your academic standing.',
                        style: GoogleFonts.manrope(fontSize: 11, color: const Color(0xFF3730A3), fontWeight: FontWeight.w500),
                      ),
                    ),
                    const Icon(Icons.close_rounded, color: Color(0xFF6366F1), size: 16),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // SUBJECT BREAKDOWN HEADER & SORT DROPDOWN
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Subject Breakdown',
                      style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Sort by: Percentage',
                          style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF475569)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // SUBJECT CARDS LIST
              const AttendanceSubjectCard(
                icon: Icons.code_rounded,
                iconBg: Color(0xFFEFF6FF),
                iconColor: Color(0xFF2563EB),
                code: 'CS301',
                name: 'Data Structures',
                faculty: 'Mr. David Williams',
                ratio: '32 / 35',
                percentStr: '91.4%',
                status: 'Excellent',
                statusColor: Color(0xFF15803D),
                progress: 0.914,
                barColor: Color(0xFF2563EB),
              ),
              const AttendanceSubjectCard(
                icon: Icons.desktop_windows_rounded,
                iconBg: Color(0xFFDCFCE7),
                iconColor: Color(0xFF166534),
                code: 'CS302',
                name: 'Operating Systems',
                faculty: 'Dr. Sarah Thompson',
                ratio: '28 / 33',
                percentStr: '84.8%',
                status: 'Good',
                statusColor: Color(0xFF15803D),
                progress: 0.848,
                barColor: Color(0xFF059669),
              ),
              const AttendanceSubjectCard(
                icon: Icons.dns_rounded,
                iconBg: Color(0xFFF3E8FF),
                iconColor: Color(0xFF7C3AED),
                code: 'CS303',
                name: 'Database Systems',
                faculty: 'Mr. James Anderson',
                ratio: '28 / 32',
                percentStr: '87.5%',
                status: 'Good',
                statusColor: Color(0xFF15803D),
                progress: 0.875,
                barColor: Color(0xFF7C3AED),
              ),
              const AttendanceSubjectCard(
                icon: Icons.calculate_rounded,
                iconBg: Color(0xFFFFEDD5),
                iconColor: Color(0xFFC2410C),
                code: 'MA301',
                name: 'Discrete Mathematics',
                faculty: 'Dr. Lisa Brown',
                ratio: '27 / 30',
                percentStr: '90.0%',
                status: 'Excellent',
                statusColor: Color(0xFF15803D),
                progress: 0.900,
                barColor: Color(0xFFEA580C),
              ),
              const AttendanceSubjectCard(
                icon: Icons.science_rounded,
                iconBg: Color(0xFFCFFAFE),
                iconColor: Color(0xFF0E7490),
                code: 'CS304',
                name: 'Web Tech Lab',
                faculty: 'Mr. Robert Johnson',
                ratio: '16 / 17',
                percentStr: '94.1%',
                status: 'Excellent',
                statusColor: Color(0xFF15803D),
                progress: 0.941,
                barColor: Color(0xFF0891B2),
              ),

              const SizedBox(height: 16),

              // BOTTOM MOTIVATIONAL TARGET CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE9D5FF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDDD6FE),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.emoji_events_rounded, color: Color(0xFF7C3AED), size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Keep It Up!',
                                style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF6D28D9)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'You\'re doing great! Your attendance is above the required 80% threshold.',
                                style: GoogleFonts.manrope(fontSize: 11, color: const Color(0xFF7C3AED), height: 1.2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          AppCircularGauge(
                            radius: 18.0,
                            lineWidth: 4.0,
                            percent: 0.885,
                            center: Text('88.5%', style: GoogleFonts.manrope(fontSize: 8, fontWeight: FontWeight.bold, color: const Color(0xFF6D28D9))),
                            progressColor: const Color(0xFF7C3AED),
                            backgroundColor: const Color(0xFFDDD6FE),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Target Goal: 90%', style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF6D28D9))),
                                Text('Attend 16 more classes to reach 90% target', style: GoogleFonts.manrope(fontSize: 10, color: const Color(0xFF7C3AED))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // BOTTOM ACTION BUTTONS ROW
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: Text('Download Report', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1E293B),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4F46E5), Color(0xFF3B82F6)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          if (onNavigateToTab != null) {
                            onNavigateToTab!(1);
                          }
                        },
                        icon: const Icon(Icons.calendar_month_rounded, size: 18),
                        label: Text('Open Complete Attendance Log', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 11)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CgpaAnalyticsDialog extends StatelessWidget {
  final String studentName;
  final String registerNum;
  final Function(int)? onNavigateToTab;

  const CgpaAnalyticsDialog({
    super.key,
    required this.studentName,
    required this.registerNum,
    this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        padding: const EdgeInsets.all(22),
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_graph_rounded, color: Color(0xFF2563EB), size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CGPA & Grade Analytics',
                          style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                        ),
                        Text(
                          '$studentName ($registerNum)',
                          style: GoogleFonts.manrope(fontSize: 13, color: const Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    AppCircularGauge(
                      radius: 44.0,
                      lineWidth: 9.0,
                      percent: 0.892,
                      center: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '8.2',
                            style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 20, color: const Color(0xFF0F172A)),
                          ),
                          Text(
                            'Overall\nCGPA',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.manrope(fontSize: 9, color: const Color(0xFF64748B), height: 1.1),
                          ),
                        ],
                      ),
                      progressColor: const Color(0xFF2563EB),
                      backgroundColor: const Color(0xFFEFF6FF),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.stars_rounded, color: Color(0xFF15803D), size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  'GOOD STANDING',
                                  style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF15803D)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Consistently maintaining Grade A+ & O across technical courses.',
                            style: GoogleFonts.manrope(fontSize: 11, color: const Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: Text('Download Marksheet', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1E293B),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onNavigateToTab?.call(2);
                        },
                        icon: const Icon(Icons.bar_chart_rounded, size: 18),
                        label: Text('Open Full Grade History', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 11)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AcademicStandingDialog extends StatelessWidget {
  final String studentName;
  final String registerNum;
  final String academicStatus;
  final Function(int)? onNavigateToTab;

  const AcademicStandingDialog({
    super.key,
    required this.studentName,
    required this.registerNum,
    required this.academicStatus,
    this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.verified_user_outlined, color: Color(0xFF059669), size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Academic Standing',
                                style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                studentName,
                                style: GoogleFonts.manrope(fontSize: 12, color: AppColors.textSecondary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              _buildStatusItem(Icons.verified_rounded, 'Standing Status', academicStatus, const Color(0xFF059669)),
              _buildStatusItem(Icons.school_rounded, 'Registration', 'Semester 5 (Autumn 2026 Active)', const Color(0xFF2563EB)),
              _buildStatusItem(Icons.stars_rounded, 'Total Credits Tally', '48 / 160 Credits Completed', const Color(0xFF7C3AED)),
              _buildStatusItem(Icons.gavel_rounded, 'Disciplinary Record', 'Clean • Zero Warnings or Penalties', AppColors.success),
              _buildStatusItem(Icons.work_history_rounded, 'Placement Eligibility', 'Eligible for On-Campus Placement Drives', AppColors.primary),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Close Academic Profile', style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusItem(IconData icon, String title, String val, Color valColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: valColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: valColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  val,
                  style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.bold, color: valColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
