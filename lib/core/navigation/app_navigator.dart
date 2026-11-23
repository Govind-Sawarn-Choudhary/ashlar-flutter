import 'dart:async';

import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

/// Global navigation helpers (e.g. session expiry redirect).
abstract final class AppNavigator {
  static void pushNamed(String route, {Object? arguments}) {
    final navigator = appNavigatorKey.currentState;
    if (navigator == null) {
      return;
    }
    unawaited(navigator.pushNamed(route, arguments: arguments));
  }

  static void toRoleSelect() {
    final navigator = appNavigatorKey.currentState;
    if (navigator == null) {
      return;
    }

    navigator.pushNamedAndRemoveUntil('/role-select', (route) => false);
  }
}
