import 'package:flutter/material.dart';
import 'package:clg_application/core/constants/app_colors.dart';

class HodExamManagement extends StatelessWidget {
  const HodExamManagement({super.key});

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
              'ASSESSMENT CONTROL HUB',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.2),
            ),
            const SizedBox(height: 4),
            const Text(
              'Examination Management',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 20),
            _buildExamCards(),
            const SizedBox(height: 24),
            _buildEvaluationStatusList(),
            const SizedBox(height: 24),
            _buildExamActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildExamCards() {
    final items = [
      {'title': 'Internal Assessments', 'val': 'Test 2 Completed', 'icon': Icons.assignment_outlined, 'color': AppColors.primary},
      {'title': 'Model Examinations', 'val': 'Scheduled next week', 'icon': Icons.quiz_outlined, 'color': const Color(0xFF7C3AED)},
      {'title': 'Marks Uploaded', 'val': '92% Subjects Uploaded', 'icon': Icons.upload_file_rounded, 'color': const Color(0xFF059669)},
      {'title': 'Pending Evaluations', 'val': '4 Faculty Pending', 'icon': Icons.hourglass_empty_rounded, 'color': AppColors.error},
      {'title': 'Pass Percentage', 'val': '96.4% Overall Pass', 'icon': Icons.verified_outlined, 'color': const Color(0xFFD97706)},
      {'title': 'Department Rank List', 'val': 'Top 10 Ranks Ready', 'icon': Icons.emoji_events_outlined, 'color': const Color(0xFF0891B2)},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.4,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        final Color col = item['color'] as Color;

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
              Icon(item['icon'] as IconData, color: col, size: 22),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['title'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(item['val'] as String, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: col)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEvaluationStatusList() {
    final statusData = [
      {'sub': 'CS301 - Distributed Systems', 'faculty': 'Dr. S. Meenakshi', 'status': 'Approved', 'col': AppColors.success},
      {'sub': 'CS302 - Machine Learning', 'faculty': 'Dr. Anita Roy', 'status': 'Pending Verification', 'col': AppColors.warning},
      {'sub': 'CS303 - Database Management', 'faculty': 'Prof. Vikram Sharma', 'status': 'Approved', 'col': AppColors.success},
      {'sub': 'CS304 - Cloud Computing Lab', 'faculty': 'Prof. Rajesh Kumar', 'status': 'Not Uploaded', 'col': AppColors.error},
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
          const Text('Faculty Evaluation & Marks Approval Status', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Column(
            children: statusData.map((d) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(14)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d['sub'].toString(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        Text(d['faculty'].toString(), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: (d['col'] as Color).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                      child: Text(d['status'].toString(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: d['col'] as Color)),
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

  Widget _buildExamActions(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ElevatedButton.icon(
          onPressed: () => _notify(context, 'Internal Test 2 Marks Approved & Published!'),
          icon: const Icon(Icons.publish_rounded, size: 16),
          label: const Text('Publish Marks'),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
        ),
        OutlinedButton.icon(
          onPressed: () => _notify(context, 'Department Rank List PDF Generated.'),
          icon: const Icon(Icons.workspace_premium_outlined, size: 16),
          label: const Text('Generate Rank List'),
        ),
        OutlinedButton.icon(
          onPressed: () => _notify(context, 'Official Mark Register Exported.'),
          icon: const Icon(Icons.menu_book_outlined, size: 16),
          label: const Text('Download Mark Register'),
        ),
        OutlinedButton.icon(
          onPressed: () => _notify(context, 'Result Analysis summary created.'),
          icon: const Icon(Icons.insights_outlined, size: 16),
          label: const Text('Result Analysis'),
        ),
      ],
    );
  }

  void _notify(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.success));
  }
}
