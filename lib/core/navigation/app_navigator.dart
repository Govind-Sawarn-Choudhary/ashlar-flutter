import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

/// Global navigation helpers (e.g. session expiry redirect).
abstract final class AppNavigator {
  static void toRoleSelect() {
    final navigator = appNavigatorKey.currentState;
    if (navigator == null) {
      return;
    }

    navigator.pushNamedAndRemoveUntil('/role-select', (route) => false);
  }
}
