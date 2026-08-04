import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clg_application/core/constants/app_colors.dart';

class AnnouncementManagementModule extends ConsumerStatefulWidget {
  const AnnouncementManagementModule({super.key});

  @override
  ConsumerState<AnnouncementManagementModule> createState() => _AnnouncementManagementModuleState();
}

class _AnnouncementManagementModuleState extends ConsumerState<AnnouncementManagementModule> {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = ['All', 'College', 'Department', 'Class'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 24),
        _buildStatsSummary(),
        const SizedBox(height: 24),
        _buildActionRow(),
        const SizedBox(height: 16),
        _buildCategoryFilters(),
        const SizedBox(height: 24),
        _buildPinnedSection(),
        const SizedBox(height: 16),
        _buildRecentAnnouncements(),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('INSTITUTIONAL HUB', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
        const SizedBox(height: 4),
        const Text('Announcements', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildActionRow() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.add, size: 20),
        label: const Text('New Announcement'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildStatsSummary() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildStatCard('ACTIVE NOW', '24', Icons.check_circle, Colors.green),
          _buildStatCard('SCHEDULED', '08', Icons.calendar_month, Colors.orange),
          _buildStatCard('AVG. VIEWS', '1.2k', Icons.trending_up, Colors.blue),
          _buildStatCard('ENGAGEMENT', '84%', Icons.chat_bubble_outline, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border.withValues(alpha: 0.5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Icon(icon, size: 18, color: color),
            ],
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(_categories[index], style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.grey.shade700)),
              selected: isSelected,
              onSelected: (selected) => setState(() => _selectedCategoryIndex = index),
              selectedColor: Colors.blue.shade700,
              backgroundColor: Colors.grey.shade100,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              showCheckmark: false,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.transparent)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPinnedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.push_pin, size: 14, color: Colors.blue),
            SizedBox(width: 8),
            Text('PINNED NOTICES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue, letterSpacing: 1)),
          ],
        ),
        const SizedBox(height: 12),
        _buildPinnedNoticeCard(),
      ],
    );
  }

  Widget _buildPinnedNoticeCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(width: 4, decoration: BoxDecoration(color: Colors.blue.shade700, borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)))),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.blue.shade700, borderRadius: BorderRadius.circular(4)), child: const Text('ADMINISTRATIVE', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold))),
                        const Spacer(),
                        const Text('Posted 2 hours ago • Registrar\'s Office', style: TextStyle(fontSize: 9, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('Spring Semester 2024 Course Enrollment Final Deadline', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.3)),
                    const SizedBox(height: 8),
                    const Text('Please be advised that all students must finalize their course registration by February 15th. Failure to do so may result in penalty.', style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4)),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        TextButton(onPressed: () {}, child: const Text('View Full Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                        const SizedBox(width: 16),
                        TextButton(onPressed: () {}, child: const Text('Acknowledge', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAnnouncements() {
    return Column(
      children: [
        _buildRegistryCard('Innovation Summit 2024', 'EVENT', 'PUBLISHED', 'Dr. Sarah Jenkins', 'Jan 12, 2024'),
        const SizedBox(height: 16),
        _buildRegistryCard('Midterm Protocols Update', 'ACADEMIC', 'SCHEDULED', 'Academic Affairs', 'Jan 10, 2024'),
      ],
    );
  }

  Widget _buildRegistryCard(String title, String tag, String status, String author, String date) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)), child: Text(tag, style: const TextStyle(color: Colors.orange, fontSize: 8, fontWeight: FontWeight.bold))),
              Row(
                children: [
                  CircleAvatar(radius: 3, backgroundColor: status == 'PUBLISHED' ? Colors.green : Colors.orange),
                  const SizedBox(width: 4),
                  Text(status, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: status == 'PUBLISHED' ? Colors.green : Colors.orange)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              const CircleAvatar(radius: 12, backgroundColor: AppColors.background, child: Icon(Icons.person, size: 14)),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(author, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  Text(date, style: const TextStyle(fontSize: 9, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Edit', style: TextStyle(fontSize: 12)))),
              const SizedBox(width: 8),
              Expanded(child: OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Analytics', style: TextStyle(fontSize: 12)))),
              const SizedBox(width: 8),
              IconButton(onPressed: () {}, icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20)),
            ],
          ),
        ],
      ),
    );
  }
}
