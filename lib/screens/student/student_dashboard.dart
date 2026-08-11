import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clg_application/core/constants/app_colors.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:clg_application/screens/student/modules/student_assignment_portal.dart';
import 'package:clg_application/widgets/common/main_sidebar.dart';
import 'package:clg_application/screens/student/gradebook_screen.dart';
import 'package:clg_application/screens/features/feature_hub_screen.dart';
import 'package:clg_application/screens/features/fees_screen.dart';
import 'package:clg_application/screens/features/hackathons_screen.dart';
import 'package:clg_application/screens/features/certifications_screen.dart';
import 'package:clg_application/screens/features/achievements_screen.dart';
import 'package:clg_application/screens/features/events_screen.dart';
import 'package:clg_application/screens/profile/profile_screen.dart';
import 'package:clg_application/screens/student/modules/student_attendance_screen.dart';
import 'package:clg_application/screens/student/modules/student_announcements_screen.dart';
import 'package:clg_application/screens/student/modules/student_library_screen.dart';
import 'package:clg_application/widgets/common/notification_sheet.dart';
import 'package:clg_application/providers/notification_provider.dart';
import 'package:clg_application/screens/features/exams_detail_screen.dart';

class StudentDashboard extends ConsumerStatefulWidget {
  const StudentDashboard({super.key});

  @override
  ConsumerState<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends ConsumerState<StudentDashboard> {
  int _currentIndex = 0;
  bool _openGpaPlannerInGradebook = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<SidebarItem> _sidebarItems = [
    SidebarItem(label: 'Home Dashboard', icon: Icons.dashboard_outlined),
    SidebarItem(label: 'Timetable', icon: Icons.calendar_month_outlined),
    SidebarItem(label: 'My Tasks', icon: Icons.assignment_outlined, badge: '3'),
    SidebarItem(label: 'Attendance', icon: Icons.calendar_today_outlined),
    SidebarItem(label: 'Academic Marks', icon: Icons.bar_chart_outlined),
    SidebarItem(label: 'Fees & Payments', icon: Icons.payments_outlined),
    SidebarItem.divider('CAMPUS & CAREER'),
    SidebarItem(label: 'Hackathons', icon: Icons.sports_score_outlined, badge: 'Live'),
    SidebarItem(label: 'Certifications', icon: Icons.workspace_premium_outlined, badge: 'Verified'),
    SidebarItem(label: 'Achievements', icon: Icons.emoji_events_outlined),
    SidebarItem(label: 'Campus Events', icon: Icons.event_outlined),
    SidebarItem(label: 'Feature Hub', icon: Icons.grid_view_rounded),
    SidebarItem.divider('CAMPUS LIFE'),
    SidebarItem(label: 'Announcements', icon: Icons.campaign_outlined),
    SidebarItem(label: 'Library Status', icon: Icons.local_library_outlined),
    SidebarItem.divider('ACCOUNT'),
    SidebarItem(label: 'My Profile', icon: Icons.person_outline),
  ];

  List<Widget> _getScreens() {
    return [
      StudentHomeScreen(onNavigateToTab: _handleNavigation), // 0
      InteractiveTimetableScreen(onBack: () => _handleNavigation(0)), // 1
      StudentAssignmentPortal(onBack: () => _handleNavigation(0)),    // 2
      StudentAttendanceScreen(onBack: () => _handleNavigation(0)), // 3
      GradebookScreen(                                       // 4
        key: ValueKey('gradebook_$_openGpaPlannerInGradebook'),
        initialShowPlanner: _openGpaPlannerInGradebook,
        onBack: () => _handleNavigation(0),
      ),
      FeesScreen(onBack: () => _handleNavigation(0)),        // 5
      const SizedBox.shrink(),                               // 6: Divider
      HackathonsScreen(onBack: () => _handleNavigation(0)),   // 7
      CertificationsScreen(onBack: () => _handleNavigation(0)), // 8
      AchievementsScreen(onBack: () => _handleNavigation(0)), // 9
      EventsScreen(onBack: () => _handleNavigation(0)),       // 10
      FeatureHubScreen(                                      // 11
        onNavigateToTab: _handleNavigation,
        onBack: () => _handleNavigation(0),
      ),
      const SizedBox.shrink(),                               // 12: Divider
      StudentAnnouncementsScreen(onBack: () => _handleNavigation(0)), // 13
      StudentLibraryScreen(onBack: () => _handleNavigation(0)),       // 14
      const SizedBox.shrink(),                               // 15: Divider
      ProfileScreen(onBack: () => _handleNavigation(0)),     // 16
    ];
  }

  void _handleNavigation(int index, {bool openCalculator = false}) {
    setState(() {
      _currentIndex = index;
      _openGpaPlannerInGradebook = openCalculator;
    });
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1200;
    final notificationState = ref.watch(notificationProvider);
    final unreadCount = notificationState.unreadCount;

    final bool showTopAppBar = _currentIndex == 0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
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
      backgroundColor: Colors.white,
      drawer: isDesktop ? null : Drawer(child: _buildSidebar()),
      appBar: showTopAppBar
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              shadowColor: Colors.black12,
              surfaceTintColor: Colors.transparent,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu_rounded, color: Color(0xFF2D3142), size: 26),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
              ),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.hub_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 8),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'UNISPHERE',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2D3142),
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'SRM',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              centerTitle: true,
              actions: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF2D3142), size: 26),
                        onPressed: () {
                          showNotificationSheet(
                            context,
                            onNavigateToTab: _handleNavigation,
                          );
                        },
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: 10,
                          top: 10,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            )
          : null,
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(),
          Expanded(
            child: Builder(
              builder: (context) {
                final screens = _getScreens();
                return screens[_currentIndex < screens.length ? _currentIndex : 0];
              },
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
      userName: 'Alex Johnson',
      userEmail: 'alex.j@unisphere.edu',
    );
  }
}

