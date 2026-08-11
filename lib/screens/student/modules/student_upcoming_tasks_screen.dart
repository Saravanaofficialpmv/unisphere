import 'package:flutter/material.dart';
import 'package:clg_application/core/constants/app_colors.dart';
import 'package:clg_application/widgets/common/notification_sheet.dart';
import 'package:clg_application/screens/features/exams_detail_screen.dart';

class StudentUpcomingTasksScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const StudentUpcomingTasksScreen({
    super.key,
    this.onBack,
  });

  @override
  State<StudentUpcomingTasksScreen> createState() => _StudentUpcomingTasksScreenState();
}

class _StudentUpcomingTasksScreenState extends State<StudentUpcomingTasksScreen> {
  bool _dbmsSubmitted = false;
  bool _tcsApplied = false;

  void _handleBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else if (widget.onBack != null) {
      widget.onBack!();
    }
  }

  void _showSubmitDialog(String title) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Submit Assignment',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.cloud_upload_outlined, size: 42, color: AppColors.primary),
                  SizedBox(height: 10),
                  Text(
                    'Drag & Drop your file here, or browse',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'PDF, DOCX, or ZIP up to 25MB',
                    style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  setState(() => _dbmsSubmitted = true);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🎉 DBMS Assignment submitted successfully!'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text(
                  'Confirm Submission',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showApplyDialog(String companyTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.work_rounded, color: Color(0xFF10B981), size: 24),
            SizedBox(width: 8),
            Text('Campus Placement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('Are you sure you want to submit your application for $companyTitle? Your resume will be shared with the recruiter.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _tcsApplied = true);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ Application for $companyTitle submitted!'),
                  backgroundColor: const Color(0xFF10B981),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Confirm Apply', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: _handleBack,
        ),
        title: const Row(
          children: [
            Icon(Icons.task_alt_rounded, color: Color(0xFF818CF8), size: 22),
            SizedBox(width: 8),
            Text(
              'Upcoming Tasks & Portal',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Top Header Card (Greeting + Notification & Profile) ──
            _buildHeaderCard(context),
            const SizedBox(height: 16),

            // ── 2. Stat Summary Metrics Bar ──
            _buildMetricsBar(),
            const SizedBox(height: 20),

            // ── 3. 🔥 UPCOMING TASKS Section ──
            _buildUpcomingTasksSection(context),
            const SizedBox(height: 20),

            // ── 4. Side-by-Side: Today's Classes & Notifications ──
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 650) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildTodaysClassesCard()),
                      const SizedBox(width: 14),
                      Expanded(child: _buildNotificationsCard()),
                    ],
                  );
                }
                return Column(
                  children: [
                    _buildTodaysClassesCard(),
                    const SizedBox(height: 14),
                    _buildNotificationsCard(),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            // ── 5. ⚠️ Attendance Alert Banner ──
            _buildAttendanceAlertCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Header Card ──
  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.1),
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Good Morning, Tharani 👋',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Computer Science • Section A',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(6),
                onPressed: () {
                  showNotificationSheet(context);
                },
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications_outlined, color: Color(0xFF475569), size: 24),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.account_circle_outlined, color: Color(0xFF4F46E5), size: 15),
                    SizedBox(width: 4),
                    Text(
                      'Profile',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Metrics Bar Card ──
  Widget _buildMetricsBar() {
    final metrics = [
      {'label': 'Attendance', 'value': '86%', 'color': const Color(0xFF10B981), 'icon': Icons.pie_chart_outline_rounded},
      {'label': 'CGPA', 'value': '8.42', 'color': const Color(0xFF6366F1), 'icon': Icons.workspace_premium_outlined},
      {'label': 'Credits', 'value': '92', 'color': const Color(0xFF8B5CF6), 'icon': Icons.school_outlined},
      {'label': 'Pending Tasks', 'value': '4', 'color': const Color(0xFFF59E0B), 'icon': Icons.pending_actions_rounded},
    ];

    return Row(
      children: metrics.map((metric) {
        final color = metric['color'] as Color;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(metric['icon'] as IconData, color: color, size: 18),
                const SizedBox(height: 4),
                Text(
                  metric['value'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  metric['label'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── UPCOMING TASKS Section ──
  Widget _buildUpcomingTasksSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('🔥', style: TextStyle(fontSize: 18)),
              SizedBox(width: 6),
              Text(
                'UPCOMING TASKS',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Task 1: 📚 DBMS Assignment [Submit]
          _buildTaskItem(
            icon: '📚',
            title: 'DBMS Assignment',
            subtitle: 'Due Tomorrow • Module 4 SQL Queries',
            buttonLabel: _dbmsSubmitted ? 'Submitted ✓' : 'Submit',
            buttonColor: _dbmsSubmitted ? const Color(0xFF10B981) : const Color(0xFF4F46E5),
            isDone: _dbmsSubmitted,
            onPressed: () {
              if (!_dbmsSubmitted) {
                _showSubmitDialog('DBMS Assignment');
              }
            },
          ),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),

          // Task 2: 📝 AI Internal Exam [View]
          _buildTaskItem(
            icon: '📝',
            title: 'AI Internal Exam',
            subtitle: 'Aug 18 • 10:00 AM • Hall 2B',
            buttonLabel: 'View',
            buttonColor: const Color(0xFF0284C7),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ExamsDetailScreen(),
                ),
              );
            },
          ),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),

          // Task 3: 💼 TCS Placement Drive [Apply]
          _buildTaskItem(
            icon: '💼',
            title: 'TCS Placement Drive',
            subtitle: 'Apply before Aug 20 • Software Engineer',
            buttonLabel: _tcsApplied ? 'Applied ✓' : 'Apply',
            buttonColor: _tcsApplied ? const Color(0xFF10B981) : const Color(0xFFEA580C),
            isDone: _tcsApplied,
            onPressed: () {
              if (!_tcsApplied) {
                _showApplyDialog('TCS Placement Drive');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem({
    required String icon,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required Color buttonColor,
    required VoidCallback onPressed,
    bool isDone = false,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          alignment: Alignment.center,
          child: Text(icon, style: const TextStyle(fontSize: 20)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDone ? const Color(0xFFECFDF5) : buttonColor,
            foregroundColor: isDone ? const Color(0xFF059669) : Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: isDone ? const BorderSide(color: Color(0xFFA7F3D0)) : BorderSide.none,
            ),
          ),
          child: Text(
            buttonLabel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDone ? const Color(0xFF059669) : Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // ── Today's Classes Card ──
  Widget _buildTodaysClassesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('📅', style: TextStyle(fontSize: 16)),
              SizedBox(width: 6),
              Text(
                'Today\'s Classes',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildClassRow('ML', '10:00 AM', const Color(0xFF6366F1)),
          const SizedBox(height: 8),
          _buildClassRow('DBMS', '11:00 AM', const Color(0xFF10B981)),
        ],
      ),
    );
  }

  Widget _buildClassRow(String subject, String time, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                subject,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155)),
              ),
            ],
          ),
          Text(
            time,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  // ── Notifications Card ──
  Widget _buildNotificationsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('📢', style: TextStyle(fontSize: 16)),
              SizedBox(width: 6),
              Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildNotificationRow('Exam timetable released'),
          const SizedBox(height: 8),
          _buildNotificationRow('Placement drive registration open'),
        ],
      ),
    );
  }

  Widget _buildNotificationRow(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 6, color: Color(0xFFD97706)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF92400E)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Attendance Alert Card ──
  Widget _buildAttendanceAlertCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFCA5A5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: const Text('⚠️', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attendance Alert',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF991B1B),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Data Mining: 72% — Attendance is low',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFB91C1C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
