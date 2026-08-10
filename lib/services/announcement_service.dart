import 'package:flutter/material.dart';
import 'package:clg_application/models/announcement_model.dart';

class AnnouncementService extends ChangeNotifier {
  static final AnnouncementService _instance = AnnouncementService._internal();
  factory AnnouncementService() => _instance;

  AnnouncementService._internal() {
    _initSeedAnnouncements();
  }

  final List<AnnouncementModel> _announcements = [];
  final String _currentUserId = 'std_alex_01'; // Default student ID

  List<AnnouncementModel> get announcements => List.unmodifiable(_announcements);

  int get unreadCount => _announcements.where((a) => !a.isReadBy(_currentUserId)).length;

  void _initSeedAnnouncements() {
    final now = DateTime.now();

    _announcements.addAll([
      AnnouncementModel(
        id: 'ann_101',
        title: 'College Holiday Notice',
        content: 'College will remain closed on 15th August for Independence Day celebrations. Regular academic classes will resume on Monday.',
        authorName: 'Office of Dean & Campus Administration',
        createdAt: now.subtract(const Duration(hours: 2)),
        category: 'Holiday',
        priority: 'Important',
        isNew: true,
        imageUrl: 'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=800',
      ),
      AnnouncementModel(
        id: 'ann_102',
        title: 'Off-Campus Placement & Internship Drive 2026',
        content: 'Registrations are open for the upcoming Off-Campus Placement & Internship Drive hosted by Google, Microsoft, and Cognizant. Eligible 3rd & 4th-year students must register before 14th August.',
        authorName: 'Career Guidance & Placement Cell',
        createdAt: now.subtract(const Duration(hours: 6)),
        category: 'Placement',
        priority: 'Urgent',
        isNew: true,
        relatedLinks: ['https://placement.unisphere.edu/apply-2026'],
      ),
      AnnouncementModel(
        id: 'ann_103',
        title: 'UNISPHERE Annual Cultural Fest 2026 Registrations Open',
        content: 'Registrations are now open for UNISPHERE Cultural Fest 2026! Participate in music, dance, coding battles, and dramatic events. Cash prizes worth ₹500,000.',
        authorName: 'Student Activity & Cultural Council',
        createdAt: now.subtract(const Duration(days: 1)),
        category: 'Event',
        priority: 'Normal',
        isNew: false,
        readByUsers: [_currentUserId],
      ),
      AnnouncementModel(
        id: 'ann_104',
        title: 'End-Semester Exam Schedule & Hall Ticket Download',
        content: 'The final exam schedule is published. Students can download digital hall tickets from the examination portal starting 12th August.',
        authorName: 'Office of Controller of Examinations',
        createdAt: now.subtract(const Duration(days: 2)),
        category: 'Examination',
        priority: 'Urgent',
        isNew: false,
        readByUsers: [_currentUserId],
      ),
      AnnouncementModel(
        id: 'ann_105',
        title: 'Library 24/7 Access During Exam Preparation',
        content: 'Central Library will remain open 24/7 starting next Monday to assist students during end-semester examination preparation.',
        authorName: 'Central Library Administration',
        createdAt: now.subtract(const Duration(days: 3)),
        category: 'Academic',
        priority: 'Normal',
        isNew: false,
        readByUsers: [_currentUserId],
      ),
    ]);
  }

  List<AnnouncementModel> getFilteredAnnouncements({
    String? category,
    bool unreadOnly = false,
    bool importantOnly = false,
    String? searchQuery,
  }) {
    return _announcements.where((ann) {
      final matchesCategory = category == null || category == 'All' || ann.category == category;
      final matchesUnread = !unreadOnly || !ann.isReadBy(_currentUserId);
      final matchesImportant = !importantOnly || ann.priority == 'Important' || ann.priority == 'Urgent';

      final query = searchQuery?.toLowerCase().trim() ?? '';
      final matchesSearch = query.isEmpty ||
          ann.title.toLowerCase().contains(query) ||
          ann.content.toLowerCase().contains(query) ||
          ann.authorName.toLowerCase().contains(query);

      return matchesCategory && matchesUnread && matchesImportant && matchesSearch;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Newest first
  }

  void markAsRead(String announcementId) {
    final index = _announcements.indexWhere((a) => a.id == announcementId);
    if (index != -1 && !_announcements[index].isReadBy(_currentUserId)) {
      _announcements[index] = _announcements[index].markReadFor(_currentUserId);
      notifyListeners();
    }
  }

  void addAnnouncement(AnnouncementModel announcement) {
    _announcements.insert(0, announcement);
    notifyListeners();
  }

  List<String> get availableCategories => [
        'All',
        'General',
        'Academic',
        'Examination',
        'Department',
        'Placement',
        'Internship',
        'Event',
        'Holiday',
        'Emergency',
        'Fee / Administration',
      ];
}
