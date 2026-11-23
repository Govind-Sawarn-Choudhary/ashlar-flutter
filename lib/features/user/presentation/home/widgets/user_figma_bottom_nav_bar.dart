import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/home/widgets/user_bottom_nav_hit_zones.dart';
import 'package:flutter/material.dart';

/// Figma `7125:1835` — white pill bottom bar + transparent hit targets.
class UserFigmaBottomNavBar extends StatelessWidget {
  const UserFigmaBottomNavBar({
    super.key,
    required this.scale,
    required this.selectedTab,
    required this.onTap,
  });

  final FigmaScale scale;
  final UserBottomNavTab selectedTab;
  final ValueChanged<UserBottomNavTab> onTap;

  static const _navHeight = 57.0;

  static double reservedBottomPadding(
    BuildContext context, {
    FigmaScale? scale,
  }) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final navHeight = scale?.s(_navHeight) ?? _navHeight;
    return navHeight + bottomInset + (scale?.s(12) ?? 12);
  }

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Positioned(
      left: s.s(22),
      right: s.s(11),
      bottom: bottomInset + s.s(8),
      height: s.s(_navHeight),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppAssets.userDashboardBottomNavBar,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
          ),
          UserBottomNavHitZones(scale: s, onTap: onTap),
        ],
      ),
    );
  }
}