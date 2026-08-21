import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/core/constants/app_colors.dart';
import 'package:unisphere/services/auth_service.dart';
import 'package:unisphere/services/firebase_firestore_service.dart';

class StudentMembershipModal extends ConsumerStatefulWidget {
  const StudentMembershipModal({super.key});

  static Future<void> show(BuildContext context) async {
    try {
      await showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => const StudentMembershipModal(),
      );
    } catch (e) {
      debugPrint('Fallback to showDialog: $e');
      if (context.mounted) {
        await showDialog(
          context: context,
          useRootNavigator: true,
          builder: (ctx) => const Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(16),
            child: StudentMembershipModal(),
          ),
        );
      }
    }
  }

  @override
  ConsumerState<StudentMembershipModal> createState() => _StudentMembershipModalState();
}

class _StudentMembershipModalState extends ConsumerState<StudentMembershipModal> {
  int _step = 1; // 1: Has Membership?, 2: Details Entry, 3: Confirmation
  bool? _hasMembership;
  String _selectedOrg = 'ISTE'; // ISTE, CSI, Other
  final TextEditingController _customOrgController = TextEditingController();
  final TextEditingController _membershipIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider).value ?? ref.read(authServiceProvider).currentUser;
    final meta = user?.metadata ?? {};
    if (meta['hasMembership'] == true) {
      _hasMembership = true;
      final org = meta['membershipOrg']?.toString() ?? 'ISTE';
      if (org == 'ISTE' || org == 'CSI') {
        _selectedOrg = org;
      } else {
        _selectedOrg = 'Other';
        _customOrgController.text = org;
      }
      _membershipIdController.text = meta['membershipId']?.toString() ?? '';
    } else if (meta['hasMembership'] == false) {
      _hasMembership = false;
    }
  }

  @override
  void dispose() {
    _customOrgController.dispose();
    _membershipIdController.dispose();
    super.dispose();
  }

  Future<void> _saveNoMembership() async {
    setState(() => _isSaving = true);
    try {
      final user = ref.read(currentUserProvider).value ?? ref.read(authServiceProvider).currentUser;
      if (user != null) {
        final meta = Map<String, dynamic>.from(user.metadata ?? {});
        meta['hasMembership'] = false;
        meta['membershipOrg'] = 'None';
        meta['membershipId'] = 'N/A';
        meta['membershipUpdatedAt'] = DateTime.now().toIso8601String();

        final updatedUser = user.copyWith(metadata: meta);
        await ref.read(authServiceProvider).updateUserProfile(updatedUser);

        final regNo = meta['registerNumber']?.toString() ?? '';
        await ref.read(firebaseFirestoreServiceProvider).saveStudentMembershipDetails(
          studentUid: user.uid,
          registerNumber: regNo,
          hasMembership: false,
          membershipOrg: 'None',
          membershipId: 'N/A',
        );
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notice: ${e.toString()}'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _saveMembershipDetails() async {
    final user = ref.read(currentUserProvider).value ?? ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    final String finalOrg = _selectedOrg == 'Other' ? _customOrgController.text.trim() : _selectedOrg;
    final String finalId = _membershipIdController.text.trim();

    if (_hasMembership == true && (finalOrg.isEmpty || finalId.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select/enter Organization and Membership ID'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final meta = Map<String, dynamic>.from(user.metadata ?? {});
      
      if (_hasMembership == false) {
        final regNo = meta['registerNumber']?.toString() ?? '';
        await ref.read(firebaseFirestoreServiceProvider).saveStudentMembershipDetails(
          studentUid: user.uid,
          registerNumber: regNo,
          hasMembership: false,
          membershipOrg: 'None',
          membershipId: 'N/A',
        );
      } else {
        final regNo = meta['registerNumber']?.toString() ?? '';
        await ref.read(firebaseFirestoreServiceProvider).saveStudentMembershipDetails(
          studentUid: user.uid,
          registerNumber: regNo,
          hasMembership: true,
          membershipOrg: finalOrg,
          membershipId: finalId,
        );
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving membership: ${e.toString()}'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String get __finalOrgText => _selectedOrg == 'Other' ? _customOrgController.text.trim() : _selectedOrg;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        margin: EdgeInsets.only(bottom: bottomInset),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header bar
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Technical Society Membership',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'ISTE, CSI & Professional Associations',
                          style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              if (_step == 1) _buildStep1HasMembershipQuestion(),
              if (_step == 2) _buildStep2MembershipDetailsForm(),
              if (_step == 3) _buildStep3ConfirmationSummary(),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildStep1HasMembershipQuestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Do you hold an active membership in any Technical or Professional Society?',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.4),
        ),
        const SizedBox(height: 8),
        const Text(
          'e.g. Indian Society for Technical Education (ISTE), Computer Society of India (CSI), IEEE, ACM, IEI, or other recognized bodies.',
          style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
        ),
        const SizedBox(height: 24),

        // Choice Card: Yes
        InkWell(
          onTap: () {
            setState(() {
              _hasMembership = true;
              _step = 2;
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _hasMembership == true ? AppColors.primary.withValues(alpha: 0.08) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _hasMembership == true ? AppColors.primary : Colors.grey.shade300, width: 1.5),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 24),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Yes, I hold a Membership', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
                      Text('ISTE, CSI, IEEE, or other society ID', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.primary),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Choice Card: No
        InkWell(
          onTap: () {
            setState(() => _hasMembership = false);
            _saveNoMembership();
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _hasMembership == false ? Colors.orange.shade50 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _hasMembership == false ? Colors.orange : Colors.grey.shade300, width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.remove_circle_outline_rounded, color: Colors.orange, size: 24),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('No, I do not hold any membership', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
                      Text('I will apply later if required', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                if (_isSaving)
                  const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                else
                  const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2MembershipDetailsForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => setState(() => _step = 1),
              ),
              const Text('Select Organization & Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),

          const Text('1. Select Technical / Professional Society', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
          const SizedBox(height: 10),

          // Society Selection Chips / Segment
          Row(
            children: [
              _buildOrgChoiceChip('ISTE', 'Indian Society for Tech Education'),
              const SizedBox(width: 8),
              _buildOrgChoiceChip('CSI', 'Computer Society of India'),
              const SizedBox(width: 8),
              _buildOrgChoiceChip('Other', 'Other Society (IEEE, ACM...)'),
            ],
          ),
          const SizedBox(height: 16),

          // Custom Org Field if Other selected
          if (_selectedOrg == 'Other') ...[
            const Text('Enter Organization Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _customOrgController,
              decoration: InputDecoration(
                hintText: 'e.g. IEEE / ACM / IEI',
                prefixIcon: const Icon(Icons.business_rounded, color: AppColors.primary, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'Please enter organization name' : null,
            ),
            const SizedBox(height: 16),
          ],

          const Text('2. Membership ID / Registration Number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _membershipIdController,
            decoration: InputDecoration(
              hintText: 'e.g. ISTE-TN-2024-9876 or CSI-00192837',
              prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.primary, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter membership ID number' : null,
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  setState(() => _step = 3);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Review & Confirm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrgChoiceChip(String orgKey, String tooltip) {
    final isSelected = _selectedOrg == orgKey;
    return Expanded(
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: () => setState(() => _selectedOrg = orgKey),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300),
            ),
            child: Column(
              children: [
                Icon(
                  orgKey == 'ISTE' ? Icons.school : (orgKey == 'CSI' ? Icons.computer : Icons.card_membership),
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  orgKey,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep3ConfirmationSummary() {
    final orgName = __finalOrgText;
    final memId = _membershipIdController.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => setState(() => _step = 2),
            ),
            const Text('Confirm Membership Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ],
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.verified_rounded, color: AppColors.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(orgName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                        const Text('Official Society Membership', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                    child: const Text('ACTIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Membership / Reg ID:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  SelectableText(memId, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _saveMembershipDetails,
            icon: _isSaving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.cloud_upload_rounded, size: 18),
            label: Text(_isSaving ? 'Saving to Database...' : 'Confirm & Save to Student Record'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}
