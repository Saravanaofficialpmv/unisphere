import 'package:flutter/material.dart';
import 'package:unisphere/screens/features/leetcode_detail_screen.dart';
import 'package:unisphere/screens/features/github_detail_screen.dart';
import 'package:url_launcher/url_launcher.dart';

/// Comprehensive Modal Sheet allowing Staff & HOD to view full student details:
/// LeetCode Analytics, GitHub Repos, Resume PDF, Academic CGPA, Attendance, etc.
void showStudentFullDetailModal(BuildContext context, Map<String, dynamic> student) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => StudentFullDetailSheet(student: student),
  );
}

class StudentFullDetailSheet extends StatefulWidget {
  final Map<String, dynamic> student;

  const StudentFullDetailSheet({super.key, required this.student});

  @override
  State<StudentFullDetailSheet> createState() => _StudentFullDetailSheetState();
}

class _StudentFullDetailSheetState extends State<StudentFullDetailSheet> {
  Future<void> _launchURL(String urlString) async {
    try {
      final Uri uri = Uri.parse(urlString);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening link: $urlString')),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening link: $urlString')),
        );
      }
    }
  }

  void _showNotification(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.student;
    final String name = s['name'] ?? 'Student Name';
    final String regNo = s['regNo'] ?? '917721104000';
    final String year = s['year'] ?? '3rd Year';
    final String section = s['section'] ?? 'CS-A';
    final String photo = s['photo'] ?? 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=150';
    final String cgpa = s['cgpa'] ?? '8.85';
    final String attendance = s['attendance'] ?? '95.0%';

    final String leetcodeUsername = s['leetcodeUsername'] ?? 'saravanapmv';
    final int leetcodeSolved = s['leetcodeSolved'] ?? 130;
    final int leetcodeEasy = s['leetcodeEasy'] ?? 104;
    final int leetcodeMedium = s['leetcodeMedium'] ?? 24;
    final int leetcodeHard = s['leetcodeHard'] ?? 2;
    final int leetcodeStreak = s['leetcodeStreak'] ?? 12;

    final String githubUsername = s['githubUsername'] ?? 'Saravanaofficialpmv';
    final int githubRepos = s['githubRepos'] ?? 14;
    final int githubCommits = s['githubCommits'] ?? 87;
    final int githubStars = s['githubStars'] ?? 0;
    final List<String> techStack = List<String>.from(
      s['githubTopTech'] ?? ['Flutter/Dart', 'C++', 'Java', 'Python'],
    );

    final String resumeFileName = s['resumeFileName'] ?? '${name.replaceAll(' ', '_')}_Resume_2026.pdf';
    final String resumeUpdated = s['resumeUpdated'] ?? 'Updated 2 weeks ago';
    final String portfolioUrl = s['portfolioUrl'] ?? 'https://$leetcodeUsername.dev';
    final String linkedinUrl = s['linkedinUrl'] ?? 'https://linkedin.com/in/saravana-selvaraju';
    final List<String> skills = List<String>.from(
      s['skills'] ?? ['Data Structures', 'Algorithms', 'Flutter App Dev', 'REST APIs', 'System Design', 'Git'],
    );

    return DefaultTabController(
      length: 6,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.92,
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Handle indicator
            const SizedBox(height: 12),
            Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 14),

            // Header Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(photo),
                    backgroundColor: const Color(0xFFE2E8F0),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFBFDBFE)),
                              ),
                              child: Text(
                                '$year ($section)',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Reg No: $regNo • CGPA: $cgpa • Att: $attendance',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
            const SizedBox(height: 12),

            // Scrollable TabBar
            Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: const TabBar(
                isScrollable: true,
                labelColor: Color(0xFF2563EB),
                unselectedLabelColor: Color(0xFF64748B),
                indicatorColor: Color(0xFF2563EB),
                indicatorWeight: 3,
                tabs: [
                  Tab(icon: Icon(Icons.code_rounded, size: 18), text: 'LeetCode Analytics'),
                  Tab(icon: Icon(Icons.integration_instructions_rounded, size: 18), text: 'GitHub & Repos'),
                  Tab(icon: Icon(Icons.description_rounded, size: 18), text: 'Resume & Links'),
                  Tab(icon: Icon(Icons.school_rounded, size: 18), text: 'Academic Record'),
                  Tab(icon: Icon(Icons.assignment_turned_in_rounded, size: 18), text: 'Internal Marks'),
                  Tab(icon: Icon(Icons.family_restroom_rounded, size: 18), text: 'Personal & Guardian'),
                ],
              ),
            ),

            // TabBar Views
            Expanded(
              child: TabBarView(
                children: [
                  // 1. LeetCode Tab
                  _buildLeetCodeTab(
                    context,
                    leetcodeUsername,
                    leetcodeSolved,
                    leetcodeEasy,
                    leetcodeMedium,
                    leetcodeHard,
                    leetcodeStreak,
                  ),

                  // 2. GitHub Tab
                  _buildGitHubTab(
                    githubUsername,
                    githubRepos,
                    githubCommits,
                    githubStars,
                    techStack,
                  ),

                  // 3. Resume & Links Tab
                  _buildResumeTab(
                    resumeFileName,
                    resumeUpdated,
                    portfolioUrl,
                    linkedinUrl,
                    skills,
                  ),

                  // 4. Academic Record Tab
                  _buildAcademicTab(cgpa, attendance, s),

                  // 5. Internal Marks Tab
                  _buildInternalMarksTab(s),

                  // 6. Personal & Guardian Tab
                  _buildPersonalTab(s),
                ],
              ),
            ),

            // Action Footer
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Wrap(
                spacing: 10,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LeetCodeDetailScreen()),
                      );
                    },
                    icon: const Icon(Icons.analytics_rounded, size: 16),
                    label: const Text('Open Live LeetCode Analytics'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEA580C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _showNotification('Opening Student PDF Resume...'),
                    icon: const Icon(Icons.download_rounded, size: 16),
                    label: const Text('Download Resume'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2563EB),
                      side: const BorderSide(color: Color(0xFF2563EB)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _showNotification('Sending email alert to student...'),
                    icon: const Icon(Icons.mail_outline_rounded, size: 16),
                    label: const Text('Contact Student'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF475569),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab 1: LeetCode Analytics ─────────────────
  Widget _buildLeetCodeTab(
    BuildContext context,
    String username,
    int total,
    int easy,
    int medium,
    int hard,
    int streak,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFD8A8)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEA580C).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.code_rounded, color: Color(0xFFEA580C), size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '@$username',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF9A3412),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEA580C),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Verified Student Profile',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Total Problems Solved: $total • Streak: $streak Days 🔥',
                        style: const TextStyle(fontSize: 12, color: Color(0xFFC2410C), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Problem Difficulty Breakdown Cards
          const Text(
            'Problem Difficulty Breakdown',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildDiffCard('Easy', easy, 820, const Color(0xFF10B981), const Color(0xFFECFDF5)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDiffCard('Medium', medium, 1720, const Color(0xFFF59E0B), const Color(0xFFFFFBEB)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDiffCard('Hard', hard, 750, const Color(0xFFEF4444), const Color(0xFFFEF2F2)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quick LeetCode Key Metrics
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn('Total Solved', '$total', const Color(0xFFEA580C)),
                _buildStatColumn('Global Rank', '#1293478', const Color(0xFF6366F1)),
                _buildStatColumn('Acceptance', '68.4%', const Color(0xFF10B981)),
                _buildStatColumn('Streak', '$streak Days 🔥', const Color(0xFFF59E0B)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiffCard(String label, int solved, int total, Color color, Color bgColor) {
    final double pct = (solved / total).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(4)),
                child: Text('${(pct * 100).toInt()}%', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('$solved / $total', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 5,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String val, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
        const SizedBox(height: 2),
        Text(val, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  // ── Tab 2: GitHub & Open Source ───────────────
  Widget _buildGitHubTab(
    String username,
    int repos,
    int commits,
    int stars,
    List<String> techStack,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GitHub Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.integration_instructions_rounded, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '@$username',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'GitHub Developer Profile • Open Source Contributor',
                        style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const GitHubDetailScreen()),
                        );
                      },
                      icon: const Icon(Icons.analytics_rounded, size: 14),
                      label: const Text('Analytics'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    OutlinedButton.icon(
                      onPressed: () => _launchURL('https://github.com/$username'),
                      icon: const Icon(Icons.open_in_new_rounded, size: 13),
                      label: const Text('GitHub', style: TextStyle(fontSize: 11)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF334155)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // GitHub Stats Grid
          Row(
            children: [
              Expanded(child: _buildGitStatCard('Public Repos', '$repos', Icons.folder_copy_rounded, const Color(0xFF2563EB))),
              const SizedBox(width: 10),
              Expanded(child: _buildGitStatCard('Commits (Year)', '$commits', Icons.commit_rounded, const Color(0xFF10B981))),
              const SizedBox(width: 10),
              Expanded(child: _buildGitStatCard('Stars Earned', '$stars ⭐', Icons.star_rounded, const Color(0xFFF59E0B))),
            ],
          ),
          const SizedBox(height: 16),

          // Top Tech Stack
          const Text('Top Languages & Technologies', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: techStack.map((tech) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.code_rounded, size: 14, color: Color(0xFF2563EB)),
                    const SizedBox(width: 6),
                    Text(tech, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8))),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Featured Projects List
          const Text('Featured Repositories', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 8),
          _buildRepoItem('unisphere-mobile-app', 'Cross-platform Smart Campus ERP built with Flutter & Firebase', 'Dart', 24),
          const SizedBox(height: 8),
          _buildRepoItem('leetcode-solutions-cpp', 'Clean C++ implementations of 130+ LeetCode DSA questions', 'C++', 12),
          const SizedBox(height: 8),
          _buildRepoItem('agentic-ai-assistant', 'Agentic workflow scripts for automated software development', 'Python', 9),
        ],
      ),
    );
  }

  Widget _buildGitStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildRepoItem(String title, String desc, String lang, int stars) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.book_outlined, color: Color(0xFF475569), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(lang, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
              const SizedBox(height: 2),
              Text('$stars ⭐', style: const TextStyle(fontSize: 10, color: Color(0xFFF59E0B), fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Tab 3: Resume & Links ────────────────────
  Widget _buildResumeTab(
    String fileName,
    String updated,
    String portfolioUrl,
    String linkedinUrl,
    List<String> skills,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resume PDF Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 4))],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFEF4444), size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(updated, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showNotification('Opening Student PDF Resume...'),
                  icon: const Icon(Icons.visibility_rounded, size: 14),
                  label: const Text('View PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // External Links
          const Text('Online Portfolios & Links', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 10),
          _buildLinkItem('Personal Portfolio Website', portfolioUrl, Icons.language_rounded, const Color(0xFF2563EB)),
          const SizedBox(height: 8),
          _buildLinkItem('LinkedIn Professional Network', linkedinUrl, Icons.work_rounded, const Color(0xFF0284C7)),
          const SizedBox(height: 16),

          // Verified Skills
          const Text('Verified Core Skills', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills.map((s) {
              return Chip(
                avatar: const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF10B981)),
                label: Text(s, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkItem(String title, String url, IconData icon, Color color) {
    return InkWell(
      onTap: () => _launchURL(url),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  Text(url, style: TextStyle(fontSize: 11, color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  // ── Tab 4: Academic Record ────────────────────
  Widget _buildAcademicTab(String cgpa, String attendance, Map<String, dynamic> s) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildInfoCard('Current CGPA', cgpa, 'Rank #3 in Class', const Color(0xFF2563EB))),
              const SizedBox(width: 10),
              Expanded(child: _buildInfoCard('Attendance', attendance, 'Eligible for Exams', const Color(0xFF10B981))),
              const SizedBox(width: 10),
              Expanded(child: _buildInfoCard('Backlogs', '0', 'Clean History', const Color(0xFF059669))),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Semester History', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 8),
          _buildSemRow('Semester 1', '9.00', 'Passed'),
          _buildSemRow('Semester 2', '9.10', 'Passed'),
          _buildSemRow('Semester 3', '9.20', 'Passed'),
          _buildSemRow('Semester 4', '9.15', 'Passed'),
          _buildSemRow('Semester 5', '9.12', 'Passed'),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String mainVal, String subVal, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          const SizedBox(height: 4),
          Text(mainVal, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(subVal, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  Widget _buildSemRow(String sem, String gpa, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(sem, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          Row(
            children: [
              Text('GPA: $gpa', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(6)),
                child: Text(status, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Tab 5: Internal Marks ─────────────────────
  Widget _buildInternalMarksTab(Map<String, dynamic> s) {
    final List<Map<String, String>> subjects = [
      {'code': 'CS3501', 'name': 'Compiler Design', 't1': '48 / 50', 't2': '46 / 50', 'assign': '10 / 10'},
      {'code': 'CS3502', 'name': 'Computer Networks', 't1': '45 / 50', 't2': '47 / 50', 'assign': '10 / 10'},
      {'code': 'CS3503', 'name': 'Full Stack Web Dev', 't1': '50 / 50', 't2': '49 / 50', 'assign': '10 / 10'},
      {'code': 'CS3504', 'name': 'Artificial Intelligence', 't1': '46 / 50', 't2': '48 / 50', 'assign': '10 / 10'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: subjects.map((sub) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(sub['name']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    Text(sub['code']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMarkPill('Internal Test 1', sub['t1']!),
                    _buildMarkPill('Internal Test 2', sub['t2']!),
                    _buildMarkPill('Assignments', sub['assign']!),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMarkPill(String label, String val) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
        const SizedBox(height: 2),
        Text(val, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
      ],
    );
  }

  // ── Tab 6: Personal & Guardian ────────────────
  Widget _buildPersonalTab(Map<String, dynamic> s) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Full Name', s['name'] ?? 'Aravind Swamy'),
          _buildDetailRow('Register Number', s['regNo'] ?? '917721104012'),
          _buildDetailRow('Email Address', s['email'] ?? 'student@unisphere.edu'),
          _buildDetailRow('Phone Number', s['phone'] ?? '+91 98765 43210'),
          _buildDetailRow('Faculty Advisor', s['advisor'] ?? 'Dr. S. Meenakshi'),
          _buildDetailRow('Residency Type', s['type'] ?? 'Day Scholar'),
          _buildDetailRow('Father / Guardian', 'Ramesh Swamy (+91 94444 12345)'),
          _buildDetailRow('Residential Address', 'No. 45, Anna Nagar 2nd Street, Chennai - 600040'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String val) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
          Flexible(
            child: Text(
              val,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
