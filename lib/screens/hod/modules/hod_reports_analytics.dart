import 'package:flutter/material.dart';
import 'package:unisphere/core/constants/app_colors.dart';
import 'package:percent_indicator/percent_indicator.dart';

class HodReportsAnalytics extends StatefulWidget {
  const HodReportsAnalytics({super.key});

  @override
  State<HodReportsAnalytics> createState() => _HodReportsAnalyticsState();
}

class _HodReportsAnalyticsState extends State<HodReportsAnalytics> {
  String _selectedSection = 'Attendance Distribution';

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
              'EXECUTIVE DASHBOARD',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.2),
            ),
            const SizedBox(height: 4),
            const Text(
              'Reports & Department Analytics',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 20),
            _buildSectionTabs(),
            const SizedBox(height: 20),
            _buildMetricsOverview(),
            const SizedBox(height: 24),
            _buildChartCard(),
            const SizedBox(height: 24),
            _buildExportActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTabs() {
    final sections = [
      'Attendance Distribution',
      'CGPA Distribution',
      'Semester Results',
      'Faculty Workload',
      'Placement Stats',
      'Department Ranking',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: sections.map((s) {
          final isSel = _selectedSection == s;
          return GestureDetector(
            onTap: () => setState(() => _selectedSection = s),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSel ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSel ? AppColors.primary : AppColors.border),
              ),
              child: Text(s, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isSel ? Colors.white : AppColors.textPrimary)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMetricsOverview() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 1.5,
      children: [
        _buildMetricBox('Average CGPA', '8.74', Icons.star_rounded, const Color(0xFF7C3AED)),
        _buildMetricBox('Placement Ratio', '92.5%', Icons.work_rounded, const Color(0xFF059669)),
        _buildMetricBox('Pass Percentage', '96.4%', Icons.check_circle_rounded, AppColors.primary),
        _buildMetricBox('Dept Rank', '#1 Institution', Icons.emoji_events_rounded, const Color(0xFFD97706)),
      ],
    );
  }

  Widget _buildMetricBox(String title, String val, IconData icon, Color color) {
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
              Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildChartCard() {
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
          Text('$_selectedSection Breakdown', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildVisualIndicator('9.0+ CGPA (Distinction)', 0.42, AppColors.primary),
          const SizedBox(height: 12),
          _buildVisualIndicator('8.0 - 8.9 CGPA (First Class)', 0.38, const Color(0xFF059669)),
          const SizedBox(height: 12),
          _buildVisualIndicator('7.0 - 7.9 CGPA (Second Class)', 0.15, const Color(0xFFD97706)),
          const SizedBox(height: 12),
          _buildVisualIndicator('< 7.0 CGPA (Re-appear)', 0.05, AppColors.error),
        ],
      ),
    );
  }

  Widget _buildVisualIndicator(String label, double val, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            Text('${(val * 100).toInt()}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        LinearPercentIndicator(
          lineHeight: 8.0,
          percent: val,
          progressColor: color,
          backgroundColor: AppColors.background,
          barRadius: const Radius.circular(10),
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildExportActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _notify(context, 'Exporting Analytics to Excel...'),
            icon: const Icon(Icons.table_chart_outlined, size: 18),
            label: const Text('Export Excel'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _notify(context, 'Generating Executive PDF Report...'),
            icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
            label: const Text('Export PDF'),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          ),
        ),
      ],
    );
  }

  void _notify(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.success));
  }
}
