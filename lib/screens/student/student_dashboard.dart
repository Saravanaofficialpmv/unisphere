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

// ─────────────────────────────────────────
//  Home Screen
// ─────────────────────────────────────────
class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

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
          _buildSectionHeader('Today\'s Classes', () {}),
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
        return Column(
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
          // Time column
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
          // Divider
          Container(width: 3, height: 44, decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 12),
          // Info
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
          // Icon
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
}
