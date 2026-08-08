import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:clg_application/models/hackathon_model.dart';
import 'package:clg_application/screens/features/hackathon_registration_screen.dart';
import 'package:clg_application/screens/features/hackathon_team_management_screen.dart';

class HackathonDetailsScreen extends StatelessWidget {
  final HackathonModel hackathon;

  const HackathonDetailsScreen({super.key, required this.hackathon});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final startDateStr = dateFormat.format(hackathon.startDate);
    final endDateStr = dateFormat.format(hackathon.endDate);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: const Color(0xFF0F172A),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                hackathon.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: hackathon.bannerImage,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: const Color(0xFF1E293B)),
                    errorWidget: (context, url, error) => Container(
                      color: const Color(0xFF312E81),
                      child: const Center(
                        child: Icon(Icons.military_tech_rounded, size: 60, color: Colors.white38),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Color(0xD9000000)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                        child: Text(hackathon.category, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFE0E7FF), borderRadius: BorderRadius.circular(8)),
                        child: Text(hackathon.mode, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4338CA))),
                      ),
                      const Spacer(),
                      if (hackathon.registrationOpen)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(8)),
                          child: const Text('Registration Open', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF15803D))),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(8)),
                          child: const Text('Registration Closed', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFB91C1C))),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text('Organized by ${hackathon.organizer}', style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                  const SizedBox(height: 20),

                  // Highlights Grid
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(Icons.emoji_events_rounded, 'Prize Pool', hackathon.prizePool, const Color(0xFFD97706)),
                        const Divider(height: 24),
                        _buildDetailRow(Icons.calendar_today_rounded, 'Event Dates', '$startDateStr - $endDateStr', const Color(0xFF2563EB)),
                        const Divider(height: 24),
                        _buildDetailRow(Icons.location_on_rounded, 'Location', hackathon.location, const Color(0xFF059669)),
                        const Divider(height: 24),
                        _buildDetailRow(Icons.groups_rounded, 'Teams & Size', '${hackathon.registeredTeams} Registered / Max ${hackathon.maxTeams} (Team size: ${hackathon.teamSize})', const Color(0xFF7C3AED)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description
                  const Text('About the Hackathon', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  const SizedBox(height: 8),
                  Text(
                    hackathon.description,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.6),
                  ),
                  const SizedBox(height: 24),

                  // Tags
                  if (hackathon.tags.isNotEmpty) ...[
                    const Text('Technologies & Domains', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: hackathon.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E8FF),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFDDD6FE)),
                          ),
                          child: Text('#$tag', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6D28D9))),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: !hackathon.registrationOpen && !hackathon.isRegistered
                          ? null
                          : () {
                              if (hackathon.isRegistered) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => HackathonTeamManagementScreen(hackathon: hackathon)),
                                );
                              } else {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => HackathonRegistrationScreen(hackathon: hackathon)),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hackathon.isRegistered ? const Color(0xFF10B981) : const Color(0xFF7C3AED),
                        disabledBackgroundColor: const Color(0xFFCBD5E1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      child: Text(
                        hackathon.isRegistered
                            ? '✓ Registered (Manage Team)'
                            : hackathon.registrationOpen
                                ? 'Register Team Now'
                                : 'Registration Closed',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            ],
          ),
        ),
      ],
    );
  }
}
