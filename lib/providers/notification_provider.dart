import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationItem {
  final String id;
  final String title;
  final String category; // 'Features', 'Academic', 'Events', 'Alerts', 'Finance'
  final String timeAgo;
  final String summary;
  final String fullDetails;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String badgeText;
  final Color badgeColor;
  final Color badgeTextColor;
  final bool isUnread;
  final String? featureId; // Map to FeatureRegistry ID
  final Map<String, String>? metadata;

  NotificationItem({
    required this.id,
    required this.title,
    required this.category,
    required this.timeAgo,
    required this.summary,
    required this.fullDetails,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.badgeText,
    required this.badgeColor,
    required this.badgeTextColor,
    this.isUnread = true,
    this.featureId,
    this.metadata,
  });

  NotificationItem copyWith({bool? isUnread}) {
    return NotificationItem(
      id: id,
      title: title,
      category: category,
      timeAgo: timeAgo,
      summary: summary,
      fullDetails: fullDetails,
      icon: icon,
      iconColor: iconColor,
      iconBgColor: iconBgColor,
      badgeText: badgeText,
      badgeColor: badgeColor,
      badgeTextColor: badgeTextColor,
      isUnread: isUnread ?? this.isUnread,
      featureId: featureId,
      metadata: metadata,
    );
  }
}

class NotificationState {
  final List<NotificationItem> items;
  final String selectedCategory;
  final String searchQuery;

  NotificationState({
    required this.items,
    this.selectedCategory = 'All',
    this.searchQuery = '',
  });

  int get unreadCount => items.where((item) => item.isUnread).length;

