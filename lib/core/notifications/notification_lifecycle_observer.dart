import 'dart:async';

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
    unawaited(PushNotificationService.instance.pollUnreadCount());
    _timer = Timer.periodic(const Duration(seconds: 90), (_) {
      unawaited(PushNotificationService.instance.pollUnreadCount());
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
      unawaited(PushNotificationService.instance.pollUnreadCount());
      unawaited(PushNotificationService.instance.syncTokenWithBackend());
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}