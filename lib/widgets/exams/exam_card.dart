import 'package:flutter/material.dart';
import 'package:clg_application/models/exam_model.dart';
import 'package:intl/intl.dart';

class ExamCard extends StatelessWidget {
  final ExamModel exam;
  final VoidCallback onTap;

  const ExamCard({
    super.key,
    required this.exam,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd');
    final monthStr = dateFormat.format(exam.date).split(' ')[0].toUpperCase();
    final dayStr = dateFormat.format(exam.date).split(' ')[1];

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
                // Date Badge
                Container(
                  width: 50,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        monthStr,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        dayStr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              exam.subjectName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF0F172A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              exam.examType,
                              style: const TextStyle(
                                color: Color(0xFF0284C7),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 11, color: Color(0xFF64748B)),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              '${exam.startTime} – ${exam.endTime}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, size: 11, color: Color(0xFF64748B)),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              '${exam.venue} — ${exam.roomNumber}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
