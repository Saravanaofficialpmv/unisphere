import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:unisphere/providers/academic_overview_provider.dart';
import 'package:unisphere/services/github_service.dart';
import 'package:unisphere/widgets/common/unisphere_header_card.dart';

class GitHubDetailScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;

  const GitHubDetailScreen({
    super.key,
    this.onBack,
  });

  @override
  ConsumerState<GitHubDetailScreen> createState() => _GitHubDetailScreenState();
}

class _GitHubDetailScreenState extends ConsumerState<GitHubDetailScreen> {
  bool _isRefreshing = false;
  late TextEditingController _handleController;
  GitHubUserStats _fullStats = GitHubUserStats.empty();

  @override
  void initState() {
    super.initState();
    final overviewData = ref.read(academicOverviewProvider);
    _handleController = TextEditingController(text: overviewData.githubUsername);
    if (overviewData.githubUsername.isNotEmpty) {
      _loadFullStats(overviewData.githubUsername);
    } else {
      _fullStats = GitHubUserStats.empty();
    }
  }

  @override
  void dispose() {
    _handleController.dispose();
    super.dispose();
  }

  Future<void> _loadFullStats(String username) async {
    final cleanUser = username.trim().replaceAll('@', '');
    if (cleanUser.isEmpty) {
      if (mounted) {
        setState(() {
          _fullStats = GitHubUserStats.empty();
          _isRefreshing = false;
        });
      }
      return;
    }

    setState(() {
      _isRefreshing = true;
    });
    final stats = await GitHubService.fetchUserStats(cleanUser);
    if (mounted) {
      setState(() {
        _fullStats = stats;
        _isRefreshing = false;
      });
      // Update provider state if stats fetched successfully
      ref.read(academicOverviewProvider.notifier).updateData(
        githubUsername: stats.username,
        githubRepos: stats.publicRepos,
        githubStars: stats.starsEarned,
        githubCommits: stats.commitsThisYear,
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

  void _showUpdateHandleDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Row(
            children: [
              Icon(Icons.integration_instructions_rounded, color: Color(0xFF2563EB)),
              SizedBox(width: 8),
              Text('Update GitHub Handle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your public GitHub username. UNISPHERE will automatically sync your public repositories, stars, and open source stats.',
                style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _handleController,
                decoration: InputDecoration(
                  labelText: 'GitHub Username',
                  hintText: 'e.g. Saravanaofficialpmv',
                  prefixIcon: const Icon(Icons.alternate_email_rounded, color: Color(0xFF2563EB)),
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
                final newUsername = _handleController.text.trim();
                if (newUsername.isNotEmpty) {
                  Navigator.pop(context);
                  _loadFullStats(newUsername);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Sync & Save'),
            ),
          ],
        );
      },
    );
  }

  Color _getLanguageColor(String language) {
    switch (language.toLowerCase()) {
      case 'dart':
        return const Color(0xFF00B4AB);
      case 'c++':
      case 'cpp':
        return const Color(0xFFF34B7D);
      case 'python':
        return const Color(0xFF3572A5);
      case 'java':
        return const Color(0xFFB07219);
      case 'typescript':
      case 'ts':
        return const Color(0xFF3178C6);
      case 'javascript':
      case 'js':
        return const Color(0xFFF7DF1E);
      case 'html':
        return const Color(0xFFE34F26);
      case 'css':
        return const Color(0xFF563D7C);
      case 'rust':
        return const Color(0xFFDEA584);
      default:
        return const Color(0xFF64748B);
    }
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
                  title: 'GitHub Developer Analytics',
                  subtitle: '@${_fullStats.username} • Open Source & Repositories',
                  onBack: _handleBack,
                ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _loadFullStats(_fullStats.username),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Profile Banner Header
                    _buildProfileHeaderCard(),

                    const SizedBox(height: 16),

                    // 2. Daily Sync & Status Info Box
                    _buildAutoSyncBanner(),

                    const SizedBox(height: 16),

                    // 3. GitHub Metrics 4-Grid
                    _buildStatsGrid(),

                    const SizedBox(height: 20),

                    // 4. Language Breakdown & Tech Stack
                    _buildLanguageBreakdownSection(),

                    const SizedBox(height: 20),

                    // 5. Featured Repositories List
                    _buildFeaturedRepositoriesSection(),

                    const SizedBox(height: 20),

                    // 6. Contribution Activity Matrix Card
                    _buildContributionActivityCard(),
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
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.25),
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
              // Avatar Image / Circle
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF38BDF8), width: 2),
                  color: Colors.white.withValues(alpha: 0.1),
                  image: _fullStats.avatarUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(_fullStats.avatarUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _fullStats.avatarUrl.isEmpty
                    ? const Icon(Icons.integration_instructions_rounded, color: Colors.white, size: 30)
                    : null,
              ),
              const SizedBox(width: 14),

              // Name & Bio
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _fullStats.name,
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
                    Text(
                      '@${_fullStats.username}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Edit Handle Icon Button
              IconButton(
                onPressed: _showUpdateHandleDialog,
                icon: const Icon(Icons.edit_note_rounded, color: Colors.white70),
                tooltip: 'Change GitHub Handle',
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Bio Text
          Text(
            _fullStats.bio,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFFCBD5E1),
              height: 1.35,
            ),
          ),

          const SizedBox(height: 14),

