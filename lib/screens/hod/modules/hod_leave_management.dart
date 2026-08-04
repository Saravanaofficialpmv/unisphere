import 'package:flutter/material.dart';
import 'package:clg_application/core/constants/app_colors.dart';

class HodLeaveManagement extends StatefulWidget {
  const HodLeaveManagement({super.key});

  @override
  State<HodLeaveManagement> createState() => _HodLeaveManagementState();
}

class _HodLeaveManagementState extends State<HodLeaveManagement> {
  String _activeTab = 'Faculty Requests';

  final List<Map<String, dynamic>> _leaveRequests = [
    {
      'name': 'Dr. Anita Roy',
      'role': 'Assistant Professor',
      'type': 'Faculty',
      'reason': 'Attending National AI Conference at IIT Madras',
      'dates': '12 Aug - 14 Aug (3 Days)',
      'leaveCategory': 'On Duty (OD)',
      'status': 'Pending Approval',
      'document': 'Conference_Invitation_IITM.pdf',
      'photo': 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=150',
    },
    {
      'name': 'Prof. Vikram Sharma',
      'role': 'Assistant Professor',
      'type': 'Faculty',
      'reason': 'Medical Emergency / Personal Illness',
      'dates': '05 Aug (1 Day)',
      'leaveCategory': 'Casual Leave (CL)',
      'status': 'Pending Approval',
      'document': 'Medical_Certificate.pdf',
      'photo': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
    },
    {
      'name': 'Karthik Raja',
      'role': 'Student (CS-B)',
      'type': 'Student',
      'reason': 'Inter-College Hackathon Participation',
      'dates': '08 Aug - 09 Aug (2 Days)',
      'leaveCategory': 'On Duty (OD)',
      'status': 'Pending Approval',
      'document': 'Hackathon_Pass.pdf',
      'photo': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _leaveRequests.where((r) {
      if (_activeTab == 'Faculty Requests') return r['type'] == 'Faculty';
      if (_activeTab == 'Student Requests') return r['type'] == 'Student';
      return r['leaveCategory'] == 'On Duty (OD)';
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'APPROVAL WORKFLOW',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.2),
            ),
            const SizedBox(height: 4),
            const Text(
              'Leave & OD Management',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 20),
            _buildStatSummary(),
            const SizedBox(height: 20),
            _buildCategoryTabs(),
            const SizedBox(height: 20),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildLeaveCard(context, filtered[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatSummary() {
    return Row(
      children: [
        _buildSmallStat('Pending', '8 Requests', AppColors.warning),
        const SizedBox(width: 10),
        _buildSmallStat('Approved', '45 Requests', AppColors.success),
        const SizedBox(width: 10),
        _buildSmallStat('Rejected', '2 Requests', AppColors.error),
      ],
    );
  }

  Widget _buildSmallStat(String label, String count, Color col) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text(count, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: col)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    final tabs = ['Faculty Requests', 'Student Requests', 'On Duty Requests'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.map((t) {
          final isSel = _activeTab == t;
          return GestureDetector(
            onTap: () => setState(() => _activeTab = t),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSel ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSel ? AppColors.primary : AppColors.border),
              ),
              child: Text(t, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isSel ? Colors.white : AppColors.textPrimary)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLeaveCard(BuildContext context, Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 24, backgroundImage: NetworkImage(item['photo'])),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('${item['role']} • ${item['leaveCategory']}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: const Text('Pending', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.warning)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Reason: ${item['reason']}', style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text('Duration: ${item['dates']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.attach_file_rounded, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(child: Text(item['document'], style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                const Icon(Icons.download_rounded, size: 18, color: AppColors.primary),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() => _leaveRequests.remove(item));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Leave Request Approved!'), backgroundColor: AppColors.success));
                  },
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Approve'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() => _leaveRequests.remove(item));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Leave Request Rejected'), backgroundColor: AppColors.error));
                  },
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
