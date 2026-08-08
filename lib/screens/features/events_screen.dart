import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CampusEventModel {
  final String title;
  final String category;
  final String date;
  final String location;
  final String time;
  final String speaker;
  final Color color;

  CampusEventModel({
    required this.title,
    required this.category,
    required this.date,
    required this.location,
    required this.time,
    required this.speaker,
    required this.color,
  });
}

class EventsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const EventsScreen({super.key, this.onBack});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final List<CampusEventModel> _events = [
    CampusEventModel(
      title: 'AI in Healthcare & Medical Robotics Seminar',
      category: 'Technical Workshop',
      date: 'Aug 14, 2026',
      time: '10:00 AM - 01:00 PM',
      location: 'Mini Auditorium 2',
      speaker: 'Dr. Radhakrishnan (Apollo Tech Labs)',
      color: const Color(0xFF2563EB),
    ),
    CampusEventModel(
      title: 'SRM Annual Cultural Fest: Milan 2026',
      category: 'Cultural',
      date: 'Sep 02 - Sep 04, 2026',
      time: 'All Day',
      location: 'Main University Grounds',
      speaker: 'Student Cultural Council',
      color: const Color(0xFFEC4899),
    ),
    CampusEventModel(
      title: 'Cloud Architecture & Microservices Bootcamp',
      category: 'Hands-on Lab',
      date: 'Sep 18, 2026',
      time: '02:00 PM - 05:30 PM',
      location: 'CS Tech Lab 4',
      speaker: 'Prof. David Miller (AWS Educate)',
      color: const Color(0xFF7C3AED),
    ),
  ];

  void _navigateBackToFeatureHub(BuildContext context) async {
    if (widget.onBack != null) {
      widget.onBack!();
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
          'Campus Events & Fests',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Upcoming Events & Workshops', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 12),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _events.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final event = _events[index];
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
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: event.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                            child: Text(event.category, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: event.color)),
                          ),
                          const Spacer(),
                          const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Text(event.date, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(event.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.person_pin_rounded, size: 14, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Text(event.speaker, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, size: 14, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              event.time,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('RSVP confirmed for ${event.title}')),
                            );
                          },
                          icon: const Icon(Icons.event_available_rounded, size: 16),
                          label: const Text('RSVP & Add to Calendar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: event.color,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
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
      canPop: widget.onBack == null,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (widget.onBack != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              widget.onBack!();
            }
          });
        }
      },
      child: scaffold,
    );
  }
}
