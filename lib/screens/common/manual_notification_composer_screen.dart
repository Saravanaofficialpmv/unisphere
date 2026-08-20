import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:unisphere/core/constants/app_colors.dart';
import 'package:unisphere/models/user_model.dart';
import 'package:unisphere/providers/manual_notification_composer_provider.dart';
import 'package:unisphere/services/auth_service.dart';

class ManualNotificationComposerScreen extends ConsumerStatefulWidget {
  const ManualNotificationComposerScreen({super.key});

  @override
  ConsumerState<ManualNotificationComposerScreen> createState() =>
      _ManualNotificationComposerScreenState();
}

class _ManualNotificationComposerScreenState
    extends ConsumerState<ManualNotificationComposerScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(manualNotificationComposerProvider);
    final notifier = ref.read(manualNotificationComposerProvider.notifier);
    final currentUser = ref.watch(authServiceProvider).currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manual Notification Composer',
              style: GoogleFonts.manrope(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
            ),
            Text(
              'Sender: ${currentUser?.name ?? "User"} (${currentUser?.roleName ?? "Staff"})',
              style: GoogleFonts.manrope(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.bookmark_outline_rounded, size: 18),
            label: const Text('Save Draft'),
            onPressed: () async {
              await notifier.saveDraft();
              if (context.mounted && state.successMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.successMessage!)),
                );
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // RBAC Notice Banner
            _buildRbacBanner(currentUser),
            const SizedBox(height: 16),

            // Live Recipient Counter & Preview Header Card
            _buildTargetRecipientCard(context, state, notifier),
            const SizedBox(height: 20),

            // Form Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Notification Content', style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // Title Field
                  TextField(
                    controller: _titleController,
                    onChanged: (val) => notifier.updateTitle(val),
                    decoration: InputDecoration(
                      labelText: 'Notification Title *',
                      hintText: 'e.g. End-Semester Examination Schedule Circular',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Message Content Field
                  TextField(
                    controller: _messageController,
                    maxLines: 4,
                    onChanged: (val) => notifier.updateMessage(val),
                    decoration: InputDecoration(
                      labelText: 'Message Body *',
                      hintText: 'Enter detailed message for target audience...',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category & Priority Row
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: state.category,
                          decoration: InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: ['General', 'Academic', 'Attendance', 'Finance', 'Career', 'Events', 'System']
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (val) => notifier.updateCategory(val ?? 'General'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: state.priority,
                          decoration: InputDecoration(
                            labelText: 'Priority',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: [
                            const DropdownMenuItem(value: 'critical', child: Text('🚨 Critical')),
                            const DropdownMenuItem(value: 'high', child: Text('⚠️ High')),
                            const DropdownMenuItem(value: 'medium', child: Text('ℹ️ Medium')),
                            const DropdownMenuItem(value: 'low', child: Text('📝 Low')),
                          ],
                          onChanged: (val) => notifier.updatePriority(val ?? 'medium'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Target Audience Selector Panel
            _buildTargetSelectorPanel(context, state, notifier, currentUser),

            const SizedBox(height: 24),

            // Error message if any
            if (state.errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red),
                ),
                child: Text(state.errorMessage!, style: GoogleFonts.manrope(color: Colors.red, fontWeight: FontWeight.bold)),
              ),

            // Submit Buttons (Send Now / Schedule Later)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.schedule_rounded),
                    label: Text(state.scheduledAt == null
                        ? 'Schedule for Later'
                        : 'Scheduled: ${DateFormat('MMM d, h:mm a').format(state.scheduledAt!)}'),
                    onPressed: () async {
                      final picked = await showDateTimePicker(context);
                      if (picked != null) {
                        notifier.setScheduledAt(picked);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: state.isSubmitting
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.send_rounded, color: Colors.white),
                    label: Text(
                      state.scheduledAt != null ? 'Schedule Notification' : 'Send Immediately',
                      style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    onPressed: state.isSubmitting
                        ? null
                        : () async {
                            final ok = await notifier.sendNotification();
                            if (ok && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(state.successMessage ?? 'Notification sent successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              _titleController.clear();
                              _messageController.clear();
                            }
                          },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRbacBanner(UserModel? user) {
    String bannerText = 'Full System Admin Access: You can send notifications college-wide.';
    Color bgColor = const Color(0xFFEFF6FF);
    Color borderColor = const Color(0xFF93C5FD);
    Color textColor = const Color(0xFF1E40AF);

    if (user?.role == UserRole.hod) {
      bannerText = 'HOD Restricted Access: Notifications are strictly constrained to your Department (${user?.metadata?['department'] ?? "CS"}).';
      bgColor = const Color(0xFFFEF3C7);
      borderColor = const Color(0xFFFCD34D);
      textColor = const Color(0xFF92400E);
    } else if (user?.role == UserRole.staff) {
      bannerText = 'Staff / Class Advisor Access: Restricted to assigned classes and students.';
      bgColor = const Color(0xFFF3E8FF);
      borderColor = const Color(0xFFD8B4FE);
      textColor = const Color(0xFF6B21A8);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_outlined, color: textColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              bannerText,
              style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetRecipientCard(
    BuildContext context,
    ManualNotificationComposerState state,
    ManualNotificationComposerNotifier notifier,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.indigoAccent, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.people_alt_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Selected Recipients: ${state.totalRecipientsCount}',
                  style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                Text(
                  'Target Mode: ${state.targetType.toUpperCase()}',
                  style: GoogleFonts.manrope(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => _showAudiencePreviewModal(context, state),
            child: const Text('Preview Audience', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetSelectorPanel(
    BuildContext context,
    ManualNotificationComposerState state,
    ManualNotificationComposerNotifier notifier,
    UserModel? user,
  ) {
    final targetModes = [
      {'id': 'role', 'label': 'By Role', 'icon': Icons.badge_outlined},
      {'id': 'org', 'label': 'By Org Structure', 'icon': Icons.business_outlined},
      {'id': 'individual', 'label': 'Individual Users', 'icon': Icons.person_search_outlined},
      {'id': 'filter', 'label': 'Dynamic Filter', 'icon': Icons.filter_alt_outlined},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recipient Targeting Selection', style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          // Target Mode Selection Chips
          Wrap(
            spacing: 8,
            children: targetModes.map((m) {
              final isSel = state.targetType == m['id'];
              return ChoiceChip(
                selected: isSel,
                avatar: Icon(m['icon'] as IconData, size: 16, color: isSel ? Colors.white : AppColors.primary),
                label: Text(m['label'] as String),
                labelStyle: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                  color: isSel ? Colors.white : AppColors.textPrimary,
                ),
                selectedColor: AppColors.primary,
                backgroundColor: const Color(0xFFF1F5F9),
                onSelected: (_) => notifier.updateTargetType(m['id'] as String),
              );
            }).toList(),
          ),

          const Divider(height: 24),

          // Sub-options based on targetType
          if (state.targetType == 'role') ...[
            Text('Select Target Roles:', style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['student', 'parent', 'staff', 'hod', 'advisor'].map((r) {
                final isSel = state.selectedRoles.contains(r);
                return FilterChip(
                  selected: isSel,
                  label: Text(r.toUpperCase()),
                  selectedColor: AppColors.primary.withValues(alpha: 0.15),
                  onSelected: (_) => notifier.toggleRole(r),
                );
              }).toList(),
            ),
          ],

          if (state.targetType == 'org') ...[
            DropdownButtonFormField<String>(
              initialValue: state.selectedDepartment ?? 'Entire College',
              decoration: const InputDecoration(labelText: 'Target Department'),
              items: ['Entire College', 'Computer Science', 'Information Technology', 'Electronics & Comm', 'Mechanical']
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: user?.role == UserRole.hod ? null : (val) => notifier.setDepartment(val),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: state.selectedSection ?? 'All Sections',
                    decoration: const InputDecoration(labelText: 'Section'),
                    items: ['All Sections', 'Sec A', 'Sec B', 'Sec C']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) => notifier.setSection(val),
                  ),
                ),
              ],
            ),
          ],

          if (state.targetType == 'filter') ...[
            Text('Select Dynamic Rule Filter:', style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: state.selectedDynamicFilter,
              decoration: const InputDecoration(labelText: 'Filter Rule'),
              items: const [
                DropdownMenuItem(value: 'none', child: Text('All Qualified Users')),
                DropdownMenuItem(value: 'low_attendance', child: Text('⚠️ Students Below Minimum Attendance (<75%)')),
                DropdownMenuItem(value: 'pending_fees', child: Text('💳 Students/Parents with Pending Fees')),
                DropdownMenuItem(value: 'incomplete_profile', child: Text('📝 Incomplete Placement Profiles')),
                DropdownMenuItem(value: 'placement_eligible', child: Text('🎯 Placement Drive Eligible Candidates')),
                DropdownMenuItem(value: 'event_registered', child: Text('🚀 Hackathon & Event Registered Participants')),
              ],
              onChanged: (val) => notifier.setDynamicFilter(val ?? 'none'),
            ),
          ],
        ],
      ),
    );
  }

  void _showAudiencePreviewModal(BuildContext context, ManualNotificationComposerState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Target Audience Review (${state.totalRecipientsCount} Users)', style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: state.resolvedAudience.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (ctx, i) {
                  final user = state.resolvedAudience[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Text(user.name[0], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ),
                    title: Text(user.name, style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
                    subtitle: Text('${user.role.toUpperCase()} | ${user.department}\n${user.details}'),
                  );
                },
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48), backgroundColor: AppColors.primary),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close Preview', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Future<DateTime?> showDateTimePicker(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return null;

    if (!context.mounted) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
}
