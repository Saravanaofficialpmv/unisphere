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

  final List<SidebarItem> _sidebarItems = [
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

  // Upcoming Exams
  final List<ParentExamModel> _upcomingExams = [
    ParentExamModel(
      id: 'ex_1',
      examName: 'Internal Assessment — II',
      subject: 'Operating Systems',
      examDate: DateTime(2026, 8, 28),
      timeSlot: '10:00 AM - 11:30 AM',
      venue: 'Room LH-204',
      examType: 'Internal',
    ),
    ParentExamModel(
      id: 'ex_2',
      examName: 'Model Examination',
      subject: 'Database Management Systems',
      examDate: DateTime(2026, 9, 2),
      timeSlot: '09:30 AM - 12:30 PM',
      venue: 'Lab 3',
      examType: 'Model',
    ),
    ParentExamModel(
      id: 'ex_3',
      examName: 'End Semester Practical',
      subject: 'Web Technology Workshop',
      examDate: DateTime(2026, 9, 8),
      timeSlot: '02:00 PM - 05:00 PM',
      venue: 'Computer Lab 1',
      examType: 'Practical',
    ),
  ];

  // Upcoming Events
  final List<ParentEventModel> _upcomingEvents = [
    ParentEventModel(
      id: 'ev_1',
      title: 'Parent–Teacher Meeting',
      eventDate: DateTime(2026, 9, 2),
      timeSlot: '10:00 AM',
      venue: 'Main Auditorium',
      category: 'Meeting',
      description: 'Semester 6 performance review and placement roadmap feedback with class mentors.',
    ),
    ParentEventModel(
      id: 'ev_2',
      title: 'Technical Symposium — TechFest 2026',
      eventDate: DateTime(2026, 9, 8),
      timeSlot: '09:30 AM',
      venue: 'Seminar Hall',
      category: 'Academic',
      description: 'Annual inter-departmental technical paper presentations and hackathons.',
    ),
    ParentEventModel(
      id: 'ev_3',
      title: 'Annual Sports Meet',
      eventDate: DateTime(2026, 9, 15),
      timeSlot: '08:30 AM',
      venue: 'College Grounds',
      category: 'Sports',
      description: 'Inter-house athletic competitions and award ceremony.',
    ),
  ];

  // Important Announcements
  final List<ParentAnnouncementModel> _announcements = [
    ParentAnnouncementModel(
      id: 'an_1',
      title: 'Semester Examination Schedule Released',
      description: 'The official timetable for upcoming semester end-term theory examinations is available.',
      datePublished: DateTime(2026, 8, 20),
      category: 'Examination',
      isImportant: true,
    ),
    ParentAnnouncementModel(
      id: 'an_2',
      title: 'Tuition & Transport Fee Payment Reminder',
      description: 'Installment 2 fee payment deadline is September 15, 2026. Online e-receipt generation active.',
      datePublished: DateTime(2026, 8, 18),
      category: 'Fees',
      isImportant: true,
    ),
    ParentAnnouncementModel(
      id: 'an_3',
      title: 'Hostel Outing Pass Consent Policy',
      description: 'Parent digital approval is now mandatory for weekend outings via Parent Portal.',
      datePublished: DateTime(2026, 8, 15),
      category: 'Policy',
      isImportant: false,
    ),
  ];

  // Recent Notifications
  final List<ParentNotificationItem> _recentNotifications = [
    ParentNotificationItem(
      id: 'not_1',
      title: 'Attendance Alert',
      message: 'Operating Systems attendance has fallen below recommended level.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      icon: Icons.warning_amber_rounded,
      iconColor: const Color(0xFFEF4444),
      targetTab: 'attendance',
      targetTabIndex: 1,
    ),
    ParentNotificationItem(
      id: 'not_2',
      title: 'New Internal Marks Published',
      message: 'DBMS Internal Assessment 2 marks have been published.',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      icon: Icons.grade_rounded,
      iconColor: const Color(0xFF2563EB),
      targetTab: 'academics',
      targetTabIndex: 2,
    ),
    ParentNotificationItem(
      id: 'not_3',
      title: 'Fee Due Reminder',
      message: 'Pending fee of ₹12,500 due on 15 Sep 2026.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      icon: Icons.payments_rounded,
      iconColor: const Color(0xFFD97706),
      targetTab: 'fees',
      targetTabIndex: 6,
    ),
    ParentNotificationItem(
      id: 'not_4',
      title: 'Parent–Teacher Meeting Invitation',
      message: 'Scheduled on 02 Sep at 10:00 AM in Main Auditorium.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      icon: Icons.event_rounded,
      iconColor: const Color(0xFF7C3AED),
      targetTab: 'events',
      targetTabIndex: 8,
    ),
  ];

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
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. STUDENT IDENTITY HEADER & WARD SWITCHER
              _buildStudentIdentityHeader(context),

              const SizedBox(height: 20),

              // 2, 3, 4. SUMMARY METRIC CARDS (ATTENDANCE, ACADEMICS, FEES)
              _buildSummaryCardsSection(isDesktop),

              const SizedBox(height: 24),

              // 5 & 6. UPCOMING EXAMS & UPCOMING EVENTS (GRID OR STACK)
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildUpcomingExamsSection()),
                    const SizedBox(width: 20),
                    Expanded(child: _buildUpcomingEventsSection()),
                  ],
                )
              else ...[
                _buildUpcomingExamsSection(),
                const SizedBox(height: 24),
                _buildUpcomingEventsSection(),
              ],

              const SizedBox(height: 24),

              // 7 & 8. IMPORTANT ANNOUNCEMENTS & RECENT NOTIFICATIONS
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildImportantAnnouncementsSection()),
                    const SizedBox(width: 20),
                    Expanded(child: _buildRecentNotificationsSection()),
                  ],
                )
              else ...[
                _buildImportantAnnouncementsSection(),
                const SizedBox(height: 24),
                _buildRecentNotificationsSection(),
              ],

              const SizedBox(height: 32),

              // 9. CAMPUS RECENT GALLERY
              const RecentPhotosSection(),

              const SizedBox(height: 90),
            ],
          ),
        ),
      ),
    );
  }

  // 1. STUDENT IDENTITY HEADER WITH WARD SWITCHER
  Widget _buildStudentIdentityHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Photo or Initials Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: _selectedWard.photoUrl != null
                      ? Image.network(
                          _selectedWard.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildAvatarFallback(),
                        )
                      : _buildAvatarFallback(),
                ),
              ),
              const SizedBox(width: 14),

              // Student Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedWard.name,
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Register No: ${_selectedWard.regNo}',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    Text(
                      '${_selectedWard.department} • ${_selectedWard.yearSection}',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // WARD SWITCHER BUTTON
              if (_wards.length > 1)
                Material(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: () => _showStudentSelectorSheet(context),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedWard.name.split(' ').first,
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback() {
    return Center(
      child: Text(
        _selectedWard.avatarInitials,
        style: GoogleFonts.manrope(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  void _showStudentSelectorSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Active Student Ward',
              style: GoogleFonts.manrope(
                fontSize: 17,
                fontWeight: FontWeight.bold,
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
    );
  }

  // 2, 3. SUMMARY METRIC CARDS SECTION
  Widget _buildSummaryCardsSection(bool isDesktop) {
    final attendanceCard = _buildAttendanceSummaryCard();
    final academicsCard = _buildAcademicsSummaryCard();

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: attendanceCard),
          const SizedBox(width: 16),
          Expanded(child: academicsCard),
        ],
      );
    }

    return Column(
      children: [
        attendanceCard,
        const SizedBox(height: 16),
        academicsCard,
      ],
    );
  }

  // 2. REDESIGNED ATTENDANCE SUMMARY CARD (MATCHING REFERENCE UI)
  Widget _buildAttendanceSummaryCard() {
    final healthBadge = _selectedWard.attendanceHealthStatus;
    final pctInt = (_selectedWard.attendancePercent * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.pie_chart_rounded, color: Color(0xFF15803D), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Attendance',
                            style: GoogleFonts.manrope(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Your child\'s attendance overview',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              color: const Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFDCFCE7)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user_rounded, size: 14, color: Color(0xFF15803D)),
                    const SizedBox(width: 4),
                    Text(
                      healthBadge,
                      style: GoogleFonts.manrope(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF15803D),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Main Percentage & Ring Indicator Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$pctInt%',
                      style: GoogleFonts.manrope(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                        height: 1.1,
                      ),
                    ),
                    Text(
                      'Overall Attendance',
                      style: GoogleFonts.manrope(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: _selectedWard.attendancePercent,
                        minHeight: 8,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Circular Attendance Ring Display
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: CircularProgressIndicator(
                      value: _selectedWard.attendancePercent,
                      strokeWidth: 7,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$pctInt%',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'Attendance',
                        style: GoogleFonts.manrope(
                          fontSize: 8.5,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),



          // Insight Banner Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFDCFCE7)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.show_chart_rounded, color: Color(0xFF15803D), size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Great! Keep maintaining good attendance.',
                        style: GoogleFonts.manrope(fontSize: 11.5, fontWeight: FontWeight.bold, color: const Color(0xFF166534)),
                      ),
                      Text(
                        'You are above the college required minimum.',
                        style: GoogleFonts.manrope(fontSize: 10.5, color: const Color(0xFF15803D)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'View Trend',
                        style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF15803D)),
                      ),
                      const SizedBox(width: 3),
                      const Icon(Icons.trending_up_rounded, size: 13, color: Color(0xFF15803D)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Footer Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 4),
                  Text(
                    'Last updated: Today, 09:30 AM',
                    style: GoogleFonts.manrope(fontSize: 11, color: const Color(0xFF64748B)),
                  ),
                ],
              ),
              InkWell(
                onTap: () => widget.onNavigateToTab?.call(1),
                child: Row(
                  children: [
                    Text(
                      'View Attendance',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primary),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 3. REDESIGNED ACADEMIC PERFORMANCE SUMMARY CARD (MATCHING REFERENCE UI)
  Widget _buildAcademicsSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E8FF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.school_rounded, color: Color(0xFF7C3AED), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Academics',
                            style: GoogleFonts.manrope(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Your child\'s academic performance',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              color: const Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _selectedWard.academicTrend,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Main CGPA Performance Card Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CGPA',
                  style: GoogleFonts.manrope(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _selectedWard.cgpa,
                      style: GoogleFonts.manrope(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF6D28D9),
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E8FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.workspace_premium_rounded, size: 14, color: Color(0xFF7C3AED)),
                          const SizedBox(width: 4),
                          Text(
                            _selectedWard.academicStatus,
                            style: GoogleFonts.manrope(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF7C3AED),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 16, color: Color(0xFF6D28D9)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Your child is performing well. Keep it up!',
                        style: GoogleFonts.manrope(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF5B21B6),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Subject Grades Summary List
          ..._selectedWard.subjectGrades.take(3).map((sub) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        sub.subjectName,
                        style: GoogleFonts.manrope(fontSize: 12, color: const Color(0xFF64748B)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: sub.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        sub.grade,
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: sub.color,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => widget.onNavigateToTab?.call(2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'View Academics',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 5. UPCOMING EXAMS SECTION
  Widget _buildUpcomingExamsSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.event_note_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Upcoming Exams',
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => widget.onNavigateToTab?.call(8),
                child: Text(
                  'View Exam Schedule →',
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
          if (_upcomingExams.isEmpty)
            _buildEmptyState('No Upcoming Exams', 'There are no scheduled examinations at the moment.')
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _upcomingExams.length,
              separatorBuilder: (_, __) => const Divider(height: 16, color: AppColors.divider),
              itemBuilder: (context, index) {
                final ex = _upcomingExams[index];
                return Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${ex.examDate.day}',
                              style: GoogleFonts.manrope(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF2563EB),
                                height: 1.0,
                              ),
                            ),
                            Text(
                              _getMonthAbbr(ex.examDate.month),
                              style: GoogleFonts.manrope(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2563EB),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${ex.examName} • ${ex.subject}',
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${ex.timeSlot} (${ex.venue})',
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        ex.examType,
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  // 6. UPCOMING EVENTS SECTION
  Widget _buildUpcomingEventsSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.celebration_rounded, color: Color(0xFF7C3AED), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Upcoming Events',
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => widget.onNavigateToTab?.call(8),
                child: Text(
                  'View All Events →',
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
          if (_upcomingEvents.isEmpty)
            _buildEmptyState('No Upcoming Events', 'There are no scheduled events at the moment.')
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _upcomingEvents.length,
              separatorBuilder: (_, __) => const Divider(height: 16, color: AppColors.divider),
              itemBuilder: (context, index) {
                final ev = _upcomingEvents[index];
                return Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F3FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          ev.category == 'Meeting'
                              ? Icons.groups_rounded
                              : ev.category == 'Sports'
                                  ? Icons.sports_soccer_rounded
                                  : Icons.school_rounded,
                          color: const Color(0xFF7C3AED),
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ev.title,
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${ev.eventDate.day} ${_getMonthAbbr(ev.eventDate.month)} • ${ev.timeSlot} (${ev.venue})',
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  // 7. IMPORTANT ANNOUNCEMENTS SECTION
  Widget _buildImportantAnnouncementsSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.campaign_rounded, color: Color(0xFFE11D48), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Important Announcements',
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => widget.onNavigateToTab?.call(3),
                child: Text(
                  'View All →',
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
          if (_announcements.isEmpty)
            _buildEmptyState('No New Announcements', 'You\'re all caught up.')
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _announcements.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final ann = _announcements[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ann.isImportant ? const Color(0xFFFECDD3) : AppColors.border,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ann.isImportant ? '🔴' : '🟡',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ann.title,
                              style: GoogleFonts.manrope(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              ann.description,
                              style: GoogleFonts.manrope(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${ann.datePublished.day} ${_getMonthAbbr(ann.datePublished.month)} ${ann.datePublished.year} • ${ann.category}',
                              style: GoogleFonts.manrope(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
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

  // 8. RECENT NOTIFICATIONS SECTION WITH DIRECT NAVIGATION
  Widget _buildRecentNotificationsSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.notifications_active_rounded, color: Color(0xFFD97706), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Recent Notifications',
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => showNotificationSheet(context),
                child: Text(
                  'View All →',
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
          if (_recentNotifications.isEmpty)
            _buildEmptyState('No Recent Notifications', 'You\'re all caught up.')
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentNotifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final notif = _recentNotifications[index];
                return InkWell(
                  onTap: () {
                    widget.onNavigateToTab?.call(notif.targetTabIndex);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: notif.iconColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(notif.icon, color: notif.iconColor, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notif.title,
                                style: GoogleFonts.manrope(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                notif.message,
                                style: GoogleFonts.manrope(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textTertiary),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // EMPTY STATE HELPER
  Widget _buildEmptyState(String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.inbox_rounded, color: AppColors.textTertiary, size: 28),
          const SizedBox(height: 6),
          Text(
            title,
            style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.manrope(fontSize: 11, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getMonthAbbr(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[(month - 1).clamp(0, 11)];
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
