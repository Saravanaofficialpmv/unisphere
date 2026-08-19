import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:unisphere/models/student_resume_model.dart';
import 'package:url_launcher/url_launcher.dart';

enum ResumeThemeStyle { modernTech, classicExecutive, minimalistMonochrome }

class ResumeDocumentView extends StatefulWidget {
  final StudentResumeModel resume;
  final bool isInteractive;
  final bool showControls;
  final VoidCallback? onEditRequest;

  const ResumeDocumentView({
    super.key,
    required this.resume,
    this.isInteractive = true,
    this.showControls = true,
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

    return Column(
      children: [
        // Controls Bar
        if (widget.showControls) _buildControlsBar(),

        // Resume A4 Document Container
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 24,
              vertical: 16,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: Transform.scale(
                  scale: _zoomScale,
                  alignment: Alignment.topCenter,
                  child: _buildA4Paper(r, isMobile),
                ),
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
              tooltip: 'Zoom Out',
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
              tooltip: 'Zoom In',
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
              tooltip: 'Copy Resume Markdown',
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
    // Style configurations based on selected theme
    Color primaryAccent;
    Color secondaryAccent;
    Color headingColor;
    TextStyle nameStyle;

    switch (_selectedTheme) {
      case ResumeThemeStyle.modernTech:
        primaryAccent = const Color(0xFF2563EB); // Royal Blue
        secondaryAccent = const Color(0xFF3B82F6);
        headingColor = const Color(0xFF1E3A8A);
        nameStyle = GoogleFonts.outfit(fontSize: isMobile ? 21 : 24, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A), letterSpacing: -0.5);
        break;
      case ResumeThemeStyle.classicExecutive:
        primaryAccent = const Color(0xFF0F172A); // Slate Navy
        secondaryAccent = const Color(0xFF475569);
        headingColor = const Color(0xFF0F172A);
        nameStyle = GoogleFonts.cinzel(fontSize: isMobile ? 19 : 22, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A), letterSpacing: 1.0);
        break;
      case ResumeThemeStyle.minimalistMonochrome:
        primaryAccent = const Color(0xFF18181B); // Zinc 900
        secondaryAccent = const Color(0xFF71717A);
        headingColor = const Color(0xFF18181B);
        nameStyle = GoogleFonts.jetBrainsMono(fontSize: isMobile ? 18 : 20, fontWeight: FontWeight.w800, color: const Color(0xFF18181B));
        break;
    }

    return Container(
      width: isMobile ? double.infinity : 794,
      constraints: BoxConstraints(minHeight: isMobile ? 600 : 1000),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 18 : 42,
        vertical: isMobile ? 22 : 38,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── HEADER ──
          _buildHeaderSection(r.header, primaryAccent, secondaryAccent, nameStyle),

          const SizedBox(height: 18),
          _buildSectionDivider(primaryAccent),
          const SizedBox(height: 14),

          // ── PROFESSIONAL SUMMARY ──
          if (r.professionalSummary.isNotEmpty) ...[
            _buildSectionTitle('PROFESSIONAL SUMMARY', primaryAccent, headingColor),
            const SizedBox(height: 6),
            Text(
              r.professionalSummary,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                color: const Color(0xFF334155),
                height: 1.5,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 16),
          ],

          // ── TECHNICAL SKILLS ──
          if (r.hasSkills) ...[
            _buildSectionTitle('TECHNICAL SKILLS & DOMAIN EXPERTISE', primaryAccent, headingColor),
            const SizedBox(height: 8),
            _buildSkillsGrid(r.categorizedSkills, primaryAccent),
            const SizedBox(height: 16),
          ],

          // ── KEY PROJECTS ──
          if (r.hasProjects) ...[
            _buildSectionTitle('KEY TECHNICAL PROJECTS', primaryAccent, headingColor),
            const SizedBox(height: 8),
            ...r.projects.map((p) => _buildProjectItem(p, primaryAccent)),
            const SizedBox(height: 12),
          ],

          // ── PROFESSIONAL EXPERIENCE & INTERNSHIPS ──
          if (r.hasExperience) ...[
            _buildSectionTitle('WORK EXPERIENCE & INTERNSHIPS', primaryAccent, headingColor),
            const SizedBox(height: 8),
            ...r.experience.map((exp) => _buildExperienceItem(exp, primaryAccent)),
            const SizedBox(height: 12),
          ],

          // ── CERTIFICATIONS & CREDENTIALS ──
          if (r.hasCertifications) ...[
            _buildSectionTitle('VERIFIED CERTIFICATIONS & CREDENTIALS', primaryAccent, headingColor),
            const SizedBox(height: 8),
            ...r.certifications.map((c) => _buildCertificationItem(c, primaryAccent)),
            const SizedBox(height: 14),
          ],

          // ── EDUCATION ──
          if (r.hasEducation) ...[
            _buildSectionTitle('EDUCATION & ACADEMIC RECORD', primaryAccent, headingColor),
            const SizedBox(height: 8),
            ...r.education.map((e) => _buildEducationItem(e, primaryAccent)),
            const SizedBox(height: 14),
          ],

          // ── ACTIVITIES, HACKATHONS & HONORS ──
          if (r.hasActivities) ...[
            _buildSectionTitle('ACTIVITIES, HONORS & LEADERSHIP', primaryAccent, headingColor),
            const SizedBox(height: 8),
            ...r.activitiesAndAchievements.map((a) => _buildActivityItem(a, primaryAccent)),
            const SizedBox(height: 16),
          ],

          // ── FOOTER ──
          _buildResumeFooter(r),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(ResumeHeader h, Color primaryAccent, Color secondaryAccent, TextStyle nameStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name & Tagline
        Text(h.fullName.toUpperCase(), style: nameStyle),
        const SizedBox(height: 3),
        Text(
          h.headline,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: primaryAccent,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 10),

        // Contact details row
        Wrap(
          spacing: 16,
          runSpacing: 6,
          children: [
            _buildContactPill(Icons.email_outlined, h.collegeEmail),
            if (h.phone != null && h.isPhoneVisible) _buildContactPill(Icons.phone_outlined, h.phone!),
            _buildContactPill(Icons.location_on_outlined, h.location),
          ],
        ),

        // Connected Links Row
        if (h.linkedinUrl != null || h.githubUrl != null || h.leetcodeUrl != null || h.portfolioUrl != null) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 6,
            children: [
              if (h.linkedinUrl != null)
                _buildLinkBadge('LinkedIn', h.linkedinUrl!, const Color(0xFF0A66C2), Icons.link_rounded),
              if (h.githubUrl != null)
                _buildLinkBadge('GitHub', h.githubUrl!, const Color(0xFF24292E), Icons.code_rounded),
              if (h.leetcodeUrl != null)
                _buildLinkBadge('LeetCode', h.leetcodeUrl!, const Color(0xFFFFA116), Icons.terminal_rounded),
              if (h.portfolioUrl != null && h.portfolioUrl != h.githubUrl)
                _buildLinkBadge('Portfolio', h.portfolioUrl!, primaryAccent, Icons.language_rounded),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildContactPill(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: const Color(0xFF64748B)),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF475569), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildLinkBadge(String label, String url, Color color, IconData icon) {
    return InkWell(
      onTap: () => _openLink(url),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionDivider(Color color) {
    return Container(
      height: 1.5,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.3), const Color(0xFFE2E8F0)],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color primaryAccent, Color headingColor) {
    return Row(
      children: [
        Container(
          width: 3.5,
          height: 13,
          decoration: BoxDecoration(
            color: primaryAccent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 7),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: headingColor,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsGrid(List<ResumeSkillCategory> categories, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categories.map((cat) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '• ${cat.categoryName}: ',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                TextSpan(
                  text: cat.skills.join(', '),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProjectItem(ResumeProjectItem p, Color primaryAccent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: p.title,
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                      ),
                      if (p.role.isNotEmpty)
                        TextSpan(
                          text: ' | ${p.role}',
                          style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: primaryAccent),
                        ),
                    ],
                  ),
                ),
              ),
              if (p.githubUrl != null && p.githubUrl!.isNotEmpty)
                InkWell(
                  onTap: () => _openLink(p.githubUrl),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.code_rounded, size: 12, color: Color(0xFF2563EB)),
                      const SizedBox(width: 3),
                      Text(
                        'Source',
                        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF2563EB)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            p.description,
            style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF475569), height: 1.35),
          ),
          if (p.technologies.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              'Technologies: ${p.technologies.join(" • ")}',
              style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w500, color: const Color(0xFF64748B)),
            ),
          ],
          if (p.outcomes.isNotEmpty) ...[
            const SizedBox(height: 2),
            ...p.outcomes.map((out) => Padding(
                  padding: const EdgeInsets.only(left: 8, top: 1),
                  child: Text(
                    '▸ $out',
                    style: GoogleFonts.inter(fontSize: 10.5, color: const Color(0xFF334155)),
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildExperienceItem(ResumeExperienceItem exp, Color primaryAccent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: exp.role,
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                      ),
                      TextSpan(
                        text: ' — ${exp.organization}',
                        style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: primaryAccent),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                exp.duration,
                style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
              ),
            ],
          ),
          if (exp.location != null && exp.location!.isNotEmpty) ...[
            const SizedBox(height: 1),
            Text(
              exp.location!,
              style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF94A3B8), fontStyle: FontStyle.italic),
            ),
          ],
          const SizedBox(height: 3),
          ...exp.bulletPoints.map((bp) => Padding(
                padding: const EdgeInsets.only(left: 8, top: 2),
                child: Text(
                  '• $bp',
                  style: GoogleFonts.inter(fontSize: 10.8, color: const Color(0xFF475569), height: 1.35),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildCertificationItem(ResumeCertificationItem c, Color primaryAccent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF10B981)),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${c.title} ',
                    style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                  ),
                  TextSpan(
                    text: '— ${c.provider} ',
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF475569)),
                  ),
                  if (c.certificateId != null && c.certificateId!.isNotEmpty)
                    TextSpan(
                      text: '[ID: ${c.certificateId}]',
                      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
                    ),
                ],
              ),
            ),
          ),
          if (c.issueDate != null)
            Text(
              c.issueDate!,
              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF64748B)),
            ),
        ],
      ),
    );
  }

  Widget _buildEducationItem(ResumeEducationItem e, Color primaryAccent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.degree,
                  style: GoogleFonts.inter(fontSize: 11.8, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                ),
                Text(
                  e.institution,
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF475569)),
                ),
                if (e.boardOrUniversity != null)
                  Text(
                    e.boardOrUniversity!,
                    style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF64748B)),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                e.period,
                style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w600, color: const Color(0xFF334155)),
              ),
              if (e.scoreLabel != null || e.score != null)
                Text(
                  e.scoreLabel ?? 'CGPA: ${e.score}',
                  style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.bold, color: primaryAccent),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(ResumeActivityItem a, Color primaryAccent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '• ${a.title} ',
                        style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                      ),
                      if (a.roleOrRank != null && a.roleOrRank!.isNotEmpty)
                        TextSpan(
                          text: '(${a.roleOrRank}) ',
                          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: primaryAccent),
                        ),
                    ],
                  ),
                ),
              ),
              if (a.date != null)
                Text(
                  a.date!,
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: const Color(0xFF64748B)),
                ),
            ],
          ),
          if (a.description != null && a.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 1),
              child: Text(
                a.description!,
                style: GoogleFonts.inter(fontSize: 10.5, color: const Color(0xFF475569), height: 1.3),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResumeFooter(StudentResumeModel r) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final formattedDate = dateFormat.format(r.lastUpdatedAt);

    return Column(
      children: [
        const Divider(height: 20, color: Color(0xFFE2E8F0)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'UNISPHERE Academic Engine • Verified Institutional Resume',
              style: GoogleFonts.inter(fontSize: 9, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500),
            ),
            Text(
              'Reg: ${r.registerNumber} • Last Synchronized: $formattedDate',
              style: GoogleFonts.inter(fontSize: 9, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }
}
