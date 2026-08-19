import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:unisphere/widgets/common/unisphere_header_card.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:unisphere/controllers/hackathon_banner_controller.dart';
import 'package:unisphere/controllers/hackathon_banner_state.dart';
import 'package:intl/intl.dart';
import 'package:unisphere/services/auth_service.dart';
import 'package:unisphere/models/hackathon_registration_model.dart';
import 'package:unisphere/controllers/hackathon_registration_controller.dart';
import 'package:unisphere/screens/features/hackathon_details_screen.dart';

class RegisteredStudentItem {
  final int index;
  final String name;
  final String registerNo;
  final String branch;
  final String year;
  final String registeredOn;
  final String status; // 'Verified', 'Pending', 'Cancelled'
  final String avatarUrl;

  RegisteredStudentItem({
    required this.index,
    required this.name,
    required this.registerNo,
    required this.branch,
    required this.year,
    required this.registeredOn,
    required this.status,
    required this.avatarUrl,
  });
}

class HackathonsScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;
  const HackathonsScreen({super.key, this.onBack});

  @override
  ConsumerState<HackathonsScreen> createState() => _HackathonsScreenState();
}

class _HackathonsScreenState extends ConsumerState<HackathonsScreen> {
  // State for search and pagination
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatusFilter = 'All'; // 'All', 'Verified', 'Pending'
  int _currentPage = 1;
  final int _rowsPerPage = 8;

  // Countdown timer state
  late Timer _countdownTimer;
  Duration _remainingDuration = const Duration(days: 4, hours: 12, minutes: 45, seconds: 30);

  // Sample student registrations dataset matching Image 1
  late List<RegisteredStudentItem> _allStudents;

  @override
  void initState() {
    super.initState();
    _initStudentData();
    _startCountdownTimer();
  }

