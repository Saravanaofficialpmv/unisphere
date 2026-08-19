import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/models/hackathon_model.dart';
import 'package:unisphere/controllers/hackathon_controller.dart';
import 'package:unisphere/core/constants/app_colors.dart';

class CreateHackathonDialog extends ConsumerStatefulWidget {
  final String userRole; // 'hod' or 'advisor'
  final String userName;

  const CreateHackathonDialog({
    super.key,
    required this.userRole,
    required this.userName,
  });

  static Future<void> show(BuildContext context, {required String userRole, required String userName}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => CreateHackathonDialog(userRole: userRole, userName: userName),
    );
  }

  @override
  ConsumerState<CreateHackathonDialog> createState() => _CreateHackathonDialogState();
}

class _CreateHackathonDialogState extends ConsumerState<CreateHackathonDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _externalUrlCtrl;
  late TextEditingController _prizePoolCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _organizerCtrl;

  String _category = 'AI & Robotics';
  String _mode = 'Offline';
  String _status = 'Published'; // 'Draft', 'Published', 'Registration Closed'
  int _minTeamSize = 1;
  int _maxTeamSize = 6;
  DateTime _registrationDeadline = DateTime.now().add(const Duration(days: 7));
  final DateTime _startDate = DateTime.now().add(const Duration(days: 10));
  final DateTime _endDate = DateTime.now().add(const Duration(days: 12));

  final List<String> _categories = [
    'AI & Robotics',
    'Web3 & Blockchain',
    'CleanTech & Energy',
    'Cybersecurity',
    'HealthTech',
    'FinTech',
    'Open Innovation',
  ];

  final List<String> _modes = ['Online', 'Offline', 'Hybrid'];

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: 'National AI & Cloud Innovation Hackathon 2026');
    _descCtrl = TextEditingController(
      text: '36-hour continuous hackathon focused on building multi-agent AI systems, scalable backend data pipelines, and smart campus automation.',
    );
    _externalUrlCtrl = TextEditingController(text: 'https://unstop.com/hackathons/unisphere-ai-2026');
    _prizePoolCtrl = TextEditingController(text: '₹2,50,000');
    _locationCtrl = TextEditingController(text: 'Main Tech Auditorium / Hybrid Discord');
    _organizerCtrl = TextEditingController(text: '${widget.userRole.toUpperCase()} Innovation Cell & IEEE Student Branch');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _externalUrlCtrl.dispose();
    _prizePoolCtrl.dispose();
    _locationCtrl.dispose();
    _organizerCtrl.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final newId = 'HACK-${now.millisecondsSinceEpoch % 9000 + 1000}';

    final newHackathon = HackathonModel(
      id: newId,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      category: _category,
      organizer: _organizerCtrl.text.trim(),
      mode: _mode,
      bannerImage: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=800&q=80',
      startDate: _startDate,
      endDate: _endDate,
      registrationOpen: true,
      registrationDeadline: _registrationDeadline,
      prizePool: _prizePoolCtrl.text.trim(),
      registeredTeams: 0,
      maxTeams: 150,
      minTeamSize: _minTeamSize,
      teamSize: _maxTeamSize,
      status: _status,
      userRegistrationStatus: 'not_registered',
      location: _locationCtrl.text.trim(),
      tags: ['AI', 'Cloud', 'Hackathon'],
      isFeatured: true,
      externalRegistrationUrl: _externalUrlCtrl.text.trim(),
      createdByRole: widget.userRole,
      createdByName: widget.userName,
    );

    ref.read(hackathonControllerProvider.notifier).addHackathon(newHackathon);

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🚀 Hackathon "${newHackathon.title}" created successfully! Registration link published.'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isHOD = widget.userRole.toLowerCase() == 'hod';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 620,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isHOD ? const Color(0xFFEEF2FF) : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isHOD ? Icons.add_moderator_rounded : Icons.supervisor_account_rounded,
                        color: isHOD ? AppColors.primary : const Color(0xFFD97706),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create New Hackathon',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                          Text(
                            'Publish event details & external registration link for students (${widget.userName})',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),

                // Title
                const Text('Hackathon Title', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _titleCtrl,
                  decoration: InputDecoration(
                    hintText: 'e.g. SRM GenAI Sprint 2026',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                ),
                const SizedBox(height: 14),

                // External Registration URL (Crucial Node in Workflow)
                const Text('External Hackathon Registration Link (Unstop / Devfolio / Official Portal)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF4F46E5))),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _externalUrlCtrl,
                  decoration: InputDecoration(
                    hintText: 'https://unstop.com/hackathons/...',
                    prefixIcon: const Icon(Icons.link_rounded, color: Color(0xFF4F46E5)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'External registration link is required' : null,
                ),
                const SizedBox(height: 14),

                // Category & Mode Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: _category,
                            items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
                            onChanged: (v) => setState(() => _category = v!),
                            decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Event Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: _mode,
                            items: _modes.map((m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 13)))).toList(),
                            onChanged: (v) => setState(() => _mode = v!),
                            decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Max Team Size & Prize Pool Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Max Team Size (Up to 6)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<int>(
                            value: _maxTeamSize,
                            items: [2, 3, 4, 5, 6].map((n) => DropdownMenuItem(value: n, child: Text('$n Members', style: const TextStyle(fontSize: 13)))).toList(),
                            onChanged: (v) => setState(() => _maxTeamSize = v!),
                            decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Prize Pool', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _prizePoolCtrl,
                            decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Registration Deadline Date Picker
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Registration Deadline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _registrationDeadline,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() => _registrationDeadline = picked);
                        }
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xFFF8FAFC),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.event_outlined, color: Color(0xFF4F46E5), size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Deadline: ${_registrationDeadline.day}/${_registrationDeadline.month}/${_registrationDeadline.year}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Organizer & Location
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Organizer Unit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _organizerCtrl,
                            decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Venue / Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _locationCtrl,
                            decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Description
                const Text('Event Description & Track Highlights', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                ),
                const SizedBox(height: 20),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _submitForm,
                    icon: const Icon(Icons.rocket_launch_rounded, size: 20),
                    label: const Text('Publish Hackathon & Broadcast to Students', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
