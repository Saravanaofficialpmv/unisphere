import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clg_application/models/hackathon_model.dart';
import 'package:clg_application/controllers/hackathon_controller.dart';
import 'package:clg_application/screens/features/hackathon_team_management_screen.dart';

class HackathonRegistrationScreen extends ConsumerStatefulWidget {
  final HackathonModel hackathon;

  const HackathonRegistrationScreen({super.key, required this.hackathon});

  @override
  ConsumerState<HackathonRegistrationScreen> createState() => _HackathonRegistrationScreenState();
}

class _HackathonRegistrationScreenState extends ConsumerState<HackathonRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _teamNameController = TextEditingController();
  final _leaderEmailController = TextEditingController(text: 'alex.j@unisphere.edu');
  final List<TextEditingController> _memberControllers = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Default slot count for extra team members
    for (int i = 1; i < widget.hackathon.teamSize; i++) {
      _memberControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    _leaderEmailController.dispose();
    for (var controller in _memberControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final payload = {
      'teamName': _teamNameController.text.trim(),
      'leaderEmail': _leaderEmailController.text.trim(),
      'members': _memberControllers.map((c) => c.text.trim()).where((e) => e.isNotEmpty).toList(),
      'registeredAt': DateTime.now().toIso8601String(),
    };

    try {
      final response = await ref.read(hackathonControllerProvider.notifier).registerTeam(widget.hackathon.id, payload);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Successfully registered!'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );

      final updatedHackathon = widget.hackathon.copyWith(
        userRegistrationStatus: 'registered',
        registrationId: response['registrationId']?.toString() ?? 'REG-${DateTime.now().millisecondsSinceEpoch}',
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HackathonTeamManagementScreen(hackathon: updatedHackathon),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
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

              TextFormField(
                controller: _leaderEmailController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Team Leader Email (You)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person_rounded, color: Color(0xFF64748B)),
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                ),
              ),
              const SizedBox(height: 24),

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
