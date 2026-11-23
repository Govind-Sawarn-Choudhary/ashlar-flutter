import 'package:flutter/foundation.dart';

/// Global unread badge — updated by dashboards, push, and polling.
class NotificationInboxNotifier extends ChangeNotifier {
  NotificationInboxNotifier._();

  static final NotificationInboxNotifier instance = NotificationInboxNotifier._();

  int _unread = 0;

  int get unread => _unread;

  void setUnread(int value) {
    final next = value < 0 ? 0 : value;
    if (next == _unread) {
      return;
    }
    _unread = next;
    notifyListeners();
  }

  void bump() {
    setUnread(_unread + 1);
  }

  void clear() {
    setUnread(0);
  }
}