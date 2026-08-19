import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:unisphere/models/hackathon_model.dart';
import 'package:unisphere/models/hackathon_registration_model.dart';
import 'package:unisphere/controllers/hackathon_registration_controller.dart';
import 'package:unisphere/screens/features/hackathon_registration_screen.dart';
import 'package:unisphere/screens/features/hackathon_team_management_screen.dart';
import 'package:unisphere/services/auth_service.dart';

class HackathonDetailsScreen extends ConsumerWidget {
  final HackathonModel hackathon;

  const HackathonDetailsScreen({super.key, required this.hackathon});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final startDateStr = dateFormat.format(hackathon.startDate);
    final endDateStr = dateFormat.format(hackathon.endDate);

    final currentUser = ref.watch(authServiceProvider).currentUser;
    final studentId = currentUser?.uid ?? 'STU-2026-042';
    final registrationNotifier = ref.read(hackathonRegistrationProvider.notifier);
    ref.watch(hackathonRegistrationProvider);

    final userRegs = registrationNotifier.getStudentRegistrations(studentId);
    HackathonRegistrationModel? registration;
    try {
      registration = userRegs.firstWhere(
        (r) => r.hackathonId == hackathon.id || r.id == hackathon.registrationId,
      );
    } catch (_) {
      registration = null;
    }

    final isRegistered = registration != null || hackathon.isRegistered;
    final now = DateTime.now();

    String currentStatus;
    Color statusBg;
    Color statusTextColor;
    String statusDot;

    if (now.isBefore(hackathon.startDate)) {
      currentStatus = 'PENDING';
      statusBg = const Color(0xFFFEF3C7);
      statusTextColor = const Color(0xFFB45309);
      statusDot = '🟡';
    } else if (now.isAfter(hackathon.endDate)) {
      currentStatus = 'COMPLETED';
      statusBg = const Color(0xFFDBEAFE);
      statusTextColor = const Color(0xFF1D4ED8);
      statusDot = '🔵';
    } else {
      currentStatus = 'ONGOING';
      statusBg = const Color(0xFFDCFCE7);
      statusTextColor = const Color(0xFF15803D);
      statusDot = '🟢';
    }

