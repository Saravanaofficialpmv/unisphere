import 'package:flutter/material.dart';
import 'package:unisphere/core/constants/app_colors.dart';
import 'package:percent_indicator/percent_indicator.dart';

class HodAttendanceManagement extends StatefulWidget {
  const HodAttendanceManagement({super.key});

  @override
  State<HodAttendanceManagement> createState() => _HodAttendanceManagementState();
}

class _HodAttendanceManagementState extends State<HodAttendanceManagement> {
  String _selectedSection = 'CS-A';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'DEPARTMENT ANALYTICS',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.2),
            ),
            const SizedBox(height: 4),
            const Text(
              'Attendance Management',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 20),
            _buildStatCards(),
            const SizedBox(height: 24),
            _buildSectionFilter(),
            const SizedBox(height: 20),
            _buildVisualCharts(),
            const SizedBox(height: 24),
            _buildLowAttendanceList(),
            const SizedBox(height: 24),
            _buildQuickActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Student Attendance', '94.2%', Icons.school_outlined, AppColors.primary),
        _buildStatCard('Faculty Attendance', '95.2%', Icons.badge_outlined, const Color(0xFF7C3AED)),
        _buildStatCard('Weekly Average', '93.8%', Icons.date_range_outlined, const Color(0xFF059669)),
        _buildStatCard('Low Attendance (<75%)', '14 Students', Icons.warning_amber_rounded, AppColors.error),
      ],
    );
  }

  Widget _buildStatCard(String label, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildSectionFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ['CS-A', 'CS-B', 'CS-C', 'CS-D'].map((sec) {
          final isSel = _selectedSection == sec;
          return GestureDetector(
            onTap: () => setState(() => _selectedSection = sec),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: isSel ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSel ? AppColors.primary : AppColors.border),
              ),
              child: Text(
                'Section $sec',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isSel ? Colors.white : AppColors.textPrimary),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildVisualCharts() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Section $_selectedSection Attendance Breakdown', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const Icon(Icons.bar_chart_rounded, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CircularPercentIndicator(
                  radius: 45.0,
                  lineWidth: 9.0,
                  percent: 0.942,
                  center: const Text("94.2%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  progressColor: AppColors.primary,
                  backgroundColor: AppColors.background,
                  circularStrokeCap: CircularStrokeCap.round,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem('Present', '94.2%', AppColors.primary),
                    const SizedBox(height: 8),
                    _buildLegendItem('Absent', '3.8%', AppColors.error),
                    const SizedBox(height: 8),
                    _buildLegendItem('On Duty (OD)', '2.0%', AppColors.warning),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Weekly Attendance Trend (Mon - Fri)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBar('Mon', 0.96),
              _buildBar('Tue', 0.94),
              _buildBar('Wed', 0.98),
              _buildBar('Thu', 0.91),
              _buildBar('Fri', 0.92),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, String val, Color color) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const Spacer(),
        Text(val, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBar(String day, double heightFactor) {
    return Column(
      children: [
        Container(
          height: 80 * heightFactor,
          width: 18,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 6),
        Text(day, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildLowAttendanceList() {
    final students = [
      {'name': 'Karthik Raja', 'reg': '917722104022', 'att': '71.5%'},
      {'name': 'Deepak Kumar', 'reg': '917722104018', 'att': '68.0%'},
      {'name': 'Sanjay V.', 'reg': '917722104052', 'att': '73.2%'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Low Attendance Alerts (<75%)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.error)),
              Icon(Icons.warning_rounded, color: AppColors.error, size: 20),
            ],
          ),
          const SizedBox(height: 14),
          Column(
            children: students.map((s) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(14)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s['name']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        Text(s['reg']!, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                    Text(s['att']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.error)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ElevatedButton.icon(
          onPressed: () => _notifyMsg(context, 'Attendance Excel report exported!'),
          icon: const Icon(Icons.download_rounded, size: 16),
          label: const Text('Export Attendance'),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
        ),
        OutlinedButton.icon(
          onPressed: () => _notifyMsg(context, 'Push notifications sent to low attendance students.'),
          icon: const Icon(Icons.notifications_active_outlined, size: 16),
          label: const Text('Notify Students'),
        ),
        OutlinedButton.icon(
          onPressed: () => _notifyMsg(context, 'SMS warning alerts sent to parents of default students.'),
          icon: const Icon(Icons.sms_outlined, size: 16),
          label: const Text('Notify Parents'),
        ),
        OutlinedButton.icon(
          onPressed: () => _notifyMsg(context, 'Formal warning letters generated.'),
          icon: const Icon(Icons.warning_amber_rounded, size: 16),
          label: const Text('Send Warning'),
        ),
      ],
    );
  }

  void _notifyMsg(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.success));
  }
}
