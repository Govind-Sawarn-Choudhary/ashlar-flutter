import 'dart:async';

import 'package:ashlar_lawyer_hub/core/auth/auth_session.dart';
import 'package:ashlar_lawyer_hub/core/notifications/app_notification_models.dart';
import 'package:ashlar_lawyer_hub/core/notifications/notification_action_router.dart';
import 'package:ashlar_lawyer_hub/core/notifications/notification_inbox_notifier.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_marketplace_repository.dart';
import 'package:ashlar_lawyer_hub/features/user/data/user_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Foreground alerts (SolarX-style): poll inbox + show top banner for new items.
class InAppNotificationCoordinator extends ChangeNotifier {
  InAppNotificationCoordinator._();

  static final InAppNotificationCoordinator instance =
      InAppNotificationCoordinator._();

  AppNotificationItem? _banner;
  int _lastPresentedId = 0;
  Timer? _autoDismiss;

  AppNotificationItem? get banner => _banner;

  void present({
    required String title,
    required String body,
    String category = 'general',
    String? actionType,
    int? actionId,
    int? id,
  }) {
    final item = AppNotificationItem(
      id: id ?? DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: body,
      isRead: false,
      category: category,
      actionType: actionType,
      actionId: actionId,
    );
    if (id != null) {
      if (id <= _lastPresentedId) {
        return;
      }
      _lastPresentedId = id;
    }
    _banner = item;
    _autoDismiss?.cancel();
    _autoDismiss = Timer(const Duration(seconds: 6), dismiss);
    HapticFeedback.mediumImpact();
    notifyListeners();
  }

  void presentItem(AppNotificationItem item) {
    if (item.isRead) {
      return;
    }
    if (item.id <= _lastPresentedId) {
      return;
    }
    _lastPresentedId = item.id;
    _banner = item;
    _autoDismiss?.cancel();
    _autoDismiss = Timer(const Duration(seconds: 6), dismiss);
    HapticFeedback.mediumImpact();
    notifyListeners();
  }

  void dismiss() {
    _autoDismiss?.cancel();
    if (_banner == null) {
      return;
    }
    _banner = null;
    notifyListeners();
  }

  void onTap() {
    final item = _banner;
    dismiss();
    if (item == null) {
      return;
    }
    unawaited(_openFromBanner(item));
  }

  Future<void> _openFromBanner(AppNotificationItem item) async {
    final role = await AuthSession.instance.getRole() ?? 'user';
    if (item.id > 0 && !item.isRead) {
      try {
        if (role == 'lawyer') {
          await LawyerMarketplaceRepository.instance.markNotificationRead(item.id);
        } else {
          await UserRepository.instance.markNotificationRead(item.id);
        }
        NotificationInboxNotifier.instance.setUnread(
          (NotificationInboxNotifier.instance.unread - 1).clamp(0, 999),
        );
      } catch (_) {}
    }
    NotificationActionRouter.open(
      role: role,
      actionType: item.actionType,
      actionId: item.actionId,
    );
  }

  Future<void> pollInbox() async {
    final role = await AuthSession.instance.getRole();
    if (role == null) {
      return;
    }

    try {
      if (role == 'lawyer') {
        final inbox =
            await LawyerMarketplaceRepository.instance.fetchNotificationInbox();
        NotificationInboxNotifier.instance.setUnread(inbox.unreadCount);
        AppNotificationItem? newest;
        for (final n in inbox.items) {
          if (!n.isRead && (newest == null || n.id > newest.id)) {
            newest = n;
          }
        }
        if (newest != null && newest.id > _lastPresentedId) {
          presentItem(newest);
        }
      } else {
        final inbox = await UserRepository.instance.fetchNotificationInbox();
        NotificationInboxNotifier.instance.setUnread(inbox.unreadCount);
        final unread = inbox.items.where((n) => !n.isRead).toList();
        if (unread.isEmpty) {
          return;
        }
        unread.sort((a, b) => b.id.compareTo(a.id));
        final newest = unread.first;
        if (newest.id > _lastPresentedId) {
          presentItem(newest);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[InAppNotify] poll failed: $e');
      }
    }
  }
}