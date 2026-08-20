import 'package:flutter/material.dart';
import 'package:unisphere/core/features/feature_item.dart';
import 'package:unisphere/screens/features/certifications_screen.dart';
import 'package:unisphere/screens/features/events_screen.dart';
import 'package:unisphere/screens/features/fees_screen.dart';
import 'package:unisphere/screens/features/hackathons_screen.dart';
import 'package:unisphere/screens/student/modules/student_announcements_screen.dart';
import 'package:unisphere/screens/student/modules/student_pyq_screen.dart';
import 'package:unisphere/screens/student/modules/student_resume_screen.dart';
import 'package:unisphere/screens/common/loader_preview_screen.dart';

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
      category: 'Career & Competitions',
      badge: 'Live',
      routeBuilder: (context) => const HackathonsScreen(),
    ),
    FeatureItem(
      id: 'certifications',
      title: 'Certifications',
      subtitle: 'Upload, manage, verify & download certificates',
      icon: Icons.workspace_premium_rounded,
      imageAsset: 'assets/certificate.png',
      color: const Color(0xFF2563EB),
      pastelBg: const Color(0xFFEFF6FF),
      category: 'Career & Credentials',
      badge: 'Verified',
      routeBuilder: (context) => const CertificationsScreen(),
    ),
    FeatureItem(
      id: 'resume',
      title: 'Professional Resume',
      subtitle: 'Dynamic ATS-ready verified student CV & A4 document',
      icon: Icons.description_rounded,
      imageAsset: 'assets/certificate.png',
      color: const Color(0xFF2563EB),
      pastelBg: const Color(0xFFEFF6FF),
      category: 'Career & Credentials',
      badge: 'Resume',
      routeBuilder: (context) => const StudentResumeScreen(),
    ),
    FeatureItem(
      id: 'announcements',
      title: 'Official Announcements',
      subtitle: 'Department circulars, alerts & campus news',
      icon: Icons.campaign_rounded,
      imageAsset: 'assets/announcement.png',
      color: const Color(0xFFD97706),
      pastelBg: const Color(0xFFFEF3C7),
      category: 'Campus Life',
      badge: 'News',
      routeBuilder: (context) => const StudentAnnouncementsScreen(),
    ),
    FeatureItem(
      id: 'events',
      title: 'Campus Events & Fests',
      subtitle: 'Technical symposiums, workshops, fests & guest talks',
      icon: Icons.event_rounded,
      imageAsset: 'assets/social-media-marketing.png',
      color: const Color(0xFFDC2626),
      pastelBg: const Color(0xFFFFE4E6),
      category: 'Campus Life',
      badge: 'Upcoming',
      routeBuilder: (context) => const EventsScreen(),
    ),
    FeatureItem(
      id: 'fees',
      title: 'Fees & Payment Receipts',
      subtitle: 'Tuition breakdown, installment dues & fee receipts',
      icon: Icons.payments_rounded,
      imageAsset: 'assets/certificate.png',
      color: const Color(0xFF16A34A),
      pastelBg: const Color(0xFFDCFCE7),
      category: 'Campus Life',
      badge: 'Finance',
      routeBuilder: (context) => const FeesScreen(),
    ),
    FeatureItem(
      id: 'pyq_question_papers',
      title: 'Question Papers & PYQ',
      subtitle: 'University previous years papers, IATs & solved question banks',
      icon: Icons.quiz_rounded,
      imageAsset: 'assets/certificate.png',
      color: const Color(0xFF4F46E5),
      pastelBg: const Color(0xFFEEF2FF),
      category: 'Academic & Learning',
      badge: 'Official PYQ',
      routeBuilder: (context) => const StudentPyqScreen(),
    ),
    FeatureItem(
      id: 'loader_preview',
      title: 'Loader Preview',
      subtitle: 'Preview & test the animated Tibsy GIF loader',
      icon: Icons.hourglass_top_rounded,
      imageAsset: 'assets/tibsy-dp.gif',
      color: const Color(0xFF6366F1),
      pastelBg: const Color(0xFFEEF2FF),
      category: 'Campus Life',
      badge: 'Preview',
      routeBuilder: (context) => const LoaderPreviewScreen(),
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