  void _initStudentData() {
    final List<Map<String, dynamic>> rawData = [
      {'name': 'Tharanikumar K', 'reg': '22BCE1234', 'branch': 'CSE', 'year': '3rd Year', 'date': 'May 18, 2026 10:30 AM', 'status': 'Verified'},
      {'name': 'Harini S', 'reg': '22ECE0987', 'branch': 'ECE', 'year': '3rd Year', 'date': 'May 18, 2026 10:32 AM', 'status': 'Verified'},
      {'name': 'Kavin Raj', 'reg': '22ME0567', 'branch': 'MECH', 'year': '3rd Year', 'date': 'May 18, 2026 10:35 AM', 'status': 'Verified'},
      {'name': 'Yogeshwaran P', 'reg': '22IT0421', 'branch': 'IT', 'year': '2nd Year', 'date': 'May 18, 2026 10:37 AM', 'status': 'Verified'},
      {'name': 'Monisha R', 'reg': '23CSE1122', 'branch': 'CSE', 'year': '2nd Year', 'date': 'May 18, 2026 10:40 AM', 'status': 'Verified'},
      {'name': 'Pranav V', 'reg': '23ECE1188', 'branch': 'ECE', 'year': '2nd Year', 'date': 'May 18, 2026 10:42 AM', 'status': 'Pending'},
      {'name': 'Sanjay K', 'reg': '23ME0677', 'branch': 'MECH', 'year': '2nd Year', 'date': 'May 18, 2026 10:45 AM', 'status': 'Verified'},
      {'name': 'Nandhini M', 'reg': '23IT0911', 'branch': 'IT', 'year': '2nd Year', 'date': 'May 18, 2026 10:48 AM', 'status': 'Pending'},
      // Additional entries to support multi-page pagination up to 142
      {'name': 'Arun Prakash G', 'reg': '22BCE1402', 'branch': 'CSE', 'year': '3rd Year', 'date': 'May 18, 2026 10:50 AM', 'status': 'Verified'},
      {'name': 'Deepika R', 'reg': '22ECE0514', 'branch': 'ECE', 'year': '3rd Year', 'date': 'May 18, 2026 10:52 AM', 'status': 'Verified'},
      {'name': 'Gokulnath S', 'reg': '23ME0819', 'branch': 'MECH', 'year': '2nd Year', 'date': 'May 18, 2026 10:55 AM', 'status': 'Verified'},
      {'name': 'Kavya Dharshini B', 'reg': '23IT0299', 'branch': 'IT', 'year': '2nd Year', 'date': 'May 18, 2026 10:58 AM', 'status': 'Pending'},
      {'name': 'Manoj Kumar V', 'reg': '22CSE1090', 'branch': 'CSE', 'year': '3rd Year', 'date': 'May 18, 2026 11:02 AM', 'status': 'Verified'},
      {'name': 'Nivedha P', 'reg': '22ECE0774', 'branch': 'ECE', 'year': '3rd Year', 'date': 'May 18, 2026 11:05 AM', 'status': 'Verified'},
      {'name': 'Praveen Raj M', 'reg': '23ME0341', 'branch': 'MECH', 'year': '2nd Year', 'date': 'May 18, 2026 11:10 AM', 'status': 'Verified'},
      {'name': 'Rohit Sharma S', 'reg': '23IT0612', 'branch': 'IT', 'year': '2nd Year', 'date': 'May 18, 2026 11:15 AM', 'status': 'Pending'},
    ];

    // Generate full list of 142 synthetic items for complete data table feel
    List<RegisteredStudentItem> list = [];
    int totalCount = 142;
    for (int i = 0; i < totalCount; i++) {
      final base = rawData[i % rawData.length];
      final isVerified = i < 138;
      list.add(
        RegisteredStudentItem(
          index: i + 1,
          name: i < rawData.length ? base['name'] : '${base['name']} ${(i ~/ rawData.length) + 1}',
          registerNo: i < rawData.length ? base['reg'] : '${base['reg'].substring(0, 5)}${1000 + i}',
          branch: base['branch'],
          year: base['year'],
          registeredOn: base['date'],
          status: isVerified ? 'Verified' : 'Pending',
          avatarUrl: 'https://i.pravatar.cc/150?img=${(i % 70) + 1}',
        ),
      );
    }
    _allStudents = list;
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingDuration.inSeconds > 0) {
        setState(() {
          _remainingDuration = _remainingDuration - const Duration(seconds: 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _navigateBackToFeatureHub(BuildContext context) {
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go('/student');
    }
  }

  List<RegisteredStudentItem> get _filteredStudents {
    return _allStudents.where((student) {
      final matchesSearch = student.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          student.registerNo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          student.branch.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _selectedStatusFilter == 'All' || student.status == _selectedStatusFilter;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bannerState = ref.watch(hackathonBannerControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            UnisphereHeaderCard(
              title: 'Hackathon Dashboard',
              subtitle: 'Live Challenges, Registrations & Leaderboard',
              onBack: () => _navigateBackToFeatureHub(context),
              rightActions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  tooltip: 'Refresh Banner',
                  onPressed: () {
                    ref.read(hackathonBannerControllerProvider.notifier).refresh();
                  },
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            // 1. TOP EVENT BANNER CARD
            _buildTopHeroBannerCard(context, bannerState),
            const SizedBox(height: 20),

            // 2. TOP METRICS STATS CARDS (5 Cards Row / Grid)
            _buildMetricsOverviewCards(),
            const SizedBox(height: 24),

            // 3. MAIN DASHBOARD CONTENT (Two Column Layout for Desktop/Tablet, Single Column for Mobile)
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 992) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column: Registered Students Table
                      Expanded(
                        flex: 7,
                        child: _buildRegisteredStudentsCard(),
                      ),
                      const SizedBox(width: 20),
                      // Right Column: My Registered Hackathons & Analytics
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                            _buildMyRegisteredHackathonsSection(),
                            const SizedBox(height: 20),
                            _buildRegistrationsOverviewWidget(),
                            const SizedBox(height: 20),
                            _buildRegistrationsOverTimeWidget(),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildMyRegisteredHackathonsSection(),
                      const SizedBox(height: 20),
                      _buildRegisteredStudentsCard(),
                      const SizedBox(height: 20),
                      _buildRegistrationsOverviewWidget(),
                      const SizedBox(height: 20),
                      _buildRegistrationsOverTimeWidget(),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    ),
  ],
),
),
);
}

  // ───────────────────────────────────────────────────────────────────────────
  // 1. HERO EVENT BANNER CARD
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildTopHeroBannerCard(BuildContext context, HackathonBannerState bannerState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 768;
          return Column(
            children: [
              Row(
                crossAxisAlignment: isCompact ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                children: [
                  // Left Poster Graphic Card
                  Container(
                    width: isCompact ? 100 : 160,
                    height: isCompact ? 100 : 110,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF4C1D95)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4C1D95).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF6D28D9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.code_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'AI & INNOVATION',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Text(
                          'HACKATHON 2026',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFA5B4FC),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Right Event Metadata & Action Button
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Flexible(
                              child: Text(
                                'AI & Innovation Hackathon 2026',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Registration Open',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF16A34A),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Detail Metadata Badges Row
                        Wrap(
                          spacing: 16,
                          runSpacing: 10,
                          children: [
                            _buildBannerMetaItem(Icons.calendar_today_rounded, 'Date', 'Aug 22 - 23, 2026'),
                            _buildBannerMetaItem(Icons.location_on_outlined, 'Venue', 'Innovation Lab'),
                            _buildBannerMetaItem(Icons.groups_outlined, 'Team Size', '2 - 4 Members'),
                            _buildBannerMetaItem(Icons.emoji_events_outlined, 'Prize Pool', '₹50,000'),
                            _buildBannerMetaItem(Icons.access_time_rounded, 'Duration', '24 Hours'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (!isCompact) ...[
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () => _showHackathonDetailsModal(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      child: const Text('View Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                ],
              ),
              if (isCompact) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showHackathonDetailsModal(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('View Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildBannerMetaItem(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF6366F1)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          ],
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 2. METRICS OVERVIEW CARDS (5 Cards)
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildMetricsOverviewCards() {
    final currentUser = ref.watch(authServiceProvider).currentUser;
    final studentId = currentUser?.uid ?? 'STU-2026-042';
    final notifier = ref.read(hackathonRegistrationProvider.notifier);
    ref.watch(hackathonRegistrationProvider);
    final userRegs = notifier.getStudentRegistrations(studentId);

    final totalRegistered = userRegs.length;
    final ongoingCount = userRegs.where((r) => r.isOngoing).length;
    final pendingCount = userRegs.where((r) => r.isPending).length;
    final completedCount = userRegs.where((r) => r.isCompleted).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 640;
        if (isMobile) {
          return GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.25,
            children: [
              _buildSummaryStatCard(
                title: 'Total Registered',
                count: totalRegistered,
                icon: Icons.emoji_events_rounded,
                accentColor: const Color(0xFF4F46E5),
                bgColor: const Color(0xFFEEF2FF),
              ),
              _buildSummaryStatCard(
                title: 'Ongoing',
                count: ongoingCount,
                icon: Icons.play_circle_fill_rounded,
                accentColor: const Color(0xFF10B981),
                bgColor: const Color(0xFFECFDF5),
                badgeDot: Colors.green,
              ),
              _buildSummaryStatCard(
                title: 'Pending',
                count: pendingCount,
                icon: Icons.pending_actions_rounded,
                accentColor: const Color(0xFFF59E0B),
                bgColor: const Color(0xFFFFFBEB),
                badgeDot: Colors.amber,
              ),
              _buildSummaryStatCard(
                title: 'Completed',
                count: completedCount,
                icon: Icons.check_circle_rounded,
                accentColor: const Color(0xFF3B82F6),
                bgColor: const Color(0xFFEFF6FF),
                badgeDot: Colors.blue,
              ),
            ],
          );
        }
        return Row(
          children: [
            Expanded(
              child: _buildSummaryStatCard(
                title: 'Total Registered',
                count: totalRegistered,
                icon: Icons.emoji_events_rounded,
                accentColor: const Color(0xFF4F46E5),
                bgColor: const Color(0xFFEEF2FF),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryStatCard(
                title: 'Ongoing',
                count: ongoingCount,
                icon: Icons.play_circle_fill_rounded,
                accentColor: const Color(0xFF10B981),
                bgColor: const Color(0xFFECFDF5),
                badgeDot: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryStatCard(
                title: 'Pending',
                count: pendingCount,
                icon: Icons.pending_actions_rounded,
                accentColor: const Color(0xFFF59E0B),
                bgColor: const Color(0xFFFFFBEB),
                badgeDot: Colors.amber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryStatCard(
                title: 'Completed',
                count: completedCount,
                icon: Icons.check_circle_rounded,
                accentColor: const Color(0xFF3B82F6),
                bgColor: const Color(0xFFEFF6FF),
                badgeDot: Colors.blue,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryStatCard({
    required String title,
    required int count,
    required IconData icon,
    required Color accentColor,
    required Color bgColor,
    Color? badgeDot,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              if (badgeDot != null)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: badgeDot,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                height: 1.0,
              ),
            ),
          ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }



  // ───────────────────────────────────────────────────────────────────────────
  // 3. REGISTERED STUDENTS DATA TABLE (Left Column)
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildRegisteredStudentsCard() {
    final filteredList = _filteredStudents;
    final totalEntries = filteredList.length;
    final totalPages = (totalEntries / _rowsPerPage).ceil().clamp(1, 999);

    final currentPageSafe = _currentPage.clamp(1, totalPages);
    final startIndex = (currentPageSafe - 1) * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage).clamp(0, totalEntries);
    final currentRows = filteredList.sublist(startIndex, endIndex);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Search / Filter Row
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 540) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Registered Students',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 38,
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) {
                                setState(() {
                                  _searchQuery = val;
                                  _currentPage = 1;
                                });
                              },
                              style: const TextStyle(fontSize: 12),
                              decoration: InputDecoration(
                                hintText: 'Search student...',
                                hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                prefixIcon: const Icon(Icons.search_rounded, size: 16, color: Color(0xFF94A3B8)),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          initialValue: _selectedStatusFilter,
                          onSelected: (val) {
                            setState(() {
                              _selectedStatusFilter = val;
                              _currentPage = 1;
                            });
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(value: 'All', child: Text('All Statuses', style: TextStyle(fontSize: 12))),
                            PopupMenuItem(value: 'Verified', child: Text('Verified Only', style: TextStyle(fontSize: 12))),
                            PopupMenuItem(value: 'Pending', child: Text('Pending Only', style: TextStyle(fontSize: 12))),
                          ],
                          child: Container(
                            height: 38,
                            width: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: const Icon(Icons.filter_alt_outlined, size: 18, color: Color(0xFF64748B)),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  const Text(
                    'Registered Students',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 240,
                    height: 38,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                          _currentPage = 1;
                        });
                      },
                      style: const TextStyle(fontSize: 12),
                      decoration: InputDecoration(
                        hintText: 'Search student name or email...',
                        hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                        prefixIcon: const Icon(Icons.search_rounded, size: 16, color: Color(0xFF94A3B8)),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    initialValue: _selectedStatusFilter,
                    onSelected: (val) {
                      setState(() {
                        _selectedStatusFilter = val;
                        _currentPage = 1;
                      });
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'All', child: Text('All Statuses', style: TextStyle(fontSize: 12))),
                      PopupMenuItem(value: 'Verified', child: Text('Verified Only', style: TextStyle(fontSize: 12))),
                      PopupMenuItem(value: 'Pending', child: Text('Pending Only', style: TextStyle(fontSize: 12))),
                    ],
                    child: Container(
                      height: 38,
                      width: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Icon(Icons.filter_alt_outlined, size: 18, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Data Table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 18,
              horizontalMargin: 8,
              headingRowHeight: 40,
              dataRowMaxHeight: 52,
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              columns: const [
                DataColumn(label: Text('#', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                DataColumn(label: Text('Student Name', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                DataColumn(label: Text('Register No.', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                DataColumn(label: Text('Branch', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                DataColumn(label: Text('Year', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                DataColumn(label: Text('Registered On', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
                DataColumn(label: Text('Status', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)))),
              ],
              rows: currentRows.map((student) {
                final isVerified = student.status == 'Verified';
                return DataRow(
                  cells: [
                    DataCell(Text('${student.index}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)))),
                    DataCell(
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: const Color(0xFFEEF2FF),
                            child: Text(
                              student.name.isNotEmpty ? student.name[0] : 'S',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(student.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                        ],
                      ),
                    ),
                    DataCell(Text(student.registerNo, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF334155)))),
                    DataCell(Text(student.branch, style: const TextStyle(fontSize: 12, color: Color(0xFF475569)))),
                    DataCell(Text(student.year, style: const TextStyle(fontSize: 12, color: Color(0xFF475569)))),
                    DataCell(Text(student.registeredOn, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)))),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isVerified ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          student.status,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isVerified ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Pagination Footer Row
          LayoutBuilder(
            builder: (context, constraints) {
              final pageButtonsWidget = SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded, size: 18),
                      onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
                    ),
                    for (int i = 1; i <= math.min(totalPages, 3); i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: InkWell(
                          onTap: () => setState(() => _currentPage = i),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _currentPage == i ? const Color(0xFF6366F1) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '$i',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _currentPage == i ? Colors.white : const Color(0xFF475569),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (totalPages > 3) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text('...', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                      ),
                      InkWell(
                        onTap: () => setState(() => _currentPage = totalPages),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _currentPage == totalPages ? const Color(0xFF6366F1) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$totalPages',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _currentPage == totalPages ? Colors.white : const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ),
                    ],
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded, size: 18),
                      onPressed: _currentPage < totalPages ? () => setState(() => _currentPage++) : null,
                    ),
                  ],
                ),
              );

              if (constraints.maxWidth < 540) {
                return Column(
                  children: [
                    Text(
                      'Showing ${startIndex + 1} to $endIndex of $totalEntries entries',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    pageButtonsWidget,
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Showing ${startIndex + 1} to $endIndex of $totalEntries entries',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                  ),
                  pageButtonsWidget,
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 4. ANALYTICS & COUNTDOWN WIDGETS (Right Column)
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildRegistrationsOverviewWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Registrations Overview',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              // Ring Donut Chart Custom Painter
              SizedBox(
                width: 120,
                height: 120,
                child: CustomPaint(
                  painter: DonutChartPainter(
                    verified: 138,
                    pending: 4,
                    cancelled: 0,
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '142',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                        ),
                        Text(
                          'Total',
                          style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),

              // Legend
              Expanded(
                child: Column(
                  children: [
                    _buildOverviewLegendItem('Verified (138)', '97.2%', const Color(0xFF22C55E)),
                    const SizedBox(height: 10),
                    _buildOverviewLegendItem('Pending (4)', '2.8%', const Color(0xFFF97316)),
                    const SizedBox(height: 10),
                    _buildOverviewLegendItem('Cancelled (0)', '0%', const Color(0xFFEF4444)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewLegendItem(String title, String percent, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 12, color: Color(0xFF475569), fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          percent,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildRegistrationsOverTimeWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Registrations Over Time',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Row(
                  children: [
                    Text('This Week', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                    SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: Color(0xFF64748B)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Line Chart Area
          SizedBox(
            height: 140,
            width: double.infinity,
            child: CustomPaint(
              painter: LineChartPainter(
                dataPoints: const [12, 18, 22, 25, 31, 35, 27],
                labels: const ['May 12', 'May 13', 'May 14', 'May 15', 'May 16', 'May 17', 'May 18'],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyRegisteredHackathonsSection() {
    final currentUser = ref.watch(authServiceProvider).currentUser;
    final studentId = currentUser?.uid ?? 'STU-2026-042';
    final notifier = ref.read(hackathonRegistrationProvider.notifier);
    ref.watch(hackathonRegistrationProvider);
    final userRegs = notifier.getStudentRegistrations(studentId);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Registered Hackathons',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${userRegs.length} Enrolled',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4338CA)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (userRegs.isEmpty)
            _buildEmptyHackathonsStateInScreen()
          else
            Column(
              children: userRegs.map((reg) => _buildRegisteredHackathonCardInScreen(reg)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildRegisteredHackathonCardInScreen(HackathonRegistrationModel reg) {
    final dateFormat = DateFormat('MMM dd');
    final startDateStr = dateFormat.format(reg.startDate);
    final endDateStr = dateFormat.format(reg.endDate);

    Color statusBg;
    Color statusText;
    String statusLabel;
    String statusDot;

    if (reg.isOngoing) {
      statusBg = const Color(0xFFDCFCE7);
      statusText = const Color(0xFF15803D);
      statusLabel = 'ONGOING';
      statusDot = '🟢';
    } else if (reg.isPending) {
      statusBg = const Color(0xFFFEF3C7);
      statusText = const Color(0xFFB45309);
      statusLabel = 'PENDING';
      statusDot = '🟡';
    } else {
      statusBg = const Color(0xFFDBEAFE);
      statusText = const Color(0xFF1D4ED8);
      statusLabel = 'COMPLETED';
      statusDot = '🔵';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: reg.isOngoing ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0),
          width: reg.isOngoing ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  reg.hackathonTitle,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$statusDot $statusLabel',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$startDateStr – $endDateStr • ${reg.mode}${reg.location.isNotEmpty && reg.location.toLowerCase() != 'online' ? ' (${reg.location})' : ''}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Team: ${reg.teamName}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
              ),
              Text(
                reg.participationStatus,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: reg.isCompleted ? const Color(0xFF2563EB) : const Color(0xFF059669)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => HackathonDetailsScreen(
                          hackathon: reg.toHackathonModel(),
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1E40AF),
                    side: const BorderSide(color: Color(0xFF93C5FD)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: Text(
                    reg.isCompleted ? 'View Result' : 'View Details',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              if (reg.isOngoing) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showSubmitProjectModalInHackathonsScreen(reg),
                    icon: const Icon(Icons.upload_file_rounded, size: 14),
                    label: Text(
                      reg.projectSubmissionUrl != null ? 'Update' : 'Submit',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHackathonsStateInScreen() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: const [
          Text('🏆', style: TextStyle(fontSize: 30)),
          SizedBox(height: 10),
          Text(
            'No Hackathons Yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          SizedBox(height: 4),
          Text(
            'You haven\'t registered for any hackathons.',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showSubmitProjectModalInHackathonsScreen(HackathonRegistrationModel reg) {
    final titleController = TextEditingController(text: reg.projectSubmissionTitle ?? '');
    final urlController = TextEditingController(text: reg.projectSubmissionUrl ?? '');
    final notesController = TextEditingController(text: reg.projectSubmissionNotes ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFD1FAE5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_upload_rounded, color: Color(0xFF059669), size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Submit Project',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    reg.hackathonTitle,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Project Title',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Autonomous AI Drone Swarm',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  validator: (val) => (val == null || val.trim().isEmpty) ? 'Project title is required' : null,
                ),
                const SizedBox(height: 14),
                const Text(
                  'GitHub / Demo URL',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: urlController,
                  decoration: InputDecoration(
                    hintText: 'https://github.com/team/project',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  validator: (val) => (val == null || val.trim().isEmpty) ? 'Repository or demo link is required' : null,
                ),
                const SizedBox(height: 14),
                const Text(
                  'Submission Notes (Optional)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Brief summary of features, tech stack, or live credentials...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                ref.read(hackathonRegistrationProvider.notifier).submitProject(
                      registrationId: reg.id,
                      projectUrl: urlController.text.trim(),
                      projectTitle: titleController.text.trim(),
                      notes: notesController.text.trim(),
                    );
                Navigator.of(dialogCtx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🎉 Project successfully submitted for ${reg.hackathonTitle}!'),
                    backgroundColor: const Color(0xFF10B981),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Confirm Submission'),
          ),
        ],
      ),
    );
  }





  // ───────────────────────────────────────────────────────────────────────────
  // 5. VIEW DETAILS MODAL SHEET
  // ───────────────────────────────────────────────────────────────────────────

  void _showHackathonDetailsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'AI & Innovation Hackathon 2026',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 24, color: Color(0xFFF1F5F9)),

              Expanded(
                child: ListView(
                  children: [
                    const Text('Event Overview', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    const SizedBox(height: 6),
                    const Text(
                      'Join the premiere 24-hour hackathon focused on building intelligent AI agents, multimodal LLM workflows, and next-gen computer vision solutions.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
                    ),
                    const SizedBox(height: 20),

                    const Text('Tracks & Problem Statements', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    const SizedBox(height: 10),
                    _buildTrackItem('🤖 Autonomous AI Agents', 'Build self-reasoning agents that accomplish multi-step complex enterprise tasks.'),
                    _buildTrackItem('🎓 Smart Campus & EdTech', 'Innovate automated grading, AI tutoring, and intelligent timetable schedulers.'),
                    _buildTrackItem('🛡️ Cybersecurity & Threat AI', 'Create real-time anomaly detection pipelines for cloud API security.'),

                    const SizedBox(height: 20),
                    const Text('Prize Pool Distribution', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildPrizeBadge('🥇 1st Prize', '₹25,000', const Color(0xFFFEF3C7), const Color(0xFFD97706)),
                        const SizedBox(width: 8),
                        _buildPrizeBadge('🥈 2nd Prize', '₹15,000', const Color(0xFFF1F5F9), const Color(0xFF475569)),
                        const SizedBox(width: 8),
                        _buildPrizeBadge('🥉 3rd Prize', '₹10,000', const Color(0xFFFFEDD5), const Color(0xFFC2410C)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Register Team Now', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrackItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 2),
            Text(description, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }

  Widget _buildPrizeBadge(String title, String amount, Color bgColor, Color textColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 4),
            Text(amount, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: textColor)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOM PAINTER: DONUT / RING CHART
// ─────────────────────────────────────────────────────────────────────────────

class DonutChartPainter extends CustomPainter {
  final int verified;
  final int pending;
  final int cancelled;

  DonutChartPainter({
    required this.verified,
    required this.pending,
    required this.cancelled,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;
    final strokeWidth = 14.0;

    final total = verified + pending + cancelled;
    if (total == 0) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    double startAngle = -math.pi / 2;

    // 1. Verified Arc (Green)
    final verifiedSweep = (verified / total) * 2 * math.pi;
    paint.color = const Color(0xFF22C55E);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, verifiedSweep - 0.05, false, paint);
    startAngle += verifiedSweep;

    // 2. Pending Arc (Orange)
    final pendingSweep = (pending / total) * 2 * math.pi;
    if (pending > 0) {
      paint.color = const Color(0xFFF97316);
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, pendingSweep - 0.05, false, paint);
      startAngle += pendingSweep;
    }

    // 3. Cancelled Arc (Red)
    final cancelledSweep = (cancelled / total) * 2 * math.pi;
    if (cancelled > 0) {
      paint.color = const Color(0xFFEF4444);
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, cancelledSweep - 0.05, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOM PAINTER: LINE CHART WITH SMOOTH FILL
// ─────────────────────────────────────────────────────────────────────────────

class LineChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final List<String> labels;

  LineChartPainter({required this.dataPoints, required this.labels});

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final paddingBottom = 24.0;
    final chartHeight = size.height - paddingBottom;
    final chartWidth = size.width;

    final maxVal = 40.0;
    final minVal = 0.0;

    final points = <Offset>[];
    final stepX = chartWidth / (dataPoints.length - 1);

    for (int i = 0; i < dataPoints.length; i++) {
      final x = i * stepX;
      final y = chartHeight - ((dataPoints[i] - minVal) / (maxVal - minVal)) * chartHeight;
      points.add(Offset(x, y));
    }

    // Draw horizontal grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1;
    for (int i = 0; i <= 3; i++) {
      final y = (chartHeight / 3) * i;
      canvas.drawLine(Offset(0, y), Offset(chartWidth, y), gridPaint);
    }

    // Path for line and gradient fill
    final linePath = Path();
    linePath.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final controlPoint1 = Offset(p1.dx + stepX / 2, p1.dy);
      final controlPoint2 = Offset(p1.dx + stepX / 2, p2.dy);
      linePath.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, p2.dx, p2.dy);
    }

    // Fill Gradient
    final fillPath = Path.from(linePath);
    fillPath.lineTo(chartWidth, chartHeight);
    fillPath.lineTo(0, chartHeight);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF8B5CF6).withValues(alpha: 0.25),
          const Color(0xFF8B5CF6).withValues(alpha: 0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, chartWidth, chartHeight));

    canvas.drawPath(fillPath, fillPaint);

    // Draw Line
    final linePaint = Paint()
      ..color = const Color(0xFF8B5CF6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawPath(linePath, linePaint);

    // Draw Points & X-Labels
    final dotPaint = Paint()..color = const Color(0xFF8B5CF6);
    final dotInnerPaint = Paint()..color = Colors.white;

    final textStyle = const TextStyle(fontSize: 9, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500);

    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      canvas.drawCircle(p, 4.5, dotPaint);
      canvas.drawCircle(p, 2.5, dotInnerPaint);

      // Label text
      final textSpan = TextSpan(text: labels[i], style: textStyle);
      final textPainter = TextPainter(text: textSpan, textDirection: ui.TextDirection.ltr);
      textPainter.layout();
      textPainter.paint(canvas, Offset(p.dx - textPainter.width / 2, chartHeight + 6));
    }
  }

  @override
  bool shouldRepaint(covariant LineChartPainter oldDelegate) => true;
}
