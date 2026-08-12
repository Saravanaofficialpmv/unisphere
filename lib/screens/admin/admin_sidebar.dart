import 'package:flutter/material.dart';
import 'package:unisphere/core/constants/app_colors.dart';

class AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const AdminSidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: double.infinity,
      decoration: BoxDecoration(color: Colors.white, border: Border(right: BorderSide(color: AppColors.border, width: 1))),
      child: Column(
        children: [
          const SizedBox(height: 24),
          _buildLogo(),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildNavItem(0, 'Dashboard', Icons.grid_view_rounded),
                _buildNavItem(1, 'Users', Icons.group_outlined),
                _buildNavItem(2, 'Departments', Icons.account_balance_outlined),
                _buildNavItem(3, 'Announcements', Icons.campaign_outlined),
                _buildNavItem(4, 'Academics', Icons.school_outlined),
                _buildNavItem(5, 'Marks', Icons.grade_outlined),
                _buildNavItem(6, 'Attendance', Icons.calendar_today_outlined),
                _buildNavItem(7, 'Reports', Icons.assessment_outlined),
                _buildNavItem(8, 'Roles', Icons.verified_user_outlined),
              ],
            ),
          ),
          _buildAdminProfile(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/app_logo.png',
              width: 36,
              height: 36,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.hub_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('UniSphere', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Text('INSTITUTIONAL ADMIN', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon) {
    final isSelected = selectedIndex == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          onTap: () => onDestinationSelected(index),
          dense: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          selected: isSelected,
          selectedTileColor: AppColors.primary.withValues(alpha: 0.05),
          leading: Icon(icon, color: isSelected ? AppColors.primary : Colors.grey, size: 20),
          title: Text(label, style: TextStyle(color: isSelected ? AppColors.primary : AppColors.textPrimary, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, fontSize: 13)),
        ),
      ),
    );
  }

  Widget _buildAdminProfile() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const CircleAvatar(radius: 16, backgroundColor: Colors.blueGrey, child: Icon(Icons.person, size: 18, color: Colors.white)),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Alex Sterling', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Text('System Administrator', style: TextStyle(fontSize: 9, color: Colors.grey)),
              ],
            ),
          ),
          Icon(Icons.more_vert, size: 16, color: Colors.grey.shade400),
        ],
      ),
    );
  }
}
