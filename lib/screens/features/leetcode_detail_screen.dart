import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unisphere/core/constants/app_colors.dart';
import 'package:unisphere/providers/academic_overview_provider.dart';
import 'package:unisphere/services/leetcode_service.dart';
import 'package:unisphere/widgets/common/unisphere_header_card.dart';

class LeetCodeDetailScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;

  const LeetCodeDetailScreen({
    super.key,
    this.onBack,
  });

  @override
  ConsumerState<LeetCodeDetailScreen> createState() => _LeetCodeDetailScreenState();
}

class _LeetCodeDetailScreenState extends ConsumerState<LeetCodeDetailScreen> {
  bool _isRefreshing = false;
  late TextEditingController _handleController;
  LeetCodeUserStats _fullStats = const LeetCodeUserStats(
    username: 'tharani_dev',
    totalSolved: 248,
    isFetched: true,
  );

  @override
  void initState() {
    super.initState();
    final overviewData = ref.read(academicOverviewProvider);
    _handleController = TextEditingController(text: overviewData.leetcodeUsername);
    _loadFullStats(overviewData.leetcodeUsername);
  }

  @override
  void dispose() {
    _handleController.dispose();
    super.dispose();
  }

  Future<void> _loadFullStats(String username) async {
    setState(() {
      _isRefreshing = true;
    });
    final stats = await LeetCodeService.fetchUserStats(username);
    if (mounted) {
      setState(() {
        _fullStats = stats;
        _isRefreshing = false;
      });
    }
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
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
              Icon(Icons.code_rounded, color: Color(0xFFEA580C)),
              SizedBox(width: 8),
              Text('Update LeetCode Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your public LeetCode handle. UNISPHERE will automatically sync your solved problems every day at 12:00 AM.',
                style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _handleController,
                decoration: InputDecoration(
                  labelText: 'LeetCode Username',
                  hintText: 'e.g. tharani_dev',
                  prefixIcon: const Icon(Icons.alternate_email_rounded, color: Color(0xFFEA580C)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
              onPressed: () {
                final newUsername = _handleController.text.trim();
                if (newUsername.isNotEmpty) {
                  ref.read(academicOverviewProvider.notifier).fetchLeetCodeStats(newUsername);
                  _loadFullStats(newUsername);
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('LeetCode profile updated to @$newUsername! Syncing at 12:00 AM daily.'),
                    backgroundColor: const Color(0xFF10B981),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEA580C),
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
    final overviewData = ref.watch(academicOverviewProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Column(
              children: [
                // Top Custom Header Card
                UnisphereHeaderCard(
                  title: 'LeetCode Analytics & Progress',
                  subtitle: 'Auto-Sync Active • Every day at 12:00 AM',
                  onBack: _handleBack,
                  margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                  rightActions: [
                    IconButton(
                      icon: const Icon(Icons.edit_note_rounded, color: Colors.white),
                      tooltip: 'Update Handle',
                      onPressed: _showUpdateHandleDialog,
                    ),
                    IconButton(
                      icon: _isRefreshing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.refresh_rounded, color: Colors.white),
                      tooltip: 'Sync Now',
                      onPressed: () => _loadFullStats(overviewData.leetcodeUsername),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── 1. Daily 12 AM Sync Status Banner ──
                        _buildDailySyncBanner(),
                        const SizedBox(height: 12),

                        // ── 2. Profile Overview Card ──
                        _buildProfileCard(overviewData.leetcodeUsername),
                        const SizedBox(height: 14),

                        // ── 3. Difficulty Breakdown Grid ──
                        const Text(
                          'Problem Difficulty Breakdown',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 8),
                        _buildDifficultyBreakdownGrid(),
                        const SizedBox(height: 16),

                        // ── 4. 7-Day Solved Activity Chart ──
                        _buildWeeklyActivityCard(),
                        const SizedBox(height: 16),

                        // ── 5. Recent Submissions ──
                        const Text(
                          'Recent LeetCode Submissions',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 8),
                        _buildRecentSubmissionsCard(),
                        const SizedBox(height: 16),

                        // ── 6. Earned Badges & Achievements ──
                        const Text(
                          'Earned Badges & Achievements',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 8),
                        _buildBadgesGrid(),
                      ],
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

  // ── 1. Daily 12 AM Sync Status Banner ──
  Widget _buildDailySyncBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDBA74).withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEA580C).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bolt_rounded, color: Color(0xFFEA580C), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Text(
                      '${_fullStats.todaysSolved} Problems Solved Today!',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF9A3412)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEA580C),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('12:00 AM Auto-Sync', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Last synced: ${_fullStats.lastSyncedAt} • Next sync: ${_fullStats.nextSyncAt}',
                  style: const TextStyle(fontSize: 10, color: Color(0xFFC2410C), fontWeight: FontWeight.w500),
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

  // ── 2. Profile Card ──
  Widget _buildProfileCard(String username) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFF7ED),
                  border: Border.all(color: const Color(0xFFEA580C), width: 2),
                ),
                child: const Icon(Icons.code_rounded, color: Color(0xFFEA580C), size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Text(
                          '@$username',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(_fullStats.status, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'LeetCode Verified Student Profile',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _showUpdateHandleDialog,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, size: 13, color: Color(0xFF475569)),
                      SizedBox(width: 4),
                      Text('Edit', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricStat('Total Solved', '${_fullStats.totalSolved}', const Color(0xFFEA580C)),
              _buildMetricStat('Global Rank', '#${_fullStats.ranking}', const Color(0xFF6366F1)),
              _buildMetricStat('Acceptance', '${_fullStats.acceptanceRate}%', const Color(0xFF10B981)),
              _buildMetricStat('Streak', '${_fullStats.streakDays} Days 🔥', const Color(0xFFF59E0B)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
      ],
    );
  }

  // ── 3. Difficulty Breakdown Grid ──
  Widget _buildDifficultyBreakdownGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildDifficultyCard(
            label: 'Easy',
            solved: _fullStats.easySolved,
            total: _fullStats.easyTotal,
            color: const Color(0xFF10B981),
            bgColor: const Color(0xFFECFDF5),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildDifficultyCard(
            label: 'Medium',
            solved: _fullStats.mediumSolved,
            total: _fullStats.mediumTotal,
            color: const Color(0xFFF59E0B),
            bgColor: const Color(0xFFFFFBEB),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildDifficultyCard(
            label: 'Hard',
            solved: _fullStats.hardSolved,
            total: _fullStats.hardTotal,
            color: const Color(0xFFEF4444),
            bgColor: const Color(0xFFFEF2F2),
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyCard({
    required String label,
    required int solved,
    required int total,
    required Color color,
    required Color bgColor,
  }) {
    final double percent = (solved / total).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(10),
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
              Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: color)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(4)),
                child: Text('${(percent * 100).toInt()}%', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('$solved / $total', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 5,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  // ── 4. 7-Day Activity Chart ──
  Widget _buildWeeklyActivityCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Weekly Solved Progress (7 Days)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              Text('Reset at 12:00 AM Daily', style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: _fullStats.dailyActivity.map((item) {
              final String day = item['day'] as String;
              final int count = item['count'] as int;
              final double heightFactor = (count / 6.0).clamp(0.1, 1.0);
              return Column(
                children: [
                  Text('$count', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                  const SizedBox(height: 4),
                  Container(
                    width: 22,
                    height: 50 * heightFactor,
                    decoration: BoxDecoration(
                      color: count > 0 ? const Color(0xFFEA580C) : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(day, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── 5. Recent Submissions ──
  Widget _buildRecentSubmissionsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: _fullStats.recentSubmissions.map((sub) {
          Color diffColor = const Color(0xFF10B981);
          if (sub.difficulty == 'Medium') diffColor = const Color(0xFFF59E0B);
          if (sub.difficulty == 'Hard') diffColor = const Color(0xFFEF4444);

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sub.title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      const SizedBox(height: 1),
                      Text('${sub.timeAgo} • ${sub.language}', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: diffColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(sub.difficulty, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: diffColor)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── 6. Badges Grid ──
  Widget _buildBadgesGrid() {
    return Row(
      children: _fullStats.badges.map((badge) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Text(badge.icon, style: const TextStyle(fontSize: 26)),
                const SizedBox(height: 4),
                Text(
                  badge.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                Text(badge.category, style: const TextStyle(fontSize: 9, color: Color(0xFF64748B))),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
