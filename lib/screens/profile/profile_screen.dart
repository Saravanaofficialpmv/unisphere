import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:unisphere/core/constants/app_colors.dart';
import 'package:unisphere/services/auth_service.dart';
import 'package:unisphere/providers/academic_overview_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;

  const ProfileScreen({super.key, this.onBack});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Notification states
  bool _announcementNotifs = true;
  bool _gradeNotifs = true;
  bool _attendanceNotifs = true;
  bool _feeNotifs = true;
  bool _biometricEnabled = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Fixed Stable Profile Header (Does NOT move or collapse on scroll)
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primary, Color(0xFF1E3A8A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        if (widget.onBack != null)
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                            onPressed: widget.onBack,
                          ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 24),
                          tooltip: 'Digital ID Card',
                          onPressed: () => _showDigitalIdModal(context),
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 2),
                        ),
                        child: const CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.person, size: 44, color: Colors.white),
                        ),
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, size: 10, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Saravana Kumar',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '7377221CS101 • B.E. Computer Science',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12.5, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '3rd Year / Semester VI • Batch 2022–2026',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 11.5),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildHeaderBadge(Icons.circle, 'Active Student', Colors.greenAccent),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _showDigitalIdModal(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.badge_outlined, size: 13, color: Colors.white),
                              SizedBox(width: 4),
                              Text('Digital ID', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Stable TabBar
          Container(
            color: Colors.white,
            width: double.infinity,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
              tabs: const [
                Tab(text: 'Personal & Contact', icon: Icon(Icons.person_outline, size: 18)),
                Tab(text: 'Connected Profiles', icon: Icon(Icons.link_rounded, size: 18)),
                Tab(text: 'Academics & Parents', icon: Icon(Icons.school_outlined, size: 18)),
                Tab(text: 'Document Vault', icon: Icon(Icons.folder_shared_outlined, size: 18)),
                Tab(text: 'Settings & Security', icon: Icon(Icons.settings_outlined, size: 18)),
              ],
            ),
          ),

          // Tab Content View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPersonalAndContactTab(),
                _buildConnectedProfilesTab(),
                _buildAcademicsAndParentsTab(),
                _buildDocumentVaultTab(),
                _buildSettingsAndSecurityTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 8, color: color),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ================= TAB 1: PERSONAL & CONTACT =================
  Widget _buildPersonalAndContactTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('👤 Personal Information'),
        _buildCard([
          _buildInfoRow('Full Name', 'Saravana Kumar'),
          _buildInfoRow('Date of Birth & Age', '14 Aug 2004 (21 Yrs)'),
          _buildInfoRow('Gender', 'Male'),
          _buildInfoRow('Blood Group', 'O+', isBadge: true, badgeColor: Colors.red.shade100, badgeTextColor: Colors.red.shade800),
          _buildInfoRow('Nationality', 'Indian'),
          _buildInfoRow('Category / Quota', 'General • Government Quota'),
          _buildInfoRow('Government ID', 'Aadhar (XXXX-XXXX-4821)'),
        ]),

        const SizedBox(height: 20),
        _buildSectionHeader('📞 Contact Details'),
        _buildCard([
          _buildInfoRow('Institutional Email', 'saravana.cs22@unisphere.edu', icon: Icons.email_outlined),
          _buildInfoRow('Personal Email', 'saravana.official@gmail.com', icon: Icons.alternate_email),
          _buildInfoRow('Primary Phone Number', '+91 98765 43210', icon: Icons.phone_android_outlined),
          _buildInfoRow('Permanent Address', 'No. 42, Anna Nagar West, Chennai, Tamil Nadu - 600040', icon: Icons.home_outlined),
          _buildInfoRow('Hostel / Residence', 'Hostel Block B, Room 304 (Hosteller)', icon: Icons.location_city_outlined),
        ]),

        const SizedBox(height: 20),
        _buildSectionHeader('🌐 Professional Profiles & Social Links'),
        Consumer(
          builder: (context, ref, child) {
            final overviewData = ref.watch(academicOverviewProvider);
            return Column(
              children: [
                // LinkedIn Card
                _buildProfessionalLinkCard(
                  title: 'LinkedIn Professional Profile',
                  handle: overviewData.linkedinUrl,
                  subtitle: 'Official Professional Network Profile',
                  icon: Icons.work_rounded,
                  brandColor: const Color(0xFF0A66C2),
                  onOpenUrl: () async {
                    final uri = Uri.parse(overviewData.linkedinUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
                const SizedBox(height: 10),
                // GitHub Card
                _buildProfessionalLinkCard(
                  title: 'GitHub Developer Profile',
                  handle: '@${overviewData.githubUsername}',
                  subtitle: '${overviewData.githubRepos} Public Repos • ${overviewData.githubCommits} Commits',
                  icon: Icons.integration_instructions_rounded,
                  brandColor: const Color(0xFF0F172A),
                  onOpenUrl: () async {
                    final uri = Uri.parse('https://github.com/${overviewData.githubUsername}');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
                const SizedBox(height: 10),
                // LeetCode Card
                _buildProfessionalLinkCard(
                  title: 'LeetCode DSA Profile',
                  handle: '@${overviewData.leetcodeUsername}',
                  subtitle: '${overviewData.leetcodeSolved} Problems Solved',
                  icon: Icons.code_rounded,
                  brandColor: const Color(0xFFEA580C),
                  onOpenUrl: () async {
                    final uri = Uri.parse('https://leetcode.com/u/${overviewData.leetcodeUsername}');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 20),
        _buildSectionHeader('🚨 Medical & Emergency Contacts'),
        _buildCard([
          _buildInfoRow('Primary Contact', 'R. Selvam (Father) • +91 98401 23456', icon: Icons.emergency_outlined),
          _buildInfoRow('Secondary Contact', 'S. Lakshmi (Mother) • +91 98401 65432', icon: Icons.contact_phone_outlined),
          _buildInfoRow('Medical Conditions', 'No known allergies / Fit for campus sports', icon: Icons.health_and_safety_outlined),
          _buildInfoRow('Campus Health Insurance ID', 'UNI-HLTH-2026-8849', icon: Icons.verified_user_outlined),
        ]),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildProfessionalLinkCard({
    required String title,
    required String handle,
    required String subtitle,
    required IconData icon,
    required Color brandColor,
    required VoidCallback onOpenUrl,
  }) {
    return InkWell(
      onTap: onOpenUrl,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: brandColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: brandColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  Text(
                    handle,
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: brandColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: onOpenUrl,
              icon: const Icon(Icons.open_in_new_rounded, size: 13),
              label: const Text('Visit Profile', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: brandColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= TAB 2: CONNECTED PROFILES & ACCOUNTS =================
  Widget _buildConnectedProfilesTab() {
    return Consumer(
      builder: (context, ref, child) {
        final overviewData = ref.watch(academicOverviewProvider);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Status Header Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.hub_rounded, color: Color(0xFF38BDF8), size: 26),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Linked Professional & Dev Accounts',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'UNISPHERE automatically syncs your GitHub activity, LeetCode DSA progress, and LinkedIn network.',
                          style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), height: 1.35),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            _buildSectionHeader('🔗 Verified Developer & Professional Networks'),

            // 1. LinkedIn
            _buildConnectedAccountCard(
              platformName: 'LinkedIn Professional Profile',
              handle: overviewData.linkedinUrl,
              subtitle: 'Official Professional Network Profile',
              statusBadge: 'Verified ✅',
              statusColor: const Color(0xFF0A66C2),
              icon: Icons.work_rounded,
              onVisit: () async {
                final uri = Uri.parse(overviewData.linkedinUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
            const SizedBox(height: 12),

            // 2. GitHub
            _buildConnectedAccountCard(
              platformName: 'GitHub Developer Account',
              handle: '@${overviewData.githubUsername}',
              subtitle: '${overviewData.githubRepos} Public Repositories • ${overviewData.githubCommits} Commits in 2026',
              statusBadge: 'Auto-Syncing ⚡',
              statusColor: const Color(0xFF059669),
              icon: Icons.integration_instructions_rounded,
              onVisit: () async {
                final uri = Uri.parse('https://github.com/${overviewData.githubUsername}');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
            const SizedBox(height: 12),

            // 3. LeetCode
            _buildConnectedAccountCard(
              platformName: 'LeetCode DSA Platform',
              handle: '@${overviewData.leetcodeUsername}',
              subtitle: '${overviewData.leetcodeSolved} Solved Problems (104 Easy, 24 Medium, 2 Hard)',
              statusBadge: 'Daily 12 AM ⏰',
              statusColor: const Color(0xFFEA580C),
              icon: Icons.code_rounded,
              onVisit: () async {
                final uri = Uri.parse('https://leetcode.com/u/${overviewData.leetcodeUsername}');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
            const SizedBox(height: 12),

            // 4. Personal Portfolio
            _buildConnectedAccountCard(
              platformName: 'Personal Portfolio Web',
              handle: 'https://saroo.online',
              subtitle: 'Live Showcase & Independent Web Domain',
              statusBadge: 'Live Site 🌐',
              statusColor: const Color(0xFF2563EB),
              icon: Icons.language_rounded,
              onVisit: () async {
                final uri = Uri.parse('https://saroo.online');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
            const SizedBox(height: 40),
          ],
        );
      },
    );
  }

  Widget _buildConnectedAccountCard({
    required String platformName,
    required String handle,
    required String subtitle,
    required String statusBadge,
    required Color statusColor,
    required IconData icon,
    required VoidCallback onVisit,
    bool isStatic = false,
  }) {
    return InkWell(
      onTap: onVisit,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: statusColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              platformName,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              statusBadge,
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        handle,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), height: 1.3),
            ),
            if (!isStatic) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onVisit,
                  icon: const Icon(Icons.open_in_new_rounded, size: 15),
                  label: const Text('Visit Profile', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: statusColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }



  // ================= TAB 3: ACADEMICS & PARENTS =================
  Widget _buildAcademicsAndParentsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('🎓 Academic Details'),
        _buildCard([
          _buildInfoRow('Program & Branch', 'B.E. Computer Science and Engineering'),
          _buildInfoRow('Section & Batch', 'Section A • Batch 1 (2022–2026)'),
          _buildInfoRow('Current Semester', 'Semester VI (3rd Year)'),
          _buildInfoRow('Cumulative GPA (CGPA)', '8.84 / 10.0', isBadge: true, badgeColor: Colors.green.shade100, badgeTextColor: Colors.green.shade800),
          _buildInfoRow('Earned Credits', '112 / 160 Credits'),
          _buildInfoRow('Admission Type', 'Single Window Counseling (Anna Univ)'),
          _buildInfoRow('Date of Joining', '18 August 2022'),
        ]),

        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person_search_rounded, color: Colors.white),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Faculty Advisor / Mentor', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    Text('Dr. R. Ananth (Professor - CSE)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    Text('ananth.r@unisphere.edu', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening message composer with Dr. R. Ananth...')),
                  );
                },
                icon: const Icon(Icons.mail_outline, size: 14),
                label: const Text('Contact', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        _buildSectionHeader('👨‍👩‍👧 Parent & Guardian Details'),
        _buildCard([
          _buildInfoRow('Father\'s Name', 'R. Selvam'),
          _buildInfoRow('Father\'s Occupation', 'Senior Software Manager'),
          _buildInfoRow('Father\'s Mobile', '+91 98401 23456'),
          _buildInfoRow('Mother\'s Name', 'S. Lakshmi'),
          _buildInfoRow('Mother\'s Occupation', 'High School Teacher'),
          _buildInfoRow('Mother\'s Mobile', '+91 98401 65432'),
          _buildInfoRow('Local Guardian', 'K. Ramanathan (Uncle) • Chennai'),
          _buildInfoRow(
            'Parent Portal Sync Status',
            'Synced ✅ (Active Parent Account)',
            isBadge: true,
            badgeColor: Colors.blue.shade100,
            badgeTextColor: Colors.blue.shade900,
          ),
        ]),
        const SizedBox(height: 40),
      ],
    );
  }

  // ================= TAB 3: DOCUMENT VAULT =================
  Widget _buildDocumentVaultTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.verified_user_rounded, color: Colors.green.shade700, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Identity & Records Verified', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade900, fontSize: 14)),
                    Text('All mandatory academic records verified on 12 Sep 2022 by Registrar Office.', style: TextStyle(color: Colors.green.shade800, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        _buildSectionHeader('📄 Official Document Vault'),

        _buildDocumentTile('10th Standard Marksheet', 'PDF • 1.2 MB • Verified', Icons.picture_as_pdf_outlined),
        _buildDocumentTile('12th Standard Higher Secondary Marksheet', 'PDF • 1.4 MB • Verified', Icons.picture_as_pdf_outlined),
        _buildDocumentTile('Transfer Certificate (TC) & Conduct Certificate', 'PDF • 850 KB • Verified', Icons.picture_as_pdf_outlined),
        _buildDocumentTile('First Graduate / Scholarship Eligibility Doc', 'PDF • 620 KB • Approved', Icons.verified_outlined),
        _buildDocumentTile('Government Aadhar ID Copy', 'PDF • 410 KB • Verified', Icons.badge_outlined),
        _buildDocumentTile('Campus Medical Fitness Certificate', 'PDF • 530 KB • Verified', Icons.health_and_safety_outlined),

        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Document upload request portal opened.')),
            );
          },
          icon: const Icon(Icons.cloud_upload_outlined, size: 18),
          label: const Text('Upload / Request Updated Document'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildDocumentTile(String title, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_red_eye_outlined, color: AppColors.primary, size: 20),
            tooltip: 'View Document',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Viewing $title')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined, color: AppColors.textSecondary, size: 20),
            tooltip: 'Download',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Downloading $title...')),
              );
            },
          ),
        ],
      ),
    );
  }

  // ================= TAB 4: SETTINGS & SECURITY =================
  Widget _buildSettingsAndSecurityTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('⚙️ Account Management'),
        _buildSettingsTile(
          icon: Icons.edit_note_outlined,
          title: 'Request Profile Information Update',
          subtitle: 'Update phone number, address, or photo with admin approval',
          onTap: () => _showEditProfileRequestDialog(),
        ),

        const SizedBox(height: 16),
        _buildSectionHeader('🔒 Security & Authentication'),
        _buildSettingsTile(
          icon: Icons.lock_outline,
          title: 'Change Password',
          subtitle: 'Update your account login password',
          onTap: () => _showChangePasswordDialog(),
        ),
        _buildSwitchTile(
          icon: Icons.fingerprint_rounded,
          title: 'Biometric Login / 2FA',
          subtitle: 'Use FaceID or Fingerprint to unlock portal',
          value: _biometricEnabled,
          onChanged: (val) => setState(() => _biometricEnabled = val),
        ),

        const SizedBox(height: 16),
        _buildSectionHeader('🔔 Notification Preferences'),
        _buildSwitchTile(
          icon: Icons.campaign_outlined,
          title: 'Academic Announcements',
          subtitle: 'Receive instant push alerts for department notices',
          value: _announcementNotifs,
          onChanged: (val) => setState(() => _announcementNotifs = val),
        ),
        _buildSwitchTile(
          icon: Icons.grade_outlined,
          title: 'Grade & Mark Release Alerts',
          subtitle: 'Notify when internal or semester grades are published',
          value: _gradeNotifs,
          onChanged: (val) => setState(() => _gradeNotifs = val),
        ),
        _buildSwitchTile(
          icon: Icons.event_available_outlined,
          title: 'Daily Attendance Warning',
          subtitle: 'Alerts when subject attendance falls below 75%',
          value: _attendanceNotifs,
          onChanged: (val) => setState(() => _attendanceNotifs = val),
        ),
        _buildSwitchTile(
          icon: Icons.receipt_long_outlined,
          title: 'Fee Payment Reminders',
          subtitle: 'Reminders for due tuition or exam fees',
          value: _feeNotifs,
          onChanged: (val) => setState(() => _feeNotifs = val),
        ),

        const SizedBox(height: 16),
        _buildSectionHeader('ℹ️ Legal & Support'),
        _buildSettingsTile(
          icon: Icons.help_outline,
          title: 'Campus IT HelpDesk & Support',
          subtitle: 'Submit a ticket for technical issues or queries',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening Support Portal...')));
          },
        ),
        _buildSettingsTile(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy & Student Data Terms',
          subtitle: 'Read Unisphere privacy policy',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening Privacy Policy...')));
          },
        ),

        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => ref.read(authServiceProvider).signOut(),
          icon: const Icon(Icons.logout_rounded, size: 18),
          label: const Text('Log Out of Account', style: TextStyle(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade50,
            foregroundColor: AppColors.error,
            elevation: 0,
            side: const BorderSide(color: AppColors.error, width: 1),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: SwitchListTile(
        secondary: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        value: value,
        activeThumbColor: AppColors.primary,
        onChanged: onChanged,
      ),
    );
  }

  // ================= DIGITAL ID MODAL =================
  void _showDigitalIdModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 340,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.school_rounded, color: AppColors.primary, size: 22),
                      SizedBox(width: 8),
                      Text('UNISPHERE UNIVERSITY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person, size: 45, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    const Text('SARAVANA KUMAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const Text('REG NO: 7377221CS101', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    const Text('B.E. COMPUTER SCIENCE & ENGG', style: TextStyle(color: Colors.white, fontSize: 11)),
                    const Text('BATCH: 2022–2026 • BLOOD: O+', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // QR Code Graphic Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.qr_code_2_rounded, size: 110, color: AppColors.primaryDark),
                    const SizedBox(height: 6),
                    const Text('Campus Entry & Library Scan', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text('Valid Until: 30 JUNE 2026', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green.shade800)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phone_in_talk_outlined, size: 14, color: Colors.red.shade700),
                  const SizedBox(width: 4),
                  Text('Emergency Hotline: +91 44 2250 0100', style: TextStyle(fontSize: 11, color: Colors.red.shade700, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= EDIT PROFILE REQUEST DIALOG =================
  void _showEditProfileRequestDialog() {
    final phoneController = TextEditingController(text: '+91 98765 43210');
    final addressController = TextEditingController(text: 'Hostel Block B, Room 304');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.edit_note_outlined, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Request Profile Update', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Changes to official details require admin approval from the Registrar Office.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Updated Mobile Number',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addressController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Updated Communication Address',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Update request submitted to Registrar office successfully!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Submit Request'),
          ),
        ],
      ),
    );
  }

  // ================= CHANGE PASSWORD DIALOG =================
  void _showChangePasswordDialog() {
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Change Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPassController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPassController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password changed successfully!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Update Password'),
          ),
        ],
      ),
    );
  }

  // ================= HELPER WIDGETS =================
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    IconData? icon,
    bool isBadge = false,
    Color? badgeColor,
    Color? badgeTextColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 10),
          ],
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 5,
            child: isBadge
                ? Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeColor ?? AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        value,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: badgeTextColor ?? AppColors.primary,
                        ),
                      ),
                    ),
                  )
                : Text(
                    value,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
          ),
        ],
      ),
    );
  }

}
