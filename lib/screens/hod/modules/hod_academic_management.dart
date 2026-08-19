import 'package:flutter/material.dart';
import 'package:unisphere/core/constants/app_colors.dart';
import 'package:unisphere/screens/hod/modules/hod_syllabus_management_screen.dart';

class HodAcademicManagement extends StatelessWidget {
  const HodAcademicManagement({super.key});

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
              'DEPARTMENT CURRICULUM & ROSTER',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.2),
            ),
            const SizedBox(height: 4),
            const Text(
              'Academic Management',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 24),
            _buildAcademicGrid(context),
            const SizedBox(height: 32),
            const Text(
              'QUICK CONFIGURATION ACTIONS',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.1),
            ),
            const SizedBox(height: 16),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademicGrid(BuildContext context) {
    final items = [
      {'title': 'Syllabus Management', 'sub': 'Academic Year, Sem & Subject Docs', 'icon': Icons.menu_book_rounded, 'color': const Color(0xFFD97706), 'type': 'syllabus'},
      {'title': 'Course Allocation', 'sub': 'Subject & Faculty Mapping', 'icon': Icons.book_outlined, 'color': const Color(0xFF2563EB)},
      {'title': 'Faculty Workload', 'sub': '16-20 Hours/Week Limits', 'icon': Icons.assessment_outlined, 'color': const Color(0xFF7C3AED)},
      {'title': 'Subject Allocation', 'sub': 'Core & Elective Subject Lists', 'icon': Icons.menu_book_outlined, 'color': const Color(0xFF059669), 'type': 'syllabus'},
      {'title': 'Lab Allocation', 'sub': 'Software & Hardware Labs', 'icon': Icons.computer_outlined, 'color': const Color(0xFFD97706)},
      {'title': 'Class Advisor Allocation', 'sub': 'Assign Advisors per Section', 'icon': Icons.person_outline, 'color': const Color(0xFFDC2626)},
      {'title': 'Elective Management', 'sub': 'Professional & Open Electives', 'icon': Icons.rule_outlined, 'color': const Color(0xFF4F46E5)},
      {'title': 'Semester Planning', 'sub': 'Syllabus Coverage Tracking', 'icon': Icons.edit_calendar_outlined, 'color': const Color(0xFF0891B2), 'type': 'syllabus'},
      {'title': 'Academic Calendar', 'sub': 'Holidays & Examination Dates', 'icon': Icons.calendar_month_outlined, 'color': const Color(0xFFBE185D)},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.35,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        final Color col = item['color'] as Color;

        return InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            if (item['type'] == 'syllabus') {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const HodSyllabusManagementScreen()),
              );
            } else {
              _showDialogMsg(context, item['title'] as String);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 6))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: col.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(item['icon'] as IconData, color: col, size: 22),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] as String,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item['sub'] as String,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildActionButton(context, Icons.menu_book_rounded, 'Syllabus Management', () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const HodSyllabusManagementScreen()));
        }),
        _buildActionButton(context, Icons.person_add_alt_outlined, 'Assign Faculty', () => _showDialogMsg(context, 'Assign Faculty to Subject')),
        _buildActionButton(context, Icons.add_circle_outline, 'Create Subject', () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const HodSyllabusManagementScreen()));
        }),
        _buildActionButton(context, Icons.supervisor_account_outlined, 'Assign Class Advisor', () => _showDialogMsg(context, 'Assign Class Advisor')),
        _buildActionButton(context, Icons.collections_bookmark_outlined, 'Manage Curriculum', () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const HodSyllabusManagementScreen()));
        }),
        _buildActionButton(context, Icons.auto_stories_outlined, 'Create Elective', () => _showDialogMsg(context, 'Create New Elective Batch')),
        _buildActionButton(context, Icons.tune_outlined, 'Semester Configuration', () => _showDialogMsg(context, 'Configure Active Semester')),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  void _showDialogMsg(BuildContext context, String action) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(action, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Execute $action configuration modal for Department of CSE.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$action executed successfully!'), backgroundColor: AppColors.success));
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Proceed', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
