import 'package:flutter/material.dart';
import 'package:clg_application/core/constants/app_colors.dart';

class HodTimetableManagement extends StatefulWidget {
  const HodTimetableManagement({super.key});

  @override
  State<HodTimetableManagement> createState() => _HodTimetableManagementState();
}

class _HodTimetableManagementState extends State<HodTimetableManagement> {
  String _activeView = 'Student View';
  String _selectedDay = 'Monday';

  final Map<String, List<Map<String, String>>> _timetableData = {
    'Monday': [
      {'period': 'P1 (09:00 - 10:00)', 'subject': 'Distributed Systems', 'staff': 'Dr. S. Meenakshi', 'room': 'Lab 3'},
      {'period': 'P2 (10:00 - 11:00)', 'subject': 'Machine Learning', 'staff': 'Dr. Anita Roy', 'room': 'Room 204'},
      {'period': 'P3 (11:15 - 12:15)', 'subject': 'Data Structures', 'staff': 'Prof. Rajesh Kumar', 'room': 'Room 204'},
      {'period': 'P4 (01:15 - 02:15)', 'subject': 'Database Management', 'staff': 'Prof. Vikram Sharma', 'room': 'Lab 1'},
      {'period': 'P5 (02:15 - 03:15)', 'subject': 'Cloud Computing Lab', 'staff': 'Dr. S. Meenakshi', 'room': 'Lab 3'},
    ],
    'Tuesday': [
      {'period': 'P1 (09:00 - 10:00)', 'subject': 'AI Fundamentals', 'staff': 'Dr. Anita Roy', 'room': 'Room 204'},
      {'period': 'P2 (10:00 - 11:00)', 'subject': 'Distributed Systems', 'staff': 'Dr. S. Meenakshi', 'room': 'Room 204'},
      {'period': 'P3 (11:15 - 12:15)', 'subject': 'SQL Labs', 'staff': 'Prof. Vikram Sharma', 'room': 'Lab 2'},
      {'period': 'P4 (01:15 - 02:15)', 'subject': 'Algorithms', 'staff': 'Prof. Rajesh Kumar', 'room': 'Room 204'},
    ],
  };

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
              'DEPARTMENT SCHEDULING HUB',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.2),
            ),
            const SizedBox(height: 4),
            const Text(
              'Timetable Management',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 20),
            _buildViewSelector(),
            const SizedBox(height: 16),
            _buildDaySelector(),
            const SizedBox(height: 20),
            _buildTimetableGrid(),
            const SizedBox(height: 24),
            _buildTimetableActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildViewSelector() {
    final views = ['Faculty View', 'Student View', 'Classroom View', 'Laboratory View'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: views.map((v) {
          final isSelected = _activeView == v;
          return GestureDetector(
            onTap: () => setState(() => _activeView = v),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
              ),
              child: Text(v, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppColors.textPrimary)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDaySelector() {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((d) {
        final isSel = _selectedDay == d;
        return GestureDetector(
          onTap: () => setState(() => _selectedDay = d),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSel ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              d.substring(0, 3),
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isSel ? AppColors.primary : AppColors.textSecondary),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimetableGrid() {
    final periods = _timetableData[_selectedDay] ?? _timetableData['Monday']!;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: periods.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = periods[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
                child: Text(item['period']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['subject']!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text('${item['staff']} • ${item['room']}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.primary), onPressed: () => _showSwapModal(context, item)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimetableActions(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ElevatedButton.icon(
          onPressed: () => _notify(context, 'Faculty assigned to vacant slot!'),
          icon: const Icon(Icons.person_add_alt_1_outlined, size: 16),
          label: const Text('Assign Faculty'),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
        ),
        OutlinedButton.icon(
          onPressed: () => _notify(context, 'Classroom venue swapped!'),
          icon: const Icon(Icons.meeting_room_outlined, size: 16),
          label: const Text('Assign Classroom'),
        ),
        OutlinedButton.icon(
          onPressed: () => _notify(context, 'Temporary replacement staff assigned.'),
          icon: const Icon(Icons.find_replace_outlined, size: 16),
          label: const Text('Replace Faculty'),
        ),
        OutlinedButton.icon(
          onPressed: () => _notify(context, 'Timetable PDF Exported!'),
          icon: const Icon(Icons.download_rounded, size: 16),
          label: const Text('Export Timetable'),
        ),
      ],
    );
  }

  void _showSwapModal(BuildContext context, Map<String, String> item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Swap Slot: ${item['subject']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text('Current Staff: ${item['staff']} (${item['room']})', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _notify(context, 'Substitution updated successfully!');
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('Confirm Substitution / Swap', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _notify(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.success));
  }
}
