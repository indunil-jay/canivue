import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:canivue/core/theme/app_theme.dart';
import 'package:canivue/core/widgets/app_feedback.dart';
import 'package:canivue/features/notifications/models/notification_item.dart';
import 'package:canivue/features/notifications/services/notification_service.dart';

class NotificationSheet extends StatefulWidget {
  const NotificationSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => const NotificationSheet(),
    );
  }

  @override
  State<NotificationSheet> createState() => _NotificationSheetState();
}

class _NotificationSheetState extends State<NotificationSheet> {
  final NotificationService _service = NotificationService();
  String _selectedFilter = 'All'; // 'All', 'Unread', 'AI Health', 'Reminders'

  /// Categories the user has expanded out of their grouped "N new X" summary
  /// (brief §25 — group notifications rather than listing every one).
  final Set<String> _expandedCategories = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.sizeOf(context);

    return AnimatedBuilder(
      animation: _service,
      builder: (context, _) {
        final allNotifs = _service.notifications;
        final unreadCount = _service.unreadCount;

        List<NotificationItem> filteredList = allNotifs;
        if (_selectedFilter == 'Unread') {
          filteredList = allNotifs.where((n) => !n.isRead).toList();
        } else if (_selectedFilter == 'AI Health') {
          filteredList = allNotifs.where((n) => n.type == NotificationType.aiHealthAlert).toList();
        } else if (_selectedFilter == 'Reminders') {
          filteredList = allNotifs.where((n) => n.type == NotificationType.vaccineReminder || n.type == NotificationType.vetAppointment).toList();
        }

        return Container(
          height: size.height * 0.82,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.96) : Colors.white.withValues(alpha: 0.98),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.2),
                blurRadius: 36,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Column(
                children: [
                  // Top Drag Handle Bar
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.25) : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Header with Title, Unread Count & Mark All Read
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Notifications',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                                letterSpacing: -0.5,
                              ),
                            ),
                            if (unreadCount > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryBlue.withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '$unreadCount new',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Row(
                          children: [
                            if (unreadCount > 0)
                              TextButton.icon(
                                onPressed: () {
                                  _service.markAllAsRead();
                                  AppFeedback.showToast(
                                    context,
                                    title: 'All Caught Up! ✨',
                                    message: 'All notifications marked as read',
                                    type: ToastType.success,
                                  );
                                },
                                icon: const Icon(Icons.done_all_rounded, size: 18),
                                label: Text(
                                  'Mark all read',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: isDark ? AppTheme.cyanAccent : AppTheme.primaryBlue,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 22),
                              color: isDark ? Colors.white70 : const Color(0xFF64748B),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Filter Chips
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _FilterChip(
                            label: 'All (${allNotifs.length})',
                            isSelected: _selectedFilter == 'All',
                            isDark: isDark,
                            onTap: () => setState(() => _selectedFilter = 'All'),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Unread ($unreadCount)',
                            isSelected: _selectedFilter == 'Unread',
                            isDark: isDark,
                            onTap: () => setState(() => _selectedFilter = 'Unread'),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'AI Health',
                            isSelected: _selectedFilter == 'AI Health',
                            isDark: isDark,
                            onTap: () => setState(() => _selectedFilter = 'AI Health'),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Reminders',
                            isSelected: _selectedFilter == 'Reminders',
                            isDark: isDark,
                            onTap: () => setState(() => _selectedFilter = 'Reminders'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Divider(
                    color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFF1F5F9),
                    thickness: 1,
                  ),

                  // Notification Activity Feed List — grouped by category so
                  // e.g. 3 health alerts show as one "3 new" summary rather
                  // than three separate cards (brief §25).
                  Expanded(
                    child: filteredList.isEmpty
                        ? _buildEmptyState(isDark)
                        : Builder(builder: (context) {
                            final categoryOrder = <String>[];
                            final byCategory = <String, List<NotificationItem>>{};
                            for (final item in filteredList) {
                              if (!byCategory.containsKey(item.category)) categoryOrder.add(item.category);
                              byCategory.putIfAbsent(item.category, () => []).add(item);
                            }

                            return ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                              physics: const BouncingScrollPhysics(),
                              itemCount: categoryOrder.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final category = categoryOrder[index];
                                final items = byCategory[category]!;

                                if (items.length == 1) {
                                  final item = items.first;
                                  return _NotificationCard(
                                    item: item,
                                    isDark: isDark,
                                    onDismissed: () => _service.removeNotification(item.id),
                                    onTap: () {
                                      _service.markAsRead(item.id);
                                      AppFeedback.showToast(context, title: item.title, message: item.message, type: ToastType.info);
                                    },
                                  );
                                }

                                if (!_expandedCategories.contains(category)) {
                                  final unread = items.where((n) => !n.isRead).length;
                                  return _GroupSummaryTile(
                                    category: category,
                                    items: items,
                                    unreadCount: unread,
                                    isDark: isDark,
                                    onTap: () => setState(() => _expandedCategories.add(category)),
                                  );
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8, left: 4),
                                      child: TextButton.icon(
                                        onPressed: () => setState(() => _expandedCategories.remove(category)),
                                        icon: const Icon(Icons.unfold_less_rounded, size: 16),
                                        label: Text('Collapse $category'),
                                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                                      ),
                                    ),
                                    for (final item in items)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 10),
                                        child: _NotificationCard(
                                          item: item,
                                          isDark: isDark,
                                          onDismissed: () => _service.removeNotification(item.id),
                                          onTap: () {
                                            _service.markAsRead(item.id);
                                            AppFeedback.showToast(context, title: item.title, message: item.message, type: ToastType.info);
                                          },
                                        ),
                                      ),
                                  ],
                                );
                              },
                            );
                          }),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF1F5F9),
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 40,
                color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Notifications',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'You’re all caught up with your canine health telemetry.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: isDark ? Colors.white70 : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppTheme.primaryBlue.withValues(alpha: 0.3) : const Color(0xFFEFF6FF))
              : (isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppTheme.cyanAccent : AppTheme.primaryBlue)
                : (isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFE2E8F0)),
            width: isSelected ? 1.4 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? (isDark ? Colors.white : AppTheme.primaryBlue)
                : (isDark ? Colors.white70 : const Color(0xFF64748B)),
          ),
        ),
      ),
    );
  }
}

