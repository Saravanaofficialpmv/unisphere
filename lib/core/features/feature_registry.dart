import 'package:flutter/material.dart';
import 'package:clg_application/core/features/feature_item.dart';
import 'package:clg_application/screens/features/certifications_screen.dart';
import 'package:clg_application/screens/features/hackathons_screen.dart';
import 'package:clg_application/screens/features/achievements_screen.dart';
import 'package:clg_application/screens/features/events_screen.dart';
import 'package:clg_application/screens/student/gradebook_screen.dart';

class FeatureRegistry {
  static final List<FeatureItem> _registeredFeatures = [
    FeatureItem(
      id: 'hackathons',
      title: 'Hackathons',
      subtitle: 'Competitive coding sprints, AI hackathons & prizes',
      icon: Icons.sports_score_rounded,
      color: const Color(0xFF7C3AED),
      category: 'Events & Competitions',
      badge: 'Live',
      routeBuilder: (context) => const HackathonsScreen(),
    ),
    FeatureItem(
      id: 'certifications',
      title: 'Certifications & Upload',
      subtitle: 'View, upload & verify professional & academic certificates',
      icon: Icons.card_membership_rounded,
      color: const Color(0xFF2563EB),
      category: 'Career & Credentials',
      badge: 'Verified',
      routeBuilder: (context) => const CertificationsScreen(),
    ),
    FeatureItem(
      id: 'gradebook',
      title: 'Gradebook & CGPA Calculator',
      subtitle: 'Marks breakdown, SGPA/CGPA planner & what-if simulator',
      icon: Icons.auto_graph_rounded,
      color: const Color(0xFF059669),
      category: 'Academic',
      badge: 'Interactive',
      routeBuilder: (context) => const GradebookScreen(initialShowPlanner: false),
    ),
    FeatureItem(
      id: 'achievements',
      title: 'Achievements',
      subtitle: 'Dean\'s Honor Roll, trophies, badges & leaderboards',
      icon: Icons.emoji_events_rounded,
      color: const Color(0xFFD97706),
      category: 'Academic',
      badge: 'Badges',
      routeBuilder: (context) => const AchievementsScreen(),
    ),
    FeatureItem(
      id: 'events',
      title: 'Campus Events',
      subtitle: 'Technical symposiums, workshops & cultural fests',
      icon: Icons.event_rounded,
      color: const Color(0xFFDC2626),
      category: 'Events & Competitions',
      badge: 'Upcoming',
      routeBuilder: (context) => const EventsScreen(),
    ),
  ];

  static List<FeatureItem> getAllFeatures() {
    return List.unmodifiable(_registeredFeatures);
  }

  static List<String> getCategories() {
    final categories = _registeredFeatures.map((f) => f.category).toSet().toList();
    categories.sort();
    return ['All', ...categories];
  }

  static List<FeatureItem> getByCategory(String category) {
    if (category == 'All') return getAllFeatures();
    return _registeredFeatures.where((f) => f.category == category).toList();
  }
}
