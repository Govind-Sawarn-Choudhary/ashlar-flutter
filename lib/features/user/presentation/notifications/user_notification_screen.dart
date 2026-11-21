import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/features/user/data/user_premium_repository.dart';
import 'package:ashlar_lawyer_hub/features/user/data/user_repository.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/widgets/user_design_tokens.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/widgets/user_premium_widgets.dart';
import 'package:flutter/material.dart';

class UserNotificationScreen extends StatefulWidget {
  const UserNotificationScreen({super.key});

  @override
  State<UserNotificationScreen> createState() => _UserNotificationScreenState();
}

class _UserNotificationScreenState extends State<UserNotificationScreen> {
  List<UserNotificationItem> _items = [];
  bool _loading = true;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await loadUserNotifications();
      if (mounted) {
        setState(() {
          _items = items;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  List<UserNotificationItem> get _filtered {
    if (_tab == 1) {
      return _items.where((n) => !n.isRead).toList();
    }
    if (_tab == 2) {
      return _items.where((n) => n.isRead).toList();
    }
    return _items;
  }

  Future<void> _markRead(UserNotificationItem item) async {
    if (item.isRead) {
      return;
    }
    try {
      await UserRepository.instance.markNotificationRead(item.id);
      await _load();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  Future<void> _markAllRead() async {
    try {
      await UserRepository.instance.markAllNotificationsRead();
      await _load();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return UserPremiumScaffold(
      appBar: UserPremiumAppBar(
        title: 'Notifications',
        subtitle: 'Stay updated on your legal matters',
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: UserDesignTokens.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: _markAllRead,
            child: Text(
              'Mark all read',
              style: AppTypography.inter(
                color: UserDesignTokens.gold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                for (final (index, label) in [
                  (0, 'All'),
                  (1, 'Unread'),
                  (2, 'Read'),
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(label),
                      selected: _tab == index,
                      onSelected: (_) => setState(() => _tab = index),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: UserDesignTokens.gold),
                  )
                : _filtered.isEmpty
                    ? const UserEmptyState(
                        icon: Icons.notifications_none_outlined,
                        title: 'No notifications',
                        subtitle: 'Booking updates and alerts will appear here.',
                      )
                    : RefreshIndicator(
                        color: UserDesignTokens.gold,
                        onRefresh: _load,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = _filtered[index];
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _markRead(item),
                                borderRadius: BorderRadius.circular(
                                  UserDesignTokens.radiusMd,
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    color: item.isRead
                                        ? UserDesignTokens.surfaceElevated
                                        : UserDesignTokens.gold.withValues(
                                            alpha: 0.12,
                                          ),
                                    borderRadius: BorderRadius.circular(
                                      UserDesignTokens.radiusMd,
                                    ),
                                    border: Border.all(
                                      color: item.isRead
                                          ? UserDesignTokens.cardBorder
                                          : UserDesignTokens.gold
                                              .withValues(alpha: 0.35),
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: AppTypography.inter(
                                          fontWeight: FontWeight.w700,
                                          color: UserDesignTokens.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        item.body,
                                        style: AppTypography.inter(
                                          fontSize: 13,
                                          height: 1.4,
                                          color: UserDesignTokens.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
