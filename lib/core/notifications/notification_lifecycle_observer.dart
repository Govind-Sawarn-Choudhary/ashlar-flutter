import 'dart:async';

import 'package:ashlar_lawyer_hub/core/notifications/in_app_notification_coordinator.dart';
import 'package:ashlar_lawyer_hub/core/notifications/push_notification_service.dart';
import 'package:flutter/material.dart';

/// Polls unread count when app resumes (fallback when FCM is not configured yet).
class NotificationLifecycleObserver extends StatefulWidget {
  const NotificationLifecycleObserver({super.key, required this.child});

  final Widget child;

  @override
  State<NotificationLifecycleObserver> createState() =>
      _NotificationLifecycleObserverState();
}

class _NotificationLifecycleObserverState extends State<NotificationLifecycleObserver>
    with WidgetsBindingObserver {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_pollAll());
    _timer = Timer.periodic(const Duration(seconds: 18), (_) {
      unawaited(_pollAll());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_pollAll());
      unawaited(PushNotificationService.instance.syncTokenWithBackend());
    }
  }

  Future<void> _pollAll() async {
    await PushNotificationService.instance.pollUnreadCount();
    await InAppNotificationCoordinator.instance.pollInbox();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}