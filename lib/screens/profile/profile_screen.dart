import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:unisphere/core/constants/app_colors.dart';
import 'package:unisphere/services/auth_service.dart';
import 'package:unisphere/services/firebase_firestore_service.dart';
import 'package:unisphere/widgets/common/sign_out_confirmation_sheet.dart';
import 'package:unisphere/models/user_model.dart';
import 'package:unisphere/providers/academic_overview_provider.dart';
import 'package:unisphere/screens/features/leetcode_detail_screen.dart';
import 'package:unisphere/screens/features/github_detail_screen.dart';
import 'package:unisphere/core/constants/app_departments.dart';
import 'package:unisphere/widgets/student/student_profile_edit_request_modal.dart';
import 'package:unisphere/widgets/student/student_membership_modal.dart';

import 'package:unisphere/widgets/resume/student_resume_modal_sheet.dart';

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
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).value ?? ref.watch(authServiceProvider).currentUser;
    final name = (currentUser?.name != null && currentUser!.name.trim().isNotEmpty) ? currentUser.name : 'User Profile';
    final email = (currentUser?.email != null && currentUser!.email.trim().isNotEmpty) ? currentUser.email : 'user@unisphere.edu';
    final isDemo = currentUser?.email.toLowerCase().trim() == 'saravanapmvofficial@gmail.com';
    final regNo = currentUser?.metadata?['registerNumber']?.toString().isNotEmpty == true 
        ? currentUser!.metadata!['registerNumber'].toString() 
        : (isDemo ? 'RA2111003010001' : (currentUser?.uid.startsWith('DEMO-') == true ? 'DEMO-REG-001' : 'Pending ID'));
    final dept = currentUser?.metadata?['department']?.toString().isNotEmpty == true 
        ? currentUser!.metadata!['department'].toString() 
        : (isDemo ? 'Computer Science' : 'Not Specified');
    final year = currentUser?.metadata?['year']?.toString().isNotEmpty == true 
        ? currentUser!.metadata!['year'].toString() 
        : (isDemo ? '3rd Year' : '1st Year');
    final roleName = currentUser?.roleName ?? 'Student';
    final photoUrl = (currentUser?.profileImageUrl ?? currentUser?.metadata?['passportPhotoUrl'] ?? currentUser?.metadata?['photoUrl'] ?? '').toString().trim();

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
                          icon: const Icon(Icons.description_rounded, color: Colors.white, size: 22),
                          tooltip: 'Professional Resume',
                          onPressed: () => showStudentResumeModalSheet(context),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showUploadPassportPhotoModal(context, currentUser),
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 2),
                          ),
                          child: _buildProfileHeaderAvatar(photoUrl),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF2563EB),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_rounded, size: 12, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    name,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$year • $dept',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12.5, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$regNo • $email • $roleName',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 11.5),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildHeaderBadge(Icons.circle, 'Active Student', Colors.greenAccent),
                      InkWell(
                        onTap: () => showStudentResumeModalSheet(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.description_rounded, size: 13, color: Colors.white),
                              SizedBox(width: 4),
                              Text('View Resume', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),

                      InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            useRootNavigator: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const StudentProfileEditRequestModal(),
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit_note_rounded, size: 13, color: Colors.white),
                              SizedBox(width: 4),
                              Text('Request Edit', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
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
                Tab(text: 'Certifications Portfolio', icon: Icon(Icons.workspace_premium_rounded, size: 18)),
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
                _buildCertificationsPortfolioTab(),
                _buildDocumentVaultTab(),
                _buildSettingsAndSecurityTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeaderAvatar(String photoUrl) {
    if (photoUrl.isNotEmpty) {
      if (photoUrl.startsWith('http://') || photoUrl.startsWith('https://')) {
        return CircleAvatar(
          radius: 36,
          backgroundImage: NetworkImage(photoUrl),
          backgroundColor: Colors.white24,
        );
      }
      final file = File(photoUrl);
      if (file.existsSync()) {
        return CircleAvatar(
          radius: 36,
          backgroundImage: FileImage(file),
          backgroundColor: Colors.white24,
        );
      }
    }
    return const CircleAvatar(
      radius: 36,
      backgroundColor: Colors.white24,
      child: Icon(Icons.person, size: 44, color: Colors.white),
    );
  }

  void _showUploadPassportPhotoModal(BuildContext context, UserModel? currentUser) {
    final photoController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.add_a_photo_rounded, color: Color(0xFF2563EB)),
            SizedBox(width: 10),
            Text('Passport Photo Upload', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter photo URL or local file path for your official student passport-size photo. It will appear on your Student ID Card & Profile.',
              style: TextStyle(fontSize: 12.5, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: photoController,
              decoration: InputDecoration(
                labelText: 'Passport Photo URL / File Path',
                hintText: 'https://... or /path/to/passport_photo.jpg',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.link_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () async {
              final newUrl = photoController.text.trim();
              if (newUrl.isNotEmpty && currentUser != null) {
                final updatedMeta = Map<String, dynamic>.from(currentUser.metadata ?? {});
                updatedMeta['passportPhotoUrl'] = newUrl;
                updatedMeta['photoUrl'] = newUrl;
                final updatedUser = currentUser.copyWith(
                  profileImageUrl: newUrl,
                  metadata: updatedMeta,
                );
                await ref.read(authServiceProvider).updateUserProfile(updatedUser);
              }
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Passport-size photo updated! Reflected on Digital Student ID Card.'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Save Photo'),
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
    final currentUser = ref.watch(currentUserProvider).value ?? ref.watch(authServiceProvider).currentUser;
    final name = (currentUser?.name != null && currentUser!.name.trim().isNotEmpty) ? currentUser.name : 'User Profile';
    final email = (currentUser?.email != null && currentUser!.email.trim().isNotEmpty) ? currentUser.email : 'user@unisphere.edu';
    final isDemo = currentUser?.email.toLowerCase().trim() == 'saravanapmvofficial@gmail.com';
    final regNo = currentUser?.metadata?['registerNumber']?.toString().isNotEmpty == true 
        ? currentUser!.metadata!['registerNumber'].toString() 
        : (isDemo ? 'RA2111003010001' : (currentUser?.uid.startsWith('DEMO-') == true ? 'DEMO-REG-001' : 'Pending ID'));
    final dept = currentUser?.metadata?['department']?.toString().isNotEmpty == true 
        ? currentUser!.metadata!['department'].toString() 
        : (isDemo ? 'Computer Science' : 'Not Specified');
    final year = currentUser?.metadata?['year']?.toString().isNotEmpty == true 
        ? currentUser!.metadata!['year'].toString() 
        : (isDemo ? '3rd Year' : '1st Year');
    final phone = currentUser?.phoneNumber ?? currentUser?.metadata?['phoneNumber'] ?? (isDemo ? '+91 98765 43210' : 'Not Provided');
    final roleName = currentUser?.roleName ?? 'Student';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildProfileVerificationCard(),

        _buildSectionHeader('👤 Personal Information'),
        _buildCard([
          _buildInfoRow('Full Name', name),
          _buildInfoRow('Account Role', roleName),
          _buildInfoRow('Department / Major', dept),
          _buildInfoRow('Academic Year', year),
          _buildInfoRow('Blood Group', currentUser?.metadata?['bloodGroup'] ?? 'O+', isBadge: true, badgeColor: Colors.red.shade100, badgeTextColor: Colors.red.shade800),
          _buildInfoRow('Nationality', 'Indian'),
          _buildInfoRow('Register / ID No.', regNo),
        ]),

        if (currentUser?.role == UserRole.student) _buildMembershipSectionCard(currentUser),

        const SizedBox(height: 20),
        _buildSectionHeader('📞 Contact Details'),
        _buildCard([
          _buildInfoRow('Institutional Email', email, icon: Icons.email_outlined),
          _buildInfoRow('Primary Phone Number', phone, icon: Icons.phone_android_outlined),
          _buildInfoRow('Permanent Address', 'No. 42, Anna Nagar West, Chennai, Tamil Nadu - 600040', icon: Icons.home_outlined),
          _buildInfoRow('Hostel / Residence', 'Hostel Block B, Room 304 (Hosteller)', icon: Icons.location_city_outlined),
        ]),

        const SizedBox(height: 20),
        _buildSectionHeader('🌐 Professional Profiles & Social Links'),
        Consumer(
          builder: (context, ref, child) {
            final overviewData = ref.watch(academicOverviewProvider);
            final hasLinkedin = overviewData.linkedinUrl.isNotEmpty;
            final hasGithub = overviewData.githubUsername.isNotEmpty;
            final hasLeetcode = overviewData.leetcodeUsername.isNotEmpty;

            return Column(
              children: [
                // LinkedIn Card
                _buildProfessionalLinkCard(
                  title: 'LinkedIn Professional Profile',
                  handle: hasLinkedin ? overviewData.linkedinUrl : 'Submit LinkedIn Profile',
                  subtitle: hasLinkedin ? 'Official Professional Network Profile' : 'Click here to submit your LinkedIn URL to connect',
                  icon: Icons.work_rounded,
                  brandColor: const Color(0xFF0A66C2),
                  onOpenUrl: () async {
                    if (!hasLinkedin) {
                      _showSubmitLinkedInDialog(context, ref);
                      return;
                    }
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
                  handle: hasGithub ? '@${overviewData.githubUsername}' : 'Submit GitHub ID',
                  subtitle: hasGithub
                      ? '${overviewData.githubRepos} Public Repos • ${overviewData.githubCommits} Commits'
                      : 'Click here to submit your GitHub Username to view repositories',
                  icon: Icons.terminal_rounded,
                  brandColor: const Color(0xFF0F172A),
                  onOpenUrl: () async {
                    if (!hasGithub) {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const GitHubDetailScreen()),
                      );
                      return;
                    }
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
                  handle: hasLeetcode ? '@${overviewData.leetcodeUsername}' : 'Submit LeetCode ID',
                  subtitle: hasLeetcode ? '${overviewData.leetcodeSolved} Problems Solved' : 'Click here to submit your LeetCode ID to view solved analytics',
                  icon: Icons.code_rounded,
                  brandColor: const Color(0xFFEA580C),
                  onOpenUrl: () async {
                    if (!hasLeetcode) {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LeetCodeDetailScreen()),
                      );
                      return;
                    }
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
          _buildInfoRow(
            'Primary Contact',
            currentUser?.metadata?['emergencyContactPrimary'] ?? (isDemo ? 'R. Selvam (Father) • +91 98401 23456' : 'Not configured'),
            icon: Icons.emergency_outlined,
          ),
          _buildInfoRow(
            'Secondary Contact',
            currentUser?.metadata?['emergencyContactSecondary'] ?? (isDemo ? 'S. Lakshmi (Mother) • +91 98401 65432' : 'Not configured'),
            icon: Icons.contact_phone_outlined,
          ),
          _buildInfoRow(
            'Medical Conditions',
            currentUser?.metadata?['medicalConditions'] ?? (isDemo ? 'No known allergies / Fit for campus sports' : 'None reported'),
            icon: Icons.health_and_safety_outlined,
          ),
          _buildInfoRow(
            'Campus Health Insurance ID',
            currentUser?.metadata?['healthInsuranceId'] ?? (isDemo ? 'UNI-HLTH-2026-8849' : 'Not issued'),
            icon: Icons.verified_user_outlined,
          ),
        ]),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildMembershipSectionCard(UserModel? currentUser) {
    final meta = currentUser?.metadata ?? {};
    final hasMembership = meta['hasMembership'];
    final org = meta['membershipOrg']?.toString() ?? 'None';
    final memId = meta['membershipId']?.toString() ?? 'N/A';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        _buildSectionHeader('🏅 Technical & Professional Society Membership'),
        _buildCard([
          _buildInfoRow(
            'Has Membership?',
            hasMembership == true ? 'Yes' : (hasMembership == false ? 'No' : 'Unrecorded'),
            isBadge: true,
            badgeColor: hasMembership == true ? Colors.green.shade100 : Colors.amber.shade100,
            badgeTextColor: hasMembership == true ? Colors.green.shade900 : Colors.amber.shade900,
          ),
          _buildInfoRow('Society / Body', org),
          _buildInfoRow('Membership ID', memId),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => StudentMembershipModal.show(context),
                icon: const Icon(Icons.verified_user_outlined, size: 16),
                label: Text(hasMembership != null ? 'Update Membership Details' : 'Record Society Membership'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  side: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ),
        ]),
      ],
    );
  }

  void _showSubmitLinkedInDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.work_rounded, color: Color(0xFF0A66C2)),
              SizedBox(width: 10),
              Text('Submit LinkedIn Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your official LinkedIn profile URL to link your professional network.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'https://www.linkedin.com/in/yourname',
                  prefixIcon: const Icon(Icons.link_rounded, color: Color(0xFF0A66C2)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A66C2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final url = controller.text.trim();
                if (url.isNotEmpty) {
                  ref.read(academicOverviewProvider.notifier).fetchLinkedInStats(url);
                  final currentUser = ref.read(authServiceProvider).currentUser;
                  if (currentUser != null) {
                    final meta = Map<String, dynamic>.from(currentUser.metadata ?? {});
                    meta['linkedinUrl'] = url;
                    final updated = currentUser.copyWith(metadata: meta);
                    await ref.read(authServiceProvider).updateUserProfile(updated);
                  }
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Submit & Link'),
            ),
          ],
        );
      },
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
              icon: Icons.terminal_rounded,
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

  // ================= TAB 4: CERTIFICATIONS PORTFOLIO =================
  Widget _buildCertificationsPortfolioTab() {
    final List<Map<String, dynamic>> nptelCerts = [
      {
        'title': 'Programming in Java',
        'issuer': 'IIT Kharagpur & NPTEL',
        'score': '82%',
        'grade': 'Elite',
        'credentialId': 'NPTEL26CS820',
        'issueDate': 'Aug 2026',
        'status': 'Certified ✓',
        'badgeColor': const Color(0xFFD97706),
        'url': 'https://nptel.ac.in/noc/E-certificate',
      },
      {
        'title': 'NPTEL Elite + Gold: Data Structures & Algorithms',
        'issuer': 'IIT Madras & NPTEL',
        'score': '92% (Top 1% National)',
        'grade': 'Elite + Gold',
        'credentialId': 'NPTEL25CS091',
        'issueDate': 'Oct 2025',
        'status': 'Verified',
        'badgeColor': const Color(0xFFD97706),
        'url': 'https://nptel.ac.in/noc/E-certificate',
      },
      {
        'title': 'NPTEL Elite + Silver: Database Management Systems',
        'issuer': 'IIT Kharagpur & NPTEL',
        'score': '86% (Top 5% National)',
        'grade': 'Elite + Silver',
        'credentialId': 'NPTEL24CS042',
        'issueDate': 'Apr 2025',
        'status': 'Verified',
        'badgeColor': const Color(0xFF475569),
        'url': 'https://nptel.ac.in/noc/E-certificate',
      },
    ];

    final List<Map<String, dynamic>> industryCerts = [
      {
        'title': 'AWS Certified Solutions Architect – Associate',
        'issuer': 'Amazon Web Services (AWS)',
        'level': 'Associate Grade',
        'credentialId': 'AWS-ASA-9920148',
        'issueDate': 'Nov 2025',
        'expiryDate': 'Nov 2028',
        'status': 'Verified',
        'badgeColor': const Color(0xFF2563EB),
        'url': 'https://aws.amazon.com/verification',
      },
      {
        'title': 'Google Cloud Associate Cloud Engineer',
        'issuer': 'Google Cloud Training',
        'level': 'Professional Grade',
        'credentialId': 'GCP-ACE-778102',
        'issueDate': 'Jan 2026',
        'expiryDate': 'Jan 2028',
        'status': 'Verified',
        'badgeColor': const Color(0xFF059669),
        'url': 'https://google.accredible.com/verify',
      },
      {
        'title': 'Meta Front-End Developer Professional Certificate',
        'issuer': 'Coursera & Meta',
        'level': 'Specialization',
        'credentialId': 'META-FED-88419',
        'issueDate': 'Feb 2026',
        'expiryDate': 'Lifetime',
        'status': 'Pending',
        'badgeColor': const Color(0xFF7C3AED),
        'url': 'https://coursera.org/verify/meta-fed',
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Portfolio Summary Header Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.workspace_premium_rounded, color: Color(0xFFF59E0B), size: 24),
                  SizedBox(width: 10),
                  Text(
                    'Student Certifications Portfolio',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Verified records of NPTEL IIT Certifications & Industry Credentials.',
                style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        children: [
                          Text('TOTAL CERTS', style: TextStyle(fontSize: 9.5, color: Colors.white70, fontWeight: FontWeight.bold)),
                          SizedBox(height: 2),
                          Text('5', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD97706).withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
                      ),
                      child: const Column(
                        children: [
                          Text('NPTEL (IIT)', style: TextStyle(fontSize: 9.5, color: Color(0xFFFCD34D), fontWeight: FontWeight.bold)),
                          SizedBox(height: 2),
                          Text('2', style: TextStyle(fontSize: 18, color: Color(0xFFFBBF24), fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF60A5FA).withValues(alpha: 0.4)),
                      ),
                      child: const Column(
                        children: [
                          Text('INDUSTRY', style: TextStyle(fontSize: 9.5, color: Color(0xFF93C5FD), fontWeight: FontWeight.bold)),
                          SizedBox(height: 2),
                          Text('3', style: TextStyle(fontSize: 18, color: Color(0xFF60A5FA), fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ── 1. NPTEL CERTIFICATIONS SECTION ─────────────────────────────
        _buildSectionHeader('🎓 NPTEL Certifications'),
        const SizedBox(height: 8),
        ...nptelCerts.map((cert) {
          final Color color = (cert['badgeColor'] as Color?) ?? const Color(0xFF10B981);
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.workspace_premium_rounded, color: color, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cert['title'] as String,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            cert['issuer'] as String,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: const Text(
                        'Verified',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('SCORE & RANK', style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(cert['score'] as String, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: color)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('CREDENTIAL ID', style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(cert['credentialId'] as String, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('ISSUE DATE', style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(cert['issueDate'] as String, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () async {
                      final uri = Uri.parse(cert['url'] as String);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                    icon: const Icon(Icons.open_in_new_rounded, size: 14),
                    label: const Text('Verify NPTEL Certificate', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFD97706),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 24),

        // ── 2. INDUSTRY CERTIFICATIONS SECTION ───────────────────────────
        _buildSectionHeader('🏢 Industry Certifications'),
        const SizedBox(height: 8),
        ...industryCerts.map((cert) {
          final Color color = (cert['badgeColor'] as Color?) ?? const Color(0xFF10B981);
          final bool isVerified = cert['status'] == 'Verified';
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.verified_user_rounded, color: color, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cert['title'] as String,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            cert['issuer'] as String,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isVerified ? const Color(0xFFECFDF5) : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isVerified ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A)),
                      ),
                      child: Text(
                        cert['status'] as String,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: isVerified ? const Color(0xFF059669) : const Color(0xFFD97706),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('CERT LEVEL', style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(cert['level'] as String, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: color)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('CREDENTIAL ID', style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(cert['credentialId'] as String, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('VALIDITY', style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text('${cert['issueDate']} - ${cert['expiryDate']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () async {
                      final uri = Uri.parse(cert['url'] as String);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                    icon: const Icon(Icons.open_in_new_rounded, size: 14),
                    label: const Text('Verify Vendor Credential', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                    style: TextButton.styleFrom(
                      foregroundColor: color,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 40),
      ],
    );
  }

  // ================= TAB 5: DOCUMENT VAULT =================
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
            onPressed: () => _showDocumentPreviewModal(context, title, subtitle),
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined, color: AppColors.textSecondary, size: 20),
            tooltip: 'Download',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Downloading $title...'), backgroundColor: AppColors.primary),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showDocumentPreviewModal(BuildContext context, String title, String subtitle) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.picture_as_pdf_rounded, size: 44, color: Colors.blue.shade700),
                    const SizedBox(height: 8),
                    Text('OFFICIAL VERIFIED DOCUMENT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue.shade900)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.blue.shade700)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.green.shade700, borderRadius: BorderRadius.circular(12)),
                      child: const Text('SEALED BY REGISTRAR OFFICE ✓', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Downloading official $title PDF...'), backgroundColor: AppColors.primary),
                  );
                },
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('Download Official PDF Document'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
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
          onPressed: () => showSignOutConfirmationSheet(context, ref),
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

  Widget _buildProfileVerificationCard() {
    final user = ref.watch(authServiceProvider).currentUser;
    if (user == null) return const SizedBox.shrink();

    final meta = user.metadata ?? {};
    final status = meta['verificationStatus'] ?? 'incomplete';

    if (status == 'verified') {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFD1FAE5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF10B981)),
        ),
        child: Row(
          children: [
            const Icon(Icons.verified_rounded, color: Color(0xFF047857), size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🟢 Verified Academic Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF047857))),
                  Text('Approved by ${meta['verifiedBy'] ?? "Dr. R. Kumar (HOD, CSE)"}', style: const TextStyle(fontSize: 12, color: Color(0xFF065F46))),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (status == 'pending') {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF59E0B)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.hourglass_top_rounded, color: Color(0xFFB45309), size: 26),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '🟡 Verification Pending by HOD',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF92400E)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Your profile details (ID: ${meta['registerNumber'] ?? "RA2111003010001"}, Dept: ${meta['department'] ?? "CSE"}, Sec: ${meta['section'] ?? "A"}) were submitted to Dr. R. Kumar (HOD) for review.',
              style: const TextStyle(fontSize: 12, color: Color(0xFF78350F), height: 1.4),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () async {
                final updatedMeta = Map<String, dynamic>.from(meta);
                updatedMeta['verificationStatus'] = 'incomplete';
                final updated = user.copyWith(metadata: updatedMeta);
                await ref.read(authServiceProvider).updateUserProfile(updated);
              },
              icon: const Icon(Icons.edit_note_rounded, size: 16),
              label: const Text('Edit Submitted Details'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD97706),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                minimumSize: const Size(0, 36),
              ),
            ),
          ],
        ),
      );
    }

    // Status: Incomplete - Render Form
    return _ProfileFormWidget(user: user);
  }
}

class _ProfileFormWidget extends ConsumerStatefulWidget {
  final UserModel user;

  const _ProfileFormWidget({required this.user});

  @override
  ConsumerState<_ProfileFormWidget> createState() => _ProfileFormWidgetState();
}

class _ProfileFormWidgetState extends ConsumerState<_ProfileFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _regNoController;
  late final TextEditingController _phoneController;
  late final TextEditingController _sectionController;
  late final TextEditingController _leetcodeController;
  late final TextEditingController _githubController;
  late final TextEditingController _emergencyPrimaryController;
  late final TextEditingController _emergencySecondaryController;
  late final TextEditingController _cgpaController;
  late final TextEditingController _attendanceController;
  late String _selectedDept;
  String _selectedSemester = 'Semester 6 (3rd Year)';
  bool _isSubmitting = false;

  final List<String> _semesters = [
    'Semester 1 (1st Year)',
    'Semester 2 (1st Year)',
    'Semester 3 (2nd Year)',
    'Semester 4 (2nd Year)',
    'Semester 5 (3rd Year)',
    'Semester 6 (3rd Year)',
    'Semester 7 (4th Year)',
    'Semester 8 (4th Year)',
  ];

  @override
  void initState() {
    super.initState();
    final meta = widget.user.metadata ?? {};
    final isDemo = widget.user.email.toLowerCase().trim() == 'saravanapmvofficial@gmail.com';
    _regNoController = TextEditingController(text: meta['registerNumber'] ?? (isDemo ? 'RA2111003010001' : ''));
    _phoneController = TextEditingController(text: widget.user.phoneNumber ?? (isDemo ? '+91 98765 43210' : ''));
    _sectionController = TextEditingController(text: meta['section'] ?? (isDemo ? 'Sec A' : ''));
    _leetcodeController = TextEditingController(text: meta['leetcodeUsername'] ?? '');
    _githubController = TextEditingController(text: meta['githubUsername'] ?? '');
    _emergencyPrimaryController = TextEditingController(text: meta['emergencyContactPrimary'] ?? '');
    _emergencySecondaryController = TextEditingController(text: meta['emergencyContactSecondary'] ?? '');
    _cgpaController = TextEditingController(text: meta['cgpa']?.toString() ?? (isDemo ? '8.72' : ''));
    _attendanceController = TextEditingController(text: meta['attendance']?.toString() ?? (isDemo ? '85.0' : ''));

    final deptVal = meta['department']?.toString() ?? '';
    _selectedDept = AppDepartments.list.firstWhere(
      (d) => d.toLowerCase() == deptVal.toLowerCase() || d.toLowerCase().contains(deptVal.toLowerCase()),
      orElse: () => AppDepartments.list.firstWhere(
        (d) => d.contains('Computer Science'),
        orElse: () => AppDepartments.list.first,
      ),
    );
  }

  @override
  void dispose() {
    _regNoController.dispose();
    _phoneController.dispose();
    _sectionController.dispose();
    _leetcodeController.dispose();
    _githubController.dispose();
    _emergencyPrimaryController.dispose();
    _emergencySecondaryController.dispose();
    _cgpaController.dispose();
    _attendanceController.dispose();
    super.dispose();
  }

  Future<void> _submitToHod() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final regNo = _regNoController.text.trim();
      final isTaken = await ref.read(firebaseFirestoreServiceProvider).isRegisterNumberTaken(regNo, widget.user.uid);
      if (isTaken) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('⚠️ Register ID "$regNo" is already taken by another student! Please check your unique student ID.'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        setState(() => _isSubmitting = false);
        return;
      }

      final updatedMeta = Map<String, dynamic>.from(widget.user.metadata ?? {});
      updatedMeta['registerNumber'] = regNo;
      updatedMeta['department'] = _selectedDept;
      updatedMeta['section'] = _sectionController.text.trim();
      updatedMeta['semester'] = _selectedSemester;
      if (_leetcodeController.text.trim().isNotEmpty) {
        updatedMeta['leetcodeUsername'] = _leetcodeController.text.trim();
      }
      if (_githubController.text.trim().isNotEmpty) {
        updatedMeta['githubUsername'] = _githubController.text.trim();
      }
      if (_emergencyPrimaryController.text.trim().isNotEmpty) {
        updatedMeta['emergencyContactPrimary'] = _emergencyPrimaryController.text.trim();
      }
      if (_emergencySecondaryController.text.trim().isNotEmpty) {
        updatedMeta['emergencyContactSecondary'] = _emergencySecondaryController.text.trim();
      }
      if (_cgpaController.text.trim().isNotEmpty) {
        final double? c = double.tryParse(_cgpaController.text.trim());
        if (c != null) updatedMeta['cgpa'] = c;
      }
      if (_attendanceController.text.trim().isNotEmpty) {
        final double? a = double.tryParse(_attendanceController.text.trim());
        if (a != null) updatedMeta['attendance'] = a;
      }
      updatedMeta['verificationStatus'] = 'pending';
      updatedMeta['submittedAt'] = DateTime.now().toIso8601String();

      final updatedUser = widget.user.copyWith(
        phoneNumber: _phoneController.text.trim(),
        metadata: updatedMeta,
      );

      await ref.read(authServiceProvider).updateUserProfile(updatedUser);

      // Trigger academic overview update
      ref.read(academicOverviewProvider.notifier).updateData(
        cgpa: double.tryParse(_cgpaController.text.trim()),
        attendancePercentage: double.tryParse(_attendanceController.text.trim()),
      );
      if (_leetcodeController.text.trim().isNotEmpty) {
        ref.read(academicOverviewProvider.notifier).fetchLeetCodeStats(_leetcodeController.text.trim());
      }
      if (_githubController.text.trim().isNotEmpty) {
        ref.read(academicOverviewProvider.notifier).fetchGitHubStats(_githubController.text.trim());
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Profile submitted to database & HOD for verification!'),
            backgroundColor: Color(0xFFD97706),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission notice: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.assignment_ind_rounded, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Complete Profile & Submit to HOD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                      Text('Fill in your academic information to submit for official HOD verification.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            const Text('Register / Student ID Number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _regNoController,
              decoration: InputDecoration(
                hintText: 'e.g. RA2111003010001',
                prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.primary, size: 18),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'Register ID is required' : null,
            ),
            const SizedBox(height: 14),

            const Text('Academic Department', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedDept,
              isExpanded: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.account_balance_outlined, color: AppColors.primary, size: 18),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: AppDepartments.list.map((dept) {
                return DropdownMenuItem<String>(
                  value: dept,
                  child: Text(dept, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedDept = val);
              },
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Section / Group', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _sectionController,
                        decoration: InputDecoration(
                          hintText: 'Sec A',
                          prefixIcon: const Icon(Icons.groups_outlined, color: AppColors.primary, size: 18),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Current Semester', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedSemester,
                        isExpanded: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                        ),
                        items: _semesters.map((sem) {
                          return DropdownMenuItem<String>(
                            value: sem,
                            child: Text(sem, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedSemester = val);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            const Text('Contact Phone Number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: '+91 98765 43210',
                prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.primary, size: 18),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Current CGPA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _cgpaController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: 'e.g. 8.75',
                          prefixIcon: const Icon(Icons.grade_outlined, color: AppColors.primary, size: 18),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Attendance (%)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _attendanceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: 'e.g. 88.5',
                          prefixIcon: const Icon(Icons.percent_rounded, color: Color(0xFF059669), size: 18),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('LeetCode Handle', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _leetcodeController,
                        decoration: InputDecoration(
                          hintText: 'e.g. johndoe',
                          prefixIcon: const Icon(Icons.code_rounded, color: Color(0xFFEA580C), size: 18),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('GitHub Username', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _githubController,
                        decoration: InputDecoration(
                          hintText: 'e.g. johndoe-dev',
                          prefixIcon: const Icon(Icons.terminal_rounded, color: Color(0xFF0F172A), size: 18),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            const Text('Emergency Contact (Name & Phone)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _emergencyPrimaryController,
              decoration: InputDecoration(
                hintText: 'e.g. Parent Name • +91 98765 43210',
                prefixIcon: const Icon(Icons.emergency_outlined, color: Colors.redAccent, size: 18),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitToHod,
                icon: _isSubmitting
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send_rounded, size: 18),
                label: Text(_isSubmitting ? 'Submitting to HOD...' : 'Submit to HOD for Verification'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
