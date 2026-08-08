import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AchievementsScreen extends StatelessWidget {
  final VoidCallback? onBack;
  const AchievementsScreen({super.key, this.onBack});

  void _navigateBackToFeatureHub(BuildContext context) async {
    if (onBack != null) {
      onBack!();
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go('/student');
    }
  }

  @override
  Widget build(BuildContext context) {
    final badges = [
      {'title': 'Dean\'s List Scholar', 'desc': 'CGPA >= 8.50 for 3 consecutive semesters', 'icon': Icons.stars_rounded, 'color': const Color(0xFFD97706), 'unlocked': true},
      {'title': 'Code Master', 'desc': 'Completed 50+ Data Structure & Algo lab tasks', 'icon': Icons.terminal_rounded, 'color': const Color(0xFF2563EB), 'unlocked': true},
      {'title': 'Perfect Attendance', 'desc': '100% attendance in OS & DBMS for 2 months', 'icon': Icons.verified_rounded, 'color': const Color(0xFF10B981), 'unlocked': true},
      {'title': 'Hackathon Winner', 'desc': 'First Prize in Annual Tech Fest 2025', 'icon': Icons.emoji_events_rounded, 'color': const Color(0xFF7C3AED), 'unlocked': true},
      {'title': 'Research Contributor', 'desc': 'Co-authored IEEE conference paper draft', 'icon': Icons.menu_book_rounded, 'color': const Color(0xFF0284C7), 'unlocked': false},
      {'title': 'Peer Mentor', 'desc': 'Tutored 15+ junior students in Python & OOP', 'icon': Icons.groups_rounded, 'color': const Color(0xFFEA580C), 'unlocked': false},
    ];

    final scaffold = Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => _navigateBackToFeatureHub(context),
        ),
        title: const Text(
          'Achievements & Trophies',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Progress Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF059669), Color(0xFF10B981)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                    child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 36),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ACADEMIC RANK #4', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        SizedBox(height: 2),
                        Text('4 of 6 Badges Unlocked', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        SizedBox(height: 4),
                        Text('Keep up the momentum to reach Gold Tier!', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text('Badges & Milestones', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: badges.length,
              itemBuilder: (context, index) {
                final badge = badges[index];
                final isUnlocked = badge['unlocked'] as bool;
                final color = badge['color'] as Color;

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isUnlocked ? color.withValues(alpha: 0.3) : const Color(0xFFE2E8F0)),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUnlocked ? color.withValues(alpha: 0.1) : const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          badge['icon'] as IconData,
                          color: isUnlocked ? color : const Color(0xFF94A3B8),
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        badge['title'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isUnlocked ? const Color(0xFF0F172A) : const Color(0xFF94A3B8)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        badge['desc'] as String,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 10, color: isUnlocked ? const Color(0xFF64748B) : const Color(0xFFCBD5E1)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );

    return PopScope(
      canPop: onBack == null,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (onBack != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onBack!();
          });
        }
      },
      child: scaffold,
    );
  }
}
