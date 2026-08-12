import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/models/hackathon_model.dart';
import 'package:unisphere/controllers/hackathon_controller.dart';
import 'package:unisphere/controllers/hackathon_registration_controller.dart';
import 'package:unisphere/screens/features/hackathon_team_management_screen.dart';

class HackathonRegistrationScreen extends ConsumerStatefulWidget {
  final HackathonModel hackathon;

  const HackathonRegistrationScreen({super.key, required this.hackathon});

  @override
  ConsumerState<HackathonRegistrationScreen> createState() => _HackathonRegistrationScreenState();
}

class _HackathonRegistrationScreenState extends ConsumerState<HackathonRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _studentIdController = TextEditingController(text: 'STU-2026-042');
  final _studentNameController = TextEditingController(text: 'Alex Johnson');
  final _departmentController = TextEditingController(text: 'Computer Science & Engineering');
  final _yearController = TextEditingController(text: '3rd Year');
  final _leaderEmailController = TextEditingController(text: 'alex.j@unisphere.edu');
  final _phoneController = TextEditingController(text: '+91 98765 43210');
  final _teamNameController = TextEditingController();
  final List<TextEditingController> _memberControllers = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    for (int i = 1; i < widget.hackathon.teamSize; i++) {
      _memberControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _studentNameController.dispose();
    _departmentController.dispose();
    _yearController.dispose();
    _leaderEmailController.dispose();
    _phoneController.dispose();
    _teamNameController.dispose();
    for (var controller in _memberControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final membersList = _memberControllers
        .map((c) => c.text.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    try {
      // 1. Dispatch registration to local reactive registration provider
      final registrationRecord = ref
          .read(hackathonRegistrationProvider.notifier)
          .registerStudentForHackathon(
            hackathon: widget.hackathon,
            studentId: _studentIdController.text.trim(),
            studentName: _studentNameController.text.trim(),
            department: _departmentController.text.trim(),
            year: _yearController.text.trim(),
            email: _leaderEmailController.text.trim(),
            phone: _phoneController.text.trim(),
            teamName: _teamNameController.text.trim(),
            teamMembers: membersList,
          );

      // 2. Also inform API controller
      final payload = {
        'studentId': _studentIdController.text.trim(),
        'studentName': _studentNameController.text.trim(),
        'department': _departmentController.text.trim(),
        'year': _yearController.text.trim(),
        'email': _leaderEmailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'teamName': _teamNameController.text.trim(),
        'members': membersList,
        'registrationDate': DateTime.now().toIso8601String(),
        'status': 'Registered',
      };

      await ref.read(hackathonControllerProvider.notifier).registerTeam(widget.hackathon.id, payload);

      if (!mounted) return;

      final updatedHackathon = widget.hackathon.copyWith(
        userRegistrationStatus: 'registered',
        registrationId: registrationRecord.id,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Registration successful for ${widget.hackathon.title}!'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HackathonTeamManagementScreen(hackathon: updatedHackathon),
        ),
      );
    } catch (e) {
      if (!mounted) return;
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Register Team',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.hackathon.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('Max Team Size: ${widget.hackathon.teamSize} Members • ${widget.hackathon.mode}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text('Student Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _studentIdController,
                      decoration: InputDecoration(
                        labelText: 'Student ID',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.badge_rounded, color: Color(0xFF64748B)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _studentNameController,
                      decoration: InputDecoration(
                        labelText: 'Student Name',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF64748B)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _departmentController,
                      decoration: InputDecoration(
                        labelText: 'Department',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.domain_rounded, color: Color(0xFF64748B)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _yearController,
                      decoration: InputDecoration(
                        labelText: 'Year',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.school_rounded, color: Color(0xFF64748B)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _leaderEmailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF64748B)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFF64748B)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text('Team Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const SizedBox(height: 12),

              TextFormField(
                controller: _teamNameController,
                decoration: InputDecoration(
                  labelText: 'Team Name',
                  hintText: 'e.g. CodeCatalysts',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.groups_rounded, color: Color(0xFF64748B)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Please enter a team name';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              Text('Teammate Emails (Up to ${widget.hackathon.teamSize - 1} optional)', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const SizedBox(height: 12),

              ...List.generate(_memberControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: TextFormField(
                    controller: _memberControllers[index],
                    decoration: InputDecoration(
                      labelText: 'Member ${index + 2} Email',
                      hintText: 'student${index + 2}@unisphere.edu',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.alternate_email_rounded, color: Color(0xFF64748B)),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitRegistration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text('Confirm Team Registration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
