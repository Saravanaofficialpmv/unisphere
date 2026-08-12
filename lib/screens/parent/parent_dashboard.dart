import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unisphere/core/constants/app_colors.dart';
import 'package:unisphere/widgets/common/notification_sheet.dart';
import 'package:unisphere/widgets/common/main_sidebar.dart';
import 'package:unisphere/screens/features/fees_screen.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<NavigatorState> _innerNavigatorKey = GlobalKey<NavigatorState>();

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

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      ParentHomeScreen(onNavigateToTab: _handleNavigation),
      ParentAttendanceDetailTab(onNavigateToTab: _handleNavigation),
      ParentAcademicPerformanceTab(onNavigateToTab: _handleNavigation),
      const Center(child: Text('Primary Institution Alerts')),
      const Center(child: Text('Account Profile Settings')),
      FeesScreen(onBack: () => _handleNavigation(0)),
      const Center(child: Text('School Transport Map')),
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
        backgroundColor: const Color(0xFFF8FAFC),
        drawer: isDesktop ? null : Drawer(child: _buildSidebar()),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
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
          title: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.family_restroom_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'PARENT PORTAL',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  letterSpacing: 1.1,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
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
      userName: 'Rajesh Kumar',
      userEmail: 'rajesh.kumar@parent.unisphere.edu',
    );
  }
}

class ParentHomeScreen extends StatefulWidget {
  final Function(int index)? onNavigateToTab;

  const ParentHomeScreen({super.key, this.onNavigateToTab});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  final List<StudentWard> _wards = [
    StudentWard(
      id: 'ward_1',
      name: 'Alex Johnson',
      regNo: 'RA2111003010245',
      department: 'Computer Science & Engg.',
      yearSection: '3rd Year • Sec B (Sem 5)',
      attendance: '88.5%',
      attendancePercent: 0.885,
      cgpa: '8.92',
      feesDue: '₹0 (Clear)',
      academicStatus: 'Good Standing',
      statusColor: AppColors.success,
      avatarInitials: 'AJ',
    ),
    StudentWard(
      id: 'ward_2',
      name: 'Sophia Johnson',
      regNo: 'RA2311004020112',
      department: 'Electronics & Comm. Engg.',
      yearSection: '1st Year • Sec A (Sem 1)',
      attendance: '94.0%',
      attendancePercent: 0.94,
      cgpa: '9.15',
      feesDue: '₹15,000 (Lab Fee)',
      academicStatus: 'Dean\'s Scholar',
      statusColor: const Color(0xFF7C3AED),
      avatarInitials: 'SJ',
    ),
  ];

  late StudentWard _selectedWard;