// ─────────────────────────────────────────
//  Home Screen
// ─────────────────────────────────────────
class StudentHomeScreen extends StatefulWidget {
  final Function(int index, {bool openCalculator}) onNavigateToTab;
  const StudentHomeScreen({super.key, required this.onNavigateToTab});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(),
          const SizedBox(height: 20),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: -20,
                      left: 20,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF3F51B5).withValues(alpha: 0.45),
                              const Color(0xFF3F51B5).withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -20,
                      right: 40,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF69F0AE).withValues(alpha: 0.35),
                              const Color(0xFF69F0AE).withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildAttendanceCard(context),
            ],
          ),
          const SizedBox(height: 20),
          _buildQuickActions(),
          const SizedBox(height: 20),
          _buildSectionHeader('Today\'s Classes', () => widget.onNavigateToTab(1)),
          const SizedBox(height: 12),
          _buildTodaysClasses(),
          const SizedBox(height: 24),
          _buildSuggestedIconsSection(),
        ],
      ),
    );
  }

  // ── Today's Classes ───────────────────────
  Widget _buildTodaysClasses() {
    return Column(
      children: [
        _buildClassCard(
          time: '09:00',
          period: 'AM',
          title: 'Advanced Mathematics',
          timeRange: '09:00 AM – 10:30 AM',
          room: 'Room 302',
          accentColor: const Color(0xFF5C6BC0),
          icon: Icons.calculate_rounded,
          iconBg: const Color(0xFFEDE7F6),
        ),
        _buildClassCard(
          time: '11:00',
          period: 'AM',
          title: 'Computer Science',
          timeRange: '11:00 AM – 12:30 PM',
          room: 'Lab 1',
          accentColor: const Color(0xFF26A69A),
          icon: Icons.computer_rounded,
          iconBg: const Color(0xFFE0F2F1),
        ),
      ],
    );
  }

  Widget _buildClassCard({
    required String time,
    required String period,
    required String title,
    required String timeRange,
    required String room,
    required Color accentColor,
    required IconData icon,
    required Color iconBg,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Color(0xFF2D3142),
                ),
              ),
              Text(
                period,
                style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Container(width: 3, height: 44, decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF2D3142)),
                ),
                const SizedBox(height: 3),
                Text(
                  '$timeRange • $room',
                  style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: accentColor, size: 22),
          ),
        ],
      ),
    );
  }

  // ── Welcome Header ──────────────────────
  Widget _buildWelcomeSection() {
    return Row(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: Container(
              color: const Color(0xFFE8EAF6),
              child: const Icon(Icons.person, color: AppColors.primary, size: 36),
            ),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, Welcome Back! 👋',
                style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
              ),
              SizedBox(height: 2),
              Text(
                'Alex Johnson',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2D3142),
                ),
              ),
              Text(
                'Computer Science • 3rd Year',
                style: TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceCard(BuildContext context) {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.32),
                Colors.white.withValues(alpha: 0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.45),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: const Color(0xFF3F51B5).withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              CircularPercentIndicator(
                radius: 42.0,
                lineWidth: 7.0,
                percent: 0.85,
                center: const Text(
                  '85%',
                  style: TextStyle(
                    color: Color(0xFF2D3142),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                progressColor: const Color(0xFF3F51B5),
                backgroundColor: const Color(0xFF3F51B5).withValues(alpha: 0.1),
                circularStrokeCap: CircularStrokeCap.round,
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Average Attendance',
                      style: TextStyle(color: Color(0xFF757575), fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Your presence\nis great! 🎉',
                      style: TextStyle(
                        color: Color(0xFF2D3142),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.arrow_upward_rounded, color: Color(0xFF2E7D32), size: 14),
                        SizedBox(width: 2),
                        Text(
                          '5% this month',
                          style: TextStyle(color: Color(0xFF2E7D32), fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Image.asset(
                'assets/calendar.png',
                width: 60,
                height: 60,
              ),
            ],
          ),
        ),
      ),
    ),
  );
  }

  // ── Suggested Icons Section ───────────────────
  Widget _buildSuggestedIconsSection() {
    final suggested = [
      {
        'title': 'Upcoming Tasks',
        'sub1': 'Calendar + Checklist + Clock',
        'sub2': '(Shows upcoming to-dos & deadlines)',
        'pillBg': const Color(0xFF6366F1),
        'iconBg': const Color(0xFFEEF2FF),
        'iconColor': const Color(0xFF4F46E5),
        'accentColor': const Color(0xFFF59E0B),
        'iconType': 'tasks',
        'tabIndex': 2,
      },
      {
        'title': 'Latest Announcement',
        'sub1': 'Megaphone + Notification',
        'sub2': '(Highlights new updates)',
        'pillBg': const Color(0xFFF97316),
        'iconBg': const Color(0xFFFEF3C7),
        'iconColor': const Color(0xFFEA580C),
        'accentColor': const Color(0xFFEF4444),
        'iconType': 'announcement',
        'tabIndex': 13,
      },
      {
        'title': 'Exams',
        'sub1': 'Test Paper + Pencil + Clock',
        'sub2': '(Displays upcoming exams & schedules)',
        'pillBg': const Color(0xFF0284C7),
        'iconBg': const Color(0xFFE0F2FE),
        'iconColor': const Color(0xFF0284C7),
        'accentColor': const Color(0xFFF59E0B),
        'iconType': 'exams',
        'tabIndex': 4,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.auto_awesome_rounded, color: Color(0xFF818CF8), size: 18),
            SizedBox(width: 6),
            Text(
              'Suggested Features',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 650;
            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: suggested.map((item) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: _buildSuggestedCard(item),
                    ),
                  );
                }).toList(),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: suggested.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: _buildSuggestedCard(item),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSuggestedCard(Map<String, dynamic> item) {
    final pillBg = item['pillBg'] as Color;
    final iconColor = item['iconColor'] as Color;
    final iconType = item['iconType'] as String;
    final tabIndex = item['tabIndex'] as int;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: pillBg.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            if (iconType == 'announcement') {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const StudentAnnouncementsScreen(),
                ),
              );
            } else if (iconType == 'exams') {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ExamsDetailScreen(),
                ),
              );
            } else {
              widget.onNavigateToTab(tabIndex);
            }
          },
          borderRadius: BorderRadius.circular(20),
          splashColor: pillBg.withValues(alpha: 0.15),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon without background container layout
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _renderSuggestedIcon(iconType, iconColor),
                    ),
                    if (iconType == 'announcement')
                      Positioned(
                        top: -2,
                        right: -6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Text(
                            '1',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                // Pill Button Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: pillBg,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: pillBg.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    item['title'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitles
                Text(
                  item['sub1'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item['sub2'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _renderSuggestedIcon(String type, Color mainColor) {
    if (type == 'tasks') {
      return Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.calendar_month_rounded, size: 36, color: mainColor),
          Positioned(
            bottom: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.schedule_rounded, size: 16, color: Color(0xFFF59E0B)),
            ),
          ),
        ],
      );
    } else if (type == 'announcement') {
      return Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.campaign_rounded, size: 38, color: mainColor),
        ],
      );
    } else {
      return Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.assignment_rounded, size: 36, color: mainColor),
          Positioned(
            bottom: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit_rounded, size: 15, color: Color(0xFFF59E0B)),
            ),
          ),
        ],
      );
    }
  }

  // ── Quick Actions ────────────────────────
  Widget _buildQuickActions() {
    final actions = [
      {'image': 'assets/timetable.png', 'label': 'Timetable', 'color': const Color(0xFF5C6BC0)},
      {'image': 'assets/assignment.png', 'label': 'Assignments', 'color': const Color(0xFF26A69A)},
      {'image': 'assets/student.png', 'label': 'Grades', 'color': const Color(0xFFEF5350)},
      {'image': 'assets/school.png', 'label': 'Fees', 'color': const Color(0xFFFFA726)},
      {'icon': Icons.grid_view_rounded, 'label': 'More', 'color': const Color(0xFFFF7043)},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((action) {
        final label = action['label'] as String;
        final color = action['color'] as Color;
        return Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (label == 'Timetable') {
                  widget.onNavigateToTab(1);
                } else if (label == 'Assignments') {
                  widget.onNavigateToTab(2);
                } else if (label == 'Grades') {
                  widget.onNavigateToTab(4, openCalculator: true);
                } else if (label == 'Fees') {
                  widget.onNavigateToTab(5);
                } else if (label == 'More') {
                  _showMoreServicesBottomSheet(context);
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: color.withValues(alpha: 0.2)),
                      ),
                      child: action.containsKey('image')
                          ? Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Image.asset(
                                action['image'] as String,
                                fit: BoxFit.contain,
                              ),
                            )
                          : Icon(action['icon'] as IconData, color: color, size: 26),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF616161), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Feature Hub Launcher ────────────────
  void _showMoreServicesBottomSheet(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/feature_hub'),
        builder: (context) => FeatureHubScreen(
          onNavigateToTab: widget.onNavigateToTab,
        ),
      ),
    );
  }



  // ── Section Header ────────────────────────
  Widget _buildSectionHeader(String title, VoidCallback onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D3142),
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'See All',
            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
      ],
    );
  }


}

