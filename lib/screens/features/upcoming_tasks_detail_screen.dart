import 'package:flutter/material.dart';
import 'package:clg_application/services/task_service.dart';
import 'package:clg_application/widgets/tasks/upcoming_task_card.dart';
import 'package:clg_application/widgets/tasks/create_task_dialog.dart';
import 'package:clg_application/screens/tasks/task_detail_screen.dart';
import 'package:clg_application/screens/student/modules/student_assignment_portal.dart';

class UpcomingTasksDetailScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const UpcomingTasksDetailScreen({super.key, this.onBack});

  @override
  State<UpcomingTasksDetailScreen> createState() => _UpcomingTasksDetailScreenState();
}

class _UpcomingTasksDetailScreenState extends State<UpcomingTasksDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedDateGroup = 'All';
  final String _selectedTaskType = 'All';

  final List<Map<String, dynamic>> _dateGroupOptions = const [
    {
      'group': 'All',
      'title': 'All',
      'subtitle': 'Show all tasks',
      'icon': Icons.grid_view_rounded,
      'color': Color(0xFF6366F1),
      'bgColor': Color(0xFFEEF2FF),
    },
    {
      'group': 'Overdue',
      'title': 'Overdue',
      'subtitle': 'Past due date',
      'icon': Icons.assignment_late_rounded,
      'color': Color(0xFFEF4444),
      'bgColor': Color(0xFFFEE2E2),
    },
    {
      'group': 'Today',
      'title': 'Today',
      'subtitle': 'Due today',
      'icon': Icons.today_rounded,
      'color': Color(0xFFF97316),
      'bgColor': Color(0xFFFFEDD5),
    },
    {
      'group': 'This Week',
      'title': 'This Week',
      'subtitle': 'Due within 7 days',
      'icon': Icons.date_range_rounded,
      'color': Color(0xFF0284C7),
      'bgColor': Color(0xFFE0F2FE),
    },
    {
      'group': 'Next Week',
      'title': 'Next Week',
      'subtitle': 'Due in 7 to 14 days',
      'icon': Icons.event_repeat_rounded,
      'color': Color(0xFF7C3AED),
      'bgColor': Color(0xFFF3E8FF),
    },
    {
      'group': 'Later',
      'title': 'Later',
      'subtitle': 'Due after 14 days',
      'icon': Icons.schedule_rounded,
      'color': Color(0xFF06B6D4),
      'bgColor': Color(0xFFCFFAFE),
    },
  ];

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _showDateFilterModal(BuildContext context) {
    String tempSelected = _selectedDateGroup;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Header Row
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Task Due Date',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Select due timeframe to filter',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 2-Column Grid of Option Cards
                  Expanded(
                    child: SingleChildScrollView(
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.15,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _dateGroupOptions.length,
                        itemBuilder: (context, index) {
                          final option = _dateGroupOptions[index];
                          final isSelected = tempSelected == option['group'];

                          return InkWell(
                            onTap: () {
                              setModalState(() {
                                tempSelected = option['group'] as String;
                              });
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0),
                                  width: isSelected ? 1.8 : 1.0,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: option['bgColor'] as Color,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          option['icon'] as IconData,
                                          color: option['color'] as Color,
                                          size: 20,
                                        ),
                                      ),
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent,
                                          border: Border.all(
                                            color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFCBD5E1),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: isSelected
                                            ? const Icon(
                                                Icons.check_rounded,
                                                size: 13,
                                                color: Colors.white,
                                              )
                                            : null,
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        option['title'] as String,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: isSelected ? const Color(0xFF4338CA) : const Color(0xFF0F172A),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        option['subtitle'] as String,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF64748B),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Info Banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F3FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFDDD6FE)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.info_outline_rounded,
                            color: Color(0xFF6366F1),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Filtering helps you find faster',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Color(0xFF4338CA),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Choose due timeframe and tap Apply Filter to view tasks.',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF6366F1),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.task_alt_outlined,
                          color: Color(0xFFA5B4FC),
                          size: 28,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Apply Filter Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedDateGroup = tempSelected;
                        });
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.filter_list_rounded, size: 18),
                      label: const Text(
                        'Apply Filter',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskService = TaskService();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black12,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: _handleBack,
        ),
        title: const Text(
          'Upcoming Tasks',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task_rounded, color: Color(0xFF4F46E5)),
            tooltip: 'Assign New Task (Staff)',
            onPressed: () => CreateTaskDialog.show(context),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: taskService,
        builder: (context, child) {
          final filteredTasks = taskService.getFilteredTasks(
            taskType: _selectedTaskType,
            dateGroup: _selectedDateGroup,
            searchQuery: _searchController.text,
          );

          return Column(
            children: [
              // Search & Filter Header Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Search tasks, subjects, instructions...',
                              hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                              prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
                        const SizedBox(width: 10),
                        // Filter Modal Trigger Button
                        Material(
                          color: _selectedDateGroup != 'All' ? const Color(0xFFEEF2FF) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            onTap: () => _showDateFilterModal(context),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _selectedDateGroup != 'All' ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.tune_rounded,
                                    size: 20,
                                    color: _selectedDateGroup != 'All' ? const Color(0xFF4F46E5) : const Color(0xFF64748B),
                                  ),
                                  if (_selectedDateGroup != 'All') ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF4F46E5),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Active Filter Bar
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.event_note_rounded, size: 14, color: Color(0xFF4F46E5)),
                              const SizedBox(width: 6),
                              Text(
                                'Due: $_selectedDateGroup',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        if (_selectedDateGroup != 'All')
                          GestureDetector(
                            onTap: () => setState(() => _selectedDateGroup = 'All'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.close_rounded, size: 14, color: Color(0xFFDC2626)),
                                  SizedBox(width: 2),
                                  Text('Reset', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Tasks List
              Expanded(
                child: filteredTasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.task_alt_rounded, size: 48, color: Color(0xFFCBD5E1)),
                            SizedBox(height: 12),
                            Text('No upcoming tasks found', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                            SizedBox(height: 4),
                            Text("You're all caught up on your coursework!", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filteredTasks.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final task = filteredTasks[index];
                          return UpcomingTaskCard(
                            task: task,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
                              );
                            },
                          );
                        },
                      ),
              ),

              // Bottom Portal Action Bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars_rounded, color: Color(0xFF6366F1)),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Access Coursework Portal for grade records & past assignments.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const StudentAssignmentPortal()),
                        );
                      },
                      child: const Text('Open Portal →', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
