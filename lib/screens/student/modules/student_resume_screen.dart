import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/core/constants/app_colors.dart';
import 'package:unisphere/models/student_resume_model.dart';
import 'package:unisphere/providers/academic_overview_provider.dart';
import 'package:unisphere/services/auth_service.dart';
import 'package:unisphere/services/resume_service.dart';
import 'package:unisphere/widgets/common/unisphere_header_card.dart';
import 'package:unisphere/widgets/resume/resume_document_view.dart';
import 'package:unisphere/widgets/resume/resume_editor_modal.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentResumeScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;
  final Function(int tabIndex)? onNavigateToTab;

  const StudentResumeScreen({
    super.key,
    this.onBack,
    this.onNavigateToTab,
  });

  @override
  ConsumerState<StudentResumeScreen> createState() => _StudentResumeScreenState();
}

class _StudentResumeScreenState extends ConsumerState<StudentResumeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  StudentResumeModel? _customizedResume;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    } else if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  void _openEditorModal(StudentResumeModel currentResume) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ResumeEditorModal(
        resume: currentResume,
        onSave: (updated) {
          setState(() {
            _customizedResume = updated;
          });
        },
      ),
    );
  }

  Future<void> _openExternalLink(String? url) async {
    if (url == null || url.isEmpty) return;
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(currentUserProvider);
    final user = authState.value ?? ref.watch(authServiceProvider).currentUser;
    final overviewData = ref.watch(academicOverviewProvider);
    final resumeAsync = ref.watch(currentStudentResumeStreamProvider);
    final fallbackResume = ref.read(resumeServiceProvider).generateSyncFallbackResume(
      user: user,
      customCgpa: overviewData.cgpa > 0 ? overviewData.cgpa.toStringAsFixed(2) : null,
      customGithub: overviewData.githubUsername.isNotEmpty ? overviewData.githubUsername : null,
      customLeetCode: overviewData.leetcodeUsername.isNotEmpty ? overviewData.leetcodeUsername : null,
      customLinkedin: overviewData.linkedinUrl.isNotEmpty ? overviewData.linkedinUrl : null,
    );
    final baseResume = resumeAsync.value ?? fallbackResume;
    final activeResume = _customizedResume ?? baseResume;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Column(
            children: [
              // ================= REFERENCE UNISPHERE HEADER CARD =================
              UnisphereHeaderCard(
                title: 'Student Resume Portal',
                subtitle: 'Verified academic CV & placement-ready student profile',
                onBack: _handleBack,
                rightActions: [
                  IconButton(
                    icon: const Icon(Icons.edit_note_rounded, color: Colors.white),
                    tooltip: 'Edit Resume',
                    onPressed: () => _openEditorModal(activeResume),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                    tooltip: 'Sync Latest Records',
                    onPressed: () {
                      setState(() {
                        _customizedResume = null;
                      });
                      ref.invalidate(currentStudentResumeStreamProvider);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Synchronizing latest student records...'),
                          backgroundColor: AppColors.primary,
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
                bottomWidget: Container(
                  height: 44,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: const Color(0xFF1E3A8A),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: const Color(0xFFBFDBFE),
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    tabs: [
                      Tab(text: 'All (${activeResume.projects.length + activeResume.certifications.length + 3})'),
                      Tab(text: 'Projects (${activeResume.projects.length})'),
                      Tab(text: 'Certificates (${activeResume.certifications.length})'),
                      Tab(text: 'Skills (${activeResume.allSkills.length})'),
                    ],
                  ),
                ),
              ),

              // ================= TAB CONTENT VIEW =================
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Tab 0: Full Document View (A4 Placement CV)
                    ResumeDocumentView(
                      resume: activeResume,
                      onEditRequest: () => _openEditorModal(activeResume),
                      onResumeUpdated: (updated) {
                        setState(() {
                          _customizedResume = updated;
                        });
                      },
                      showControls: true,
                    ),

                    // Tab 1: Projects Showcase
                    _buildProjectsList(activeResume),

                    // Tab 2: Verified Certifications
                    _buildCertificationsList(activeResume),

                    // Tab 3: Skills & Technical Profiles
                    _buildSkillsList(activeResume),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectsList(StudentResumeModel resume) {
    if (resume.projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.folder_open_rounded, size: 48, color: Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            const Text('No projects added yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B))),
            const SizedBox(height: 6),
            const Text('Add hackathon submissions and technical projects to your resume.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _openEditorModal(resume),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Project'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      itemCount: resume.projects.length,
      itemBuilder: (context, index) {
        final p = resume.projects[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.code_rounded, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      p.title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                  ),
                  if (p.githubUrl != null && p.githubUrl!.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.open_in_new_rounded, size: 18, color: AppColors.primary),
                      onPressed: () => _openExternalLink(p.githubUrl),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                p.description,
                style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
              ),
              if (p.technologies.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: p.technologies.map((tech) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(tech, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildCertificationsList(StudentResumeModel resume) {
    if (resume.certifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified_outlined, size: 48, color: Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            const Text('No certifications found', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B))),
            const SizedBox(height: 6),
            const Text('Complete NPTEL courses or add verified certificates.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _openEditorModal(resume),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Certification'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      itemCount: resume.certifications.length,
      itemBuilder: (context, index) {
        final c = resume.certifications[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.verified_rounded, color: AppColors.success, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.title,
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      c.provider,
                      style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                    ),
                    if (c.issueDate != null && c.issueDate!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Issued: ${c.issueDate}',
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkillsList(StudentResumeModel resume) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.psychology_rounded, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text('Technical Skills & Frameworks', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  ],
                ),
                const SizedBox(height: 14),
                if (resume.allSkills.isEmpty)
                  const Text('No skills listed yet', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13))
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: resume.allSkills.map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: Text(skill, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.terminal_rounded, color: Color(0xFF10B981), size: 20),
                    SizedBox(width: 8),
                    Text('Verified Coding Profiles', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  ],
                ),
                const SizedBox(height: 12),
                if (resume.header.githubUrl != null && resume.header.githubUrl!.isNotEmpty)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.code_rounded, color: Color(0xFF334155)),
                    title: const Text('GitHub Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text(resume.header.githubUrl!),
                    trailing: const Icon(Icons.open_in_new_rounded, size: 16, color: AppColors.primary),
                    onTap: () => _openExternalLink(resume.header.githubUrl),
                  ),
                if (resume.header.leetcodeUrl != null && resume.header.leetcodeUrl!.isNotEmpty)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.data_object_rounded, color: Color(0xFFF59E0B)),
                    title: const Text('LeetCode Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text(resume.header.leetcodeUrl!),
                    trailing: const Icon(Icons.open_in_new_rounded, size: 16, color: AppColors.primary),
                    onTap: () => _openExternalLink(resume.header.leetcodeUrl),
                  ),
                if (resume.header.linkedinUrl != null && resume.header.linkedinUrl!.isNotEmpty)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.business_center_outlined, color: Color(0xFF0077B5)),
                    title: const Text('LinkedIn Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text(resume.header.linkedinUrl!),
                    trailing: const Icon(Icons.open_in_new_rounded, size: 16, color: AppColors.primary),
                    onTap: () => _openExternalLink(resume.header.linkedinUrl),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
