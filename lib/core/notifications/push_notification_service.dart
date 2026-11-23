import 'dart:async';

import 'package:ashlar_lawyer_hub/core/auth/auth_session.dart';
import 'package:ashlar_lawyer_hub/core/network/api_client.dart';
import 'package:ashlar_lawyer_hub/core/notifications/notification_action_router.dart';
import 'package:ashlar_lawyer_hub/core/notifications/notification_inbox_notifier.dart';
import 'package:ashlar_lawyer_hub/core/notifications/push_background.dart';
import 'package:ashlar_lawyer_hub/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// FCM + local notifications (foreground) + backend token sync.
class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'ashlar_alerts',
    'Ashlar alerts',
    description: 'Booking, consultation, and wallet updates',
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  bool _ready = false;
  String? _cachedToken;

  Future<void> bootstrap() async {
    if (_ready) {
      return;
    }

    await _initLocalNotifications();

    if (!DefaultFirebaseOptions.isConfigured) {
      if (kDebugMode) {
        debugPrint(
          '[Push] Firebase dart-defines not set — in-app + polling only until FIREBASE_SETUP.',
        );
      }
      _ready = true;
      return;
    }

    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);

      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      FirebaseMessaging.onMessage.listen(_onForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_onOpenedApp);

      final initial = await messaging.getInitialMessage();
      if (initial != null) {
        _handleOpenPayload(initial.data);
      }

      messaging.onTokenRefresh.listen((token) {
        _cachedToken = token;
        unawaited(syncTokenWithBackend());
      });

      _ready = true;
      await syncTokenWithBackend();
    } catch (error, stack) {
      if (kDebugMode) {
        debugPrint('[Push] init failed: $error\n$stack');
      }
      _ready = true;
    }
  }

  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _local.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) {
          return;
        }
        unawaited(_openFromPayload(payload));
      },
    );

    final androidPlugin = _local.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_channel);
  }

  Future<void> syncTokenWithBackend() async {
    final role = await AuthSession.instance.getRole();
    final token = await AuthSession.instance.getToken();
    if (role == null || token == null || token.isEmpty) {
      return;
    }

    if (!DefaultFirebaseOptions.isConfigured) {
      return;
    }

    try {
      final messaging = FirebaseMessaging.instance;
      final fcmToken = _cachedToken ?? await messaging.getToken();
      if (fcmToken == null || fcmToken.isEmpty) {
        return;
      }
      _cachedToken = fcmToken;

      final path = role == 'lawyer' ? '/api/lawyer/device-token' : '/api/user/device-token';
      await ApiClient.instance.postJson(
        path,
        body: {'token': fcmToken, 'platform': 'android'},
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[Push] token sync failed: $error');
      }
    }
  }

  Future<void> pollUnreadCount() async {
    final role = await AuthSession.instance.getRole();
    if (role == null) {
      return;
    }
    try {
      final path =
          role == 'lawyer' ? '/api/lawyer/notifications' : '/api/user/notifications';
      final json = await ApiClient.instance.getJson(path);
      final unread = json['unreadCount'] as int? ?? 0;
      NotificationInboxNotifier.instance.setUnread(unread);
    } catch (_) {
      // ignore background poll errors
    }
  }

  void _onForegroundMessage(RemoteMessage message) {
    NotificationInboxNotifier.instance.bump();
    final notification = message.notification;
    final title = notification?.title ?? message.data['title']?.toString() ?? 'Ashlar';
    final body =
        notification?.body ?? message.data['body']?.toString() ?? 'You have an update';

    unawaited(
      _local.show(
        message.hashCode,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: _encodePayload(message.data),
      ),
    );
  }

  void _onOpenedApp(RemoteMessage message) {
    _handleOpenPayload(message.data);
  }

  void _handleOpenPayload(Map<String, dynamic> data) {
    unawaited(_openFromData(data));
  }

  Future<void> _openFromPayload(String payload) async {
    final parts = payload.split('|');
    if (parts.length < 2) {
      return;
    }
    final role = await AuthSession.instance.getRole() ?? 'user';
    NotificationActionRouter.open(
      role: role,
      actionType: parts[0].isEmpty ? null : parts[0],
      actionId: int.tryParse(parts[1]),
    );
  }

  Future<void> _openFromData(Map<String, dynamic> data) async {
    final role = await AuthSession.instance.getRole() ?? 'user';
    NotificationActionRouter.openFromData(data, role: role);
    NotificationInboxNotifier.instance.bump();
  }

  String _encodePayload(Map<String, dynamic> data) {
    final actionType = data['actionType']?.toString() ?? '';
    final actionId = data['actionId']?.toString() ?? '';
    return '$actionType|$actionId';
  }
}