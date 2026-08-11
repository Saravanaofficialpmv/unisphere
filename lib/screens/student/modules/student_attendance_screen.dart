import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class StudentAttendanceScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const StudentAttendanceScreen({
    super.key,
    this.onBack,
  });

  @override
  State<StudentAttendanceScreen> createState() => _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;
  int _selectedSemesterIndex = 3; // Default Sem 4 (Active)
  String _historyFilter = 'All';

  final List<Map<String, dynamic>> _semestersData = [
    {
      'name': 'Semester 1',
      'number': 1,
      'isCurrent': false,
      'overallPercentage': 0.880,
      'attendedHours': 176,
      'totalHours': 200,
      'status': 'COMPLETED - ELIGIBLE',
      'safeMargin': 'Passed with 88.0%',
      'subjects': [
        {
          'code': 'GE101',
          'subject': 'Basic Electrical Engineering',
          'attended': 43,
          'total': 50,
          'percentage': 0.860,
          'faculty': 'Dr. K. Sharma',
          'status': 'Completed',
          'safeMargin': 'Good Standing',
          'color': const Color(0xFF2563EB),
        },
        {
          'code': 'GE102',
          'subject': 'Engineering Graphics',
          'attended': 45,
          'total': 50,
          'percentage': 0.900,
          'faculty': 'Prof. V. Raman',
          'status': 'Completed',
          'safeMargin': 'Good Standing',
          'color': const Color(0xFF059669),
        },
        {
          'code': 'GE103',
          'subject': 'Engineering Chemistry',
          'attended': 44,
          'total': 50,
          'percentage': 0.880,
          'faculty': 'Dr. S. Priya',
          'status': 'Completed',
          'safeMargin': 'Good Standing',
          'color': const Color(0xFF7C3AED),
        },
        {
          'code': 'MA101',
          'subject': 'Matrices & Calculus',
          'attended': 44,
          'total': 50,
          'percentage': 0.880,
          'faculty': 'Prof. R. Menon',
          'status': 'Completed',
          'safeMargin': 'Good Standing',
          'color': const Color(0xFFD97706),
        },
      ],
    },
    {
      'name': 'Semester 2',
      'number': 2,
      'isCurrent': false,
      'overallPercentage': 0.910,
      'attendedHours': 182,
      'totalHours': 200,
      'status': 'COMPLETED - ELIGIBLE',
      'safeMargin': 'Passed with 91.0%',
      'subjects': [
        {
          'code': 'CS101',
          'subject': 'Python Programming',
          'attended': 47,
          'total': 50,
          'percentage': 0.940,
          'faculty': 'Dr. M. Tech',
          'status': 'Completed',
          'safeMargin': 'Excellence Distinction',
          'color': const Color(0xFF059669),
        },
        {
          'code': 'CS102',
          'subject': 'Engineering Physics',
          'attended': 45,
          'total': 50,
          'percentage': 0.900,
          'faculty': 'Dr. H. Verma',
          'status': 'Completed',
          'safeMargin': 'Good Standing',
          'color': const Color(0xFF2563EB),
        },
        {
          'code': 'MA102',
          'subject': 'Differential Equations',
          'attended': 44,
          'total': 50,
          'percentage': 0.880,
          'faculty': 'Prof. R. Menon',
          'status': 'Completed',
          'safeMargin': 'Good Standing',
          'color': const Color(0xFF7C3AED),
        },
        {
          'code': 'CS103',
          'subject': 'Digital Electronics',
          'attended': 46,
          'total': 50,
          'percentage': 0.920,
          'faculty': 'Prof. A. Joseph',
          'status': 'Completed',
          'safeMargin': 'Good Standing',
          'color': const Color(0xFFDC2626),
        },
      ],
    },
    {
      'name': 'Semester 3',
      'number': 3,
      'isCurrent': false,
      'overallPercentage': 0.892,
      'attendedHours': 178,
      'totalHours': 200,
      'status': 'COMPLETED - ELIGIBLE',
      'safeMargin': 'Passed with 89.2%',
      'subjects': [
        {
          'code': 'CS201',
          'subject': 'Data Structures & Algorithms',
          'attended': 46,
          'total': 50,
          'percentage': 0.920,
          'faculty': 'Dr. Dennis Ritchie',
          'status': 'Completed',
          'safeMargin': 'Good Standing',
          'color': const Color(0xFF2563EB),
        },
        {
          'code': 'CS202',
          'subject': 'Object Oriented Java',
          'attended': 44,
          'total': 50,
          'percentage': 0.880,
          'faculty': 'Prof. James Gosling',
          'status': 'Completed',
          'safeMargin': 'Good Standing',
          'color': const Color(0xFF059669),
        },
        {
          'code': 'CS203',
          'subject': 'Discrete Mathematics',
          'attended': 43,
          'total': 50,
          'percentage': 0.860,
          'faculty': 'Dr. Donald Knuth',
          'status': 'Completed',
          'safeMargin': 'Good Standing',
          'color': const Color(0xFFD97706),
        },
        {
          'code': 'CS204',
          'subject': 'Computer Architecture',
          'attended': 45,
          'total': 50,
          'percentage': 0.900,
          'faculty': 'Dr. Hennessy',
          'status': 'Completed',
          'safeMargin': 'Good Standing',
          'color': const Color(0xFF7C3AED),
        },
      ],
    },
    {
      'name': 'Semester 4',
      'number': 4,
      'isCurrent': true,
      'overallPercentage': 0.865,
      'attendedHours': 169,
      'totalHours': 195,
      'status': 'EXAM ELIGIBLE',
      'safeMargin': 'Safe Margin: Skip up to 4 classes',
      'subjects': [
        {
          'code': 'CS301',
          'subject': 'Computer Networks',
          'attended': 38,
          'total': 42,
          'percentage': 0.905,
          'faculty': 'Dr. Robert Vance',
          'status': 'Good Standing',
          'safeMargin': 'Safe: Can skip 4 classes',
          'color': const Color(0xFF2563EB),
        },
        {
          'code': 'CS302',
          'subject': 'Database Systems',
          'attended': 35,
          'total': 40,
          'percentage': 0.875,
          'faculty': 'Prof. Sarah Jenkins',
          'status': 'Good Standing',
          'safeMargin': 'Safe: Can skip 3 classes',
          'color': const Color(0xFF059669),
        },
        {
          'code': 'CS303',
          'subject': 'Web Technology',
          'attended': 29,
          'total': 38,
          'percentage': 0.763,
          'faculty': 'Dr. Alan Turing',
          'status': 'Attention Needed (<80%)',
          'safeMargin': 'Warning: Attend next 2 classes!',
          'color': const Color(0xFFD97706),
        },
        {
          'code': 'CS304',
          'subject': 'Software Engineering',
          'attended': 36,
          'total': 40,
          'percentage': 0.900,
          'faculty': 'Prof. Michael Scott',
          'status': 'Good Standing',
          'safeMargin': 'Safe: Can skip 4 classes',
          'color': const Color(0xFF7C3AED),
        },
        {
          'code': 'CS305',
          'subject': 'AI & Machine Learning',
          'attended': 31,
          'total': 35,
          'percentage': 0.885,
          'faculty': 'Dr. Grace Hopper',
          'status': 'Good Standing',
          'safeMargin': 'Safe: Can skip 3 classes',
          'color': const Color(0xFFDC2626),
        },
      ],
    },
  ];

  final List<Map<String, String>> _attendanceLogs = [
    {'date': '08 Aug 2026', 'subject': 'Computer Networks', 'slot': '09:00 - 10:00 AM', 'status': 'Present'},
    {'date': '08 Aug 2026', 'subject': 'Database Systems', 'slot': '10:15 - 11:15 AM', 'status': 'Present'},
    {'date': '07 Aug 2026', 'subject': 'Web Technology', 'slot': '11:30 AM - 12:30 PM', 'status': 'Absent'},
    {'date': '07 Aug 2026', 'subject': 'Software Engineering', 'slot': '01:30 - 02:30 PM', 'status': 'Present'},
    {'date': '06 Aug 2026', 'subject': 'AI & Machine Learning', 'slot': '02:45 - 03:45 PM', 'status': 'On Duty'},
    {'date': '05 Aug 2026', 'subject': 'Computer Networks', 'slot': '09:00 - 10:00 AM', 'status': 'Present'},
    {'date': '05 Aug 2026', 'subject': 'Database Systems', 'slot': '10:15 - 11:15 AM', 'status': 'Present'},
  ];

  final List<Map<String, String>> _leaveRequests = [
    {
      'type': 'Medical Leave',
      'duration': '04 Aug - 05 Aug 2026 (2 Days)',
      'reason': 'High fever & doctor advised bed rest',
      'status': 'Approved',
      'appliedDate': '03 Aug 2026',
    },
    {
      'type': 'On Duty (OD)',
      'duration': '28 Jul 2026 (1 Day)',
      'reason': 'Attended Inter-College Hackathon at IIT Madras',
      'status': 'Approved',
      'appliedDate': '26 Jul 2026',
    },
    {
      'type': 'Casual Leave',
      'duration': '15 Aug 2026 (1 Day)',
      'reason': 'Family function attendance',
      'status': 'Pending Approval',
      'appliedDate': '07 Aug 2026',
    },
  ];

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
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else if (widget.onBack != null) {
      widget.onBack!();
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
                    setState(() {
                      _leaveRequests.insert(0, {
                        'type': leaveType,
                        'duration': '$startDate - $endDate (2 Days)',
                        'reason': reasonController.text.trim().isEmpty ? 'Leave application' : reasonController.text.trim(),
                        'status': 'Pending Approval',
                        'appliedDate': 'Today',
                      });
                    });
                    Navigator.pop(ctx);
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

  @override
  Widget build(BuildContext context) {
    final currentSem = _semestersData[_selectedSemesterIndex];
    final double overallPercentage = currentSem['overallPercentage'] as double;
    final int overallAttended = currentSem['attendedHours'] as int;
    final int overallTotal = currentSem['totalHours'] as int;
    final String statusStr = currentSem['status'] as String;
    final String safeMarginStr = currentSem['safeMargin'] as String;
    final bool isCurrentSem = currentSem['isCurrent'] as bool;
    final List<Map<String, dynamic>> subjectsList = List<Map<String, dynamic>>.from(currentSem['subjects'] as List);

    final filteredLogs = _historyFilter == 'All'
        ? _attendanceLogs
        : _attendanceLogs.where((l) => l['status'] == _historyFilter).toList();

    final bool canPopRoute = Navigator.canPop(context);
    return PopScope(
      canPop: canPopRoute,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (widget.onBack != null) {
          widget.onBack!();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.black12,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
            onPressed: () => _handleBack(context),
          ),
          title: const Text(
            'Attendance Tracker & Log',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.note_add_outlined, color: Color(0xFF2563EB)),
              tooltip: 'Apply Leave',
              onPressed: _showLeaveApplicationModal,
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            onTap: (index) {
              setState(() {
                _selectedTabIndex = index;
              });
            },
            labelColor: const Color(0xFF2563EB),
            unselectedLabelColor: const Color(0xFF64748B),
            indicatorColor: const Color(0xFF2563EB),
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            tabs: const [
              Tab(text: 'Breakdown'),
              Tab(text: 'History Log'),
              Tab(text: 'Leave & OD'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Executive Header Card with Royal Blue Gradient (Gradebook Palette Alignment)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
                    percent: overallPercentage,
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
                          '$overallAttended / $overallTotal Hours Attended',
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
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
            ),

            // Tab Content Body
            Expanded(
              child: IndexedStack(
                index: _selectedTabIndex,
                children: [
                  // Tab 0: Subject Breakdown with Semester Chips
                  _buildSubjectBreakdownTab(subjectsList),

                  // Tab 1: History Log
                  _buildHistoryLogTab(filteredLogs),

                  // Tab 2: Leave & OD Tracker
                  _buildLeaveTrackerTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectBreakdownTab(List<Map<String, dynamic>> subjectsList) {
    return Column(
      children: [
        // Semester Selector Chips Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: List.generate(_semestersData.length, (index) {
              final sem = _semestersData[index];
              final isSel = index == _selectedSemesterIndex;
              final isCurrent = sem['isCurrent'] as bool;

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text('${sem['name']}${isCurrent ? ' (Active)' : ''}'),
                  selected: isSel,
                  onSelected: (val) {
                    if (val) setState(() => _selectedSemesterIndex = index);
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
            }),
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: subjectsList.length,
            itemBuilder: (context, index) {
              final item = subjectsList[index];
              final Color color = item['color'];
              final double pct = item['percentage'];
              final bool isLow = pct < 0.80;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
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
                                item['code'],
                                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item['subject'],
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
                    Text(
                      'Faculty: ${item['faculty']}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 12),
                    LinearPercentIndicator(
                      lineHeight: 8.0,
                      percent: pct,
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
                          'Attended: ${item['attended']} of ${item['total']} sessions',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF475569)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isLow ? const Color(0xFFFEE2E2) : const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item['safeMargin'],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isLow ? const Color(0xFFDC2626) : const Color(0xFF059669),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryLogTab(List<Map<String, String>> logs) {
    return Column(
      children: [
        // Filter Chips Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: ['All', 'Present', 'Absent', 'On Duty'].map((filter) {
              final isSel = _historyFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(filter),
                  selected: isSel,
                  onSelected: (val) {
                    if (val) setState(() => _historyFilter = filter);
                  },
                  selectedColor: const Color(0xFF1D4ED8),
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSel ? Colors.white : const Color(0xFF475569),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: isSel ? const Color(0xFF1D4ED8) : const Color(0xFFE2E8F0)),
                  ),
                  showCheckmark: false,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              final status = log['status']!;
              Color statusColor;
              Color statusBg;
              IconData statusIcon;

              if (status == 'Present') {
                statusColor = const Color(0xFF059669);
                statusBg = const Color(0xFFECFDF5);
                statusIcon = Icons.check_circle_rounded;
              } else if (status == 'Absent') {
                statusColor = const Color(0xFFDC2626);
                statusBg = const Color(0xFFFEE2E2);
                statusIcon = Icons.cancel_rounded;
              } else {
                statusColor = const Color(0xFF2563EB);
                statusBg = const Color(0xFFEFF6FF);
                statusIcon = Icons.business_center_rounded;
              }

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
                            log['subject']!,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${log['date']} • ${log['slot']}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        status,
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLeaveTrackerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stat cards row
          Row(
            children: [
              _buildLeaveStatCard('Approved Leaves', '3 Days', Icons.event_available_rounded, const Color(0xFF059669), const Color(0xFFECFDF5)),
              const SizedBox(width: 10),
              _buildLeaveStatCard('OD Granted', '2 Days', Icons.workspace_premium_rounded, const Color(0xFF2563EB), const Color(0xFFEFF6FF)),
              const SizedBox(width: 10),
              _buildLeaveStatCard('Pending', '1 Request', Icons.pending_actions_rounded, const Color(0xFFD97706), const Color(0xFFFEF3C7)),
            ],
          ),
          const SizedBox(height: 16),

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

          ..._leaveRequests.map((req) {
            final isApp = req['status'] == 'Approved';
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
                      Text(req['type']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(6)),
                        child: Text(req['status']!, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(req['duration']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2563EB))),
                  const SizedBox(height: 4),
                  Text('Reason: ${req['reason']}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
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
