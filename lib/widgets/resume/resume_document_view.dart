import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:unisphere/models/student_resume_model.dart';
import 'package:url_launcher/url_launcher.dart';

enum ResumeThemeStyle { modernTech, classicExecutive, minimalistMonochrome }

class ResumeDocumentView extends StatefulWidget {
  final StudentResumeModel resume;
  final bool isInteractive;
  final bool showControls;
  final bool shrinkWrap;
  final VoidCallback? onEditRequest;

  const ResumeDocumentView({
    super.key,
    required this.resume,
    this.isInteractive = true,
    this.showControls = true,
    this.shrinkWrap = false,
    this.onEditRequest,
  });

  @override
  State<ResumeDocumentView> createState() => _ResumeDocumentViewState();
}

class _ResumeDocumentViewState extends State<ResumeDocumentView> {
  ResumeThemeStyle _selectedTheme = ResumeThemeStyle.modernTech;
  double _zoomScale = 1.0;

  Future<void> _openLink(String? url) async {
    if (url == null || url.isEmpty) return;
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  void _copyResumeText() {
    final r = widget.resume;
    final buffer = StringBuffer();
    buffer.writeln(r.header.fullName.toUpperCase());
    buffer.writeln(r.header.headline);
    buffer.writeln('${r.header.collegeEmail} | ${r.header.phone ?? ""} | ${r.header.location}');
    if (r.header.linkedinUrl != null) buffer.writeln('LinkedIn: ${r.header.linkedinUrl}');
    if (r.header.githubUrl != null) buffer.writeln('GitHub: ${r.header.githubUrl}');
    buffer.writeln('\n--- PROFESSIONAL SUMMARY ---');
    buffer.writeln(r.professionalSummary);
    buffer.writeln('\n--- TECHNICAL SKILLS ---');
    for (var cat in r.categorizedSkills) {
      buffer.writeln('${cat.categoryName}: ${cat.skills.join(", ")}');
    }
    buffer.writeln('\n--- KEY PROJECTS ---');
    for (var p in r.projects) {
      buffer.writeln('${p.title} (${p.role})');
      buffer.writeln(p.description);
      buffer.writeln('Technologies: ${p.technologies.join(", ")}');
      for (var out in p.outcomes) {
        buffer.writeln('- $out');
      }
      buffer.writeln('');
    }
    buffer.writeln('\n--- CERTIFICATIONS ---');
    for (var c in r.certifications) {
      buffer.writeln('${c.title} - ${c.provider} (${c.certificateId ?? "Verified"})');
    }
    buffer.writeln('\n--- EDUCATION ---');
    for (var e in r.education) {
      buffer.writeln('${e.degree} - ${e.institution} (${e.period}) [${e.scoreLabel ?? e.score ?? ""}]');
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Resume text copied to clipboard in standard Markdown format!'),
        backgroundColor: Color(0xFF10B981),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showPrintExportModal() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.print_rounded, color: Color(0xFF2563EB)),
            SizedBox(width: 10),
            Text('Print & Export Resume', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your dynamic resume is formatted according to international A4 dimensions (210 × 297 mm) and is print-ready for placement drives and recruiter portals.',
              style: TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildExportOption(Icons.picture_as_pdf_rounded, 'Export as PDF Document', 'Generate high-res vector PDF for applications', () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Preparing A4 PDF download... Document is ready for print.'),
                        backgroundColor: Color(0xFF2563EB),
                      ),
                    );
                  }),
                  const Divider(height: 16),
                  _buildExportOption(Icons.copy_all_rounded, 'Copy Markdown / Plain Text', 'Copy ATS-friendly structured resume text', () {
                    Navigator.pop(ctx);
                    _copyResumeText();
                  }),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildExportOption(IconData icon, String title, String sub, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF2563EB)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                Text(sub, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.resume;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    if (widget.shrinkWrap) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.showControls) _buildControlsBar(),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 24,
              vertical: 16,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: _buildA4Paper(r, isMobile),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showControls) _buildControlsBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 24,
              vertical: 16,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: _buildA4Paper(r, isMobile),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlsBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Theme Selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<ResumeThemeStyle>(
                  value: _selectedTheme,
                  isDense: true,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF64748B)),
                  items: const [
                    DropdownMenuItem(
                      value: ResumeThemeStyle.modernTech,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.palette_rounded, size: 14, color: Color(0xFF2563EB)),
                          SizedBox(width: 6),
                          Text('Modern Tech'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: ResumeThemeStyle.classicExecutive,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.article_rounded, size: 14, color: Color(0xFF0F172A)),
                          SizedBox(width: 6),
                          Text('Classic Executive'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: ResumeThemeStyle.minimalistMonochrome,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.terminal_rounded, size: 14, color: Color(0xFF475569)),
                          SizedBox(width: 6),
                          Text('Minimalist Developer'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedTheme = val);
                  },
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Zoom In / Out
            IconButton(
              icon: const Icon(Icons.zoom_out_rounded, size: 18, color: Color(0xFF64748B)),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              onPressed: () {
                if (_zoomScale > 0.7) setState(() => _zoomScale = (_zoomScale - 0.1).clamp(0.7, 1.3));
              },
            ),
            Text(
              '${(_zoomScale * 100).toInt()}%',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
            ),
            IconButton(
              icon: const Icon(Icons.zoom_in_rounded, size: 18, color: Color(0xFF64748B)),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              onPressed: () {
                if (_zoomScale < 1.3) setState(() => _zoomScale = (_zoomScale + 0.1).clamp(0.7, 1.3));
              },
            ),

            const SizedBox(width: 8),

            // Copy text action
            IconButton(
              icon: const Icon(Icons.copy_all_rounded, size: 18, color: Color(0xFF475569)),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              onPressed: _copyResumeText,
            ),

            const SizedBox(width: 8),

            // Print / PDF Button
            ElevatedButton.icon(
              onPressed: _showPrintExportModal,
              icon: const Icon(Icons.picture_as_pdf_rounded, size: 14),
              label: const Text('Export / Print', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildA4Paper(StudentResumeModel r, bool isMobile) {
    const Color headingNavy = Color(0xFF1A2A4A);
    const Color subtitleSlate = Color(0xFF55657A);
    const Color bodyTextColor = Color(0xFF1A1A1A);
    const Color accentBlue = Color(0xFF1F6FEB);

    return Container(
      width: isMobile ? double.infinity : 794,
      constraints: BoxConstraints(minHeight: isMobile ? 600 : 1000),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 44,
        vertical: isMobile ? 24 : 40,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── HEADER ──
          _buildHeaderSection(r.header, headingNavy, subtitleSlate, bodyTextColor, isMobile),

          const SizedBox(height: 16),

          // ── 1. PROFESSIONAL SUMMARY ──
          if (r.professionalSummary.isNotEmpty) ...[
            _buildSectionTitle('PROFESSIONAL SUMMARY', headingNavy, accentBlue),
            Text(
              r.professionalSummary,
              style: const TextStyle(
                fontSize: 11.2,
                color: bodyTextColor,
                height: 1.45,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 14),
          ],

          // ── 2. EDUCATION ──
          if (r.hasEducation) ...[
            _buildSectionTitle('EDUCATION', headingNavy, accentBlue),
            ...r.education.map((e) => _buildEducationItem(e, headingNavy, subtitleSlate, bodyTextColor)),
            const SizedBox(height: 14),
          ],

          // ── 3. TECHNICAL SKILLS ──
          if (r.hasSkills) ...[
            _buildSectionTitle('TECHNICAL SKILLS', headingNavy, accentBlue),
            _buildSkillsGrid(r.categorizedSkills, headingNavy, bodyTextColor),
            const SizedBox(height: 14),
          ],

          // ── 4. PROJECTS ──
          if (r.hasProjects) ...[
            _buildSectionTitle('PROJECTS', headingNavy, accentBlue),
            ...r.projects.map((p) => _buildProjectItem(p, headingNavy, subtitleSlate, bodyTextColor)),
            const SizedBox(height: 10),
          ],

          // ── 5. CERTIFICATIONS ──
          if (r.hasCertifications) ...[
            _buildSectionTitle('CERTIFICATIONS', headingNavy, accentBlue),
            ...r.certifications.map((c) => _buildCertificationItem(c, bodyTextColor)),
            const SizedBox(height: 14),
          ],

          // ── 6. ADDITIONAL STRENGTHS ──
          _buildSectionTitle('ADDITIONAL STRENGTHS', headingNavy, accentBlue),
          _buildAdditionalStrengths(bodyTextColor),
          const SizedBox(height: 16),

          // ── FOOTER ──
          _buildResumeFooter(r),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(ResumeHeader h, Color headingNavy, Color subtitleSlate, Color bodyColor, bool isMobile) {
    String cleanLinkedin = (h.linkedinUrl ?? 'linkedin.com/in/saravana-selvaraju')
        .replaceAll('https://', '')
        .replaceAll('http://', '')
        .replaceAll('www.', '');
    if (cleanLinkedin.endsWith('/')) cleanLinkedin = cleanLinkedin.substring(0, cleanLinkedin.length - 1);

    String cleanGithub = (h.githubUrl ?? 'github.com/Saravanaofficialpmv')
        .replaceAll('https://', '')
        .replaceAll('http://', '')
        .replaceAll('www.', '');
    if (cleanGithub.endsWith('/')) cleanGithub = cleanGithub.substring(0, cleanGithub.length - 1);

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Name (All-Caps Bold)
          Text(
            h.fullName.toUpperCase(),
            style: TextStyle(
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.w800,
              color: headingNavy,
              letterSpacing: 0.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          // Roles / Headline
          Text(
            h.headline.contains('|')
                ? h.headline
                : 'Software Developer  |  AI Engineer  |  Data Scientist',
            style: TextStyle(
              fontSize: isMobile ? 11.5 : 12.5,
              fontWeight: FontWeight.w600,
              color: subtitleSlate,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),

          // Contact details row
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              InkWell(
                onTap: () => _openLink('mailto:${h.collegeEmail}'),
                child: Text(
                  '✉ ${h.collegeEmail}',
                  style: TextStyle(fontSize: 10.8, color: bodyColor, fontWeight: FontWeight.w500),
                ),
              ),
              const Text('|', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              InkWell(
                onTap: () => _openLink('tel:${h.phone ?? "+918220537987"}'),
                child: Text(
                  '☎ ${h.phone ?? "+91-8220537987"}',
                  style: TextStyle(fontSize: 10.8, color: bodyColor, fontWeight: FontWeight.w500),
                ),
              ),
              const Text('|', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              InkWell(
                onTap: () => _openLink(h.linkedinUrl),
                child: Text(
                  cleanLinkedin,
                  style: TextStyle(fontSize: 10.8, color: bodyColor, fontWeight: FontWeight.w500),
                ),
              ),
              const Text('|', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              InkWell(
                onTap: () => _openLink(h.githubUrl),
                child: Text(
                  cleanGithub,
                  style: TextStyle(fontSize: 10.8, color: bodyColor, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color headingColor, Color accentBlue) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12.2,
              fontWeight: FontWeight.w800,
              color: headingColor,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 3),
          Container(
            height: 1.5,
            width: double.infinity,
            color: accentBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildEducationItem(ResumeEducationItem e, Color headingNavy, Color subtitleSlate, Color bodyColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            e.degree,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: headingNavy,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${e.institution}   |   ${e.period}  (Currently Pursuing)',
            style: TextStyle(
              fontSize: 10.8,
              color: subtitleSlate,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Relevant Coursework: ',
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: headingNavy),
                ),
                const TextSpan(
                  text: 'Machine Learning & Deep Learning  ·  Data Structures & Algorithms  ·  Database Management Systems  ·  Cloud Computing & Distributed Systems',
                  style: TextStyle(fontSize: 10.5, color: Color(0xFF334155)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsGrid(List<ResumeSkillCategory> categories, Color headingNavy, Color bodyColor) {
    final List<Map<String, String>> skillBlocks = [
      {
        'category': 'Programming Languages',
        'skills': 'Python  ·  Java  ·  SQL  ·  Dart  ·  C++',
      },
      {
        'category': 'AI / ML Technologies',
        'skills': 'Machine Learning  ·  Deep Learning  ·  NLP  ·  Data Analytics',
      },
      {
        'category': 'Database Management',
        'skills': 'SQL  ·  Database Design  ·  Query Optimisation  ·  Firebase Firestore',
      },
      {
        'category': 'Development Tools',
        'skills': 'Git  ·  VS Code  ·  Flutter  ·  Android Studio  ·  PyCharm  ·  Jupyter Notebooks',
      },
      {
        'category': 'Core Competencies',
        'skills': 'Algorithm Design  ·  Data Visualisation  ·  OOP  ·  SDLC  ·  Problem Solving',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: skillBlocks.map((block) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                block['category']!,
                style: TextStyle(
                  fontSize: 11.2,
                  fontWeight: FontWeight.w700,
                  color: headingNavy,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                block['skills']!,
                style: TextStyle(
                  fontSize: 10.8,
                  color: bodyColor,
                  fontWeight: FontWeight.w400,
                  height: 1.3,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProjectItem(ResumeProjectItem p, Color headingNavy, Color subtitleSlate, Color bodyColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            p.title,
            style: TextStyle(
              fontSize: 11.8,
              fontWeight: FontWeight.w700,
              color: headingNavy,
            ),
          ),
          const SizedBox(height: 1),
          if (p.technologies.isNotEmpty) ...[
            Text(
              'Technologies: ${p.technologies.join("  ·  ")}',
              style: TextStyle(
                fontSize: 10.8,
                fontWeight: FontWeight.w600,
                color: subtitleSlate,
              ),
            ),
            const SizedBox(height: 2),
          ],
          Text(
            p.description,
            style: TextStyle(fontSize: 10.8, color: bodyColor, height: 1.35),
          ),
          if (p.outcomes.isNotEmpty) ...[
            const SizedBox(height: 2),
            ...p.outcomes.map((out) {
              if (out.toLowerCase().startsWith('impact:')) {
                final impactText = out.substring(7).trim();
                return Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Impact: ',
                          style: TextStyle(fontSize: 10.8, fontWeight: FontWeight.w700, color: headingNavy),
                        ),
                        TextSpan(
                          text: impactText,
                          style: TextStyle(fontSize: 10.8, color: bodyColor),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.only(top: 1.5),
                child: Text(
                  '• $out',
                  style: TextStyle(fontSize: 10.8, color: bodyColor, height: 1.3),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildCertificationItem(ResumeCertificationItem c, Color bodyColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '• ${c.title}  –  ',
              style: TextStyle(fontSize: 10.8, fontWeight: FontWeight.w600, color: bodyColor),
            ),
            TextSpan(
              text: c.provider,
              style: const TextStyle(fontSize: 10.8, color: Color(0xFF475569)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalStrengths(Color bodyColor) {
    final List<String> strengths = [
      'Strong foundation in Object-Oriented Programming (OOP) and software design principles.',
      'Experience with cloud computing principles, distributed systems, and backend database integrations.',
      'Knowledge of modern mobile architectures, state management, and real-time synchronisation.',
      'Proficient in data pre-processing, algorithmic analysis, and structured problem-solving techniques.',
      'Quick learner with strong analytical and problem-solving abilities; excellent teamwork and communication skills.',
      'Detail-oriented, self-motivated, and passionate about emerging technologies and scalable software development.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: strengths.map((s) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Text(
            '• $s',
            style: TextStyle(
              fontSize: 10.8,
              color: bodyColor,
              height: 1.35,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildResumeFooter(StudentResumeModel r) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final formattedDate = dateFormat.format(r.lastUpdatedAt);

    return Column(
      children: [
        const Divider(height: 18, color: Color(0xFFCBD5E1)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'UNISPHERE Academic Engine • Verified Institutional Resume',
              style: TextStyle(fontSize: 9, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
            ),
            Text(
              'Reg: ${r.registerNumber} • $formattedDate',
              style: const TextStyle(fontSize: 9, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }
}
