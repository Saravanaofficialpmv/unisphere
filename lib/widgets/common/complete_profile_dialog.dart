import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/core/constants/app_colors.dart';
import 'package:unisphere/core/constants/app_departments.dart';
import 'package:unisphere/models/user_model.dart';
import 'package:unisphere/services/auth_service.dart';

class CompleteProfileDialog extends ConsumerStatefulWidget {
  final UserModel user;

  const CompleteProfileDialog({super.key, required this.user});

  static Future<void> showIfRequired(BuildContext context, WidgetRef ref) async {
    final user = ref.read(authServiceProvider).currentUser;
    if (user != null && user.metadata?['profileCompleted'] != true) {
      // Delay slightly so layout builds completely
      await Future.delayed(const Duration(milliseconds: 600));
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => CompleteProfileDialog(user: user),
        );
      }
    }
  }

  @override
  ConsumerState<CompleteProfileDialog> createState() => _CompleteProfileDialogState();
}

class _CompleteProfileDialogState extends ConsumerState<CompleteProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _regNoController;
  late final TextEditingController _phoneController;
  late final TextEditingController _sectionController;
  late String _selectedDept;
  String _selectedSemester = 'Semester 6 (3rd Year)';
  bool _isSaving = false;

  final List<String> _semesters = [
    'Semester 1 (1st Year)',
    'Semester 2 (1st Year)',
    'Semester 3 (2nd Year)',
    'Semester 4 (2nd Year)',
    'Semester 5 (3rd Year)',
    'Semester 6 (3rd Year)',
    'Semester 7 (4th Year)',
    'Semester 8 (4th Year)',
  ];

  @override
  void initState() {
    super.initState();
    final meta = widget.user.metadata ?? {};
    _regNoController = TextEditingController(text: meta['registerNumber'] ?? 'RA2111003010001');
    _phoneController = TextEditingController(text: widget.user.phoneNumber ?? '+91 98765 43210');
    _sectionController = TextEditingController(text: meta['section'] ?? 'Sec A');

    final deptVal = meta['department']?.toString() ?? '';
    _selectedDept = AppDepartments.list.firstWhere(
      (d) => d.toLowerCase() == deptVal.toLowerCase() || d.toLowerCase().contains(deptVal.toLowerCase()),
      orElse: () => AppDepartments.list.firstWhere(
        (d) => d.contains('Computer Science'),
        orElse: () => AppDepartments.list.first,
      ),
    );
  }

  @override
  void dispose() {
    _regNoController.dispose();
    _phoneController.dispose();
    _sectionController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final updatedMeta = Map<String, dynamic>.from(widget.user.metadata ?? {});
      updatedMeta['profileCompleted'] = true;
      updatedMeta['registerNumber'] = _regNoController.text.trim();
      updatedMeta['department'] = _selectedDept;
      updatedMeta['section'] = _sectionController.text.trim();
      updatedMeta['semester'] = _selectedSemester;
      updatedMeta['completedAt'] = DateTime.now().toIso8601String();

      final updatedUser = widget.user.copyWith(
        phoneNumber: _phoneController.text.trim(),
        metadata: updatedMeta,
      );

      await ref.read(authServiceProvider).updateUserProfile(updatedUser);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Profile details completed & updated successfully! Welcome!'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile update notice: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 30,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Complete Your Profile 🎓',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Hi ${widget.user.name.split(' ').first}! Please confirm your academic details to activate your portal.',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Register / ID Number
                const Text('Register / Employee ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _regNoController,
                  decoration: InputDecoration(
                    hintText: 'e.g. RA2111003010001',
                    prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.primary, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Register ID is required' : null,
                ),
                const SizedBox(height: 16),

                // Department
                const Text('Academic Department', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _selectedDept,
                  isExpanded: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.account_balance_outlined, color: AppColors.primary, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  items: AppDepartments.list.map((dept) {
                    return DropdownMenuItem<String>(
                      value: dept,
                      child: Text(dept, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedDept = val);
                  },
                ),
                const SizedBox(height: 16),

                // Section & Semester Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Section / Group', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _sectionController,
                            decoration: InputDecoration(
                              hintText: 'Sec A',
                              prefixIcon: const Icon(Icons.groups_outlined, color: AppColors.primary, size: 20),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Current Semester', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedSemester,
                            isExpanded: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                            ),
                            items: _semesters.map((sem) {
                              return DropdownMenuItem<String>(
                                value: sem,
                                child: Text(sem, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedSemester = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Contact Phone Number
                const Text('Contact Phone Number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: '+91 98765 43210',
                    prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.primary, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Skip for Now'),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _handleSaveProfile,
                        icon: _isSaving
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.check_circle_rounded, size: 18),
                        label: Text(_isSaving ? 'Saving...' : 'Save & Continue'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
