import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:unisphere/widgets/common/unisphere_header_card.dart';
import 'package:unisphere/providers/attendance_system_provider.dart';
import 'package:unisphere/providers/post_od_provider.dart';
import 'package:unisphere/providers/notification_provider.dart';
import 'package:unisphere/models/attendance_model.dart';

class StudentAttendanceScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;

  const StudentAttendanceScreen({
    super.key,
    this.onBack,
  });

  @override
  ConsumerState<StudentAttendanceScreen> createState() => _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends ConsumerState<StudentAttendanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;
  String _historyFilter = 'All';
  String _searchQuery = '';

  // Interactive Attendance Simulator ("What-If" Calculator) state
  bool _showSimulator = false;
  int _simulatedAttendDays = 0;
  int _simulatedMissDays = 0;

  // Track expanded subject card index
  int? _expandedSubjectIndex;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedTabIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleBack(BuildContext context) {
    if (!mounted) return;
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _showLeaveApplicationModal() {
    final reasonController = TextEditingController();
    String leaveType = 'Medical Leave';
    String startDate = '12 Aug 2026';
    String endDate = '13 Aug 2026';
    bool attachedFile = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Apply for Leave / OD',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Submit request for HOD & Counselor approval',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              const Text('Leave Category', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: leaveType,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                ),
                items: ['Medical Leave', 'On Duty (OD)', 'Casual Leave', 'Event / Sports OD']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13))))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setModalState(() => leaveType = val);
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Start Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF2563EB)),
                              const SizedBox(width: 8),
                              Text(startDate, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('End Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.event_rounded, size: 16, color: Color(0xFF2563EB)),
                              const SizedBox(width: 8),
                              Text(endDate, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text('Reason & Explanation', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
              const SizedBox(height: 6),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Describe reason for leave / event details...',
                  hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                ),
              ),
              const SizedBox(height: 14),
              InkWell(
                onTap: () {
                  setModalState(() => attachedFile = !attachedFile);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: attachedFile ? const Color(0xFFECFDF5) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: attachedFile ? const Color(0xFF10B981) : const Color(0xFFCBD5E1)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        attachedFile ? Icons.check_circle_rounded : Icons.attach_file_rounded,
                        color: attachedFile ? const Color(0xFF059669) : const Color(0xFF2563EB),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          attachedFile ? 'Medical_Certificate_Aug2026.pdf attached' : 'Attach Medical / OD Proof (PDF / Image)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: attachedFile ? const Color(0xFF059669) : const Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final req = LeaveRequestModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      studentName: 'Alex Johnson',
                      type: leaveType,
                      duration: '$startDate - $endDate (2 Days)',
                      reason: reasonController.text.trim().isEmpty ? 'Leave application' : reasonController.text.trim(),
                      status: 'Pending Approval',
                      appliedDate: 'Today',
                      hasAttachment: attachedFile,
                    );
                    ref.read(attendanceSystemProvider.notifier).addLeaveRequest(req);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Leave application submitted for HOD approval!'),
                        backgroundColor: Color(0xFF059669),
                      ),
                    );
                  },
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text('Submit Application', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPostOdLeaderFormModal() {
    final eventNameCtrl = TextEditingController(text: 'IIT Madras Inter-College Hackathon 2026');
    final prizeTitleCtrl = TextEditingController(text: '1st Prize / Winner Gold Trophy');
    final cashPrizeCtrl = TextEditingController(text: '₹50,000 & Trophy');
    final lossReasonCtrl = TextEditingController();
    String outcomeChoice = 'Won'; // 'Won' or 'Lost'
    String eventCategory = 'Hackathon & Coding';
    String teamCertificateFile = 'Team_Winner_Certificate.pdf';

    final selectedMembers = <Map<String, String>>[
      {'uid': '917722104022', 'name': 'Alex Johnson (Leader)', 'rollNo': '917722104022'},
      {'uid': '917722104012', 'name': 'Aravind Swamy', 'rollNo': '917722104012'},
      {'uid': '917722104045', 'name': 'Priya Dharshini', 'rollNo': '917722104045'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.88,
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.emoji_events_rounded, color: Color(0xFF1D4ED8), size: 24),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Post-OD Event Return Form', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                          Text('Team Leader Outcome & Certificate Submission', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        ],
                      ),
                    ],
                  ),
                  IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Event Category', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: eventCategory,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                        ),
                        items: ['Hackathon & Coding', 'Technical Paper Presentation', 'Robotics & Hardware Expo', 'Sports & Cultural Fest']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13))))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setModalState(() => eventCategory = val);
                        },
                      ),
                      const SizedBox(height: 14),

                      const Text('Event / Competition Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                      const SizedBox(height: 6),
                      TextField(
                        controller: eventNameCtrl,
                        decoration: InputDecoration(
                          hintText: 'Enter institution & event name...',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text('EVENT OUTCOME STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF), letterSpacing: 0.8)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setModalState(() => outcomeChoice = 'Won'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: outcomeChoice == 'Won' ? const Color(0xFFECFDF5) : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: outcomeChoice == 'Won' ? const Color(0xFF059669) : const Color(0xFFCBD5E1),
                                    width: outcomeChoice == 'Won' ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.military_tech_rounded, color: outcomeChoice == 'Won' ? const Color(0xFF059669) : const Color(0xFF64748B), size: 24),
                                    const SizedBox(height: 4),
                                    Text('🏆 WON / PRIZE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: outcomeChoice == 'Won' ? const Color(0xFF047857) : const Color(0xFF64748B))),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setModalState(() => outcomeChoice = 'Lost'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: outcomeChoice == 'Lost' ? const Color(0xFFFEF2F2) : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: outcomeChoice == 'Lost' ? const Color(0xFFDC2626) : const Color(0xFFCBD5E1),
                                    width: outcomeChoice == 'Lost' ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.flag_rounded, color: outcomeChoice == 'Lost' ? const Color(0xFFDC2626) : const Color(0xFF64748B), size: 24),
                                    const SizedBox(height: 4),
                                    Text('❌ LOST / PARTICIPATED', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: outcomeChoice == 'Lost' ? const Color(0xFFB91C1C) : const Color(0xFF64748B))),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (outcomeChoice == 'Won') ...[
                        const Text('Prize / Merit Position', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                        const SizedBox(height: 6),
                        TextField(
                          controller: prizeTitleCtrl,
                          decoration: InputDecoration(
                            hintText: 'e.g. 1st Place Winner, 2nd Runner Up',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text('Cash Reward / Trophy Info', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                        const SizedBox(height: 6),
                        TextField(
                          controller: cashPrizeCtrl,
                          decoration: InputDecoration(
                            hintText: 'e.g. ₹25,000 cash prize & Winner Shield',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                          ),
                        ),
                        const SizedBox(height: 14),

                        const Text('Team Winner Certificate Document', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () {
                            setModalState(() {
                              teamCertificateFile = 'IITM_Hackathon_Winner_Certificate.pdf';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFBFDBFE)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFF2563EB), size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(teamCertificateFile, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1E3A8A))),
                                      const Text('Tap to attach/change team certificate scan', style: TextStyle(fontSize: 10, color: Color(0xFF3B82F6))),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 20),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        // MANDATORY LOSS REASON ANALYSIS
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 20),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Mandatory HOD Requirement: Explain the technical issues, jury feedback, or reasons for not placing in top positions.',
                                  style: TextStyle(fontSize: 11, color: Color(0xFF92400E), fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text('Reason for Loss & Post-Mortem Analysis *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                        const SizedBox(height: 6),
                        TextField(
                          controller: lossReasonCtrl,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Enter detailed post-mortem report (e.g. GPU memory limits during live demo, prototype latency, jury suggestions)...',
                            contentPadding: const EdgeInsets.all(14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),
                      const Text('Registered Team Members (Notified upon submission)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                      const SizedBox(height: 8),
                      ...selectedMembers.map((m) => Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.person_rounded, size: 16, color: Color(0xFF2563EB)),
                                const SizedBox(width: 8),
                                Expanded(child: Text('${m['name']} (${m['rollNo']})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                                if (m['uid'] == '917722104022')
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(4)),
                                    child: const Text('LEADER', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8))),
                                  ),
                              ],
                            ),
                          )),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (outcomeChoice == 'Lost' && lossReasonCtrl.text.trim().length < 10) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill out the mandatory Reason for Loss / Post-Mortem Analysis before submitting.'),
                          backgroundColor: Color(0xFFDC2626),
                        ),
                      );
                      return;
                    }

                    ref.read(postOdProvider.notifier).submitLeaderOutcome(
                          odRequestId: 'l2',
                          eventName: eventNameCtrl.text,
                          eventCategory: eventCategory,
                          eventDate: '28 Jul 2026',
                          teamLeaderUid: '917722104022',
                          teamLeaderName: 'Alex Johnson (Leader)',
                          teamLeaderRollNo: '917722104022',
                          outcome: outcomeChoice,
                          prizeTitle: outcomeChoice == 'Won' ? prizeTitleCtrl.text : null,
                          cashPrizeAmount: outcomeChoice == 'Won' ? cashPrizeCtrl.text : null,
                          lossReason: outcomeChoice == 'Lost' ? lossReasonCtrl.text : null,
                          teamCertificateUrl: outcomeChoice == 'Won' ? teamCertificateFile : null,
                          members: selectedMembers,
                        );

                    ref.read(notificationProvider.notifier).addNotification(
                          title: outcomeChoice == 'Won' ? '🏆 OD Outcome Filed: WON 1st Prize!' : 'OD Outcome Filed: Post-Mortem Submitted',
                          category: 'Academic',
                          summary: outcomeChoice == 'Won'
                              ? 'Team Leader Alex Johnson reported WON for ${eventNameCtrl.text}. Teammates must upload certificates.'
                              : 'Team Leader Alex Johnson filed Post-OD Loss Analysis report to HOD.',
                          fullDetails: 'OD Return Status filed for ${eventNameCtrl.text}. HOD verification pending.',
                          icon: Icons.military_tech_rounded,
                          iconColor: outcomeChoice == 'Won' ? const Color(0xFF059669) : const Color(0xFFDC2626),
                          iconBgColor: outcomeChoice == 'Won' ? const Color(0xFFECFDF5) : const Color(0xFFFEE2E2),
                          badgeText: 'OD UPDATE',
                          badgeColor: const Color(0xFF2563EB),
                          badgeTextColor: Colors.white,
                        );

                    Navigator.pop(ctx);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(outcomeChoice == 'Won'
                            ? 'OD Outcome "WON" submitted! Teammates have been notified to upload certificates.'
                            : 'Post-OD Loss Analysis report submitted to HOD successfully.'),
                        backgroundColor: const Color(0xFF059669),
                      ),
                    );
                  },
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text('Submit Post-OD Outcome to HOD', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D4ED8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMemberCertificateUploadSheet(BuildContext context, String outcomeId, String eventName) {
    String filename = 'Alex_Individual_Merit_Cert.pdf';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.workspace_premium_rounded, color: Color(0xFF2563EB), size: 24),
                      SizedBox(width: 10),
                      Text('Upload Teammate Certificate', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    ],
                  ),
                  IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 8),
              Text('Event: $eventName', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 14),

              const Text('Attach Your Individual Certificate Document', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
              const SizedBox(height: 8),

              InkWell(
                onTap: () {
                  setModalState(() {
                    filename = 'Individual_Participation_Certificate.pdf';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFF2563EB), size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(filename, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1E3A8A))),
                            const Text('Tap to choose clear PDF scan of certificate', style: TextStyle(fontSize: 10, color: Color(0xFF3B82F6))),
                          ],
                        ),
                      ),
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 20),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(postOdProvider.notifier).submitMemberCertificate(
                          outcomeId: outcomeId,
                          memberUid: '917722104022',
                          certificateUrl: filename,
                        );

                    ref.read(notificationProvider.notifier).addNotification(
                          title: '📜 Certificate Uploaded for HOD Approval',
                          category: 'Academic',
                          summary: 'Individual certificate uploaded for $eventName. HOD review pending.',
                          fullDetails: 'Certificate submitted for OD approval.',
                          icon: Icons.workspace_premium_rounded,
                          iconColor: const Color(0xFF2563EB),
                          iconBgColor: const Color(0xFFEFF6FF),
                          badgeText: 'CERTIFICATE',
                          badgeColor: const Color(0xFF10B981),
                          badgeTextColor: Colors.white,
                        );

                    Navigator.pop(ctx);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Individual certificate submitted successfully! HOD verification in progress.'),
                        backgroundColor: Color(0xFF059669),
                      ),
                    );
                  },
                  icon: const Icon(Icons.upload_file_rounded, size: 18),
                  label: const Text('Submit Certificate for HOD Verification', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final systemState = ref.watch(attendanceSystemProvider);
    final semDataList = systemState.studentSemesters;
    final activeSemData = systemState.selectedSemester;

    final double overallPercentage = activeSemData.attendancePercentage / 100.0;
    final int overallAttended = activeSemData.attendedWorkingDays;
    final int overallTotalDays = activeSemData.totalWorkingDays;
    final String statusStr = activeSemData.statusLabel;
    final String safeMarginStr = activeSemData.safeMarginText;
    final bool isCurrentSem = activeSemData.isCurrentSemester;

    final filteredLogs = systemState.attendanceLogs.where((l) {
      final matchesFilter = _historyFilter == 'All' || l.status.label == _historyFilter;
      final matchesQuery = _searchQuery.isEmpty ||
          l.subjectName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          l.subjectCode.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesFilter && matchesQuery;
    }).toList();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack(context);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Column(
            children: [
              UnisphereHeaderCard(
                title: 'Attendance Tracker',
                subtitle: 'Monitor your course attendance and records',
                onBack: () => _handleBack(context),
                rightActions: [
                  IconButton(
                    icon: const Icon(Icons.note_add_outlined, color: Colors.white70),
                    tooltip: 'Apply Leave',
                    onPressed: _showLeaveApplicationModal,
                  ),
                ],
                bottomWidget: Container(
                  height: 44,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    onTap: (index) {
                      setState(() {
                        _selectedTabIndex = index;
                      });
                    },
                    indicator: BoxDecoration(
                      color: const Color(0xFF1E3A8A),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: const Color(0xFFBFDBFE),
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'Breakdown'),
                      Tab(text: 'History Log'),
                      Tab(text: 'Leave & OD'),
                    ],
                  ),
                ),
              ),

              // Tab Content Body
              Expanded(
                child: IndexedStack(
                  index: _selectedTabIndex,
                  children: [
                    // Tab 0: Subject Breakdown with Semester Chips
                    _buildSubjectBreakdownTab(
                      semDataList: semDataList,
                      selectedSemData: activeSemData,
                      summaryCard: _buildSummaryCard(
                        overallPercentage: overallPercentage,
                        overallAttended: overallAttended,
                        overallTotalDays: overallTotalDays,
                        statusStr: statusStr,
                        safeMarginStr: safeMarginStr,
                        isCurrentSem: isCurrentSem,
                      ),
                    ),

                    // Tab 1: History Log
                    _buildHistoryLogTab(
                      filteredLogs: filteredLogs,
                      totalLogsCount: systemState.attendanceLogs.length,
                      summaryCard: _buildSummaryCard(
                        overallPercentage: overallPercentage,
                        overallAttended: overallAttended,
                        overallTotalDays: overallTotalDays,
                        statusStr: statusStr,
                        safeMarginStr: safeMarginStr,
                        isCurrentSem: isCurrentSem,
                      ),
                    ),

                    // Tab 2: Leave & OD Tracker
                    _buildLeaveTrackerTab(
                      leaveRequests: systemState.leaveRequests,
                      summaryCard: _buildSummaryCard(
                        overallPercentage: overallPercentage,
                        overallAttended: overallAttended,
                        overallTotalDays: overallTotalDays,
                        statusStr: statusStr,
                        safeMarginStr: safeMarginStr,
                        isCurrentSem: isCurrentSem,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required double overallPercentage,
    required int overallAttended,
    required int overallTotalDays,
    required String statusStr,
    required String safeMarginStr,
    required bool isCurrentSem,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E40AF), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D4ED8).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 42.0,
            lineWidth: 7.0,
            percent: overallPercentage.clamp(0.0, 1.0),
            center: Text(
              '${(overallPercentage * 100).toStringAsFixed(1)}%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
            progressColor: const Color(0xFF34D399),
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusStr,
                        style: const TextStyle(color: Color(0xFFB45309), fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (isCurrentSem)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'ACTIVE SEMESTER',
                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '$overallAttended / $overallTotalDays Days Attended (HOD Set)',
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shield_rounded, size: 12, color: Color(0xFF34D399)),
                      const SizedBox(width: 4),
                      Text(
                        safeMarginStr,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectBreakdownTab({
    required List<SemesterAttendance> semDataList,
    required SemesterAttendance selectedSemData,
    required Widget summaryCard,
  }) {
    final subjectsList = selectedSemData.subjects;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          summaryCard,
          _buildSemesterPills(semDataList),
          const SizedBox(height: 6),
          _buildAttendanceSimulatorWidget(selectedSemData.attendedWorkingDays, selectedSemData.totalWorkingDays),
          const SizedBox(height: 10),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: subjectsList.length,
            itemBuilder: (context, index) {
              final item = subjectsList[index];
              final Color color = Color(item.colorValue);
              final double pct = item.percentage / 100.0;
              final bool isLow = item.isLow;
              final bool isExpanded = _expandedSubjectIndex == index;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: isLow ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _expandedSubjectIndex = isExpanded ? null : index;
                    });
                  },
                  borderRadius: BorderRadius.circular(18),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    item.code,
                                    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${(pct * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: isLow ? const Color(0xFFDC2626) : const Color(0xFF059669),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Faculty: ${item.facultyName}',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${item.credits} Credits',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearPercentIndicator(
                          lineHeight: 8.0,
                          percent: pct.clamp(0.0, 1.0),
                          backgroundColor: const Color(0xFFF1F5F9),
                          progressColor: isLow ? const Color(0xFFDC2626) : color,
                          barRadius: const Radius.circular(4),
                          padding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Attended: ${item.attendedSessions} of ${item.totalSessions} sessions',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF475569)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isLow ? const Color(0xFFFEE2E2) : const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.safeMarginText,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isLow ? const Color(0xFFDC2626) : const Color(0xFF059669),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Expanded Details Drawer
                        if (isExpanded) ...[
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Recent Session Logs:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildSessionPill('Today', 'Present', const Color(0xFF059669)),
                                    _buildSessionPill('Yesterday', 'Present', const Color(0xFF059669)),
                                    _buildSessionPill('05 Aug', isLow ? 'Absent' : 'Present', isLow ? const Color(0xFFDC2626) : const Color(0xFF059669)),
                                    _buildSessionPill('02 Aug', 'Present', const Color(0xFF059669)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSessionPill(String date, String status, Color color) {
    return Column(
      children: [
        Text(date, style: const TextStyle(fontSize: 9, color: Color(0xFF64748B))),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            status,
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color),
          ),
        ),
      ],
    );
  }

  Widget _buildSemesterPills(List<SemesterAttendance> semDataList) {
    final systemState = ref.watch(attendanceSystemProvider);
    final selectedIndex = systemState.selectedSemesterIndex;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: List.generate(semDataList.length, (index) {
          final sem = semDataList[index];
          final isSel = index == selectedIndex;
          final isCurrent = sem.isCurrentSemester;

          return GestureDetector(
            onTap: () {
              ref.read(attendanceSystemProvider.notifier).selectSemesterIndex(index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSel ? const Color(0xFF1D4ED8) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSel ? const Color(0xFF1D4ED8) : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
                boxShadow: [
                  if (isSel)
                    BoxShadow(
                      color: const Color(0xFF1D4ED8).withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Sem ${sem.semesterNumber}',
                    style: TextStyle(
                      color: isSel ? Colors.white : const Color(0xFF334155),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  if (isCurrent) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSel ? const Color(0xFF34D399) : const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'ACTIVE',
                        style: TextStyle(
                          color: isSel ? const Color(0xFF064E3B) : const Color(0xFF15803D),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAttendanceSimulatorWidget(int currentAttended, int currentTotal) {
    final projectedAttended = (currentAttended + _simulatedAttendDays).clamp(0, 500);
    final projectedTotal = (currentTotal + _simulatedAttendDays + _simulatedMissDays).clamp(1, 500);
    final projectedPct = (projectedAttended / projectedTotal) * 100.0;
    final currentPct = (currentAttended / currentTotal) * 100.0;
    final diff = projectedPct - currentPct;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _showSimulator = !_showSimulator),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.calculate_rounded, color: Color(0xFF38BDF8), size: 20),
                      SizedBox(width: 10),
                      Text(
                        'ATTENDANCE SIMULATOR (WHAT-IF)',
                        style: TextStyle(
                          color: Color(0xFF38BDF8),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    _showSimulator ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF38BDF8),
                  ),
                ],
              ),
            ),
          ),
          if (_showSimulator) ...[
            const Divider(color: Color(0xFF1E293B), height: 1),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Classes to Attend',
                              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                IconButton.filledTonal(
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  onPressed: () {
                                    if (_simulatedAttendDays > 0) {
                                      setState(() => _simulatedAttendDays--);
                                    }
                                  },
                                  icon: const Icon(Icons.remove, size: 16),
                                  style: IconButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E293B),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    '+$_simulatedAttendDays',
                                    style: const TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ),
                                IconButton.filledTonal(
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  onPressed: () => setState(() => _simulatedAttendDays++),
                                  icon: const Icon(Icons.add, size: 16),
                                  style: IconButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E293B),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Classes to Miss',
                              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                IconButton.filledTonal(
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  onPressed: () {
                                    if (_simulatedMissDays > 0) {
                                      setState(() => _simulatedMissDays--);
                                    }
                                  },
                                  icon: const Icon(Icons.remove, size: 16),
                                  style: IconButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E293B),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    '-$_simulatedMissDays',
                                    style: const TextStyle(color: Color(0xFFF87171), fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ),
                                IconButton.filledTonal(
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                  onPressed: () => setState(() => _simulatedMissDays++),
                                  icon: const Icon(Icons.add, size: 16),
                                  style: IconButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E293B),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Simulated Attendance:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                            const SizedBox(height: 2),
                            Text(
                              '${projectedPct.toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: projectedPct >= 75.0 ? const Color(0xFF34D399) : const Color(0xFFF87171),
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: diff >= 0 ? const Color(0xFF064E3B) : const Color(0xFF7F1D1D),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                diff >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${diff >= 0 ? '+' : ''}${diff.toStringAsFixed(1)}%',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryLogTab({
    required List<AttendanceRecord> filteredLogs,
    required int totalLogsCount,
    required Widget summaryCard,
  }) {
    final presentCount = filteredLogs.where((l) => l.status == AttendanceStatus.present).length;
    final absentCount = filteredLogs.where((l) => l.status == AttendanceStatus.absent).length;
    final odCount = filteredLogs.where((l) => l.status == AttendanceStatus.onDuty).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          summaryCard,

          // Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search session by subject or code...',
                hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF64748B)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Filter Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Row(
              children: [
                {'label': 'All ($totalLogsCount)', 'value': 'All'},
                {'label': 'Present ($presentCount)', 'value': 'Present'},
                {'label': 'Absent ($absentCount)', 'value': 'Absent'},
                {'label': 'On Duty ($odCount)', 'value': 'On Duty'},
              ].map((filterObj) {
                final String filterVal = filterObj['value']!;
                final String filterLabel = filterObj['label']!;
                final isSel = _historyFilter == filterVal;

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(filterLabel),
                    selected: isSel,
                    onSelected: (val) {
                      if (val) setState(() => _historyFilter = filterVal);
                    },
                    selectedColor: const Color(0xFF1D4ED8),
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSel ? Colors.white : const Color(0xFF475569),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: isSel ? const Color(0xFF1D4ED8) : const Color(0xFFE2E8F0)),
                    ),
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 10),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredLogs.length,
            itemBuilder: (context, index) {
              final log = filteredLogs[index];
              final statusStr = log.status.label;
              Color statusColor;
              Color statusBg;
              IconData statusIcon;

              if (log.status == AttendanceStatus.present) {
                statusColor = const Color(0xFF059669);
                statusBg = const Color(0xFFECFDF5);
                statusIcon = Icons.check_circle_rounded;
              } else if (log.status == AttendanceStatus.absent) {
                statusColor = const Color(0xFFDC2626);
                statusBg = const Color(0xFFFEE2E2);
                statusIcon = Icons.cancel_rounded;
              } else {
                statusColor = const Color(0xFF2563EB);
                statusBg = const Color(0xFFEFF6FF);
                statusIcon = Icons.business_center_rounded;
              }

              final dateFormatted = '${log.date.day.toString().padLeft(2, '0')} ${_monthName(log.date.month)} ${log.date.year}';

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(10)),
                      child: Icon(statusIcon, color: statusColor, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${log.subjectCode} - ${log.subjectName}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$dateFormatted • ${log.timeSlot}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        statusStr,
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[(month - 1).clamp(0, 11)];
  }

  Widget _buildLeaveTrackerTab({
    required List<LeaveRequestModel> leaveRequests,
    required Widget summaryCard,
  }) {
    final approvedCount = leaveRequests.where((r) => r.status == 'Approved').length;
    final pendingCount = leaveRequests.where((r) => r.status == 'Pending Approval').length;
    final postOdState = ref.watch(postOdProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          summaryCard,
          const SizedBox(height: 12),
          // Stat cards row
          Row(
            children: [
              _buildLeaveStatCard('Approved Leaves', '$approvedCount Days', Icons.event_available_rounded, const Color(0xFF059669), const Color(0xFFECFDF5)),
              const SizedBox(width: 10),
              _buildLeaveStatCard('OD Granted', '2 Days', Icons.workspace_premium_rounded, const Color(0xFF2563EB), const Color(0xFFEFF6FF)),
              const SizedBox(width: 10),
              _buildLeaveStatCard('Pending', '$pendingCount Request', Icons.pending_actions_rounded, const Color(0xFFD97706), const Color(0xFFFEF3C7)),
            ],
          ),
          const SizedBox(height: 16),

          // ── POST-OD RETURN & OUTCOME STATUS MODULE ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1D4ED8).withValues(alpha: 0.2),
                  blurRadius: 12,
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
                    const Row(
                      children: [
                        Icon(Icons.emoji_events_rounded, color: Color(0xFFF59E0B), size: 22),
                        SizedBox(width: 8),
                        Text(
                          'POST-OD RETURN STATUS & CERTS',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.8),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                      child: const Text('HOD Required', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Returned from Hackathon / OD? Team Leader submits outcome (Won/Lost with reason). Teammates upload certificates for HOD approval.',
                  style: TextStyle(fontSize: 11, color: Color(0xFFDBEAFE)),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _showPostOdLeaderFormModal,
                        icon: const Icon(Icons.rate_review_rounded, size: 14),
                        label: const Text('Submit OD Outcome (Leader)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF59E0B),
                          foregroundColor: const Color(0xFF0F172A),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Display List of Post-OD Outcome Cards
          if (postOdState.outcomes.isNotEmpty) ...[
            const Text(
              'Post-OD Event Return History & Certificates',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 10),
            ...postOdState.outcomes.map((item) {
              final isWon = item.isWon;
              final outcomeColor = isWon ? const Color(0xFF059669) : const Color(0xFFDC2626);
              final outcomeBg = isWon ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.eventName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF0F172A)),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: outcomeBg, borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            isWon ? '🏆 WON (${item.prizeTitle})' : '❌ LOST / PARTICIPATED',
                            style: TextStyle(color: outcomeColor, fontWeight: FontWeight.bold, fontSize: 10.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Leader: ${item.teamLeaderName} • Date: ${item.eventDate}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 8),

                    if (isWon) ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
                        child: Row(
                          children: [
                            const Icon(Icons.workspace_premium_rounded, color: Color(0xFFD97706), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Reward: ${item.cashPrizeAmount ?? 'Merit Certificate & Trophy'}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Display Mandatory Loss Reason
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFFCA5A5))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.report_problem_rounded, color: Color(0xFFDC2626), size: 14),
                                SizedBox(width: 6),
                                Text('Post-Mortem Analysis & Loss Reason (Submitted to HOD)', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFFB91C1C))),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(item.lossReason ?? 'Reason details recorded.', style: const TextStyle(fontSize: 11, color: Color(0xFF7F1D1D))),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 10),
                    // Teammate Certificates Row & Upload Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${item.teamMembers.where((m) => m.hasSubmittedCert).length} / ${item.teamMembers.length} Certificates Attached',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                        ),
                        if (isWon)
                          ElevatedButton.icon(
                            onPressed: () => _showMemberCertificateUploadSheet(context, item.id, item.eventName),
                            icon: const Icon(Icons.upload_file_rounded, size: 12),
                            label: const Text('Upload My Cert', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                      ],
                    ),

                    if (item.hodRemarks != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          'HOD Remarks: ${item.hodRemarks}',
                          style: const TextStyle(fontSize: 10.5, color: Color(0xFF047857), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
          ],

          // Apply button banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.note_add_rounded, color: Color(0xFF2563EB), size: 22),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Need Medical or Event Leave?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                      SizedBox(height: 2),
                      Text('Submit your request & attach docs for approval.', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _showLeaveApplicationModal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: const Text('Apply Now', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Recent Leave Applications',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 10),

          ...leaveRequests.map((req) {
            final isApp = req.status == 'Approved';
            final statusColor = isApp ? const Color(0xFF059669) : const Color(0xFFD97706);
            final statusBg = isApp ? const Color(0xFFECFDF5) : const Color(0xFFFEF3C7);

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(req.type, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(6)),
                        child: Text(req.status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(req.duration, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2563EB))),
                  const SizedBox(height: 4),
                  Text('Reason: ${req.reason}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  if (req.hasAttachment) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: const [
                        Icon(Icons.attach_file_rounded, size: 14, color: Color(0xFF059669)),
                        SizedBox(width: 4),
                        Text('Proof document attached', style: TextStyle(fontSize: 10, color: Color(0xFF059669), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLeaveStatCard(String label, String value, IconData icon, Color color, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF475569)), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
