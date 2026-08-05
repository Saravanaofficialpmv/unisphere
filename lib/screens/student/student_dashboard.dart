import 'dart:ui';
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
    SidebarItem(label: 'Timetable', icon: Icons.calendar_month_outlined),
    SidebarItem(label: 'My Tasks', icon: Icons.assignment_outlined, badge: '3'),
    SidebarItem(label: 'Attendance', icon: Icons.calendar_today_outlined),
    SidebarItem(label: 'Academic Marks', icon: Icons.bar_chart_outlined),
    SidebarItem(label: 'My Profile', icon: Icons.person_outline),
    SidebarItem.divider('CAMPUS LIFE'),
    SidebarItem(label: 'Announcements', icon: Icons.campaign_outlined),
    SidebarItem(label: 'Library Status', icon: Icons.local_library_outlined),
  ];

  List<Widget> _getScreens() {
    return [
      StudentHomeScreen(onNavigateToTab: _handleNavigation),
      const InteractiveTimetableScreen(),
      const Center(child: Text('Assignments & Tasks')),
      const Center(child: Text('Detailed Attendance')),
      const Center(child: Text('Marks & Grades')),
      const Center(child: Text('Student Profile')),
      const Center(child: Text('Announcements')),
      const Center(child: Text('Library')),
    ];
  }

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
      backgroundColor: const Color(0xFFF5F6FA),
      drawer: isDesktop ? null : Drawer(child: _buildSidebar()),
      appBar: AppBar(
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
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF2D3142), size: 26),
                onPressed: () {},
              ),
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
        ],
      ),
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
  final Function(int) onNavigateToTab;
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
              _buildAttendanceCard(context),
            ],
          ),
          const SizedBox(height: 20),
          _buildQuickActions(),
          const SizedBox(height: 20),
          _buildSectionHeader('Today\'s Classes', () => widget.onNavigateToTab(1)),
          const SizedBox(height: 12),
          _buildTodaysClasses(),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildUpcomingTasks()),
              const SizedBox(width: 12),
              Expanded(child: _buildExamsCard()),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('Latest Announcements', () {}),
          const SizedBox(height: 12),
          _buildAnnouncements(),
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
    return ClipRRect(
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
    );
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
        final color = action['color'] as Color;
        return InkWell(
          onTap: () {
            if (action['label'] == 'Timetable') {
              widget.onNavigateToTab(1);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opening ${action['label']}...'),
                  duration: const Duration(seconds: 1),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
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
                  action['label'] as String,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF616161), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        );
      }).toList(),
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            val
                                ? 'Simulating real-time schedule alerts!'
                                : 'Real-time updates simulation paused.',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
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
          ...classes.map((c) {
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

            final accentColor = isCancelled ? const Color(0xFFE53935) : (c['accentColor'] as Color);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isLive ? Colors.white : Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(16),
                border: isLive
                    ? Border.all(color: AppColors.primary.withValues(alpha: 0.8), width: 1.5)
                    : Border.all(color: const Color(0xFFEEEEEE), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: isLive
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.03),
                    blurRadius: isLive ? 12 : 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
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
                              Text(
                                'Lecturer: ${c['lecturer']}',
                                style: const TextStyle(color: Color(0xFF757575), fontSize: 11),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(Icons.location_on_outlined, color: accentColor, size: 12),
                                  const SizedBox(width: 2),
                                  Text(
                                    c['room'] as String,
                                    style: TextStyle(
                                      color: isCancelled ? const Color(0xFFB71C1C) : const Color(0xFF9E9E9E),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (isCancelled || isRescheduled) ...[
                                    const SizedBox(width: 8),
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

                  // Actions bar (visible unless cancelled)
                  if (!isCancelled) ...[
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildActionBtn(
                            label: 'Locate Room',
                            icon: Icons.map_outlined,
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Locating ${c['room']} on campus map...'),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          _buildActionBtn(
                            label: isLive ? 'Join Live Class' : 'Class Materials',
                            icon: isLive ? Icons.video_call_outlined : Icons.menu_book_outlined,
                            color: isLive ? AppColors.primary : null,
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isLive
                                      ? 'Launching Zoom Room for ${c['title']}...'
                                      : 'Opening lecture materials for ${c['title']}...'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildActionBtn({
    required String label,
    required IconData icon,
    Color? color,
    required VoidCallback onPressed,
  }) {
    final useColor = color ?? const Color(0xFF757575);
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: useColor, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: useColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

  // ── Upcoming Tasks ────────────────────────
  Widget _buildUpcomingTasks() {
    final tasks = [
      {'icon': Icons.assignment_outlined, 'color': const Color(0xFFFFA726), 'title': 'Maths Assignment', 'due': 'Due Tomorrow', 'urgent': true},
      {'icon': Icons.science_outlined, 'color': const Color(0xFF5C6BC0), 'title': 'Lab Report', 'due': 'Due 12 Jun, 2025', 'urgent': false},
      {'icon': Icons.quiz_outlined, 'color': const Color(0xFF26A69A), 'title': 'DBMS Quiz', 'due': 'Due 15 Jun, 2025', 'urgent': false},
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Upcoming Tasks', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF2D3142))),
              Text('See All', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          ...tasks.map((t) {
            final color = t['color'] as Color;
            final urgent = t['urgent'] as bool;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(t['icon'] as IconData, color: color, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t['title'] as String,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF2D3142)),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          t['due'] as String,
                          style: TextStyle(fontSize: 11, color: urgent ? Colors.red : const Color(0xFF9E9E9E)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Exams Card ────────────────────────────
  Widget _buildExamsCard() {
    final exams = [
      {'month': 'JUN', 'day': '15', 'title': 'Data Structures', 'type': 'Internal Exam', 'time': '10:00 AM – 12:00 PM'},
      {'month': 'JUN', 'day': '22', 'title': 'Operating Systems', 'type': 'Internal Exam', 'time': '10:00 AM – 12:00 PM'},
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Exams', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF2D3142))),
              Text('See All', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          ...exams.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF5350),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(e['day']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                      Text(e['month']!, style: const TextStyle(color: Colors.white70, fontSize: 9)),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e['title']!,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF2D3142)),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(e['type']!, style: const TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
                      Text(e['time']!, style: const TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // ── Announcements ─────────────────────────
  Widget _buildAnnouncements() {
    final items = [
      {
        'icon': Icons.campaign_rounded,
        'iconBg': const Color(0xFFE3F2FD),
        'iconColor': const Color(0xFF1E88E5),
        'title': 'End Semester Exam Date Out!',
        'subtitle': 'The exams will start from 15th June. Check timetable.',
        'time': '2h ago',
      },
      {
        'icon': Icons.local_library_rounded,
        'iconBg': const Color(0xFFE8F5E9),
        'iconColor': const Color(0xFF43A047),
        'title': 'New Library Timings',
        'subtitle': 'Library will be open till 10 PM from Monday.',
        'time': '5h ago',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          final iconBg = item['iconBg'] as Color;
          final iconColor = item['iconColor'] as Color;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
                      child: Icon(item['icon'] as IconData, color: iconColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] as String,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF2D3142)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['subtitle'] as String,
                            style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(item['time'] as String, style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 11)),
                  ],
                ),
              ),
              if (i < items.length - 1)
                const Divider(height: 1, indent: 14, endIndent: 14),
            ],
          );
        }).toList(),
      ),
    );
  }

class InteractiveTimetableScreen extends StatelessWidget {
  const InteractiveTimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF5F6FA),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: InteractiveTimetable(),
      ),
    );
  }
}
