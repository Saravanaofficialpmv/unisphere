import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:unisphere/providers/academic_overview_provider.dart';
import 'package:unisphere/services/linkedin_service.dart';
import 'package:unisphere/widgets/common/unisphere_header_card.dart';

class LinkedInDetailScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;

  const LinkedInDetailScreen({
    super.key,
    this.onBack,
  });

  @override
  ConsumerState<LinkedInDetailScreen> createState() => _LinkedInDetailScreenState();
}

class _LinkedInDetailScreenState extends ConsumerState<LinkedInDetailScreen> {
  bool _isRefreshing = false;
  late TextEditingController _urlController;
  LinkedInProfileStats _profileStats = const LinkedInProfileStats(
    username: 'Saravanaofficialpmv',
    profileUrl: 'https://linkedin.com/in/Saravanaofficialpmv',
  );

  @override
  void initState() {
    super.initState();
    final overviewData = ref.read(academicOverviewProvider);
    _urlController = TextEditingController(text: overviewData.linkedinUrl);
    _loadProfileStats(overviewData.linkedinUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileStats(String urlOrHandle) async {
    setState(() {
      _isRefreshing = true;
    });
    final stats = await LinkedInService.fetchProfileStats(urlOrHandle);
    if (mounted) {
      setState(() {
        _profileStats = stats;
        _isRefreshing = false;
      });
      ref.read(academicOverviewProvider.notifier).updateData(
        linkedinUrl: stats.profileUrl,
        linkedinConnections: stats.connectionsCount,
        linkedinHeadline: stats.headline,
      );
    }
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _launchURL(String urlString) async {
    final Uri uri = Uri.parse(urlString);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not launch $urlString')),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open URL: $urlString')),
        );
      }
    }
  }

  void _showUpdateUrlDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Row(
            children: [
              Icon(Icons.work_rounded, color: Color(0xFF0A66C2)),
              SizedBox(width: 8),
              Text('Update LinkedIn Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your public LinkedIn profile URL or username (e.g. https://linkedin.com/in/Saravanaofficialpmv).',
                style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: 'LinkedIn URL or Handle',
                  hintText: 'https://linkedin.com/in/Saravanaofficialpmv',
                  prefixIcon: const Icon(Icons.link_rounded, color: Color(0xFF0A66C2)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
              onPressed: () {
                final newUrl = _urlController.text.trim();
                if (newUrl.isNotEmpty) {
                  Navigator.pop(context);
                  _loadProfileStats(newUrl);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A66C2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Save & Sync'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Column(
              children: [
                // Header Card
                UnisphereHeaderCard(
                  title: 'LinkedIn Professional Profile',
                  subtitle: '@${_profileStats.username} • Professional Network',
                  onBack: _handleBack,
                  gradientColors: const [Color(0xFF0A66C2), Color(0xFF004182)],
                ),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => _loadProfileStats(_profileStats.profileUrl),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Profile Banner Header
                          _buildProfileHeaderCard(),

                          const SizedBox(height: 16),

                          // 2. Metrics 4-Grid
                          _buildMetricsGrid(),

                          const SizedBox(height: 20),

                          // 3. About Section
                          _buildAboutSection(),

                          const SizedBox(height: 20),

                          // 4. Featured Top Skills
                          _buildTopSkillsSection(),

                          const SizedBox(height: 20),

                          // 5. Experience & Academic Projects
                          _buildExperienceSection(),

                          const SizedBox(height: 20),

                          // 6. Certifications & Badges
                          _buildCertificationsSection(),
                        ],
                      ),
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

  Widget _buildProfileHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A66C2), Color(0xFF004182)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A66C2).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Circle Avatar
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 34),
              ),
              const SizedBox(width: 14),

              // Name & Location
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _profileStats.name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.verified_rounded, size: 16, color: Color(0xFF38BDF8)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 12, color: Color(0xFF93C5FD)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _profileStats.location,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFFBFDBFE),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Edit URL Button
              IconButton(
                onPressed: _showUpdateUrlDialog,
                icon: const Icon(Icons.edit_note_rounded, color: Colors.white70),
                tooltip: 'Edit LinkedIn Profile URL',
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Headline
          Text(
            _profileStats.headline,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),

          const SizedBox(height: 14),

          // Action Buttons: Launch LinkedIn & Edit
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _launchURL(_profileStats.profileUrl),
                  icon: const Icon(Icons.open_in_new_rounded, size: 15),
                  label: const Text('Open LinkedIn Profile', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0A66C2),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: _isRefreshing ? null : () => _loadProfileStats(_profileStats.profileUrl),
                icon: _isRefreshing
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.sync_rounded, size: 16, color: Colors.white),
                label: Text(_isRefreshing ? 'Syncing...' : 'Sync', style: const TextStyle(fontSize: 12.5, color: Colors.white)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Connections',
                value: _profileStats.connectionsCount,
                subtitle: 'Professional Network',
                icon: Icons.people_alt_rounded,
                accentColor: const Color(0xFF0A66C2),
                bgGradient: const [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Profile Views',
                value: '${_profileStats.profileViews}',
                subtitle: 'Past 90 Days',
                icon: Icons.remove_red_eye_rounded,
                accentColor: const Color(0xFF0D9488),
                bgGradient: const [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Post Impressions',
                value: '${_profileStats.postImpressions}',
                subtitle: 'Content Reach',
                icon: Icons.show_chart_rounded,
                accentColor: const Color(0xFF7C3AED),
                bgGradient: const [Color(0xFFF5F3FF), Color(0xFFEDE9FE)],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Search Appearances',
                value: '${_profileStats.searchAppearances}',
                subtitle: 'Recruiter Searches',
                icon: Icons.search_rounded,
                accentColor: const Color(0xFFD97706),
                bgGradient: const [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required List<Color> bgGradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: bgGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.12),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: accentColor.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 9.5,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
              Icon(Icons.notes_rounded, color: Color(0xFF0A66C2), size: 18),
              SizedBox(width: 8),
              Text(
                'About / Summary',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _profileStats.about,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF475569),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSkillsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
              Icon(Icons.workspace_premium_rounded, color: Color(0xFF0A66C2), size: 18),
              SizedBox(width: 8),
              Text(
                'Top Skills & Endorsements',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _profileStats.topSkills.map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF0A66C2)),
                    const SizedBox(width: 6),
                    Text(
                      skill,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
              Icon(Icons.business_center_rounded, color: Color(0xFF0A66C2), size: 18),
              SizedBox(width: 8),
              Text(
                'Experience & Project Roles',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _profileStats.experiences.length,
            separatorBuilder: (context, index) => const Divider(height: 20, color: Color(0xFFF1F5F9)),
            itemBuilder: (context, index) {
              final exp = _profileStats.experiences[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.domain_rounded, color: Color(0xFF0A66C2), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exp.title,
                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${exp.company} • ${exp.period}',
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF2563EB), fontWeight: FontWeight.w600),
                        ),
                        Text(
                          exp.location,
                          style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          exp.description,
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569), height: 1.35),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCertificationsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
              Icon(Icons.card_membership_rounded, color: Color(0xFF0A66C2), size: 18),
              SizedBox(width: 8),
              Text(
                'Certifications & Licenses',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: _profileStats.certifications.map((cert) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.military_tech_rounded, color: Color(0xFFD97706), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        cert,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
