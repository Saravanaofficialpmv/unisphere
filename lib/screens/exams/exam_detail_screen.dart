import 'package:flutter/material.dart';
import 'package:clg_application/models/exam_model.dart';
import 'package:clg_application/widgets/exams/exam_requirements_card.dart';
import 'package:clg_application/widgets/exams/hall_ticket_modal.dart';
import 'package:intl/intl.dart';

class ExamDetailScreen extends StatelessWidget {
  final ExamModel exam;

  const ExamDetailScreen({super.key, required this.exam});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMMM dd, yyyy');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Examination Details',
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exam Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 3))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          exam.examType,
                          style: const TextStyle(color: Color(0xFF0284C7), fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Eligible',
                          style: TextStyle(color: Color(0xFF16A34A), fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Sem ${exam.semester}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    exam.subjectName,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Course Code: ${exam.courseCode}',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.event_rounded, size: 18, color: Color(0xFF0284C7)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          dateFormat.format(exam.date),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 18, color: Color(0xFF0284C7)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${exam.startTime} – ${exam.endTime} (${exam.durationMinutes} mins)',
                          style: const TextStyle(fontSize: 13, color: Color(0xFF334155), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 18, color: Color(0xFF0284C7)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${exam.venue} — ${exam.roomNumber} (${exam.blockBuilding})',
                          style: const TextStyle(fontSize: 13, color: Color(0xFF334155), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  if (exam.facultyInvigilator != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.person_pin_rounded, size: 18, color: Color(0xFF0284C7)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Invigilator: ${exam.facultyInvigilator}',
                            style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Exam Requirements Checklist Component (✓ Allowed, ✕ Not Allowed, ⚠ Required)
            ExamRequirementsCard(requirements: exam.requirements),
            const SizedBox(height: 20),

            // Instructions Box
            const Text(
              'Exam Instructions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                exam.instructions,
                style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.5),
              ),
            ),
            const SizedBox(height: 24),

            // Hall Ticket Trigger Button
            if (exam.isHallTicketAvailable)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => HallTicketModal.show(context, exam),
                  icon: const Icon(Icons.badge_rounded),
                  label: const Text('View Hall Ticket'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
