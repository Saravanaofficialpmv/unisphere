import 'package:flutter/material.dart';
import 'package:clg_application/models/assignment_model.dart';
import 'package:clg_application/services/task_service.dart';
import 'package:intl/intl.dart';

class CreateTaskDialog extends StatefulWidget {
  const CreateTaskDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const CreateTaskDialog(),
    );
  }

  @override
  State<CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends State<CreateTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();
  final _descController = TextEditingController();
  
  String _selectedType = 'Assignment';
  String _selectedPriority = 'Normal';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 3));

  final List<String> _types = [
    'Assignment',
    'Lab Record',
    'Quiz',
    'Seminar',
    'Project Review',
    'Internal Assessment',
    'Submission',
    'Other',
  ];

  final List<String> _priorities = ['Normal', 'High', 'Urgent'];

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newTask = AssignmentModel(
        id: 'task_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        authorName: 'Prof. Sarah Jenkins (Staff)',
        subjectName: _subjectController.text.trim(),
        createdAt: DateTime.now(),
        dueDate: _dueDate,
        maxMarks: 100,
        taskType: _selectedType,
        priority: _selectedPriority,
        status: 'Pending',
        targetedClasses: ['CSE - 3rd Year - Sec A'],
      );

      TaskService().addTask(newTask);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task "${newTask.title}" published successfully!'),
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
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.add_task_rounded, color: Color(0xFF4F46E5), size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Assign New Task',
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
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Task Title', border: OutlineInputBorder()),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Enter title' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _subjectController,
                    decoration: const InputDecoration(labelText: 'Subject / Course', border: OutlineInputBorder()),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Enter subject' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Task Type',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    items: _types
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
                    onChanged: (v) => setState(() => _selectedType = v!),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedPriority,
                    decoration: const InputDecoration(
                      labelText: 'Priority Level',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    items: _priorities
                        .map(
                          (p) => DropdownMenuItem(
                            value: p,
                            child: Text(
                              p,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedPriority = v!),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Instructions / Description', border: OutlineInputBorder()),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Enter instructions' : null,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.event_rounded, color: Color(0xFF4F46E5), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Due Date: ${DateFormat('MMM dd, yyyy').format(_dueDate)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _dueDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 180)),
                          );
                          if (picked != null) setState(() => _dueDate = picked);
                        },
                        child: const Text('Change Date'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Publish Task', style: TextStyle(fontWeight: FontWeight.bold)),
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
