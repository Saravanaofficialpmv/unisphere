import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/core/constants/app_colors.dart';
import 'package:unisphere/providers/post_od_provider.dart';
import 'package:unisphere/providers/notification_provider.dart';

class HodLeaveManagement extends ConsumerStatefulWidget {
  const HodLeaveManagement({super.key});

  @override
  ConsumerState<HodLeaveManagement> createState() => _HodLeaveManagementState();
}

class _HodLeaveManagementState extends ConsumerState<HodLeaveManagement> {
  String _activeTab = 'Faculty Requests';
  String _postOdFilter = 'All Outcomes';

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
    final postOdState = ref.watch(postOdProvider);

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
            _buildStatSummary(postOdState.outcomes),
            const SizedBox(height: 20),
            _buildCategoryTabs(),
            const SizedBox(height: 20),

            if (_activeTab == 'Post-OD Outcomes & Certs') ...[
              _buildPostOdApprovalPortal(context, postOdState.outcomes),
            ] else ...[
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
          ],
        ),
      ),
    );
  }

  Widget _buildStatSummary(List<PostOdOutcomeModel> outcomes) {
    final pendingOdOutcomes = outcomes.where((o) => o.hodStatus == 'Pending HOD Verification').length;

    return Row(
      children: [
        _buildSmallStat('Pending Leaves', '8 Requests', AppColors.warning),
        const SizedBox(width: 10),
        _buildSmallStat('Post-OD Outcomes', '$pendingOdOutcomes Review', const Color(0xFF2563EB)),
        const SizedBox(width: 10),
        _buildSmallStat('Approved Today', '45 Requests', AppColors.success),
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
    final tabs = ['Faculty Requests', 'Student Requests', 'On Duty Requests', 'Post-OD Outcomes & Certs'];
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

  // ── POST-OD VERIFICATION & CERTIFICATE APPROVAL PORTAL FOR HOD ─────────────

  Widget _buildPostOdApprovalPortal(BuildContext context, List<PostOdOutcomeModel> outcomes) {
    final filteredOutcomes = outcomes.where((o) {
      if (_postOdFilter == 'Pending HOD Verification') return o.hodStatus == 'Pending HOD Verification';
      if (_postOdFilter == 'Won (Certs Review)') return o.isWon;
      if (_postOdFilter == 'Lost (Post-Mortem Reports)') return o.isLost;
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sub-filter row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              {'label': 'All Outcomes (${outcomes.length})', 'value': 'All Outcomes'},
              {'label': 'Pending Verification (${outcomes.where((o) => o.hodStatus == 'Pending HOD Verification').length})', 'value': 'Pending HOD Verification'},
              {'label': 'Won (${outcomes.where((o) => o.isWon).length})', 'value': 'Won (Certs Review)'},
              {'label': 'Lost (${outcomes.where((o) => o.isLost).length})', 'value': 'Lost (Post-Mortem Reports)'},
            ].map((f) {
              final val = f['value']!;
              final isSel = _postOdFilter == val;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(f['label']!),
                  selected: isSel,
                  onSelected: (_) => setState(() => _postOdFilter = val),
                  selectedColor: const Color(0xFF1D4ED8),
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(color: isSel ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 11.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: isSel ? const Color(0xFF1D4ED8) : AppColors.border)),
                  showCheckmark: false,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),

        if (filteredOutcomes.isEmpty)
          Container(
            padding: const EdgeInsets.all(30),
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: const Text('No Post-OD outcome reports found matching this filter.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredOutcomes.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = filteredOutcomes[index];
              return _buildPostOdCard(context, item);
            },
          ),
      ],
    );
  }

  Widget _buildPostOdCard(BuildContext context, PostOdOutcomeModel item) {
    final isWon = item.isWon;
    final isPending = item.hodStatus == 'Pending HOD Verification';
    final badgeColor = isWon ? const Color(0xFF059669) : const Color(0xFFDC2626);
    final badgeBg = isWon ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: isPending ? const Color(0xFF93C5FD) : AppColors.border, width: isPending ? 1.5 : 1.0),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(6)),
                      child: Text(item.eventCategory, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                    ),
                    const SizedBox(height: 4),
                    Text(item.eventName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: badgeColor.withValues(alpha: 0.3))),
                child: Text(
                  isWon ? '🏆 WON (${item.prizeTitle ?? 'Prize'})' : '❌ LOST / PARTICIPATED',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: badgeColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Text('Team Leader: ${item.teamLeaderName} (${item.teamLeaderRollNo}) • Date: ${item.eventDate}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 12),

          if (isWon) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Row(
                children: [
                  const Icon(Icons.workspace_premium_rounded, color: Color(0xFFD97706), size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Reward & Position: ${item.cashPrizeAmount ?? 'Merit Shield'}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        if (item.teamCertificateUrl != null) Text('Team Cert Document: ${item.teamCertificateUrl}', style: const TextStyle(fontSize: 11, color: Color(0xFF2563EB))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // MANDATORY LOSS REASON DISPLAY FOR HOD
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFFCA5A5))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.report_problem_rounded, color: Color(0xFFDC2626), size: 18),
                      SizedBox(width: 8),
                      Text('POST-MORTEM ANALYSIS & REASON FOR LOSS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFB91C1C), letterSpacing: 0.8)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.lossReason ?? 'No detailed loss reason provided by team leader.',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF7F1D1D), height: 1.3),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // TEAMMATES CERTIFICATE MATRIX TABLE
          const Text('Team Members & Individual Certificates', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 8),

          Container(
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: item.teamMembers.map((m) {
                final isLeader = m.uid == item.teamLeaderUid;
                final bool isApproved = m.status == 'HOD Approved';

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0)))),
                  child: Row(
                    children: [
                      Icon(isLeader ? Icons.star_rounded : Icons.person_rounded, size: 18, color: isLeader ? const Color(0xFFD97706) : const Color(0xFF64748B)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(m.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                if (isLeader) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(4)),
                                    child: const Text('LEADER', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8))),
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              m.hasSubmittedCert ? 'Cert: ${m.certificateUrl ?? 'Attached.pdf'}' : 'Certificate pending teammate upload',
                              style: TextStyle(fontSize: 10.5, color: m.hasSubmittedCert ? const Color(0xFF2563EB) : const Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isApproved ? const Color(0xFFECFDF5) : (m.hasSubmittedCert ? const Color(0xFFFEF3C7) : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          m.status,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: isApproved ? const Color(0xFF059669) : (m.hasSubmittedCert ? const Color(0xFFD97706) : const Color(0xFF64748B)),
                          ),
                        ),
                      ),
                      if (m.hasSubmittedCert && !isApproved) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 20),
                          tooltip: 'Approve Teammate Cert',
                          onPressed: () {
                            ref.read(postOdProvider.notifier).approveMemberCertByHod(item.id, m.uid);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Certificate approved for ${m.name}!'), backgroundColor: const Color(0xFF059669)),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // HOD APPROVAL & REJECTION BAR
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(postOdProvider.notifier).approveOutcomeByHod(item.id, remarks: 'Verified outcome & certificates approved by HOD.');

                    ref.read(notificationProvider.notifier).addNotification(
                          title: '✅ OD Outcome & Certificates Approved by HOD',
                          category: 'Academic',
                          summary: 'HOD verified and approved outcome & certificates for ${item.eventName}.',
                          fullDetails: 'OD Verified by Department HOD.',
                          icon: Icons.verified_rounded,
                          iconColor: const Color(0xFF059669),
                          iconBgColor: const Color(0xFFECFDF5),
                          badgeText: 'APPROVED',
                          badgeColor: const Color(0xFF059669),
                          badgeTextColor: Colors.white,
                        );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Post-OD outcome & certificates approved by HOD!'), backgroundColor: AppColors.success),
                    );
                  },
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                  label: Text(item.hodStatus == 'HOD Approved' ? 'Approved (Update)' : 'Approve Outcome & Certs'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () {
                  _showHodRejectDialog(context, item.id);
                },
                icon: const Icon(Icons.cancel_outlined, size: 18),
                label: const Text('Reject / Re-upload'),
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showHodRejectDialog(BuildContext context, String outcomeId) {
    final remarksCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.report_problem_rounded, color: Color(0xFFDC2626)),
            SizedBox(width: 10),
            Text('Request Certificate Revision', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Specify reason or required document revision for the team:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            TextField(
              controller: remarksCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g. Uploaded certificate is blurry or missing official institutional stamp...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ref.read(postOdProvider.notifier).rejectOutcomeByHod(outcomeId, remarks: remarksCtrl.text.isEmpty ? 'HOD requested certificate revision.' : remarksCtrl.text);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feedback sent to student team!'), backgroundColor: AppColors.error));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            child: const Text('Send Feedback'),
          ),
        ],
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

