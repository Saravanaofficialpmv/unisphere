import 'package:flutter/material.dart';
import 'package:clg_application/core/constants/app_colors.dart';

class HodSettings extends StatefulWidget {
  const HodSettings({super.key});

  @override
  State<HodSettings> createState() => _HodSettingsState();
}

class _HodSettingsState extends State<HodSettings> {
  bool _emailNotifs = true;
  bool _smsAlerts = true;
  bool _darkTheme = false;

  final Map<String, bool> _permissions = {
    'Manage department faculty': true,
    'Manage department students': true,
    'Approve leave requests': true,
    'View attendance analytics': true,
    'Assign faculty to subjects': true,
    'Assign faculty advisors': true,
    'Allocate classrooms & laboratories': true,
    'Manage timetables': true,
    'Publish announcements': true,
    'Upload academic notices': true,
    'Monitor academic performance': true,
    'Generate department reports': true,
    'Export analytics': true,
    'Reset faculty passwords': true,
    'Activate/Deactivate faculty accounts': true,
    'Configure department academic settings': true,
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
              'PORTAL CONFIGURATION',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.2),
            ),
            const SizedBox(height: 4),
            const Text(
              'Department Settings',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 20),
            _buildDeptInfoCard(),
            const SizedBox(height: 24),
            const Text('ROLE & PERMISSION MATRIX (HOD)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.1)),
            const SizedBox(height: 12),
            _buildPermissionMatrix(),
            const SizedBox(height: 24),
            const Text('SECURITY & SYSTEM PREFERENCES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.1)),
            const SizedBox(height: 12),
            _buildPreferencesCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeptInfoCard() {
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
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.school_rounded, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Computer Science & Engineering', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Head of Department: Dr. R. Kumar', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 16),
          _buildDetailRow('Department Code', 'CSE'),
          _buildDetailRow('Building / Block', 'Ramanujan Block (3rd Floor)'),
          _buildDetailRow('Active Academic Session', '2026 - 2027 (Odd Semester)'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text(val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildPermissionMatrix() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 6))],
      ),
      child: Column(
        children: _permissions.keys.map((perm) {
          final isChecked = _permissions[perm]!;
          return CheckboxListTile(
            title: Text(perm, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            subtitle: const Text('Authorized by Super Admin', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            value: isChecked,
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() => _permissions[perm] = val!),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPreferencesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 6))],
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Email Notifications', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            subtitle: const Text('Receive instant emails for leave requests and notices'),
            value: _emailNotifs,
            activeThumbColor: AppColors.primary,
            onChanged: (v) => setState(() => _emailNotifs = v),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('SMS Parent Warnings', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            subtitle: const Text('Auto-dispatch SMS to parents on low attendance'),
            value: _smsAlerts,
            activeThumbColor: AppColors.primary,
            onChanged: (v) => setState(() => _smsAlerts = v),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Dark Theme Mode', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            subtitle: const Text('Enable modern dark mode aesthetic'),
            value: _darkTheme,
            activeThumbColor: AppColors.primary,
            onChanged: (v) => setState(() => _darkTheme = v),
          ),
        ],
      ),
    );
  }
}
