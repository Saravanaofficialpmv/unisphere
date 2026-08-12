import 'package:flutter/material.dart';
import 'package:unisphere/models/exam_model.dart';
import 'package:unisphere/services/exam_service.dart';
import 'package:intl/intl.dart';

class CreateExamDialog extends StatefulWidget {
  const CreateExamDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const CreateExamDialog(),
    );
  }

  @override
  State<CreateExamDialog> createState() => _CreateExamDialogState();
}

class _CreateExamDialogState extends State<CreateExamDialog> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _codeController = TextEditingController();
  final _venueController = TextEditingController(text: 'Main Block');
  final _roomController = TextEditingController(text: 'Room 201');

  String _selectedExamType = 'Internal Assessment';
  DateTime _examDate = DateTime.now().add(const Duration(days: 14));

  final List<String> _examTypes = [
    'Unit Test',
    'Internal Assessment',
    'Model Exam',
    'Practical Exam',
    'Lab Exam',
    'End Semester',
    'Supplementary Exam',
  ];

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newExam = ExamModel(
        id: 'exam_${DateTime.now().millisecondsSinceEpoch}',
        subjectName: _subjectController.text.trim(),
        courseCode: _codeController.text.trim().toUpperCase(),
        examType: _selectedExamType,
        date: _examDate,
        startTime: '09:00 AM',
        endTime: '12:00 PM',
        durationMinutes: 180,
        venue: _venueController.text.trim(),
        roomNumber: _roomController.text.trim(),
        blockBuilding: 'Main Academic Building',
        requirements: const [
          ExamRequirementItem(label: 'College ID Card', status: ExamRequirementStatus.required),
          ExamRequirementItem(label: 'Hall Ticket', status: ExamRequirementStatus.required),
          ExamRequirementItem(label: 'Blue/Black Pen', status: ExamRequirementStatus.required),
          ExamRequirementItem(label: 'Mobile Phone', status: ExamRequirementStatus.notAllowed),
          ExamRequirementItem(label: 'Smart Watch', status: ExamRequirementStatus.notAllowed),
        ],
      );

      ExamService().addExam(newExam);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exam schedule for "${newExam.subjectName}" created!'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.assignment_rounded, color: Color(0xFF0284C7), size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Schedule New Exam',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _subjectController,
                    decoration: const InputDecoration(labelText: 'Subject Name', border: OutlineInputBorder()),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Enter subject name' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _codeController,
                    decoration: const InputDecoration(labelText: 'Course Code (e.g. CS201)', border: OutlineInputBorder()),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Enter code' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedExamType,
                    decoration: const InputDecoration(
                      labelText: 'Exam Type',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    items: _examTypes
                        .map(
                          (t) => DropdownMenuItem(
                            value: t,
                            child: Text(
                              t,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedExamType = v!),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _venueController,
                          decoration: const InputDecoration(labelText: 'Venue / Building', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _roomController,
                          decoration: const InputDecoration(labelText: 'Room Number', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.event_rounded, color: Color(0xFF0284C7), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Exam Date: ${DateFormat('MMM dd, yyyy').format(_examDate)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _examDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 180)),
                          );
                          if (picked != null) setState(() => _examDate = picked);
                        },
                        child: const Text('Select Date'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Schedule Exam', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