          // Action Buttons: Open GitHub Profile & Refresh
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _launchURL('https://github.com/${_fullStats.username}'),
                  icon: const Icon(Icons.open_in_new_rounded, size: 15),
                  label: const Text('Open GitHub Profile', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: _isRefreshing ? null : () => _loadFullStats(_fullStats.username),
                icon: _isRefreshing
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.sync_rounded, size: 16, color: Colors.white),
                label: Text(_isRefreshing ? 'Syncing...' : 'Sync', style: const TextStyle(fontSize: 12.5, color: Colors.white)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
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

  Widget _buildAutoSyncBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          const Icon(Icons.schedule_rounded, color: Color(0xFF2563EB), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Auto-Sync • GitHub REST API',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E40AF),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Last synced: ${_fullStats.lastSyncedAt} • Next sync: Tomorrow at 12:00 AM',
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF3B82F6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Public Repos',
                value: '${_fullStats.publicRepos}',
                subtitle: 'Active Repositories',
                icon: Icons.folder_copy_rounded,
                accentColor: const Color(0xFF2563EB),
                bgGradient: const [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Stars Earned',
                value: '${_fullStats.starsEarned} ⭐',
                subtitle: 'Total Repos Stars',
                icon: Icons.star_rounded,
                accentColor: const Color(0xFFD97706),
                bgGradient: const [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Yearly Commits',
                value: '${_fullStats.commitsThisYear}',
                subtitle: 'Contributions in 2026',
                icon: Icons.commit_rounded,
                accentColor: const Color(0xFF059669),
                bgGradient: const [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Network',
                value: '${_fullStats.followers} / ${_fullStats.following}',
                subtitle: 'Followers / Following',
                icon: Icons.people_alt_rounded,
                accentColor: const Color(0xFF7C3AED),
                bgGradient: const [Color(0xFFF5F3FF), Color(0xFFEDE9FE)],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
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

  Widget _buildLanguageBreakdownSection() {
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
              Icon(Icons.code_rounded, color: Color(0xFF2563EB), size: 18),
              SizedBox(width: 8),
              Text(
                'Most Used Languages & Tech Stack',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Percentage Stacked Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 12,
              child: Row(
                children: _fullStats.languageBreakdown.entries.map((entry) {
                  final color = _getLanguageColor(entry.key);
                  final pct = entry.value;
                  return Expanded(
                    flex: (pct * 10).round().clamp(1, 1000),
                    child: Container(color: color),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Language Chips Grid
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _fullStats.languageBreakdown.entries.map((entry) {
              final color = _getLanguageColor(entry.key);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: color.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${entry.value}%',
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
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

  Widget _buildFeaturedRepositoriesSection() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.bookmark_border_rounded, color: Color(0xFF2563EB), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Featured Repositories',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Text(
                '${_fullStats.featuredRepos.length} Repos',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _fullStats.featuredRepos.length,
            separatorBuilder: (context, index) => const Divider(height: 16, color: Color(0xFFF1F5F9)),
            itemBuilder: (context, index) {
              final repo = _fullStats.featuredRepos[index];
              final langColor = _getLanguageColor(repo.language);

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.folder_open_rounded, color: Color(0xFF2563EB), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            repo.name,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.open_in_new_rounded, size: 16, color: Color(0xFF2563EB)),
                          onPressed: () => _launchURL(repo.htmlUrl),
                          tooltip: 'Open Repository',
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      repo.description,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF475569),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        // Language Pill
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: langColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          repo.language,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: langColor,
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Stars
                        const Icon(Icons.star_outline_rounded, size: 14, color: Color(0xFFD97706)),
                        const SizedBox(width: 3),
                        Text(
                          '${repo.stars}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 14),

                        // Forks
                        const Icon(Icons.alt_route_rounded, size: 14, color: Color(0xFF64748B)),
                        const SizedBox(width: 3),
                        Text(
                          '${repo.forks}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                        ),

                        const Spacer(),
                        Text(
                          'Updated ${repo.updatedAt}',
                          style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContributionActivityCard() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.grid_view_rounded, color: Color(0xFF059669), size: 18),
                  SizedBox(width: 8),
                  Text(
                    '2026 Commit Activity Grid',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${_fullStats.commitsThisYear} Commits',
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Visual Activity Grid Preview (12 weeks matrix)
          LayoutBuilder(
            builder: (context, constraints) {
              final double boxSize = ((constraints.maxWidth - (16 * 4)) / 12).clamp(12.0, 22.0);
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(12, (colIndex) {
                  return Column(
                    children: List.generate(5, (rowIndex) {
                      final intensity = (colIndex + rowIndex * 3) % 4;
                      Color boxColor;
                      switch (intensity) {
                        case 3:
                          boxColor = const Color(0xFF059669);
                          break;
                        case 2:
                          boxColor = const Color(0xFF34D399);
                          break;
                        case 1:
                          boxColor = const Color(0xFFA7F3D0);
                          break;
                        default:
                          boxColor = const Color(0xFFF1F5F9);
                      }
                      return Container(
                        width: boxSize,
                        height: boxSize,
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: boxColor,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  );
                }),
              );
            },
          ),
          const SizedBox(height: 10),

          // Legend Row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text('Less', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
              const SizedBox(width: 4),
              _buildLegendBox(const Color(0xFFF1F5F9)),
              _buildLegendBox(const Color(0xFFA7F3D0)),
              _buildLegendBox(const Color(0xFF34D399)),
              _buildLegendBox(const Color(0xFF059669)),
              const SizedBox(width: 4),
              const Text('More', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendBox(Color color) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
