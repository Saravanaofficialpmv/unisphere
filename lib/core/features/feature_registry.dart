import 'package:flutter/material.dart';
import 'package:unisphere/core/features/feature_item.dart';
import 'package:unisphere/screens/features/certifications_screen.dart';
import 'package:unisphere/screens/features/hackathons_screen.dart';
import 'package:unisphere/screens/features/achievements_screen.dart';
import 'package:unisphere/screens/features/events_screen.dart';


class FeatureRegistry {
  static final List<FeatureItem> _registeredFeatures = [
    FeatureItem(
      id: 'hackathons',
      title: 'Hackathons',
      subtitle: 'View ongoing, upcoming & completed hackathons',
      icon: Icons.sports_score_rounded,
      imageAsset: 'assets/hackathon.png',
      color: const Color(0xFF7C3AED),
      pastelBg: const Color(0xFFF3E8FF),
      category: 'Events & Competitions',
      badge: 'Live',
      routeBuilder: (context) => const HackathonsScreen(),
    ),
    FeatureItem(
      id: 'certifications',
      title: 'Certifications',
      subtitle: 'Upload, manage, verify & download certificates',
      icon: Icons.card_membership_rounded,
      imageAsset: 'assets/certificate.png',
      color: const Color(0xFF2563EB),
      pastelBg: const Color(0xFFEFF6FF),
      category: 'Career & Credentials',
      badge: 'Verified',
      routeBuilder: (context) => const CertificationsScreen(),
    ),

    FeatureItem(
      id: 'achievements',
      title: 'Achievements',
      subtitle: 'Dean\'s Honor Roll, trophies & badges',
      icon: Icons.emoji_events_rounded,
      imageAsset: 'assets/school.png',
      color: const Color(0xFFD97706),
      pastelBg: const Color(0xFFFEF3C7),
      category: 'Academic',
      badge: 'Badges',
      routeBuilder: (context) => const AchievementsScreen(),
    ),
    FeatureItem(
      id: 'events',
      title: 'Campus Events',
      subtitle: 'Technical symposiums, workshops & fests',
      icon: Icons.event_rounded,
      imageAsset: 'assets/calendar.png',
      color: const Color(0xFFDC2626),
      pastelBg: const Color(0xFFFFEDD5),
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
