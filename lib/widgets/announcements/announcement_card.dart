import 'package:flutter/material.dart';
import 'package:clg_application/models/announcement_model.dart';
import 'package:intl/intl.dart';

class AnnouncementCard extends StatelessWidget {
  final AnnouncementModel announcement;
  final String currentUserId;
  final VoidCallback onTap;

  const AnnouncementCard({
    super.key,
    required this.announcement,
    this.currentUserId = 'std_alex_01',
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = !announcement.isReadBy(currentUserId);
    final isUrgent = announcement.priority == 'Urgent';

    Color categoryBg = const Color(0xFFEFF6FF);
    Color categoryText = const Color(0xFF2563EB);
    IconData categoryIcon = Icons.campaign_rounded;

    if (announcement.category == 'Examination') {
      categoryBg = const Color(0xFFFEF2F2);
      categoryText = const Color(0xFFDC2626);
      categoryIcon = Icons.assignment_late_rounded;
    } else if (announcement.category == 'Placement' || announcement.category == 'Internship') {
      categoryBg = const Color(0xFFE0F2FE);
      categoryText = const Color(0xFF0284C7);
      categoryIcon = Icons.work_rounded;
    } else if (announcement.category == 'Event') {
      categoryBg = const Color(0xFFF3E8FF);
      categoryText = const Color(0xFF7C3AED);
      categoryIcon = Icons.emoji_events_rounded;
    } else if (announcement.category == 'Holiday') {
      categoryBg = const Color(0xFFFEF3C7);
      categoryText = const Color(0xFFD97706);
      categoryIcon = Icons.beach_access_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        color: isUnread ? Colors.white : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isUrgent
              ? const Color(0xFFEF4444)
              : (isUnread ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0)),
          width: isUrgent ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isUrgent ? const Color(0xFFEF4444).withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: categoryBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(categoryIcon, size: 14, color: categoryText),
                          const SizedBox(width: 4),
                          Text(
                            announcement.category ?? 'General',
                            style: TextStyle(color: categoryText, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    if (isUrgent) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'URGENT',
                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (isUnread)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  announcement.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isUnread ? FontWeight.w800 : FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  announcement.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.person_rounded, size: 14, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        announcement.authorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('MMM dd · hh:mm a').format(announcement.createdAt),
                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
