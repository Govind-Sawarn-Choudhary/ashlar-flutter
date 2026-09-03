import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:flutter/material.dart';

enum UserBottomNavTab { home, lawyers, documents, challan, profile }

/// Transparent tap targets — Figma bottom nav `7125:1835` / `7125:2465` @ (22, 725).
class UserBottomNavHitZones extends StatelessWidget {
  const UserBottomNavHitZones({
    super.key,
    required this.scale,
    required this.onTap,
  });

  final FigmaScale scale;
  final ValueChanged<UserBottomNavTab> onTap;

  static const _navLeft = 22.0;
  static const _navTop = 725.0;
  static const _navHeight = 57.0;

  static const _zones = <(UserBottomNavTab, double, double)>[
    (UserBottomNavTab.home, 24.5234375, 52.0),
    (UserBottomNavTab.lawyers, 81.0, 52.0),
    (UserBottomNavTab.documents, 136.0, 70.0),
    (UserBottomNavTab.challan, 214.0, 55.0),
    (UserBottomNavTab.profile, 276.0, 48.0),
  ];

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: scale.s(_navLeft),
      top: scale.s(_navTop),
      width: scale.s(327),
      height: scale.s(_navHeight),
      child: Stack(
        children: [
          for (final zone in _zones)
            Positioned(
              left: scale.s(zone.$2),
              top: 0,
              width: scale.s(zone.$3),
              height: scale.s(_navHeight),
              child: GestureDetector(
                onTap: () => onTap(zone.$1),
                behavior: HitTestBehavior.opaque,
              ),
            ),
        ],
      ),
    );
  }
}
