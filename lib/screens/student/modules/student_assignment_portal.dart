import 'package:flutter/material.dart';
import 'package:unisphere/core/constants/app_colors.dart';
import 'package:unisphere/models/assignment_model.dart';
import 'package:unisphere/models/submission_model.dart';
import 'package:unisphere/services/assignment_service.dart';
import 'package:unisphere/widgets/common/apple_glass_card.dart';
import 'package:intl/intl.dart';

class StudentAssignmentPortal extends StatefulWidget {
  final String studentUid;
  final String studentName;
  final String registerNumber;
  final VoidCallback? onBack;

  const StudentAssignmentPortal({
    super.key,
    this.studentUid = 'std_alex_01',
    this.studentName = 'Alex Johnson',
    this.registerNumber = 'RA2111003010001',
    this.onBack,
  });

  @override
  State<StudentAssignmentPortal> createState() => _StudentAssignmentPortalState();
}

class _StudentAssignmentPortalState extends State<StudentAssignmentPortal> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AssignmentService _service = AssignmentService();
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _service.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceUpdate);
    _tabController.dispose();
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  void _handleBack(BuildContext context) {
    if (!mounted) return;
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else if (widget.onBack != null) {
      widget.onBack!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final assignments = _service.assignments;

    // Stats counts
    int pendingCount = 0;
    int submittedCount = 0;
    int gradedCount = 0;
    double totalMarksEarned = 0;
    double totalMaxMarksGraded = 0;

    for (var asg in assignments) {
      final sub = _service.getSubmissionForStudent(asg.id, widget.studentUid);
      if (sub == null || sub.status == 'Draft') {
        pendingCount++;
      } else if (sub.status == 'Submitted' || sub.status == 'Late') {
        submittedCount++;
      } else if (sub.status == 'Graded') {
        gradedCount++;
        if (sub.obtainedMarks != null) {
          totalMarksEarned += sub.obtainedMarks!;
          totalMaxMarksGraded += asg.maxMarks;
        }
      }
    }

    final avgPercentage = totalMaxMarksGraded > 0
        ? ((totalMarksEarned / totalMaxMarksGraded) * 100).toStringAsFixed(1)
        : '94.0';

    final bool canPopRoute = ModalRoute.of(context)?.canPop ?? false;
    return PopScope(
      canPop: canPopRoute,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || !mounted) return;
        if (widget.onBack != null) {
          widget.onBack!();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.black12,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
            tooltip: 'Back to Home',
            onPressed: () => _handleBack(context),
          ),
          title: const Text(
            'Assignment & Coursework Portal',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Header Title Card
            _buildHeaderBanner(),
            const SizedBox(height: 20),

            // Top Stat Cards (Responsive Layout)
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;
                if (isWide) {
                  return Row(
                    children: [
                      Expanded(child: _buildStatCard('Pending', '$pendingCount', Icons.pending_actions_rounded, const Color(0xFFF59E0B))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard('Submitted', '$submittedCount', Icons.task_alt_rounded, const Color(0xFF3B82F6))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard('Graded', '$gradedCount', Icons.workspace_premium_rounded, const Color(0xFF10B981))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard('Avg Score', '$avgPercentage%', Icons.insights_rounded, const Color(0xFF8B5CF6))),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildStatCard('Pending', '$pendingCount', Icons.pending_actions_rounded, const Color(0xFFF59E0B))),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStatCard('Submitted', '$submittedCount', Icons.task_alt_rounded, const Color(0xFF3B82F6))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildStatCard('Graded', '$gradedCount', Icons.workspace_premium_rounded, const Color(0xFF10B981))),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStatCard('Avg Score', '$avgPercentage%', Icons.insights_rounded, const Color(0xFF8B5CF6))),
                        ],
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 24),

            // Register Number Banner Alert
            _buildRegNoBadgeBanner(),
            const SizedBox(height: 24),

            // Tab Filter Navigation Bar
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(4),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                dividerColor: Colors.transparent,
                onTap: (index) {
                  setState(() {
                    if (index == 0) _selectedFilter = 'All';
                    if (index == 1) _selectedFilter = 'Pending';
                    if (index == 2) _selectedFilter = 'Submitted';
                    if (index == 3) _selectedFilter = 'Graded';
                  });
                },
                tabs: const [
                  Tab(text: 'All Tasks'),
                  Tab(text: 'Pending'),
                  Tab(text: 'Submitted'),
                  Tab(text: 'Graded'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Assignment Cards List
            _buildAssignmentList(assignments),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildHeaderBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.assignment_rounded, color: Colors.white, size: 36),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Digital Assignment & Lab Submission Portal',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Access course homework, submit reports securely, and view personalized feedback from your instructors.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegNoBadgeBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.badge_outlined, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                children: [
                  const TextSpan(text: 'Logged in as '),
                  TextSpan(text: widget.studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(text: ' | Register No: '),
                  TextSpan(
                    text: widget.registerNumber,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const TextSpan(text: ' • Your specific assignment questions are automatically matched below.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return AppleGlassCard.frosted(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentList(List<AssignmentModel> assignments) {
    final filtered = assignments.where((asg) {
      final sub = _service.getSubmissionForStudent(asg.id, widget.studentUid);
      final status = sub?.status ?? 'Pending';

      if (_selectedFilter == 'Pending') return status == 'Pending' || status == 'Draft';
      if (_selectedFilter == 'Submitted') return status == 'Submitted' || status == 'Late';
      if (_selectedFilter == 'Graded') return status == 'Graded';
      return true;
    }).toList();

    if (filtered.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        width: double.infinity,
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.folder_open_rounded, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'No assignments found under "$_selectedFilter"',
              style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final asg = filtered[index];
        final submission = _service.getSubmissionForStudent(asg.id, widget.studentUid);
        return _buildAssignmentCard(asg, submission);
      },
    );
  }

  Widget _buildAssignmentCard(AssignmentModel asg, SubmissionModel? submission) {
    final status = submission?.status ?? 'Pending';
    final specificQuestion = asg.getQuestionForRegNo(widget.registerNumber);

    final isPastDue = DateTime.now().isAfter(asg.dueDate);
    final dueFormatted = DateFormat('MMM dd, yyyy • hh:mm a').format(asg.dueDate);

    return AppleGlassCard.frosted(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      onTap: () => _openSubmissionModal(asg, submission),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Course Code badge, Subject, Status Chip
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  asg.courseCode ?? 'CS201',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  asg.subjectName ?? 'General',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusChip(status),
            ],
          ),
          const SizedBox(height: 12),

          // Assignment Title
          Text(
            asg.title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),

          // Register Number specific question preview container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.psychology_outlined, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Assigned Question for Reg No: ${widget.registerNumber}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  specificQuestion,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Due date & Max Marks Metadata Row
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 15,
                color: isPastDue && status != 'Graded' && status != 'Submitted'
                    ? AppColors.error
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Due: $dueFormatted',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isPastDue ? FontWeight.w600 : FontWeight.normal,
                    color: isPastDue && status != 'Graded' && status != 'Submitted'
                        ? AppColors.error
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text('•', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(width: 8),
              Text(
                'Max Marks: ${asg.maxMarks}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Submission Action Button (Full Width)
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton.icon(
              onPressed: () => _openSubmissionModal(asg, submission),
              icon: Icon(
                status == 'Graded'
                    ? Icons.grading_rounded
                    : status == 'Submitted' || status == 'Late'
                        ? Icons.remove_red_eye_rounded
                        : Icons.upload_file_rounded,
                size: 16,
              ),
              label: Text(
                status == 'Graded'
                    ? 'View Feedback (${submission?.obtainedMarks}/${asg.maxMarks})'
                    : status == 'Submitted' || status == 'Late'
                        ? 'View Submission'
                        : 'Submit File',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: status == 'Graded'
                    ? const Color(0xFF059669)
                    : status == 'Submitted' || status == 'Late'
                        ? const Color(0xFF2563EB)
                        : AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bg;
    Color fg;
    IconData icon;

    switch (status) {
      case 'Graded':
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF047857);
        icon = Icons.check_circle_rounded;
        break;
      case 'Submitted':
        bg = const Color(0xFFDBEAFE);
        fg = const Color(0xFF1D4ED8);
        icon = Icons.task_alt_rounded;
        break;
      case 'Late':
        bg = const Color(0xFFFFEDD5);
        fg = const Color(0xFFC2410C);
        icon = Icons.warning_amber_rounded;
        break;
      case 'Draft':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
        icon = Icons.edit_note_rounded;
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF475569);
        icon = Icons.pending_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(status, style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  void _openSubmissionModal(AssignmentModel asg, SubmissionModel? existingSub) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AssignmentSubmissionSheet(
        assignment: asg,
        existingSubmission: existingSub,
        studentUid: widget.studentUid,
        studentName: widget.studentName,
        registerNumber: widget.registerNumber,
      ),
    );
  }
}

// ─────────────────────────────────────────
//  Submission Modal Sheet Widget
// ─────────────────────────────────────────
class _AssignmentSubmissionSheet extends StatefulWidget {
  final AssignmentModel assignment;
  final SubmissionModel? existingSubmission;
  final String studentUid;
  final String studentName;
  final String registerNumber;

  const _AssignmentSubmissionSheet({
    required this.assignment,
    this.existingSubmission,
    required this.studentUid,
    required this.studentName,
    required this.registerNumber,
  });

  @override
  State<_AssignmentSubmissionSheet> createState() => _AssignmentSubmissionSheetState();
}

class _AssignmentSubmissionSheetState extends State<_AssignmentSubmissionSheet> {
  String? _selectedFileName;
  String? _selectedFileType;
  int _selectedFileSize = 0;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  final AssignmentService _service = AssignmentService();

  @override
  void initState() {
    super.initState();
    if (widget.existingSubmission != null) {
      _selectedFileName = widget.existingSubmission!.fileName;
      _selectedFileType = widget.existingSubmission!.fileType;
      _selectedFileSize = widget.existingSubmission!.fileSizeBytes ?? 2450000;
    }
  }

  void _simulateFileUpload(String fileType) async {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.1;
      _selectedFileType = fileType.toUpperCase();
      _selectedFileName = '${widget.studentName.replaceAll(" ", "_")}_${widget.assignment.courseCode}_Submission.$fileType';
      _selectedFileSize = (1.5 * 1024 * 1024).toInt(); // 1.5MB
    });

    for (int i = 2; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        setState(() {
          _uploadProgress = i / 10;
        });
      }
    }

    if (mounted) {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _handleSave(bool isFinalSubmit) {
    if (_selectedFileName == null) {
      return;
    }

    _service.saveSubmission(
      assignmentId: widget.assignment.id,
      studentUid: widget.studentUid,
      studentName: widget.studentName,
      registerNumber: widget.registerNumber,
      fileName: _selectedFileName!,
      fileType: _selectedFileType ?? 'PDF',
      fileSizeBytes: _selectedFileSize,
      isFinalSubmit: isFinalSubmit,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final sub = widget.existingSubmission;
    final isGraded = sub?.isGraded ?? false;
    final specificQuestion = widget.assignment.getQuestionForRegNo(widget.registerNumber);

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 12),

          // Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.assignment.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('${widget.assignment.subjectName} • ${widget.assignment.courseCode}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          const Divider(height: 24),

          // Content Area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Assigned Question details for Reg No
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.assignment_ind_rounded, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Question Prompt assigned to Reg No: ${widget.registerNumber}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(specificQuestion, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.4)),
                        const SizedBox(height: 12),
                        const Text('General Instructions:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary)),
                        Text(widget.assignment.description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Instructor Feedback Panel (If Graded)
                  if (isGraded && sub != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [const Color(0xFF10B981).withValues(alpha: 0.12), const Color(0xFF059669).withValues(alpha: 0.05)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Row(
                                  children: [
                                    Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 24),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Grading & Faculty Feedback',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF065F46)),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(20)),
                                child: Text(
                                  'Score: ${sub.obtainedMarks} / ${widget.assignment.maxMarks}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text('Evaluated by: ${sub.gradedBy ?? "Instructor"}', style: const TextStyle(fontSize: 12, color: Color(0xFF047857), fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                            child: Text(sub.feedback ?? 'Great effort on this submission!', style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontStyle: FontStyle.italic)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // File Upload Area
                  const Text('Solution File Upload (PDF, DOCX, ZIP, Images)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 10),

                  if (_selectedFileName == null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid, width: 1.5),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.cloud_upload_outlined, size: 48, color: AppColors.primary.withValues(alpha: 0.8)),
                          const SizedBox(height: 12),
                          const Text('Click or choose a format to upload solution file', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text('Supported formats: ${widget.assignment.allowedFileTypes.join(", ").toUpperCase()}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: widget.assignment.allowedFileTypes.map<Widget>((ext) {
                              return ActionChip(
                                avatar: Icon(_getFileIcon(ext), size: 16, color: AppColors.primary),
                                label: Text(ext.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                backgroundColor: Colors.white,
                                side: const BorderSide(color: AppColors.border),
                                onPressed: () => _simulateFileUpload(ext),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // File Selected Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                                child: Icon(_getFileIcon(_selectedFileType ?? 'PDF'), color: AppColors.primary, size: 28),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_selectedFileName!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 2),
                                    Text('${(_selectedFileSize / (1024 * 1024)).toStringAsFixed(2)} MB • ${_selectedFileType ?? "PDF"} Document', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                              if (!isGraded)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                                  onPressed: () => setState(() => _selectedFileName = null),
                                ),
                            ],
                          ),
                          if (_isUploading) ...[
                            const SizedBox(height: 12),
                            LinearProgressIndicator(value: _uploadProgress, backgroundColor: Colors.grey.shade200, color: AppColors.primary),
                          ],
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom Action Buttons
          if (!isGraded)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isUploading ? null : () => _handleSave(false),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Save as Draft'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isUploading ? null : () => _handleSave(true),
                      icon: const Icon(Icons.send_rounded, size: 18),
                      label: const Text('Submit Assignment'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String ext) {
    ext = ext.toLowerCase();
    if (ext == 'pdf') return Icons.picture_as_pdf_rounded;
    if (ext == 'docx' || ext == 'doc') return Icons.description_rounded;
    if (ext == 'zip' || ext == 'rar') return Icons.folder_zip_rounded;
    if (ext == 'png' || ext == 'jpg' || ext == 'jpeg') return Icons.image_rounded;
    return Icons.insert_drive_file_rounded;
  }
}
