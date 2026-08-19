import 'package:flutter/material.dart';
import 'package:unisphere/core/features/feature_item.dart';
import 'package:unisphere/screens/features/achievements_screen.dart';
import 'package:unisphere/screens/features/certifications_screen.dart';
import 'package:unisphere/screens/features/events_screen.dart';
import 'package:unisphere/screens/features/exams_detail_screen.dart';
import 'package:unisphere/screens/features/fees_screen.dart';
import 'package:unisphere/screens/features/github_detail_screen.dart';
import 'package:unisphere/screens/features/hackathons_screen.dart';
import 'package:unisphere/screens/features/leetcode_detail_screen.dart';
import 'package:unisphere/screens/gallery/full_photo_gallery_screen.dart';
import 'package:unisphere/screens/student/cgpa_details_screen.dart';
import 'package:unisphere/screens/student/modules/student_announcements_screen.dart';
import 'package:unisphere/screens/student/modules/student_upcoming_tasks_screen.dart';
import 'package:unisphere/screens/student/modules/student_library_screen.dart';
import 'package:unisphere/screens/features/academic_schedule_detail_screen.dart';
import 'package:unisphere/screens/student/modules/student_resume_screen.dart';

class FeatureRegistry {
  static final List<FeatureItem> _registeredFeatures = [
    FeatureItem(
      id: 'upcoming_tasks',
      title: 'Upcoming Tasks',
      subtitle: 'Course assignments, homework submissions & deadlines',
      icon: Icons.task_alt_rounded,
      imageAsset: 'assets/certificate.png',
      color: const Color(0xFF0D9488),
      pastelBg: const Color(0xFFCCFBF1),
      category: 'Academics',
      badge: 'Active',
      routeBuilder: (context) => const StudentUpcomingTasksScreen(),
    ),
    FeatureItem(
      id: 'exams',
      title: 'Examinations & Hall Ticket',
      subtitle: 'IA schedules, university dates & seating guidelines',
      icon: Icons.badge_outlined,
      imageAsset: 'assets/calendar.png',
      color: const Color(0xFF4F46E5),
      pastelBg: const Color(0xFFEEF2FF),
      category: 'Academics',
      badge: 'Exams',
      routeBuilder: (context) => const ExamsDetailScreen(),
    ),
    FeatureItem(
      id: 'cgpa_planner',
      title: 'CGPA & Target Planner',
      subtitle: 'Semester grade breakdowns & GPA target forecasting',
      icon: Icons.calculate_rounded,
      imageAsset: 'assets/school.png',
      color: const Color(0xFF2563EB),
      pastelBg: const Color(0xFFEFF6FF),
      category: 'Academics',
      badge: 'Calculator',
      routeBuilder: (context) => const CgpaDetailsScreen(),
    ),
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
      id: 'leetcode',
      title: 'LeetCode Problem Tracker',
      subtitle: 'Solved problems, acceptance rate & contest rating',
      icon: Icons.code_rounded,
      imageAsset: 'assets/hackathon.png',
      color: const Color(0xFFEA580C),
      pastelBg: const Color(0xFFFFEDD5),
      category: 'Career & Credentials',
      badge: 'DSA',
      routeBuilder: (context) => const LeetCodeDetailScreen(),
    ),
    FeatureItem(
      id: 'github',
      title: 'GitHub Dev Portfolio',
      subtitle: 'Contribution activity, repositories & tech stack',
      icon: Icons.terminal_rounded,
      imageAsset: 'assets/hackathon.png',
      color: const Color(0xFF0F172A),
      pastelBg: const Color(0xFFF1F5F9),
      category: 'Career & Credentials',
      badge: 'Git',
      routeBuilder: (context) => const GitHubDetailScreen(),
    ),
    FeatureItem(
      id: 'professional_resume',
      title: 'Professional Resume',
      subtitle: 'Dynamic A4 resume generated from verified campus records',
      icon: Icons.description_rounded,
      imageAsset: 'assets/certificate.png',
      color: const Color(0xFF2563EB),
      pastelBg: const Color(0xFFEFF6FF),
      category: 'Career & Credentials',
      badge: 'Live',
      routeBuilder: (context) => const StudentResumeScreen(),
    ),
    FeatureItem(
      id: 'achievements',
      title: 'Achievements & Badges',
      subtitle: 'Dean\'s Honor Roll, trophies & competitive badges',
      icon: Icons.emoji_events_rounded,
      imageAsset: 'assets/school.png',
      color: const Color(0xFFD97706),
      pastelBg: const Color(0xFFFEF3C7),
      category: 'Academics',
      badge: 'Badges',
      routeBuilder: (context) => const AchievementsScreen(),
    ),
    FeatureItem(
      id: 'events',
      title: 'Campus Events & Fests',
      subtitle: 'Technical symposiums, workshops, fests & guest talks',
      icon: Icons.event_rounded,
      imageAsset: 'assets/calendar.png',
      color: const Color(0xFFDC2626),
      pastelBg: const Color(0xFFFFE4E6),
      category: 'Campus Life',
      badge: 'Upcoming',
      routeBuilder: (context) => const EventsScreen(),
    ),
    FeatureItem(
      id: 'photo_gallery',
      title: 'Campus Photo Gallery',
      subtitle: 'High-res memories, fest pictures & album highlights',
      icon: Icons.collections_rounded,
      imageAsset: 'assets/school.png',
      color: const Color(0xFF0284C7),
      pastelBg: const Color(0xFFE0F2FE),
      category: 'Campus Life',
      badge: 'Gallery',
      routeBuilder: (context) => const FullPhotoGalleryScreen(),
    ),
    FeatureItem(
      id: 'announcements',
      title: 'Official Announcements',
      subtitle: 'Department circulars, alerts & campus news',
      icon: Icons.campaign_rounded,
      imageAsset: 'assets/calendar.png',
      color: const Color(0xFFD97706),
      pastelBg: const Color(0xFFFEF3C7),
      category: 'Campus Life',
      badge: 'News',
      routeBuilder: (context) => const StudentAnnouncementsScreen(),
    ),
    FeatureItem(
      id: 'library',
      title: 'Digital Library Access',
      subtitle: 'Issued books, due dates, fines & search catalog',
      icon: Icons.local_library_rounded,
      imageAsset: 'assets/school.png',
      color: const Color(0xFF059669),
      pastelBg: const Color(0xFFD1FAE5),
      category: 'Campus Life',
      badge: 'Library',
      routeBuilder: (context) => const StudentLibraryScreen(),
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
      id: 'academic_schedule',
      title: 'Important Days & Schedule',
      subtitle: 'Official academic calendar, CAT dates, working days & holidays',
      icon: Icons.calendar_month_rounded,
      imageAsset: 'assets/calendar.png',
      color: const Color(0xFF1E40AF),
      pastelBg: const Color(0xFFEFF6FF),
      category: 'Academics',
      badge: 'Official',
      routeBuilder: (context) => const AcademicScheduleDetailScreen(),
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
