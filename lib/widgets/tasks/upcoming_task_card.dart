import 'package:flutter/material.dart';
import 'package:clg_application/models/assignment_model.dart';
import 'package:intl/intl.dart';

class UpcomingTaskCard extends StatelessWidget {
  final AssignmentModel task;
  final VoidCallback onTap;

  const UpcomingTaskCard({
    super.key,
    required this.task,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd');
    final timeFormat = DateFormat('hh:mm a');
    final monthStr = dateFormat.format(task.dueDate).split(' ')[0].toUpperCase();
    final dayStr = dateFormat.format(task.dueDate).split(' ')[1];

    Color statusBg = const Color(0xFFFEF3C7);
    Color statusText = const Color(0xFFD97706);

    if (task.isOverdue) {
      statusBg = const Color(0xFFFEE2E2);
      statusText = const Color(0xFFDC2626);
    } else if (task.status == 'In Progress') {
      statusBg = const Color(0xFFE0F2FE);
      statusText = const Color(0xFF0284C7);
    } else if (task.status == 'Upcoming') {
      statusBg = const Color(0xFFF3E8FF);
      statusText = const Color(0xFF7C3AED);
    } else if (task.status == 'Submitted' || task.status == 'Completed') {
      statusBg = const Color(0xFFDCFCE7);
      statusText = const Color(0xFF16A34A);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                // Date Pill Badge
                Container(
                  width: 48,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF818CF8).withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        monthStr,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4F46E5),
                        ),
                      ),
                      Text(
                        dayStr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF4F46E5),
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Title & Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF0F172A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (task.priority == 'Urgent')
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'URGENT',
                                style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${task.subjectName ?? 'Academic'} · ${task.taskType}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Status & Time
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        task.dynamicStatus,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time_rounded, size: 11, color: Color(0xFF64748B)),
                        const SizedBox(width: 3),
                        Text(
                          timeFormat.format(task.dueDate),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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