  @override
  void initState() {
    super.initState();
    _selectedWard = _wards[0];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Section
          _buildHeaderSection(context),

          const SizedBox(height: 20),

          // 2. Student Profile Card
          _buildStudentProfileCard(),

          const SizedBox(height: 24),

          // 3. Quick Stats (Attendance, CGPA, Fees Due, Academic Status)
          _buildQuickStatsSection(),

          const SizedBox(height: 24),

          // 4. Today's Attendance
          _buildTodaysAttendanceSection(),

          const SizedBox(height: 24),

          // 5. Academic Performance
          _buildAcademicPerformanceSection(),

          const SizedBox(height: 24),

          // 6. Fee Status
          _buildFeeStatusSection(context),

          const SizedBox(height: 24),

          // 7. Important Announcements
          _buildImportantAnnouncementsSection(),

          const SizedBox(height: 24),

          // 8. Faculty Communication
          _buildFacultyCommunicationSection(context),

          const SizedBox(height: 24),

          // 9. Achievements
          _buildAchievementsSection(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // 1. HEADER SECTION
  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D4ED8).withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // TOP ROYAL BLUE HEADER
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF1D4ED8),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 2),
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        child: Center(
                          child: Text(
                            'RK',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Rajesh Kumar',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Parent',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w400,
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
                const SizedBox(width: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeaderActionButton(
                      icon: Icons.search_rounded,
                      onTap: () {},
                    ),
                    const SizedBox(width: 6),
                    _buildHeaderActionButton(
                      icon: Icons.qr_code_scanner_rounded,
                      onTap: () {},
                    ),
                    const SizedBox(width: 6),
                    _buildHeaderActionButton(
                      icon: Icons.notifications_none_rounded,
                      badgeCount: 3,
                      onTap: () => showNotificationSheet(context),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // BOTTOM WHITE ACTIVE STUDENT SELECTOR CARD
          Material(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            child: InkWell(
              onTap: () => _showStudentSelectorSheet(context),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Student',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              Text(
                                _selectedWard.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Active',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF15803D),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textPrimary,
                      size: 24,
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

  Widget _buildHeaderActionButton({
    required IconData icon,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            if (badgeCount > 0)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                  child: Text(
                    '$badgeCount',
                    style: GoogleFonts.poppins(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showStudentSelectorSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
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
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Switch profile view to monitor another student ward',
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
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
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  subtitle: Text(
                    '${ward.department} • ${ward.yearSection}',
                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
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

  // 2. STUDENT PROFILE CARD SECTION
  Widget _buildStudentProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
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
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
                ),
                child: Center(
                  child: Text(
                    _selectedWard.avatarInitials,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
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
                          child: Text(
                            _selectedWard.name,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            _selectedWard.academicStatus,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Reg. No: ${_selectedWard.regNo}',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: Colors.white24),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildProfileMetaTile(
                  Icons.school_rounded,
                  'Department',
                  _selectedWard.department,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildProfileMetaTile(
                  Icons.calendar_today_rounded,
                  'Year / Section',
                  _selectedWard.yearSection,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMetaTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. QUICK STATS SECTION WITH INTERACTIVE CLICK HANDLERS
  Widget _buildQuickStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Quick Academic Stats'),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.5,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildStatCard(
              'Attendance',
              _selectedWard.attendance,
              'Minimum 80% required',
              Icons.pie_chart_outline_rounded,
              const Color(0xFF059669),
              const Color(0xFFD1FAE5),
              onTap: () {
                _showAttendanceDetailsDialog(context);
              },
            ),
            _buildStatCard(
              'CGPA',
              _selectedWard.cgpa,
              'Rank: #12 in Department',
              Icons.auto_graph_rounded,
              const Color(0xFF2563EB),
              const Color(0xFFEFF6FF),
              onTap: () {
                _showCgpaDetailsDialog(context);
              },
            ),
            _buildStatCard(
              'Fees Due',
              _selectedWard.feesDue,
              _selectedWard.feesDue.contains('0') ? 'All clear' : 'Pay by Aug 25',
              Icons.account_balance_wallet_outlined,
              _selectedWard.feesDue.contains('0') ? const Color(0xFF10B981) : const Color(0xFFEA580C),
              _selectedWard.feesDue.contains('0') ? const Color(0xFFD1FAE5) : const Color(0xFFFFEDD5),
              onTap: () {
                _showFeeDetailsDialog(context);
              },
            ),
            _buildStatCard(
              'Academic Status',
              _selectedWard.academicStatus,
              'Semester 5 Registered',
              Icons.verified_user_outlined,
              _selectedWard.statusColor,
              _selectedWard.statusColor.withValues(alpha: 0.12),
              onTap: () {
                _showAcademicStatusDialog(context);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    String subtitle,
    IconData icon,
    Color color,
    Color bgColor, {
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          subtitle,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: AppColors.textTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.textTertiary),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 1. ATTENDANCE DETAILS DIALOG (MATCHING SCREENSHOT UI)
  void _showAttendanceDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AttendanceOverviewDialog(
        studentName: _selectedWard.name,
        registerNum: _selectedWard.regNo,
        onNavigateToTab: widget.onNavigateToTab,
      ),
    );
  }

  // 2. CGPA DETAILS DIALOG (MATCHING SCREENSHOT RICH UI)
  void _showCgpaDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => CgpaAnalyticsDialog(
        studentName: _selectedWard.name,
        registerNum: _selectedWard.regNo,
        onNavigateToTab: widget.onNavigateToTab,
      ),
    );
  }

  // 3. FEE DETAILS DIALOG MATCHING IMAGE 2 DESIGN
  void _showFeeDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => FeeDetailsDialog(
        studentName: _selectedWard.name,
        registerNum: _selectedWard.regNo,
        onNavigateToTab: widget.onNavigateToTab,
      ),
    );
  }

  // 4. ACADEMIC STATUS DIALOG
  void _showAcademicStatusDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AcademicStandingDialog(
        studentName: _selectedWard.name,
        registerNum: _selectedWard.regNo,
        onNavigateToTab: widget.onNavigateToTab,
        academicStatus: _selectedWard.academicStatus,
      ),
    );
  }

  // 4. TODAY'S ATTENDANCE SECTION
  Widget _buildTodaysAttendanceSection() {
    final List<Map<String, String>> todaysClasses = [
      {'code': 'CS301', 'name': 'Data Structures', 'time': '09:00 AM - 10:00 AM', 'status': 'Present', 'room': 'LH-201'},
      {'code': 'CS302', 'name': 'Operating Systems', 'time': '10:00 AM - 11:00 AM', 'status': 'Present', 'room': 'LH-202'},
      {'code': 'CS303', 'name': 'Database Systems', 'time': '11:15 AM - 12:15 PM', 'status': 'Present', 'room': 'Lab 4'},
      {'code': 'MA301', 'name': 'Discrete Mathematics', 'time': '01:30 PM - 02:30 PM', 'status': 'Present', 'room': 'LH-104'},
      {'code': 'CS304', 'name': 'Web Tech Workshop', 'time': '02:30 PM - 03:30 PM', 'status': 'Upcoming', 'room': 'Auditorium'},
    ];

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
              _buildSectionTitle('Today\'s Attendance'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '4/4 Attended',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: todaysClasses.length,
            separatorBuilder: (context, index) => const Divider(height: 16, color: AppColors.divider),
            itemBuilder: (context, index) {
              final c = todaysClasses[index];
              final isPresent = c['status'] == 'Present';
              return Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isPresent ? const Color(0xFFD1FAE5) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isPresent ? Icons.check_circle_rounded : Icons.schedule_rounded,
                      color: isPresent ? const Color(0xFF059669) : AppColors.textTertiary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${c['code']} • ${c['name']}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${c['time']}  (${c['room']})',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPresent ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      c['status']!,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isPresent ? const Color(0xFF059669) : const Color(0xFFD97706),
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

  // 5. ACADEMIC PERFORMANCE SECTION
  Widget _buildAcademicPerformanceSection() {
    final List<Map<String, dynamic>> subjects = [
      {'name': 'Data Structures & Algorithms', 'score': '92%', 'grade': 'O', 'percent': 0.92, 'color': AppColors.primary},
      {'name': 'Operating Systems', 'score': '86%', 'grade': 'A+', 'percent': 0.86, 'color': const Color(0xFF059669)},
      {'name': 'Database Management Systems', 'score': '88%', 'grade': 'A+', 'percent': 0.88, 'color': const Color(0xFF7C3AED)},
      {'name': 'Discrete Mathematics', 'score': '84%', 'grade': 'A', 'percent': 0.84, 'color': const Color(0xFFEA580C)},
    ];

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
              _buildSectionTitle('Academic Performance'),
              TextButton(
                onPressed: () {
                  if (widget.onNavigateToTab != null) {
                    widget.onNavigateToTab!(2);
                  }
                },
                child: Text(
                  'Full Breakdown',
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: subjects.map((sub) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          sub['name'],
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${sub['score']} (${sub['grade']})',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: sub['color'],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    AppLinearProgressBar(
                      lineHeight: 7.0,
                      percent: sub['percent'],
                      backgroundColor: const Color(0xFFF1F5F9),
                      progressColor: sub['color'],
                      borderRadius: 4.0,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 6. FEE STATUS SECTION
  Widget _buildFeeStatusSection(BuildContext context) {
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
              _buildSectionTitle('Fee Payment Status'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'PAID & VERIFIED',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildFeeItem('Total Tuition Fee', '₹1,25,000', Colors.black87),
              ),
              Expanded(
                child: _buildFeeItem('Hostel & Mess', '₹45,000', Colors.black87),
              ),
              Expanded(
                child: _buildFeeItem('Pending Due', _selectedWard.feesDue, AppColors.success),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _showFeeDetailsDialog(context);
              },
              icon: const Icon(Icons.receipt_long_rounded, size: 18),
              label: Text(
                'View Detailed Fee Structure & E-Receipts',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeItem(String title, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // 7. IMPORTANT ANNOUNCEMENTS SECTION
  Widget _buildImportantAnnouncementsSection() {
    final List<Map<String, String>> announcements = [
      {
        'title': 'Parent-Teacher Conference 2026',
        'desc': 'Interactive session on Semester 5 progress and placement roadmap.',
        'date': 'Aug 23, 2026 • 10:00 AM',
        'tag': 'IMPORTANT',
        'color': '0xFF7C3AED',
      },
      {
        'title': 'Mid-Semester Exam Timetable Released',
        'desc': 'Autumn mid-term exams begin Sept 5, 2026. Hall tickets available.',
        'date': 'Aug 18, 2026',
        'tag': 'ACADEMIC',
        'color': '0xFF2563EB',
      },
      {
        'title': 'Campus Hostel Outing Pass Rule',
        'desc': 'Parent online consent mandatory for weekend outings via portal.',
        'date': 'Aug 15, 2026',
        'tag': 'POLICY',
        'color': '0xFFEA580C',
      },
    ];

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
          _buildSectionTitle('Important Announcements'),
          const SizedBox(height: 14),
          Column(
            children: announcements.map((ann) {
              final color = Color(int.parse(ann['color']!));
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.campaign_rounded, color: color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  ann['tag']!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                ann['date']!,
                                style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textTertiary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ann['title']!,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            ann['desc']!,
                            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 8. FACULTY COMMUNICATION SECTION
  Widget _buildFacultyCommunicationSection(BuildContext context) {
    final List<Map<String, String>> facultyList = [
      {
        'name': 'Dr. Rajesh Sharma',
        'role': 'Class Counselor & Sr. Professor',
        'dept': 'Dept of Computer Science',
        'phone': '+91 98401 23456',
        'email': 'rajesh.s@srmist.edu.in',
      },
      {
        'name': 'Dr. Anita Sundaram',
        'role': 'Head of Department (HOD)',
        'dept': 'Dept of Computer Science',
        'phone': '+91 98402 34567',
        'email': 'hod.cse@srmist.edu.in',
      },
    ];

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
          _buildSectionTitle('Faculty & Counselor Contacts'),
          const SizedBox(height: 14),
          Column(
            children: facultyList.map((f) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            f['name']!,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${f['role']} • ${f['dept']}',
                            style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Call Counselor',
                      icon: const Icon(Icons.phone_rounded, color: AppColors.primary, size: 20),
                      onPressed: () {},
                    ),
                    IconButton(
                      tooltip: 'Send Email',
                      icon: const Icon(Icons.email_rounded, color: AppColors.primary, size: 20),
                      onPressed: () {},
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 9. ACHIEVEMENTS SECTION
  Widget _buildAchievementsSection() {
    final List<Map<String, String>> achievements = [
      {
        'title': '1st Prize - SRM Tech Fest Hackathon 2026',
        'category': 'National Competition',
        'date': 'July 2026',
        'icon': 'trophy',
      },
      {
        'title': 'Dean\'s Honor Roll (SGPA >= 9.0)',
        'category': 'Academic Merit',
        'date': 'Semester 4',
        'icon': 'badge',
      },
      {
        'title': 'AWS Certified Cloud Practitioner',
        'category': 'Industry Certification',
        'date': 'June 2026',
        'icon': 'certificate',
      },
    ];

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
          _buildSectionTitle('Child\'s Achievements & Badges'),
          const SizedBox(height: 14),
          Column(
            children: achievements.map((ach) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD97706),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ach['title']!,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${ach['category']} • ${ach['date']}',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: const Color(0xFFB45309),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.workspace_premium_rounded, color: Color(0xFFD97706), size: 22),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
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
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
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
                  center: Text('88.5%', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
                  progressColor: Colors.white,
                  backgroundColor: Colors.white24,
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('OVERALL ATTENDANCE', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.bold)),
                      Text('Alex Johnson • B.Tech CSE', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text('131 / 147 Total Classes Attended (8.5% above cutoff)', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withValues(alpha: 0.9))),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Text('Subject-wise Attendance', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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
                          child: Text('${s['code']} - ${s['name']}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(s['status'], style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF059669))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${s['attended']} attended out of ${s['total']} classes', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                        Text('${(p * 100).toStringAsFixed(1)}%', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF059669))),
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
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
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
                    Text('CUMULATIVE GRADE POINT AVERAGE', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.bold)),
                    Text('8.92', style: GoogleFonts.poppins(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white)),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(14)),
                      child: Text('Rank: #12 in Dept', style: GoogleFonts.poppins(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 6),
                    Text('48 / 160 Credits Earned', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Text('Semester Grades & SGPA Summary', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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
              Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
              Text('SGPA: $sgpa', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary)),
            ],
          ),
          const Divider(height: 20),
          ...subs.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(s['subject']!, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                    Text('${s['marks']} (${s['grade']})', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
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
            Text(val, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
            Text(label, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 9, color: const Color(0xFF64748B))),
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
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      faculty,
                      style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B)),
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
                      Text(ratio, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF2563EB))),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
                        child: Text(percentStr, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF2563EB))),
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
                      Text(status, style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B))),
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
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                        ),
                        Text(
                          '$studentName ($registerNum)',
                          style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF64748B)),
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
                                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF15803D)),
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
                                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF2563EB)),
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
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 18, color: const Color(0xFF0F172A)),
                          ),
                          Text(
                            'Overall\nAttendance',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(fontSize: 9, color: const Color(0xFF64748B), height: 1.1),
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
                                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF15803D)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'You\'re maintaining excellent attendance!',
                            style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B)),
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
                        style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF3730A3), fontWeight: FontWeight.w500),
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
                      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
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
                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
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
                                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF6D28D9)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'You\'re doing great! Your attendance is above the required 80% threshold.',
                                style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF7C3AED), height: 1.2),
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
                            center: Text('88.5%', style: GoogleFonts.poppins(fontSize: 8, fontWeight: FontWeight.bold, color: const Color(0xFF6D28D9))),
                            progressColor: const Color(0xFF7C3AED),
                            backgroundColor: const Color(0xFFDDD6FE),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Target Goal: 90%', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF6D28D9))),
                                Text('Attend 16 more classes to reach 90% target', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF7C3AED))),
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
                      label: Text('Download Report', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
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
                        label: Text('Open Complete Attendance Log', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11)),
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
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                        ),
                        Text(
                          '$studentName ($registerNum)',
                          style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF64748B)),
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
                                  const Icon(Icons.emoji_events_rounded, color: Color(0xFF15803D), size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Top 10% Rank',
                                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF15803D)),
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
                                  const Icon(Icons.school_rounded, color: Color(0xFF2563EB), size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Semester 5 Active',
                                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF2563EB)),
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
                            '8.92',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 20, color: const Color(0xFF0F172A)),
                          ),
                          Text(
                            'Overall\nCGPA',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(fontSize: 9, color: const Color(0xFF64748B), height: 1.1),
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
                                  'EXCELLENT • CLASS FIRST',
                                  style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF15803D)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Consistently maintaining Grade A+ & O across technical courses.',
                            style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 12),
                          const Row(
                            children: [
                              MiniStatCard(
                                icon: Icons.emoji_events_rounded,
                                iconBg: Color(0xFFFEF3C7),
                                iconColor: Color(0xFFD97706),
                                val: '#12',
                                label: 'Dept Rank',
                              ),
                              SizedBox(width: 8),
                              MiniStatCard(
                                icon: Icons.school_rounded,
                                iconBg: Color(0xFFEFF6FF),
                                iconColor: Color(0xFF2563EB),
                                val: '48',
                                label: 'Earned Credits',
                              ),
                              SizedBox(width: 8),
                              MiniStatCard(
                                icon: Icons.trending_up_rounded,
                                iconBg: Color(0xFFDCFCE7),
                                iconColor: Color(0xFF15803D),
                                val: '9.12',
                                label: 'Sem 4 SGPA',
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

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE9D5FF)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFDDD6FE),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.card_giftcard_rounded, color: Color(0xFF7C3AED), size: 16),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Outstanding performance! CGPA >= 8.50 qualifies for Institutional Merit Scholarship.',
                        style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF6D28D9), fontWeight: FontWeight.w500),
                      ),
                    ),
                    const Icon(Icons.close_rounded, color: Color(0xFF8B5CF6), size: 16),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Semester 5 Internal Marks',
                      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
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
                          'Sort by: Score',
                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF475569)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              const AttendanceSubjectCard(
                icon: Icons.code_rounded,
                iconBg: Color(0xFFEFF6FF),
                iconColor: Color(0xFF2563EB),
                code: 'CS301',
                name: 'Data Structures & Algo',
                faculty: 'Mr. David Williams',
                ratio: '92 / 100',
                percentStr: 'Grade O',
                status: 'Outstanding',
                statusColor: Color(0xFF2563EB),
                progress: 0.92,
                barColor: Color(0xFF2563EB),
              ),
              const AttendanceSubjectCard(
                icon: Icons.desktop_windows_rounded,
                iconBg: Color(0xFFDCFCE7),
                iconColor: Color(0xFF166534),
                code: 'CS302',
                name: 'Operating Systems',
                faculty: 'Dr. Sarah Thompson',
                ratio: '86 / 100',
                percentStr: 'Grade A+',
                status: 'Excellent',
                statusColor: Color(0xFF15803D),
                progress: 0.86,
                barColor: Color(0xFF059669),
              ),
              const AttendanceSubjectCard(
                icon: Icons.dns_rounded,
                iconBg: Color(0xFFF3E8FF),
                iconColor: Color(0xFF7C3AED),
                code: 'CS303',
                name: 'Database Management',
                faculty: 'Mr. James Anderson',
                ratio: '88 / 100',
                percentStr: 'Grade A+',
                status: 'Excellent',
                statusColor: Color(0xFF7C3AED),
                progress: 0.88,
                barColor: Color(0xFF7C3AED),
              ),
              const AttendanceSubjectCard(
                icon: Icons.calculate_rounded,
                iconBg: Color(0xFFFFEDD5),
                iconColor: Color(0xFFC2410C),
                code: 'MA301',
                name: 'Discrete Mathematics',
                faculty: 'Dr. Lisa Brown',
                ratio: '84 / 100',
                percentStr: 'Grade A',
                status: 'Good',
                statusColor: Color(0xFFEA580C),
                progress: 0.84,
                barColor: Color(0xFFEA580C),
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.military_tech_rounded, color: Color(0xFF2563EB), size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Target 9.0+ CGPA Milestone',
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E40AF)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Maintaining current 9.12 SGPA pace will comfortably elevate cumulative CGPA past 9.00 threshold.',
                            style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF1D4ED8), height: 1.2),
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
                      label: Text('Download Marksheet', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
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
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          if (onNavigateToTab != null) {
                            onNavigateToTab!(2);
                          }
                        },
                        icon: const Icon(Icons.bar_chart_rounded, size: 18),
                        label: Text('Open Full Grade History', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 11)),
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

