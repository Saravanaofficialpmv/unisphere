import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:clg_application/core/constants/app_colors.dart';
import 'package:clg_application/core/features/feature_registry.dart';
import 'package:clg_application/providers/notification_provider.dart';
import 'package:clg_application/screens/features/feature_hub_screen.dart';

void showNotificationSheet(
  BuildContext context, {
  Function(int index, {bool openCalculator})? onNavigateToTab,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (context) => NotificationSheet(onNavigateToTab: onNavigateToTab),
  );
}

class NotificationSheet extends ConsumerStatefulWidget {
  final Function(int index, {bool openCalculator})? onNavigateToTab;

  const NotificationSheet({super.key, this.onNavigateToTab});

  @override
  ConsumerState<NotificationSheet> createState() => _NotificationSheetState();
}

class _NotificationSheetState extends ConsumerState<NotificationSheet> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationProvider);
    final notifier = ref.read(notificationProvider.notifier);
    final unreadCount = state.unreadCount;
    final items = state.filteredItems;

    final categories = ['All', 'Features', 'Academic', 'Finance', 'Alerts', 'Events'];

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag Handle
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),

              // Header Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.notifications_active_rounded, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            runSpacing: 2,
                            children: [
                              Text(
                                'Notifications',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (unreadCount > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$unreadCount NEW',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Text(
                            'Feature releases, updates & notices',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (unreadCount > 0)
                      IconButton(
                        tooltip: 'Mark all as read',
                        icon: const Icon(Icons.done_all_rounded, size: 20, color: AppColors.primary),
                        onPressed: () => notifier.markAllAsRead(),
                      ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => notifier.setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Search notification feature details...',
                    hintStyle: GoogleFonts.poppins(fontSize: 13, color: AppColors.textTertiary),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textSecondary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              notifier.setSearchQuery('');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Filter Category Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: categories.map((cat) {
                    final isSelected = state.selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(cat),
                        labelStyle: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                        backgroundColor: const Color(0xFFF1F5F9),
                        selectedColor: AppColors.primary,
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : AppColors.border,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        onSelected: (_) => notifier.setCategory(cat),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const Divider(height: 24, thickness: 1, color: AppColors.border),

              // Notification List
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.notifications_off_outlined, size: 48, color: AppColors.textTertiary),
                            const SizedBox(height: 12),
                            Text(
                              'No notifications found',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Try adjusting your search or category filter',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        itemCount: items.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _buildNotificationCard(context, item, ref);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationItem item, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showFeatureDetailsModal(context, item, ref),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: item.isUnread ? item.iconBgColor.withValues(alpha: 0.25) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: item.isUnread ? item.iconColor.withValues(alpha: 0.4) : AppColors.border,
              width: item.isUnread ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: item.iconBgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.icon, color: item.iconColor, size: 24),
              ),
              const SizedBox(width: 14),

              // Content Area
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: item.isUnread ? FontWeight.bold : FontWeight.w600,
                              color: AppColors.textPrimary,
                              height: 1.3,
                            ),
                          ),
                        ),
                        if (item.isUnread) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 9,
                            height: 9,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Badge Tag + Category + Time Row
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: item.badgeColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.badgeText,
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: item.badgeTextColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Text(
                          '•  ${item.category}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '•  ${item.timeAgo}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Summary preview
                    Text(
                      item.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Action hint line
                    Row(
                      children: [
                        Text(
                          'Tap to view feature details',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: item.iconColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 14, color: item.iconColor),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFeatureDetailsModal(BuildContext context, NotificationItem item, WidgetRef ref) {
    // Mark notification as read upon opening feature details
    ref.read(notificationProvider.notifier).markAsRead(item.id);

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 540),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Banner
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: item.iconBgColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(item.icon, color: item.iconColor, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: item.badgeColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.badgeText,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: item.badgeTextColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.title,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item.category}  •  ${item.timeAgo}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const Divider(height: 1, thickness: 1, color: AppColors.border),
                const SizedBox(height: 20),

                // Feature Full Details Section
                Text(
                  'Feature Description & Details',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    item.fullDetails,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),

                // Key Metadata Grid (if available)
                if (item.metadata != null && item.metadata!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Key Feature Information',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: item.metadata!.entries.map((entry) {
                      return Container(
                        width: (MediaQuery.of(dialogContext).size.width > 500 ? 230 : 140),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key.toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textTertiary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              entry.value,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: const BorderSide(color: AppColors.border),
                        ),
                        child: Text(
                          'Close',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    if (item.featureId != null) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(dialogContext).pop(); // close feature details dialog
                            Navigator.of(context).pop(); // close notification sheet

                            _launchFeature(context, item.featureId!);
                          },
                          icon: const Icon(Icons.rocket_launch_rounded, size: 18),
                          label: Text(
                            'Open Feature',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: item.iconColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _launchFeature(BuildContext context, String featureId) {
    if (featureId == 'gradebook') {
      if (widget.onNavigateToTab != null) {
        widget.onNavigateToTab!(4); // Gradebook tab
        return;
      }
    } else if (featureId == 'timetable') {
      if (widget.onNavigateToTab != null) {
        widget.onNavigateToTab!(1); // Timetable tab
        return;
      }
    } else if (featureId == 'attendance') {
      if (widget.onNavigateToTab != null) {
        widget.onNavigateToTab!(3); // Attendance tab
        return;
      }
    }

    final allFeatures = FeatureRegistry.getAllFeatures();
    final match = allFeatures.where((f) => f.id == featureId);

    if (match.isNotEmpty) {
      final feature = match.first;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => feature.routeBuilder(ctx),
        ),
      );
    } else {
      // Fallback to Feature Hub Screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => FeatureHubScreen(
            onNavigateToTab: widget.onNavigateToTab,
          ),
        ),
      );
    }
  }
}