class InteractiveTimetable extends StatefulWidget {
  const InteractiveTimetable({super.key});

  @override
  State<InteractiveTimetable> createState() => _InteractiveTimetableState();
}

class _InteractiveTimetableState extends State<InteractiveTimetable> {
  int _selectedDayIndex = 0; // 0 = Mon, 1 = Tue, 2 = Wed, 3 = Thu, 4 = Fri, 5 = Sat
  int? _selectedClassIndex = 1; // Default select 1 (e.g. Computer Science live class)
  bool _simulateRealtimeUpdates = false;

  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  final List<List<Map<String, dynamic>>> _timetableData = [
    // Monday
    [
      {
        'time': '09:00',
        'period': 'AM',
        'title': 'Advanced Mathematics',
        'timeRange': '09:00 AM – 10:30 AM',
        'room': 'Room 302',
        'lecturer': 'Dr. Sarah Vance',
        'accentColor': const Color(0xFF5C6BC0),
        'icon': Icons.calculate_rounded,
        'iconBg': const Color(0xFFEDE7F6),
        'isLive': false,
      },
      {
        'time': '11:00',
        'period': 'AM',
        'title': 'Computer Science',
        'timeRange': '11:00 AM – 12:30 PM',
        'room': 'Lab 1',
        'lecturer': 'Prof. Alan Turing',
        'accentColor': const Color(0xFF26A69A),
        'icon': Icons.computer_rounded,
        'iconBg': const Color(0xFFE0F2F1),
        'isLive': true, // highlighted as ongoing
      },
      {
        'time': '02:00',
        'period': 'PM',
        'title': 'Physics Lab',
        'timeRange': '02:00 PM – 03:30 PM',
        'room': 'Lab 3',
        'lecturer': 'Dr. Marie Curie',
        'accentColor': const Color(0xFFFFA726),
        'icon': Icons.science_rounded,
        'iconBg': const Color(0xFFFFF3E0),
        'isLive': false,
      },
    ],
    // Tuesday
    [
      {
        'time': '09:30',
        'period': 'AM',
        'title': 'Database Systems',
        'timeRange': '09:30 AM – 11:00 AM',
        'room': 'Room 104',
        'lecturer': 'Dr. Grace Hopper',
        'accentColor': const Color(0xFF29B6F6),
        'icon': Icons.storage_rounded,
        'iconBg': const Color(0xFFE1F5FE),
        'isLive': false,
      },
      {
        'time': '11:30',
        'period': 'AM',
        'title': 'Software Engineering',
        'timeRange': '11:30 AM – 01:00 PM',
        'room': 'Room 205',
        'lecturer': 'Prof. Margaret Hamilton',
        'accentColor': const Color(0xFF66BB6A),
        'icon': Icons.code_rounded,
        'iconBg': const Color(0xFFE8F5E9),
        'isLive': false,
        'status': 'rescheduled',
        'statusText': 'Rescheduled to 02:00 PM',
      },
      {
        'time': '03:00',
        'period': 'PM',
        'title': 'Communication Skills',
        'timeRange': '03:00 PM – 04:30 PM',
        'room': 'Seminar Hall',
        'lecturer': 'Prof. Dale Carnegie',
        'accentColor': const Color(0xFFAB47BC),
        'icon': Icons.record_voice_over_rounded,
        'iconBg': const Color(0xFFF3E5F5),
        'isLive': false,
      },
    ],
    // Wednesday
    [
      {
        'time': '09:00',
        'period': 'AM',
        'title': 'Advanced Mathematics',
        'timeRange': '09:00 AM – 10:30 AM',
        'room': 'Room 302',
        'lecturer': 'Dr. Sarah Vance',
        'accentColor': const Color(0xFF5C6BC0),
        'icon': Icons.calculate_rounded,
        'iconBg': const Color(0xFFEDE7F6),
        'isLive': false,
      },
      {
        'time': '11:00',
        'period': 'AM',
        'title': 'Computer Science',
        'timeRange': '11:00 AM – 12:30 PM',
        'room': 'Lab 1',
        'lecturer': 'Prof. Alan Turing',
        'accentColor': const Color(0xFF26A69A),
        'icon': Icons.computer_rounded,
        'iconBg': const Color(0xFFE0F2F1),
        'isLive': false,
      },
      {
        'time': '01:30',
        'period': 'PM',
        'title': 'Discrete Structures',
        'timeRange': '01:30 PM – 03:00 PM',
        'room': 'Room 310',
        'lecturer': 'Dr. Ada Lovelace',
        'accentColor': const Color(0xFFEC407A),
        'icon': Icons.hub_rounded,
        'iconBg': const Color(0xFFFCE4EC),
        'isLive': false,
      },
    ],
    // Thursday
    [
      {
        'time': '10:00',
        'period': 'AM',
        'title': 'Database Systems',
        'timeRange': '10:00 AM – 11:30 AM',
        'room': 'Room 104',
        'lecturer': 'Dr. Grace Hopper',
        'accentColor': const Color(0xFF29B6F6),
        'icon': Icons.storage_rounded,
        'iconBg': const Color(0xFFE1F5FE),
        'isLive': false,
      },
      {
        'time': '12:00',
        'period': 'PM',
        'title': 'Software Engineering',
        'timeRange': '12:00 PM – 01:30 PM',
        'room': 'Room 205',
        'lecturer': 'Prof. Margaret Hamilton',
        'accentColor': const Color(0xFFEF5350),
        'icon': Icons.code_rounded,
        'iconBg': const Color(0xFFFFEBEE),
        'isLive': false,
        'status': 'cancelled',
        'statusText': 'Cancelled Today',
      },
      {
        'time': '02:30',
        'period': 'PM',
        'title': 'Web Development',
        'timeRange': '02:30 PM – 04:00 PM',
        'room': 'Lab 2',
        'lecturer': 'Prof. Tim Berners-Lee',
        'accentColor': const Color(0xFF26A69A),
        'icon': Icons.web_rounded,
        'iconBg': const Color(0xFFE0F2F1),
        'isLive': false,
      },
    ],
    // Friday
    [
      {
        'time': '09:00',
        'period': 'AM',
        'title': 'Digital Logic Design',
        'timeRange': '09:00 AM – 10:30 AM',
        'room': 'Lab 4',
        'lecturer': 'Dr. Claude Shannon',
        'accentColor': const Color(0xFF26A69A),
        'icon': Icons.memory_rounded,
        'iconBg': const Color(0xFFE0F2F1),
        'isLive': false,
      },
      {
        'time': '11:00',
        'period': 'AM',
        'title': 'Discrete Structures',
        'timeRange': '11:00 AM – 12:30 PM',
        'room': 'Room 310',
        'lecturer': 'Dr. Ada Lovelace',
        'accentColor': const Color(0xFFEC407A),
        'icon': Icons.hub_rounded,
        'iconBg': const Color(0xFFFCE4EC),
        'isLive': false,
      },
      {
        'time': '02:00',
        'period': 'PM',
        'title': 'Seminar / Guest Lecture',
        'timeRange': '02:00 PM – 03:30 PM',
        'room': 'Auditorium',
        'lecturer': 'Invited Speakers',
        'accentColor': const Color(0xFF5C6BC0),
        'icon': Icons.groups_rounded,
        'iconBg': const Color(0xFFEDE7F6),
        'isLive': false,
      },
    ],
    // Saturday
    [
      {
        'time': '10:00',
        'period': 'AM',
        'title': 'Project Work / Mentorship',
        'timeRange': '10:00 AM – 12:00 PM',
        'room': 'Lab 1',
        'lecturer': 'Internal Faculty',
        'accentColor': const Color(0xFFFF7043),
        'icon': Icons.lightbulb_outline_rounded,
        'iconBg': const Color(0xFFFBE9E7),
        'isLive': false,
      },
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final classes = _timetableData[_selectedDayIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with live updates simulator toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Interactive Timetable',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D3142),
              ),
            ),
            Row(
              children: [
                const Text(
                  'Live Updates',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF757575)),
                ),
                const SizedBox(width: 4),
                Transform.scale(
                  scale: 0.7,
                  child: Switch(
                    value: _simulateRealtimeUpdates,
                    activeThumbColor: AppColors.primary,
                    activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onChanged: (val) {
                      setState(() {
                        _simulateRealtimeUpdates = val;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Day Selector Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_days.length, (index) {
              final isSelected = _selectedDayIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDayIndex = index;
                    _selectedClassIndex = null;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8, bottom: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isSelected ? 0.15 : 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color: isSelected ? AppColors.primary : const Color(0xFFEEEEEE),
                    ),
                  ),
                  child: Text(
                    _days[index],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isSelected ? Colors.white : const Color(0xFF616161),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 16),

        // Classes Grid/List
        if (classes.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No classes scheduled for this day.',
                style: TextStyle(color: Color(0xFF9E9E9E)),
              ),
            ),
          )
        else
          ...classes.asMap().entries.map((entry) {
            final classIndex = entry.key;
            final c = entry.value;

            // Apply simulation changes if toggled
            String? status = c['status'] as String?;
            String? statusText = c['statusText'] as String?;

            if (_simulateRealtimeUpdates && _selectedDayIndex == 0 && c['title'] == 'Advanced Mathematics') {
              // Simulate rescheduling Advanced Mathematics on Monday
              status = 'rescheduled';
              statusText = 'Rescheduled to 01:00 PM';
            }

            final isLive = c['isLive'] as bool && !_simulateRealtimeUpdates;
            final isCancelled = status == 'cancelled';
            final isRescheduled = status == 'rescheduled';
            final isSelectedCard = _selectedClassIndex == classIndex;

            final accentColor = isCancelled ? const Color(0xFFE53935) : (c['accentColor'] as Color);

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedClassIndex = isSelectedCard ? null : classIndex;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isSelectedCard
                      ? Colors.white
                      : (isLive ? Colors.white : Colors.white.withValues(alpha: 0.95)),
                  borderRadius: BorderRadius.circular(16),
                  border: isSelectedCard
                      ? Border.all(color: const Color(0xFF2563EB), width: 2.5) // Vibrant Blue outline on click!
                      : (isLive
                          ? Border.all(color: const Color(0xFF10B981), width: 1.5) // Emerald green border for Live class!
                          : Border.all(color: const Color(0xFFEEEEEE), width: 1)),
                  boxShadow: [
                    BoxShadow(
                      color: isSelectedCard
                          ? const Color(0xFF2563EB).withValues(alpha: 0.22) // Blue glow shadow on click!
                          : (isLive
                              ? const Color(0xFF10B981).withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.03)),
                      blurRadius: isSelectedCard ? 12 : (isLive ? 12 : 8),
                      offset: isSelectedCard ? const Offset(0, 4) : const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    // Time column
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          isRescheduled ? '01:00' : (c['time'] as String),
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: isCancelled ? const Color(0xFFB71C1C) : const Color(0xFF2D3142),
                            decoration: isCancelled ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        Text(
                          c['period'] as String,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    // Indicator
                    Container(
                      width: 3,
                      height: 48,
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Information
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  c['title'] as String,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: const Color(0xFF2D3142),
                                    decoration: isCancelled ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                              ),
                              if (isLive)
                                Container(
                                  margin: const EdgeInsets.only(left: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: const Color(0xFF81C784)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.fiber_manual_record, color: Colors.green, size: 8),
                                      SizedBox(width: 3),
                                      Text(
                                        'LIVE NOW',
                                        style: TextStyle(
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Lecturer: ${c['lecturer']}',
                                  style: const TextStyle(color: Color(0xFF757575), fontSize: 11, fontWeight: FontWeight.w500),
                                ),
                              ),
                              if (isCancelled || isRescheduled) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isCancelled ? const Color(0xFFFFEBEE) : const Color(0xFFFFF3E0),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    statusText!,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: isCancelled ? const Color(0xFFD32F2F) : const Color(0xFFEF6C00),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Icon
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: c['iconBg'] as Color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(c['icon'] as IconData, color: c['accentColor'] as Color, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}





class InteractiveTimetableScreen extends StatelessWidget {
  final VoidCallback? onBack;

  const InteractiveTimetableScreen({super.key, this.onBack});

  void _handleBack(BuildContext context) {
    if (onBack != null) {
      onBack!();
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: onBack == null,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack(context);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.black12,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
            tooltip: 'Back to Home',
            onPressed: () => _handleBack(context),
          ),
          title: const Text(
            'Interactive Timetable & Schedule',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
        ),
        body: const SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: InteractiveTimetable(),
        ),
      ),
    );
  }
}

// ── Modals ───────────────────────────────────────────────────

void showClassMaterialsModal(BuildContext context, Map<String, String> classData) {
  final title = classData['title'] ?? 'Course';
  final code = classData['code'] ?? 'CS301';
  final isLive = classData['status'] == 'Live Now';

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    code,
                    style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          if (isLive) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: Color(0xFF2563EB), shape: BoxShape.circle),
                    child: const Icon(Icons.video_call_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Online Session Active', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E40AF))),
                        Text('Hosted via Zoom • Room ID: 884 902 119', style: TextStyle(fontSize: 11, color: Color(0xFF3B82F6))),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Join Room', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          const Text(
            'Course Lecture Materials & Resources',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 12),
          _buildMaterialItem(Icons.picture_as_pdf_rounded, 'Unit 3: Lecture Slides & Architecture', 'PDF • 4.2 MB', const Color(0xFFDC2626), const Color(0xFFFEF2F2)),
          const SizedBox(height: 10),
          _buildMaterialItem(Icons.folder_zip_rounded, 'Lab Exercises & Sample Code', 'ZIP • 8.5 MB', const Color(0xFFD97706), const Color(0xFFFEF3C7)),
          const SizedBox(height: 10),
          _buildMaterialItem(Icons.play_circle_fill_rounded, 'Recorded Video Session (Class 14)', 'MP4 • 45 min', const Color(0xFF059669), const Color(0xFFECFDF5)),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}

Widget _buildMaterialItem(IconData icon, String title, String subtitle, Color color, Color bg) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            ],
          ),
        ),
        const Icon(Icons.download_rounded, color: Color(0xFF2563EB), size: 20),
      ],
    ),
  );
}

void showRoomLocationModal(BuildContext context, Map<String, String> classData) {
  final title = classData['title'] ?? 'Course';
  final room = classData['room'] ?? 'Room 302';
  final time = classData['time'] ?? '09:00 AM';

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Campus Navigation', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text('$title ($room)', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.domain_rounded, color: Color(0xFF2563EB), size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(room, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
                          const Text('Tech Park Block B • Floor 3', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.schedule_rounded, size: 16, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Text('Session: $time', style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.event_seat_rounded, size: 16, color: Color(0xFF059669)),
                        const SizedBox(width: 4),
                        const Text('Capacity: 60 Seats', style: TextStyle(fontSize: 12, color: Color(0xFF059669), fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}