class FeeDetailsDialog extends StatelessWidget {
  final String studentName;
  final String registerNum;
  final Function(int)? onNavigateToTab;

  const FeeDetailsDialog({
    super.key,
    required this.studentName,
    required this.registerNum,
    this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 500),
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
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF15803D), size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Fee Structure & Payments',
                                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '$studentName • Academic Year 2025 – 2026',
                                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
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

              _buildFeeRow(
                icon: Icons.domain_rounded,
                bgColor: const Color(0xFFE0F2FE),
                iconColor: const Color(0xFF0369A1),
                title: 'Tuition & Academic Facility Fee',
                desc: 'Smart classrooms, high-speed Wi-Fi, campus amenities & security',
                amount: '₹75,000',
              ),
              _buildFeeRow(
                icon: Icons.developer_board_rounded,
                bgColor: const Color(0xFFF3E8FF),
                iconColor: const Color(0xFF7C3AED),
                title: 'Special Lab & Cloud Computing',
                desc: 'Advanced AI/ML Lab, AWS/GCP cloud credits & hardware kits',
                amount: '₹12,000',
              ),
              _buildFeeRow(
                icon: Icons.assignment_turned_in_rounded,
                bgColor: const Color(0xFFD1FAE5),
                iconColor: const Color(0xFF059669),
                title: 'Examination & Controller Fee',
                desc: 'Mid-term and end-sem exam valuation, hall tickets & grade sheets',
                amount: '₹8,000',
              ),
              _buildFeeRow(
                icon: Icons.local_library_rounded,
                bgColor: const Color(0xFFFEF3C7),
                iconColor: const Color(0xFFD97706),
                title: 'Library & Digital IEEE Resources',
                desc: 'Access to physical library, IEEE Xplore digital journals & e-books',
                amount: '₹5,000',
              ),
              _buildFeeRow(
                icon: Icons.sports_basketball_rounded,
                bgColor: const Color(0xFFFFEDD5),
                iconColor: const Color(0xFFEA580C),
                title: 'Sports & Campus Life Activity',
                desc: 'Sports complex access, annual tech fest & student club activities',
                amount: '₹5,000',
              ),
              _buildFeeRow(
                icon: Icons.card_giftcard_rounded,
                bgColor: const Color(0xFFDCFCE7),
                iconColor: const Color(0xFF166534),
                title: 'Merit Scholarship Concession',
                desc: 'Institutional Merit Scholarship (CGPA >= 8.50 Reward Discount)',
                amount: '- ₹15,000',
                badgeText: 'REWARD',
                isDiscount: true,
              ),

              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'NET TOTAL ANNUAL FEE',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      '₹1,10,000',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Semester Installment Schedule',
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.calendar_month_rounded, color: Color(0xFF059669), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Semester 5 Fee Installment',
                            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          Text(
                            'Paid on 15 Jun 2025',
                            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹62,500',
                          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'PAID',
                            style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF059669)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (onNavigateToTab != null) {
                      onNavigateToTab!(5);
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const FeesScreen()),
                      );
                    }
                  },
                  icon: const Icon(Icons.receipt_long_rounded, size: 18),
                  label: Text(
                    'Open Full Fee Structure & E-Receipts',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeeRow({
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required String title,
    required String desc,
    required String amount,
    String? badgeText,
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ),
                    if (badgeText != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          badgeText,
                          style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF166534)),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            amount,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDiscount ? const Color(0xFF166534) : AppColors.textPrimary,
            ),
          ),
        ],
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
                                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                studentName,
                                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
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
                  child: Text('Close Academic Profile', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
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
                  style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  val,
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: valColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

