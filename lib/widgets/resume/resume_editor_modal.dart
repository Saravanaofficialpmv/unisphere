import 'package:flutter/material.dart';
import 'package:unisphere/models/student_resume_model.dart';

class ResumeEditorModal extends StatefulWidget {
  final StudentResumeModel resume;
  final Function(StudentResumeModel updatedResume) onSave;

  const ResumeEditorModal({
    super.key,
    required this.resume,
    required this.onSave,
  });

  @override
  State<ResumeEditorModal> createState() => _ResumeEditorModalState();
}

class _ResumeEditorModalState extends State<ResumeEditorModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Header controllers
  late TextEditingController _nameController;
  late TextEditingController _headlineController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _linkedinController;
  late TextEditingController _githubController;

  // Summary controller
  late TextEditingController _summaryController;

  // Skills controllers
  late TextEditingController _progLangController;
  late TextEditingController _aimlController;
  late TextEditingController _dbController;
  late TextEditingController _toolsController;
  late TextEditingController _coreCompController;

  // Projects local list
  late List<ResumeProjectItem> _projects;

  // Certifications local list
  late List<ResumeCertificationItem> _certifications;

  // Strengths local list
  late List<String> _strengths;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    final h = widget.resume.header;
    _nameController = TextEditingController(text: h.fullName);
    _headlineController = TextEditingController(text: h.headline);
    _emailController = TextEditingController(text: h.collegeEmail);
    _phoneController = TextEditingController(text: h.phone ?? '+91-8220537987');
    _linkedinController = TextEditingController(text: h.linkedinUrl ?? '');
    _githubController = TextEditingController(text: h.githubUrl ?? '');

    _summaryController = TextEditingController(text: widget.resume.professionalSummary);

    // Initial skills extraction
    String findSkills(String category) {
      final match = widget.resume.categorizedSkills.where((c) => c.categoryName.toLowerCase().contains(category.toLowerCase()));
      if (match.isNotEmpty) return match.first.skills.join('  ·  ');
      return '';
    }

    _progLangController = TextEditingController(text: findSkills('Programming Languages').isNotEmpty ? findSkills('Programming Languages') : 'Python  ·  Java  ·  SQL  ·  Dart  ·  C++');
    _aimlController = TextEditingController(text: findSkills('AI').isNotEmpty ? findSkills('AI') : 'Machine Learning  ·  Deep Learning  ·  NLP  ·  Data Analytics');
    _dbController = TextEditingController(text: findSkills('Database').isNotEmpty ? findSkills('Database') : 'SQL  ·  Database Design  ·  Query Optimisation  ·  Firebase Firestore');
    _toolsController = TextEditingController(text: findSkills('Tools').isNotEmpty ? findSkills('Tools') : 'Git  ·  VS Code  ·  Flutter  ·  Android Studio  ·  PyCharm');
    _coreCompController = TextEditingController(text: findSkills('Competencies').isNotEmpty ? findSkills('Competencies') : 'Algorithm Design  ·  Data Visualisation  ·  OOP  ·  SDLC  ·  Problem Solving');

    _projects = List.from(widget.resume.projects);
    _certifications = List.from(widget.resume.certifications);
    _strengths = List.from(widget.resume.strengths);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _headlineController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    _summaryController.dispose();
    _progLangController.dispose();
    _aimlController.dispose();
    _dbController.dispose();
    _toolsController.dispose();
    _coreCompController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final updatedHeader = ResumeHeader(
      fullName: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : widget.resume.header.fullName,
      headline: _headlineController.text.trim().isNotEmpty ? _headlineController.text.trim() : widget.resume.header.headline,
      collegeEmail: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      location: widget.resume.header.location,
      linkedinUrl: _linkedinController.text.trim().isNotEmpty ? _linkedinController.text.trim() : widget.resume.header.linkedinUrl,
      githubUrl: _githubController.text.trim().isNotEmpty ? _githubController.text.trim() : widget.resume.header.githubUrl,
      leetcodeUrl: widget.resume.header.leetcodeUrl,
      portfolioUrl: widget.resume.header.portfolioUrl,
    );

    List<String> parseSkills(String text) {
      return text.split(RegExp(r'[\·•,]+')).map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    }

    final updatedSkills = [
      ResumeSkillCategory(categoryName: 'Programming Languages', skills: parseSkills(_progLangController.text)),
      ResumeSkillCategory(categoryName: 'AI / ML Technologies', skills: parseSkills(_aimlController.text)),
      ResumeSkillCategory(categoryName: 'Database Management', skills: parseSkills(_dbController.text)),
      ResumeSkillCategory(categoryName: 'Development Tools', skills: parseSkills(_toolsController.text)),
      ResumeSkillCategory(categoryName: 'Core Competencies', skills: parseSkills(_coreCompController.text)),
    ];

    final updatedResume = widget.resume.copyWith(
      header: updatedHeader,
      professionalSummary: _summaryController.text.trim(),
      categorizedSkills: updatedSkills,
      projects: _projects,
      certifications: _certifications,
      strengths: _strengths,
      lastUpdatedAt: DateTime.now(),
    );

    widget.onSave(updatedResume);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.tune_rounded, color: Color(0xFF2563EB), size: 18),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customize Resume Details',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      Text(
                        'Edit your target role, summary, skills & projects in real-time',
                        style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Tab Bar
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: const Color(0xFF2563EB),
            unselectedLabelColor: const Color(0xFF64748B),
            labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            indicatorColor: const Color(0xFF2563EB),
            indicatorWeight: 2.5,
            tabs: const [
              Tab(text: 'Header & Roles'),
              Tab(text: 'Summary'),
              Tab(text: 'Skills'),
              Tab(text: 'Projects'),
              Tab(text: 'Certifications'),
            ],
          ),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildHeaderTab(),
                _buildSummaryTab(),
                _buildSkillsTab(),
                _buildProjectsTab(),
                _buildCertificationsTab(),
              ],
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveChanges,
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text('Apply & Re-generate Resume', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField('Full Name (All-Caps on Resume)', _nameController, 'e.g. SARAVANA SELVARAJU'),
          const SizedBox(height: 14),

          // Target Role Preset Selector
          const Text('Target Roles / Headline', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildRoleChip('Software Developer  |  AI Engineer  |  Data Scientist'),
              _buildRoleChip('Full-Stack Software Engineer  |  Mobile App Specialist'),
              _buildRoleChip('Cloud Architect  |  Backend Distributed Systems Specialist'),
            ],
          ),
          const SizedBox(height: 8),
          _buildTextField('', _headlineController, 'Custom role subtitle'),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(child: _buildTextField('College Email', _emailController, 'name@college.edu')),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField('Phone Number', _phoneController, '+91 98765 43210')),
            ],
          ),
          const SizedBox(height: 14),

          _buildTextField('LinkedIn Profile URL', _linkedinController, 'https://linkedin.com/in/...'),
          const SizedBox(height: 14),
          _buildTextField('GitHub Profile URL', _githubController, 'https://github.com/...'),
        ],
      ),
    );
  }

  Widget _buildRoleChip(String roleText) {
    final isSelected = _headlineController.text.trim() == roleText.trim();
    return InkWell(
      onTap: () => setState(() => _headlineController.text = roleText),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1)),
        ),
        child: Text(
          roleText,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Professional Summary',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 4),
          const Text(
            'A 3-4 sentence concise opening statement highlighting your academic background, technical focus, and career aspirations.',
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _summaryController,
            maxLines: 6,
            style: const TextStyle(fontSize: 12, height: 1.45, color: Color(0xFF1E293B)),
            decoration: InputDecoration(
              hintText: 'Enter your career summary...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2563EB))),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              ActionChip(
                label: const Text('Use AI & Data Science Template', style: TextStyle(fontSize: 11)),
                onPressed: () {
                  setState(() {
                    _summaryController.text = 'Motivated Computer Science student specialising in Artificial Intelligence and Data Science, with hands-on experience in Java, Python, and AI technologies. Passionate about building innovative solutions through machine learning, data analytics, and software development. Eager to leverage strong programming and AI foundations in a dynamic, technology-driven environment.';
                  });
                },
              ),
              ActionChip(
                label: const Text('Use Mobile & Cloud Template', style: TextStyle(fontSize: 11)),
                onPressed: () {
                  setState(() {
                    _summaryController.text = 'Dedicated and result-driven Computer Science student with expertise in Flutter cross-platform mobile architecture, Firebase cloud integrations, and scalable software systems. Experienced in architecting production campus management solutions and real-time backend sync workflows.';
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField('Programming Languages', _progLangController, 'Python  ·  Java  ·  SQL  ·  Dart  ·  C++'),
          const SizedBox(height: 14),
          _buildTextField('AI / ML Technologies', _aimlController, 'Machine Learning  ·  Deep Learning  ·  NLP  ·  Data Analytics'),
          const SizedBox(height: 14),
          _buildTextField('Database Management', _dbController, 'SQL  ·  Database Design  ·  Query Optimisation  ·  Firebase Firestore'),
          const SizedBox(height: 14),
          _buildTextField('Development Tools', _toolsController, 'Git  ·  VS Code  ·  Flutter  ·  Android Studio  ·  PyCharm'),
          const SizedBox(height: 14),
          _buildTextField('Core Competencies', _coreCompController, 'Algorithm Design  ·  Data Visualisation  ·  OOP  ·  SDLC  ·  Problem Solving'),
        ],
      ),
    );
  }

  Widget _buildProjectsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _projects.length,
      itemBuilder: (context, index) {
        final p = _projects[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Color(0xFFE2E8F0))),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        p.title,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 18),
                      onPressed: () {
                        setState(() => _projects.removeAt(index));
                      },
                    ),
                  ],
                ),
                Text(
                  'Tech: ${p.technologies.join(" · ")}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF2563EB), fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  p.description,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCertificationsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _certifications.length,
      itemBuilder: (context, index) {
        final c = _certifications[index];
        return ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Color(0xFFE2E8F0))),
          title: Text(c.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          subtitle: Text(c.provider, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 18),
            onPressed: () {
              setState(() => _certifications.removeAt(index));
            },
          ),
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
          const SizedBox(height: 4),
        ],
        TextField(
          controller: controller,
          style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2563EB))),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
          ),
        ),
      ],
    );
  }
}
