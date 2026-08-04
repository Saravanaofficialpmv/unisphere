import 'package:flutter/material.dart';
import 'package:clg_application/core/constants/app_colors.dart';

class HodAnnouncements extends StatefulWidget {
  const HodAnnouncements({super.key});

  @override
  State<HodAnnouncements> createState() => _HodAnnouncementsState();
}

class _HodAnnouncementsState extends State<HodAnnouncements> {
  String _selectedCategory = 'Department Notice';
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _pinAnnouncement = false;
  bool _notifyParents = true;

  final List<Map<String, String>> _announcements = [
    {
      'title': 'Mid-Term Practical Schedule Published',
      'category': 'Examination Notice',
      'date': 'Today, 10:30 AM',
      'target': 'All Students & Faculty',
      'content': 'Practical examinations for 3rd Year CSE will commence from 18th August. Detailed batch lists are posted on notice boards.',
    },
    {
      'title': 'Google Cloud Campus Placement Drive',
      'category': 'Placement Notice',
      'date': 'Yesterday',
      'target': '4th Year Students',
      'content': 'Pre-placement talk by Google Engineers on Friday @ 2 PM in Main Auditorium.',
    },
    {
      'title': 'National Conference on AI & ML',
      'category': 'Seminar',
      'date': '02 Aug 2026',
      'target': 'Department Staff',
      'content': 'Call for papers extended till 15th August for all CSE faculty members.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'DEPARTMENT BROADCAST HUB',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.2),
            ),
            const SizedBox(height: 4),
            const Text(
              'Announcements & Circulars',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 20),
            _buildCreateAnnouncementForm(),
            const SizedBox(height: 28),
            const Text(
              'RECENT BROADCASTS',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 1.1),
            ),
            const SizedBox(height: 14),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _announcements.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final item = _announcements[index];
                return _buildAnnouncementTile(item);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateAnnouncementForm() {
    final categories = [
      'Department Notice',
      'Examination Notice',
      'Placement Notice',
      'Workshop',
      'Seminar',
      'Symposium',
      'Circular',
      'Holiday Notice',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Publish New Circular / Notice', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text('Select Category', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((cat) {
                final isSel = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSel ? AppColors.primary : AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(cat, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSel ? Colors.white : AppColors.textPrimary)),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'Announcement Title...',
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _contentController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Write announcement content or instructions here...',
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Checkbox(value: _pinAnnouncement, onChanged: (v) => setState(() => _pinAnnouncement = v!)),
              const Text('Pin to top of Dashboard', style: TextStyle(fontSize: 13)),
              const Spacer(),
              Checkbox(value: _notifyParents, onChanged: (v) => setState(() => _notifyParents = v!)),
              const Text('Notify Parents', style: TextStyle(fontSize: 13)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (_titleController.text.isEmpty) return;
                setState(() {
                  _announcements.insert(0, {
                    'title': _titleController.text,
                    'category': _selectedCategory,
                    'date': 'Just now',
                    'target': 'CSE Department',
                    'content': _contentController.text,
                  });
                  _titleController.clear();
                  _contentController.clear();
                });
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Announcement Published Successfully!'), backgroundColor: AppColors.success));
              },
              icon: const Icon(Icons.campaign_outlined, color: Colors.white),
              label: const Text('Publish Announcement', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementTile(Map<String, String> item) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: Text(item['category']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ),
              Text(item['date']!, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 10),
          Text(item['title']!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(item['content']!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
