import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:flutter/material.dart';

enum LawyerBottomNavTab { home, appointments, chatHistory, profile }

/// Transparent tap targets — Figma bottom nav `7267:1931` @ (16, 724.78).
class LawyerBottomNavHitZones extends StatelessWidget {
  const LawyerBottomNavHitZones({
    super.key,
    required this.scale,
    required this.onTap,
  });

  final FigmaScale scale;
  final ValueChanged<LawyerBottomNavTab> onTap;

  static const _navLeft = 16.0;
  static const _navTop = 724.78125;
  static const _navWidth = 327.0;
  static const _navHeight = 57.0;

  static const _zones = <(LawyerBottomNavTab, double, double)>[
    (LawyerBottomNavTab.home, 17, 78),
    (LawyerBottomNavTab.appointments, 85, 82),
    (LawyerBottomNavTab.chatHistory, 174, 68),
    (LawyerBottomNavTab.profile, 250, 77),
  ];

  static List<Widget> buildTapTargets({
    required FigmaScale scale,
    required double navHeight,
    required ValueChanged<LawyerBottomNavTab> onTap,
  }) {
    return [
      for (final zone in _zones)
        Positioned(
          left: scale.s(zone.$2),
          top: 0,
          width: scale.s(zone.$3),
          height: scale.s(navHeight),
          child: GestureDetector(
            onTap: () => onTap(zone.$1),
            behavior: HitTestBehavior.opaque,
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: scale.s(_navLeft),
      top: scale.s(_navTop),
      width: scale.s(_navWidth),
      height: scale.s(_navHeight),
      child: Stack(
        children: buildTapTargets(
          scale: scale,
          navHeight: _navHeight,
          onTap: onTap,
        ),
      ),
    );
  }
}
