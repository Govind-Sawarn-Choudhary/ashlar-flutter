import 'package:ashlar_lawyer_hub/features/user/presentation/home/widgets/user_bottom_nav_hit_zones.dart';
import 'package:flutter/material.dart';

class UserShellScope extends InheritedWidget {
  const UserShellScope({
    super.key,
    required this.switchTab,
    required super.child,
  });

  final ValueChanged<UserBottomNavTab> switchTab;

  static UserShellScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<UserShellScope>();
  }

  @override
  bool updateShouldNotify(UserShellScope oldWidget) =>
      switchTab != oldWidget.switchTab;
}
