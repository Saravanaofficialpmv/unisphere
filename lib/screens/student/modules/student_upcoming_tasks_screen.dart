import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/core/constants/app_colors.dart';
import 'package:unisphere/services/auth_service.dart';
import 'package:unisphere/services/firebase_firestore_service.dart';
import 'package:unisphere/widgets/common/unisphere_header_card.dart';
import 'package:unisphere/widgets/common/custom_loader.dart';

class StudentUpcomingTasksScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;

  const StudentUpcomingTasksScreen({
    super.key,
    this.onBack,
  });

  @override
  ConsumerState<StudentUpcomingTasksScreen> createState() => _StudentUpcomingTasksScreenState();
}

class _StudentUpcomingTasksScreenState extends ConsumerState<StudentUpcomingTasksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  // Mock list of posted assignment questions for students
  final List<Map<String, dynamic>> _assignments = [
    {
      'id': 'asg_1',
      'courseCode': 'CS302',
      'subjectName': 'Database Systems',
      'title': 'SQL Query Optimization & Indexing Assignment',
      'facultyName': 'Prof. Sarah Jenkins',
      'postedDate': '10 Aug 2026',
      'dueDate': '13 Aug 2026 • 11:59 PM',
      'isDueSoon': true,
      'maxMarks': 100,
      'status': 'Pending', // Pending, Submitted, Graded
      'allowedFormats': 'PDF Document (.pdf)',
      'questionPrompt':
          'Write optimized SQL queries for complex multi-table JOINs, indexing strategies, and normalized schema design for a university portal database.',
      'submittedFile': null,
      'submittedDate': null,
      'obtainedMarks': null,
      'feedback': null,
    },
    {
      'id': 'asg_2',
      'courseCode': 'CS301',
      'subjectName': 'Computer Networks',
      'title': 'Subnetting & TCP/IP Protocol Analysis Report',
      'facultyName': 'Dr. Robert Vance',
      'postedDate': '08 Aug 2026',
      'dueDate': '15 Aug 2026 • 05:00 PM',
      'isDueSoon': false,
      'maxMarks': 50,
      'status': 'Pending',
      'allowedFormats': 'PDF Document (.pdf)',
      'questionPrompt':
          'Analyze Wireshark packet capture logs for TCP 3-way handshake and compute CIDR subnet masks for a class B network distribution.',
      'submittedFile': null,
      'submittedDate': null,
      'obtainedMarks': null,
      'feedback': null,
    },
    {
      'id': 'asg_3',
      'courseCode': 'CS304',
      'subjectName': 'Software Engineering',
      'title': 'UML Class & Sequence Diagram Modeling',
      'facultyName': 'Prof. Michael Scott',
      'postedDate': '04 Aug 2026',
      'dueDate': '11 Aug 2026 • 11:59 PM',
      'isDueSoon': false,
      'maxMarks': 100,
      'status': 'Submitted',
      'allowedFormats': 'PDF Document (.pdf)',
      'questionPrompt':
          'Design comprehensive UML Structural and Behavioral diagrams for an e-commerce order management subsystem.',
      'submittedFile': 'Alex_Johnson_SoftwareEng_UML_Assignment.pdf',
      'submittedDate': '10 Aug 2026 • 09:30 PM',
      'obtainedMarks': null,
      'feedback': null,
    },
    {
      'id': 'asg_4',
      'courseCode': 'CS305',
      'subjectName': 'AI & Machine Learning',
      'title': 'Supervised Linear Regression Lab Notebook',
      'facultyName': 'Dr. Grace Hopper',
      'postedDate': '01 Aug 2026',
      'dueDate': '07 Aug 2026 • 11:59 PM',
      'isDueSoon': false,
      'maxMarks': 100,
      'status': 'Graded',
      'allowedFormats': 'PDF Document (.pdf)',
      'questionPrompt':
          'Implement Linear & Polynomial Regression using NumPy & Scikit-Learn to predict house prices based on multi-variate features.',
      'submittedFile': 'Alex_Johnson_ML_LinearRegression.pdf',
      'submittedDate': '06 Aug 2026 • 04:15 PM',
      'obtainedMarks': 94,
      'feedback': 'Excellent implementation! Clean code structure and detailed plot visualizations.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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

  void _handleBack() {
    if (!mounted) return;
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else if (widget.onBack != null) {
      widget.onBack!();
    }
  }

  void _showSubmissionPortalModal(Map<String, dynamic> assignment) {
    final noteController = TextEditingController();
    String? selectedFileName = assignment['submittedFile'];
    bool isUploading = false;

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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignment['title'],
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${assignment['courseCode']} - ${assignment['subjectName']} • Max Marks: ${assignment['maxMarks']}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 14),

              // Question Prompt Container
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.help_outline_rounded, size: 16, color: Color(0xFF2563EB)),
                        const SizedBox(width: 6),
                        Text(
                          'Posted Question (${assignment['facultyName']}):',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      assignment['questionPrompt'],
                      style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B), height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Upload File Section
              const Text(
                'Upload Assignment Solution File',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
              ),
              const SizedBox(height: 6),

              InkWell(
                onTap: () async {
                  setModalState(() {
                    isUploading = true;
                  });
                  await Future.delayed(const Duration(milliseconds: 600));
                  setModalState(() {
                    isUploading = false;
                    selectedFileName = 'Alex_Johnson_${assignment['courseCode']}_Solution.pdf';
                  });
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: selectedFileName != null ? const Color(0xFFECFDF5) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selectedFileName != null ? const Color(0xFF10B981) : const Color(0xFFCBD5E1),
                      style: selectedFileName != null ? BorderStyle.solid : BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    children: [
                      if (isUploading)
                        const CustomLoader(size: 32, label: 'Uploading file...')
                      else if (selectedFileName != null) ...[
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 32),
                        const SizedBox(height: 6),
                        Text(
                          selectedFileName!,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                        ),
                        const Text('Click to replace file', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                      ] else ...[
                        const Icon(Icons.cloud_upload_outlined, color: Color(0xFF2563EB), size: 32),
                        const SizedBox(height: 6),
                        const Text(
                          'Tap to select & upload PDF document',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Only PDF format (.pdf) supported • Max 25MB',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Submission Notes
              const Text(
                'Submission Notes / Comments (Optional)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: noteController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Add remarks for instructor...',
                  hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                ),
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: selectedFileName == null
                      ? null
                      : () {
                          setState(() {
                            assignment['status'] = 'Submitted';
                            assignment['submittedFile'] = selectedFileName;
                            assignment['submittedDate'] = 'Today • Just Now';
                            assignment['isDueSoon'] = false;
                          });
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('🎉 ${assignment['title']} submitted successfully!'),
                              backgroundColor: const Color(0xFF059669),
                            ),
                          );
                        },
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text('Submit Assignment Solution', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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
    final user = ref.watch(currentUserProvider).value ?? ref.watch(authServiceProvider).currentUser;
    final email = user?.email.toLowerCase().trim() ?? '';
    final isDemo = email == 'saravanapmvofficial@gmail.com' || (user != null && user.uid == 'DEMO-STU');

    final dbAssignments = ref.watch(allAssignmentsStreamProvider).value ?? [];

    List<Map<String, dynamic>> sourceAssignments = [];
    if (dbAssignments.isNotEmpty) {
      sourceAssignments = dbAssignments.map((doc) {
        return {
          'id': doc['id'],
          'courseCode': doc['subject']?.toString().split(' - ')[0] ?? 'CS301',
          'subjectName': doc['subject']?.toString() ?? 'Course Subject',
          'title': doc['title']?.toString() ?? 'Posted Assignment',
          'facultyName': doc['uploadedBy']?.toString() ?? 'Course Faculty',
          'postedDate': 'Official Release',
          'dueDate': 'Check Marksheet',
          'isDueSoon': false,
          'maxMarks': 100,
          'status': 'Graded',
          'allowedFormats': 'PDF Document (.pdf)',
          'questionPrompt': 'Official staff assignment marks published in Cloud Firestore.',
          'submittedFile': doc['fileName']?.toString(),
          'submittedDate': null,
          'obtainedMarks': null,
          'feedback': null,
        };
      }).toList();
    } else if (isDemo) {
      sourceAssignments = _assignments;
    } else {
      sourceAssignments = [];
    }

    final pendingAssignments = sourceAssignments.where((a) => a['status'] == 'Pending').toList();
    final submittedAssignments = sourceAssignments.where((a) => a['status'] == 'Submitted').toList();
    final gradedAssignments = sourceAssignments.where((a) => a['status'] == 'Graded').toList();

    List<Map<String, dynamic>> activeList = sourceAssignments;
    if (_selectedTabIndex == 1) activeList = pendingAssignments;
    if (_selectedTabIndex == 2) activeList = submittedAssignments;
    if (_selectedTabIndex == 3) activeList = gradedAssignments;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Column(
            children: [
              UnisphereHeaderCard(
                title: 'Student Assignment Portal',
                subtitle: 'View posted assignment questions & submit coursework online',
                onBack: _handleBack,
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
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    tabs: [
                      Tab(text: 'All (${sourceAssignments.length})'),
                      Tab(text: 'Pending (${pendingAssignments.length})'),
                      Tab(text: 'Submitted (${submittedAssignments.length})'),
                      Tab(text: 'Graded (${gradedAssignments.length})'),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔔 Pending Assignment Deadline Notification Banner
                      if (pendingAssignments.isNotEmpty) ...[
                        _buildDeadlineNotificationBanner(pendingAssignments.length),
                        const SizedBox(height: 16),
                      ],

                      const Text(
                        'Faculty Posted Assignments & Question Papers',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 10),

                      if (activeList.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(36),
                          width: double.infinity,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.assignment_turned_in_rounded, size: 48, color: Color(0xFF94A3B8)),
                              SizedBox(height: 10),
                              Text(
                                'No assignments under this tab',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: activeList.length,
                          itemBuilder: (context, index) {
                            final assignment = activeList[index];
                            return _buildAssignmentQuestionCard(assignment);
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔔 Deadline Notification Alert Banner
  Widget _buildDeadlineNotificationBanner(int pendingCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFDBA74)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEA580C).withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF97316).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_active_rounded, color: Color(0xFFEA580C), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'DEADLINE ALERT NOTIFICATION',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFFC2410C), letterSpacing: 0.8),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEA580C),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$pendingCount Pending',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'You have pending assignment submissions due soon! DBMS Assignment is due tomorrow. Please upload your work on time to avoid marks deduction.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF7C2D12), height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 📝 Posted Assignment Question Card
  Widget _buildAssignmentQuestionCard(Map<String, dynamic> assignment) {
    final status = assignment['status'] as String;
    final isPending = status == 'Pending';
    final isSubmitted = status == 'Submitted';
    final isGraded = status == 'Graded';
    final isDueSoon = assignment['isDueSoon'] as bool;

    Color statusColor = const Color(0xFF2563EB);
    Color statusBg = const Color(0xFFEFF6FF);
    if (isPending) {
      statusColor = isDueSoon ? const Color(0xFFDC2626) : const Color(0xFFD97706);
      statusBg = isDueSoon ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7);
    } else if (isSubmitted) {
      statusColor = const Color(0xFF2563EB);
      statusBg = const Color(0xFFEFF6FF);
    } else if (isGraded) {
      statusColor = const Color(0xFF059669);
      statusBg = const Color(0xFFECFDF5);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDueSoon ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      assignment['courseCode'],
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    assignment['subjectName'],
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isDueSoon) ...[
                      const Icon(Icons.timer_outlined, size: 12, color: Color(0xFFDC2626)),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      isDueSoon ? 'DUE SOON' : status.toUpperCase(),
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Text(
            assignment['title'],
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 4),
          Text(
            'Posted by ${assignment['facultyName']} on ${assignment['postedDate']}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),

          // Question Prompt Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.quiz_outlined, size: 15, color: Color(0xFF2563EB)),
                    SizedBox(width: 6),
                    Text(
                      'Posted Question Prompt:',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  assignment['questionPrompt'],
                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155), height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Due date and format info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.event_outlined, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text(
                    'Deadline: ${assignment['dueDate']}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isDueSoon ? FontWeight.bold : FontWeight.w500,
                      color: isDueSoon ? const Color(0xFFDC2626) : const Color(0xFF475569),
                    ),
                  ),
                ],
              ),
              Text(
                'Max Marks: ${assignment['maxMarks']}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
            ],
          ),

          if (isSubmitted || isGraded) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isGraded ? const Color(0xFFECFDF5) : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    isGraded ? Icons.workspace_premium_rounded : Icons.check_circle_rounded,
                    color: isGraded ? const Color(0xFF059669) : const Color(0xFF2563EB),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isGraded
                              ? 'Graded: ${assignment['obtainedMarks']} / ${assignment['maxMarks']} Marks'
                              : 'Submitted file: ${assignment['submittedFile']}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isGraded ? const Color(0xFF059669) : const Color(0xFF2563EB),
                          ),
                        ),
                        if (isGraded && assignment['feedback'] != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Feedback: ${assignment['feedback']}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF047857)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Submit / View Action Button
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              onPressed: () => _showSubmissionPortalModal(assignment),
              icon: Icon(
                isPending
                    ? Icons.upload_file_rounded
                    : isSubmitted
                        ? Icons.edit_document
                        : Icons.rate_review_rounded,
                size: 16,
              ),
              label: Text(
                isPending
                    ? 'Submit Assignment Solution'
                    : isSubmitted
                        ? 'Update / View Submission'
                        : 'View Submission & Grade',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isPending ? const Color(0xFF2563EB) : const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