/// Collapsed "N new X" row for a category with more than one notification
/// (brief §25) — tapping expands it into the individual cards.
class _GroupSummaryTile extends StatelessWidget {
  const _GroupSummaryTile({
    required this.category,
    required this.items,
    required this.unreadCount,
    required this.isDark,
    required this.onTap,
  });

  final String category;
  final List<NotificationItem> items;
  final int unreadCount;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = items.first.accentColor;
    final label = unreadCount > 0 ? '$unreadCount new $category' : '${items.length} $category';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : accent.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : accent.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(color: accent.withValues(alpha: isDark ? 0.25 : 0.15), shape: BoxShape.circle),
              child: Icon(items.first.icon, color: accent, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A)),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white54 : const Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.item,
    required this.isDark,
    required this.onTap,
    required this.onDismissed,
  });

  final NotificationItem item;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    final cardBg = item.isRead
        ? (isDark ? const Color(0xFF1E293B).withValues(alpha: 0.6) : Colors.white)
        : (isDark ? const Color(0xFF0066FF).withValues(alpha: 0.14) : const Color(0xFFEFF6FF));

    final borderColor = item.isRead
        ? (isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF1F5F9))
        : (isDark ? AppTheme.primaryBlue.withValues(alpha: 0.4) : const Color(0xFFBFDBFE));

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed(),
      background: Container(
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: const Color(0xFFF43F5E),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: item.isRead
                ? null
                : [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: isDark ? 0.15 : 0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Medallion with Overlay Type Emblem
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          item.accentColor.withValues(alpha: 0.25),
                          item.accentColor.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: item.accentColor.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        item.petName.isNotEmpty ? item.petName[0] : '🐾',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: item.accentColor,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3.5),
                      decoration: BoxDecoration(
                        color: item.accentColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? const Color(0xFF0F172A) : Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        item.icon,
                        size: 11,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Notification Title & Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                              fontSize: 14.5,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                              height: 1.25,
                            ),
                          ),
                        ),
                        if (!item.isRead) ...[
                          const SizedBox(width: 6),
                          Container(
                            height: 9,
                            width: 9,
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.message,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: isDark ? Colors.white.withValues(alpha: 0.8) : const Color(0xFF475569),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Timestamp & Action Button Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${item.timeAgo} • ${item.petName}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                          ),
                        ),
                        if (item.actionLabel != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: item.accentColor.withValues(alpha: isDark ? 0.2 : 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: item.accentColor.withValues(alpha: isDark ? 0.35 : 0.25),
                              ),
                            ),
                            child: Text(
                              item.actionLabel!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: item.accentColor,
                              ),
                            ),
                          ),
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
}

