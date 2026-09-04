import 'package:ashlar_lawyer_hub/features/lawyer/presentation/dashboard/widgets/lawyer_bottom_nav_hit_zones.dart';
import 'package:flutter/material.dart';

/// Exposes tab switching to child screens embedded in [LawyerMainShellScreen].
class LawyerShellScope extends InheritedWidget {
  const LawyerShellScope({
    super.key,
    required this.switchTab,
    required super.child,
  });

  final ValueChanged<LawyerBottomNavTab> switchTab;

  static LawyerShellScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LawyerShellScope>();
  }

  static void switchTo(BuildContext context, LawyerBottomNavTab tab) {
    maybeOf(context)?.switchTab(tab);
  }

  @override
  bool updateShouldNotify(LawyerShellScope oldWidget) => false;
}
