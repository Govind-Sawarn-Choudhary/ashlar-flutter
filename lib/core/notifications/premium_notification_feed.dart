import 'package:ashlar_lawyer_hub/core/notifications/app_notification_models.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

typedef NotificationTap = void Function(AppNotificationItem item);

/// YouTube-style grouped notification list with category avatars and relative time.
class PremiumNotificationFeed extends StatelessWidget {
  const PremiumNotificationFeed({
    super.key,
    required this.items,
    required this.onTap,
    this.titleStyle,
    this.subtitleColor,
    this.dividerColor,
    this.accentColor = AppColors.gold,
    this.surfaceColor,
    this.unreadSurfaceColor,
  });

  final List<AppNotificationItem> items;
  final NotificationTap onTap;
  final TextStyle? titleStyle;
  final Color? subtitleColor;
  final Color? dividerColor;
  final Color accentColor;
  final Color? surfaceColor;
  final Color? unreadSurfaceColor;

  @override
  Widget build(BuildContext context) {
    final groups = groupNotifications(items);
    final now = DateTime.now();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: groups.length,
      itemBuilder: (context, groupIndex) {
        final group = groups[groupIndex];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (groupIndex > 0) const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
              child: Text(
                group.label,
                style: AppTypography.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: subtitleColor ?? Colors.white70,
                ),
              ),
            ),
            ...group.items.map(
              (item) => _NotificationTile(
                item: item,
                now: now,
                accentColor: accentColor,
                titleStyle: titleStyle,
                subtitleColor: subtitleColor,
                surfaceColor: surfaceColor,
                unreadSurfaceColor: unreadSurfaceColor,
                onTap: () => onTap(item),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.item,
    required this.now,
    required this.onTap,
    required this.accentColor,
    this.titleStyle,
    this.subtitleColor,
    this.surfaceColor,
    this.unreadSurfaceColor,
  });

  final AppNotificationItem item;
  final DateTime now;
  final VoidCallback onTap;
  final Color accentColor;
  final TextStyle? titleStyle;
  final Color? subtitleColor;
  final Color? surfaceColor;
  final Color? unreadSurfaceColor;

  @override
  Widget build(BuildContext context) {
    final timeLabel = item.relativeTime(now);
    final bg = item.isRead
        ? (surfaceColor ?? const Color(0xFF1E1E22))
        : (unreadSurfaceColor ?? accentColor.withValues(alpha: 0.14));

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: item.isRead
                    ? Colors.white12
                    : accentColor.withValues(alpha: 0.35),
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: accentColor.withValues(alpha: 0.2),
                      child: Icon(item.categoryIcon, color: accentColor, size: 22),
                    ),
                    if (!item.isRead)
                      Positioned(
                        right: -1,
                        top: -1,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: accentColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 1.5),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
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
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: titleStyle ??
                                  AppTypography.inter(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                            ),
                          ),
                          if (timeLabel != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              timeLabel,
                              style: AppTypography.inter(
                                fontSize: 11,
                                color: subtitleColor ?? Colors.white54,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.body,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.inter(
                          fontSize: 13,
                          height: 1.35,
                          color: subtitleColor ?? Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}