  List<NotificationItem> get filteredItems {
    return items.where((item) {
      final matchesCategory = selectedCategory == 'All' || item.category == selectedCategory;
      final matchesSearch = searchQuery.isEmpty ||
          item.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.summary.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.fullDetails.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.category.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  NotificationState copyWith({
    List<NotificationItem>? items,
    String? selectedCategory,
    String? searchQuery,
  }) {
    return NotificationState(
      items: items ?? this.items,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier() : super(NotificationState(items: _initialNotifications));

  static final List<NotificationItem> _initialNotifications = [
    NotificationItem(
      id: 'notif_1',
      title: 'SRM Unisphere National Hackathon 2026 Live',
      category: 'Features',
      timeAgo: '10m ago',
      summary: 'Registration for SRM Unisphere Tech Fest 2026 is officially open!',
      fullDetails:
          'SRM Unisphere invites student developer teams to participate in the 2026 National Level Innovation Hackathon. Build AI, Mobile, and Web3 solutions to win cash prizes totaling ₹1,50,000, internship opportunities with top tech firms, and exclusive certificates of recognition.',
      icon: Icons.emoji_events_rounded,
      iconColor: const Color(0xFF7C3AED),
      iconBgColor: const Color(0xFFF3E8FF),
      badgeText: 'NEW FEATURE',
      badgeColor: const Color(0xFF7C3AED),
      badgeTextColor: Colors.white,
      isUnread: true,
      featureId: 'hackathons',
      metadata: {
        'Prize Pool': '₹1,50,000 Cash',
        'Team Size': '2 - 4 Members',
        'Deadline': 'August 25, 2026',
        'Venue': 'Tech Park Auditorium',
      },
    ),
    NotificationItem(
      id: 'notif_2',
      title: 'Mid-Semester Exam Seating & Timetable Published',
      category: 'Academic',
      timeAgo: '1h ago',
      summary: 'Autumn 2026 mid-term timetable and seating arrangements are live.',
      fullDetails:
          'The Academic Controller\'s office has finalized the mid-semester examination timetable for all B.Tech and M.Tech branches. Students can check their subject-wise exam dates, assigned hall numbers, and seating slots directly in the Gradebook module.',
      icon: Icons.calendar_month_rounded,
      iconColor: const Color(0xFF059669),
      iconBgColor: const Color(0xFFD1FAE5),
      badgeText: 'ACTION REQUIRED',
      badgeColor: const Color(0xFF059669),
      badgeTextColor: Colors.white,
      isUnread: true,
      featureId: 'gradebook',
      metadata: {
        'Exam Dates': 'Sept 5 - Sept 15, 2026',
        'Hall Ticket': 'Download Active',
        'Seating Plan': 'Main Block Floor 2-4',
      },
    ),
    NotificationItem(
      id: 'notif_3',
      title: 'Semester 5 Tuition Fee Payment Link Active',
      category: 'Finance',
      timeAgo: '3h ago',
      summary: 'Pay tuition & hostel fees online with zero processing fee.',
      fullDetails:
          'The official online payment portal for Semester 5 tuition, laboratory, and library fees is now active on Unisphere. Flexible payment options include UPI, NetBanking, Credit/Debit cards, and 0% interest EMI options. E-Receipts are issued instantly.',
      icon: Icons.account_balance_wallet_rounded,
      iconColor: const Color(0xFFEA580C),
      iconBgColor: const Color(0xFFFFEDD5),
      badgeText: 'IMPORTANT',
      badgeColor: const Color(0xFFEA580C),
      badgeTextColor: Colors.white,
      isUnread: true,
      featureId: 'fees',
      metadata: {
        'Due Date': 'August 20, 2026',
        'Late Charge': '₹500 / week post deadline',
        'Portal': 'Unisphere Pay Instant',
      },
    ),
    NotificationItem(
      id: 'notif_4',
      title: 'Attendance Alert: CS302 Data Structures',
      category: 'Alerts',
      timeAgo: '5h ago',
      summary: 'Your attendance in CS302 is currently 78% (80% mandatory).',
      fullDetails:
          'Attendance Warning Notice: You have attended 25 out of 32 sessions in CS302 Data Structures & Algorithms. SRM University regulations mandate a minimum of 80% attendance to be eligible for end-semester examinations. You need to attend the next 4 consecutive lectures to reach safety.',
      icon: Icons.warning_amber_rounded,
      iconColor: const Color(0xFFDC2626),
      iconBgColor: const Color(0xFFFEE2E2),
      badgeText: 'URGENT',
      badgeColor: const Color(0xFFDC2626),
      badgeTextColor: Colors.white,
      isUnread: true,
      featureId: 'gradebook',
      metadata: {
        'Current Level': '78%',
        'Required Level': '80% Mandatory',
        'Classes Attended': '25 / 32 Sessions',
        'Classes Needed': '4 Consecutive Classes',
      },
    ),
    NotificationItem(
      id: 'notif_5',
      title: 'Subsidized AWS & GCP Certification Vouchers',
      category: 'Features',
      timeAgo: '1d ago',
      summary: '80% discount vouchers for Cloud Certifications available.',
      fullDetails:
          'SRM Center of Excellence has partnered with AWS and Google Cloud to offer 80% subsidized certification vouchers for AWS Solutions Architect & GCP Digital Leader exams. Free practice test vouchers and learning paths are available in the Certifications tab.',
      icon: Icons.card_membership_rounded,
      iconColor: const Color(0xFF2563EB),
      iconBgColor: const Color(0xFFEFF6FF),
      badgeText: 'NEW FEATURE',
      badgeColor: const Color(0xFF2563EB),
      badgeTextColor: Colors.white,
      isUnread: true,
      featureId: 'certifications',
      metadata: {
        'Discount': '80% Off Vouchers',
        'Vouchers Available': '120 Remaining',
        'Providers': 'AWS & Google Cloud',
      },
    ),
    NotificationItem(
      id: 'notif_6',
      title: 'Semester 4 Dean\'s Honor Roll Awarded',
      category: 'Academic',
      timeAgo: '2d ago',
      summary: 'Dean\'s List badge and merit certificate issued to your profile.',
      fullDetails:
          'Congratulations! Based on your outstanding academic performance in Semester 4 (SGPA >= 9.00), you have been awarded the Dean\'s Honor Roll distinction. Your digital merit badge is now displayed on your student profile and achievements tab.',
      icon: Icons.workspace_premium_rounded,
      iconColor: const Color(0xFFD97706),
      iconBgColor: const Color(0xFFFEF3C7),
      badgeText: 'HONOR ROLL',
      badgeColor: const Color(0xFFD97706),
      badgeTextColor: Colors.white,
      isUnread: false,
      featureId: 'achievements',
      metadata: {
        'Semester': 'Semester 4 Autumn',
        'Criteria': 'SGPA >= 9.00',
        'Award': 'Dean\'s Merit Certificate',
      },
    ),
    NotificationItem(
      id: 'notif_7',
      title: 'Annual Campus Tech Symposium \'Unisphere 2026\'',
      category: 'Events',
      timeAgo: '3d ago',
      summary: '3-Day National Symposium event schedule & workshop registrations.',
      fullDetails:
          'SRM Campus is organizing Unisphere Fest 2026 featuring 40+ technical competitions, AI robotics showcases, esports tournaments, and keynote talks by industry leads. Register early to reserve workshop slots.',
      icon: Icons.event_rounded,
      iconColor: const Color(0xFF0891B2),
      iconBgColor: const Color(0xFFCFFAFE),
      badgeText: 'ANNOUNCEMENT',
      badgeColor: const Color(0xFF0891B2),
      badgeTextColor: Colors.white,
      isUnread: false,
      featureId: 'events',
      metadata: {
        'Event Dates': 'Sept 20 - Sept 22, 2026',
        'Venue': 'SRM Main Campus',
        'Registration': 'Open to All Branches',
      },
    ),
  ];

  void addNotification({
    required String title,
    required String category,
    required String summary,
    required String fullDetails,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String badgeText,
    required Color badgeColor,
    required Color badgeTextColor,
    String? featureId,
    Map<String, String>? metadata,
  }) {
    final newItem = NotificationItem(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      category: category,
      timeAgo: 'Just now',
      summary: summary,
      fullDetails: fullDetails,
      icon: icon,
      iconColor: iconColor,
      iconBgColor: iconBgColor,
      badgeText: badgeText,
      badgeColor: badgeColor,
      badgeTextColor: badgeTextColor,
      isUnread: true,
      featureId: featureId,
      metadata: metadata,
    );
    state = state.copyWith(items: [newItem, ...state.items]);
  }

  void setCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void markAsRead(String id) {
    final updatedItems = state.items.map((item) {
      if (item.id == id) {
        return item.copyWith(isUnread: false);
      }
      return item;
    }).toList();
    state = state.copyWith(items: updatedItems);
  }

  void markAllAsRead() {
    final updatedItems = state.items.map((item) => item.copyWith(isUnread: false)).toList();
    state = state.copyWith(items: updatedItems);
  }
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier();
});
