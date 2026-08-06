import 'package:flutter/material.dart';
import 'package:clg_application/screens/features/feature_hub_screen.dart';

class HackathonModel {
  final String id;
  final String title;
  final String organizer;
  final String date;
  final String prizePool;
  final String category;
  final String mode; // 'Online', 'In-Person', 'Hybrid'
  final int registeredTeams;
  final String bannerGradient;
  final bool isRegistered;

  HackathonModel({
    required this.id,
    required this.title,
    required this.organizer,
    required this.date,
    required this.prizePool,
    required this.category,
    required this.mode,
    required this.registeredTeams,
    required this.bannerGradient,
    this.isRegistered = false,
  });
}

class HackathonsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const HackathonsScreen({super.key, this.onBack});

  @override
  State<HackathonsScreen> createState() => _HackathonsScreenState();
}

class _HackathonsScreenState extends State<HackathonsScreen> {
  final List<HackathonModel> _hackathons = [
    HackathonModel(
      id: 'HACK-1',
      title: 'UniHack 2026: GenAI & Autonomous Systems',
      organizer: 'Department of Computer Science & IEEE',
      date: 'Aug 28 - Aug 30, 2026',
      prizePool: '₹2,50,000',
      category: 'AI & Robotics',
      mode: 'In-Person',
      registeredTeams: 142,
      bannerGradient: 'purple',
      isRegistered: true,
    ),
    HackathonModel(
      id: 'HACK-2',
      title: 'Global Web3 & Smart Contracts Challenge',
      organizer: 'Crypto & Blockchain Club',
      date: 'Sep 10 - Sep 12, 2026',
      prizePool: '\$5,000 USDT',
      category: 'Blockchain',
      mode: 'Online',
      registeredTeams: 88,
      bannerGradient: 'blue',
      isRegistered: false,
    ),
    HackathonModel(
      id: 'HACK-3',
      title: 'CleanTech & Sustainable Energy Sprint',
      organizer: 'SRM Green Initiative Foundation',
      date: 'Oct 05 - Oct 06, 2026',
      prizePool: '₹1,00,000',
      category: 'Sustainability',
      mode: 'Hybrid',
      registeredTeams: 64,
      bannerGradient: 'green',
      isRegistered: false,
    ),
  ];

  void _navigateBackToFeatureHub(BuildContext context) {
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const FeatureHubScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Hackathons & Sprints',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Spotlight Card
            _buildHeroSpotlightCard(),
            const SizedBox(height: 20),

            const Text(
              'Explore Active & Upcoming Hackathons',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 12),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _hackathons.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final hack = _hackathons[index];
                return _buildHackathonCard(hack);
              },
            ),
          ],
        ),
      ),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _navigateBackToFeatureHub(context);
      },
      child: scaffold,
    );
  }

  Widget _buildHeroSpotlightCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                child: const Row(
                  children: [
                    Icon(Icons.military_tech_rounded, color: Color(0xFFFDE047), size: 14),
                    SizedBox(width: 4),
                    Text('FLAGSHIP EVENT', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const Spacer(),
              const Text('Registrations Open', style: TextStyle(color: Color(0xFF86EFAC), fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          const Text('UniHack 2026: GenAI Sprint', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 6),
          const Text(
            '36-hour non-stop hackathon building autonomous AI agents and intelligent workflows.',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildSpotlightDetail('Prize Pool', '₹2,50,000'),
              const SizedBox(width: 20),
              _buildSpotlightDetail('Teams Registered', '142 Teams'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpotlightDetail(String title, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: const TextStyle(fontSize: 9, color: Colors.white60, fontWeight: FontWeight.bold)),
        Text(val, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  Widget _buildHackathonCard(HackathonModel hack) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  hack.category,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E7FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  hack.mode,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4338CA)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(hack.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Text('Organized by ${hack.organizer}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.emoji_events_rounded, size: 16, color: Color(0xFFD97706)),
              const SizedBox(width: 4),
              Text(hack.prizePool, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
              const Spacer(),
              const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 4),
              Text(hack.date, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            ],
          ),
          const Divider(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(hack.isRegistered ? 'Viewing Team Portal for ${hack.title}' : 'Registering for ${hack.title}')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: hack.isRegistered ? const Color(0xFF10B981) : const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(hack.isRegistered ? '✓ Registered (Manage Team)' : 'Register Team Now'),
            ),
          ),
        ],
      ),
    );
  }
}