    final rulesList = registration?.rules.isNotEmpty == true
        ? registration!.rules
        : [
            'All code commits must occur within the specified event timeline.',
            'Projects must be built during the hackathon. Pre-existing code bases are prohibited.',
            'Submissions require an open-source GitHub link and a video demo.',
            'Adhere to safety, ethical AI, and conduct guidelines.',
          ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: const Color(0xFF0F172A),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                hackathon.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: hackathon.bannerImage.isNotEmpty
                        ? hackathon.bannerImage
                        : 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=800&q=80',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: const Color(0xFF1E293B)),
                    errorWidget: (context, url, error) => Container(
                      color: const Color(0xFF312E81),
                      child: const Center(
                        child: Icon(Icons.military_tech_rounded, size: 60, color: Colors.white38),
                      ),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Color(0xD9000000)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges & Status Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$statusDot $currentStatus',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: statusTextColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E7FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          hackathon.mode,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4338CA),
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (isRegistered)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF15803D)),
                              SizedBox(width: 4),
                              Text(
                                'Registered',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF15803D),
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (hackathon.registrationOpen)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Registration Open',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB45309),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Organized by ${hackathon.organizer}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Event Metadata Highlights Box
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          Icons.calendar_today_rounded,
                          'Date & Time',
                          '$startDateStr – $endDateStr',
                          const Color(0xFF2563EB),
                        ),
                        const Divider(height: 24),
                        _buildDetailRow(
                          Icons.location_on_rounded,
                          'Venue / Online',
                          '${hackathon.mode}${hackathon.location.isNotEmpty && hackathon.location.toLowerCase() != 'online' ? ' (${hackathon.location})' : ''}',
                          const Color(0xFF059669),
                        ),
                        const Divider(height: 24),
                        _buildDetailRow(
                          Icons.hourglass_bottom_rounded,
                          'Submission Deadline',
                          dateFormat.format(hackathon.endDate),
                          const Color(0xFFDC2626),
                        ),
                        const Divider(height: 24),
                        _buildDetailRow(
                          Icons.emoji_events_rounded,
                          'Prize Pool',
                          hackathon.prizePool,
                          const Color(0xFFD97706),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // External Hackathon Registration Link Banner Button (Workflow Step 2 & 3)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFC7D2FE)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.open_in_new_rounded, color: Color(0xFF4F46E5), size: 20),
                            SizedBox(width: 8),
                            Text('External Registration Portal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF4F46E5))),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Register on the official external platform (${hackathon.externalRegistrationUrl}), then return to CMS to submit team details and upload registration screenshot proof.',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.4),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                title: const Row(
                                  children: [
                                    Icon(Icons.open_in_new_rounded, color: Color(0xFF4F46E5)),
                                    SizedBox(width: 8),
                                    Text('External Registration Link'),
                                  ],
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Opening official portal link for "${hackathon.title}":', style: const TextStyle(fontSize: 13)),
                                    const SizedBox(height: 10),
                                    SelectableText(
                                      hackathon.externalRegistrationUrl,
                                      style: const TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    const SizedBox(height: 14),
                                    const Text('After completing registration on the external platform, return to CMS to enter your team members and upload screenshot proof.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                  ],
                                ),
                                actions: [
                                  TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('🌐 Redirecting to ${hackathon.externalRegistrationUrl}'),
                                          backgroundColor: const Color(0xFF4F46E5),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), foregroundColor: Colors.white),
                                    child: const Text('Open Portal'),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.launch_rounded, size: 16),
                          label: const Text('Click to Register on External Portal', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF4F46E5),
                            side: const BorderSide(color: Color(0xFF4F46E5)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Registered Team Info Card if Registered
                  if (registration != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF312E81).withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'My Team Registration',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: registration.isVerified
                                      ? const Color(0xFF10B981)
                                      : registration.isCorrectionRequired
                                          ? const Color(0xFFEF4444)
                                          : const Color(0xFFF59E0B),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  registration.verificationStatus,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.groups_rounded, color: Color(0xFFA5B4FC), size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Team Name: ${registration.teamName}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Year & Section: ${registration.year} (${registration.section}) • Ext Reg ID: ${registration.externalRegistrationId}',
                            style: const TextStyle(color: Color(0xFFC7D2FE), fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Assigned Class Advisor: ${registration.assignedAdvisorName}',
                            style: const TextStyle(color: Color(0xFF34D399), fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Members (Max 6): ${registration.teamMembers.join(', ')}',
                            style: const TextStyle(
                              color: Color(0xFFC7D2FE),
                              fontSize: 12,
                            ),
                          ),
                          if (registration.isCorrectionRequired && registration.advisorCorrectionNotes != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFFCA5A5)),
                              ),
                              child: Text(
                                'Advisor Note: "${registration.advisorCorrectionNotes}"',
                                style: const TextStyle(color: Color(0xFFFECACA), fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                          if (registration.projectSubmissionUrl != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.link_rounded, color: Color(0xFF34D399), size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Submitted: ${registration.projectSubmissionTitle ?? registration.projectSubmissionUrl}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Activity Log Timeline Section (Requirement #13)
                  if (registration != null && registration.activities.isNotEmpty) ...[
                    const Text(
                      'Hackathon Activity Timeline',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Chronological history of team actions, advisor reviews, and status transitions:',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: registration!.activities.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final act = entry.value;
                          final isLast = idx == registration!.activities.length - 1;
                          final timeStr = DateFormat('hh:mm a').format(act.timestamp);
                          final dateStr = DateFormat('MMM dd').format(act.timestamp);

                          Color iconBg;
                          IconData iconData;
                          if (act.activityType.contains('verified')) {
                            iconBg = const Color(0xFF10B981);
                            iconData = Icons.verified_rounded;
                          } else if (act.activityType.contains('correction')) {
                            iconBg = const Color(0xFFEF4444);
                            iconData = Icons.warning_amber_rounded;
                          } else if (act.activityType.contains('submitted')) {
                            iconBg = const Color(0xFF3B82F6);
                            iconData = Icons.send_rounded;
                          } else if (act.activityType.contains('created')) {
                            iconBg = const Color(0xFF8B5CF6);
                            iconData = Icons.groups_rounded;
                          } else {
                            iconBg = const Color(0xFF6366F1);
                            iconData = Icons.history_rounded;
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: iconBg.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(iconData, color: iconBg, size: 16),
                                  ),
                                  if (!isLast)
                                    Container(
                                      width: 2,
                                      height: 32,
                                      color: const Color(0xFFE2E8F0),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '$timeStr ($dateStr)',
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                                          ),
                                          if (act.newStatus != null)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: iconBg.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                act.newStatus!,
                                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: iconBg),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        act.description,
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Description
                  const Text(
                    'About the Hackathon',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hackathon.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF334155),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Rules Section
                  const Text(
                    'Rules & Guidelines',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...rulesList.map(
                    (rule) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '• ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4F46E5),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              rule,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF334155),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Technologies / Tags
                  if (hackathon.tags.isNotEmpty) ...[
                    const Text(
                      'Technologies & Domains',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: hackathon.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E8FF),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFDDD6FE)),
                          ),
                          child: Text(
                            '#$tag',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6D28D9),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Action Buttons
                  if (currentStatus == 'ONGOING' && registration != null)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => _showSubmitProjectModal(context, ref, registration!),
                        icon: const Icon(Icons.cloud_upload_rounded, size: 20),
                        label: Text(
                          registration.projectSubmissionUrl != null ? 'Update Submitted Project' : 'Submit Project',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: !hackathon.registrationOpen && !isRegistered
                            ? null
                            : () {
                                if (isRegistered) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => HackathonTeamManagementScreen(hackathon: hackathon),
                                    ),
                                  );
                                } else {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => HackathonRegistrationScreen(hackathon: hackathon),
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isRegistered ? const Color(0xFF10B981) : const Color(0xFF1E40AF),
                          disabledBackgroundColor: const Color(0xFFCBD5E1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        child: Text(
                          isRegistered
                              ? '✓ CMS Registered (Manage Team)'
                              : hackathon.registrationOpen
                                  ? 'Enter CMS Registration & Upload Screenshot'
                                  : 'Registration Closed',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            ],
          ),
        ),
      ],
    );
  }

  void _showSubmitProjectModal(BuildContext context, WidgetRef ref, HackathonRegistrationModel reg) {
    final titleController = TextEditingController(text: reg.projectSubmissionTitle ?? '');
    final urlController = TextEditingController(text: reg.projectSubmissionUrl ?? '');
    final notesController = TextEditingController(text: reg.projectSubmissionNotes ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFD1FAE5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_upload_rounded, color: Color(0xFF059669), size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Submit Project',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    reg.hackathonTitle,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Project Title',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Autonomous AI Agent System',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  validator: (val) => (val == null || val.trim().isEmpty) ? 'Project title is required' : null,
                ),
                const SizedBox(height: 14),
                const Text(
                  'GitHub / Demo URL',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: urlController,
                  decoration: InputDecoration(
                    hintText: 'https://github.com/team/project',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  validator: (val) => (val == null || val.trim().isEmpty) ? 'Repository or demo link is required' : null,
                ),
                const SizedBox(height: 14),
                const Text(
                  'Submission Notes (Optional)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Brief summary of features, tech stack, or live credentials...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                ref.read(hackathonRegistrationProvider.notifier).submitProject(
                      registrationId: reg.id,
                      projectUrl: urlController.text.trim(),
                      projectTitle: titleController.text.trim(),
                      notes: notesController.text.trim(),
                    );
                Navigator.of(dialogCtx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🎉 Project successfully submitted for ${reg.hackathonTitle}!'),
                    backgroundColor: const Color(0xFF10B981),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Confirm Submission'),
          ),
        ],
      ),
    );
  }
}
