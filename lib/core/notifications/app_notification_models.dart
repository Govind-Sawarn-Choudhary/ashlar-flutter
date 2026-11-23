import 'package:flutter/material.dart';

class AppNotificationItem {
  const AppNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    this.createdAt,
    this.category = 'general',
    this.actionType,
    this.actionId,
  });

  factory AppNotificationItem.fromJson(Map<String, dynamic> json) {
    return AppNotificationItem(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      isRead: json['isRead'] as bool? ?? false,
      createdAt: json['createdAt'] as String?,
      category: json['category'] as String? ?? 'general',
      actionType: json['actionType'] as String?,
      actionId: json['actionId'] as int?,
    );
  }

  final int id;
  final String title;
  final String body;
  final bool isRead;
  final String? createdAt;
  final String category;
  final String? actionType;
  final int? actionId;

  IconData get categoryIcon {
    switch (category) {
      case 'consultation':
        return Icons.video_chat_outlined;
      case 'booking':
        return Icons.event_available_outlined;
      case 'wallet':
        return Icons.account_balance_wallet_outlined;
      case 'document':
        return Icons.description_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  String groupLabel(DateTime now) {
    final created = _parseCreatedAt();
    if (created == null) {
      return 'Earlier';
    }
    final local = created.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final itemDay = DateTime(local.year, local.month, local.day);
    if (itemDay == today) {
      return 'Today';
    }
    if (itemDay == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    }
  if (now.difference(local).inDays < 7) {
      return 'This week';
    }
    return 'Earlier';
  }

  String? relativeTime(DateTime now) {
    final created = _parseCreatedAt();
    if (created == null) {
      return null;
    }
    final diff = now.difference(created.toLocal());
    if (diff.inMinutes < 1) {
      return 'Just now';
    }
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    }
    return null;
  }

  DateTime? _parseCreatedAt() {
    final raw = createdAt;
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }
}

List<({String label, List<AppNotificationItem> items})> groupNotifications(
  List<AppNotificationItem> items,
) {
  final now = DateTime.now();
  final buckets = <String, List<AppNotificationItem>>{};
  for (final item in items) {
    final key = item.groupLabel(now);
    buckets.putIfAbsent(key, () => []).add(item);
  }
  const order = ['Today', 'Yesterday', 'This week', 'Earlier'];
  return [
    for (final label in order)
      if (buckets.containsKey(label)) (label: label, items: buckets[label]!),
  ];
}