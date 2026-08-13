import 'dart:async';
import 'package:flutter/material.dart';
import 'package:unisphere/models/announcement_model.dart';
import 'package:unisphere/services/firebase_firestore_service.dart';

class AnnouncementService extends ChangeNotifier {
  static final AnnouncementService _instance = AnnouncementService._internal();
  factory AnnouncementService() => _instance;

  StreamSubscription<List<AnnouncementModel>>? _subscription;

  AnnouncementService._internal() {
    _initSeedAnnouncements();
    _connectFirestoreStream();
  }

  final List<AnnouncementModel> _announcements = [];
  final String _currentUserId = 'std_alex_01'; // Default student ID

  List<AnnouncementModel> get announcements => List.unmodifiable(_announcements);

  int get unreadCount => _announcements.where((a) => !a.isReadBy(_currentUserId)).length;

  void _connectFirestoreStream() {
    try {
      final firestoreService = FirebaseFirestoreService();
      _subscription = firestoreService.getAnnouncements().listen(
        (list) {
          if (list.isNotEmpty) {
            _announcements.clear();
            _announcements.addAll(list);
            notifyListeners();
          }
        },
        onError: (e) {
          debugPrint('AnnouncementService stream error: $e');
        },
      );
    } catch (e) {
      debugPrint('AnnouncementService connect error: $e');
    }
  }

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
        content: 'Registrations are now open for UNISPHERE Cultural Fest 2026! Participate in music, dance, coding battles, and dramatic events.',
        authorName: 'Student Activity & Cultural Council',
        createdAt: now.subtract(const Duration(days: 1)),
        category: 'Event',
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
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void markAsRead(String announcementId) {
    final index = _announcements.indexWhere((a) => a.id == announcementId);
    if (index != -1 && !_announcements[index].isReadBy(_currentUserId)) {
      _announcements[index] = _announcements[index].markReadFor(_currentUserId);
      notifyListeners();
      FirebaseFirestoreService().markAnnouncementRead(announcementId, _currentUserId);
    }
  }

  void addAnnouncement(AnnouncementModel announcement) {
    _announcements.insert(0, announcement);
    notifyListeners();
    FirebaseFirestoreService().addAnnouncement(announcement);
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

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
