import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/home/widgets/user_bottom_nav_hit_zones.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/home/widgets/user_dashboard_preference_toggle.dart';
import 'package:ashlar_lawyer_hub/features/user/user_routes.dart';
import 'package:flutter/material.dart';

/// User home dashboard — Figma [`7125:1745`](https://www.figma.com/design/3PtNxJn9gYGj6S0yAHBce3/ashlarlawyerhub-To-Share--Copy-?node-id=7125-1745) (360×800).
///
/// Full artboard PNG + preference toggle overlay + bottom nav taps.
class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  UserDashboardPreference _preference = UserDashboardPreference.law;

  void _onNavTap(UserBottomNavTab tab) {
    switch (tab) {
      case UserBottomNavTab.home:
        break;
      case UserBottomNavTab.lawyers:
        Navigator.of(context).pushNamed(UserRoutes.lawyers);
      case UserBottomNavTab.documents:
        Navigator.of(context).pushNamed(UserRoutes.documents);
      case UserBottomNavTab.challan:
        Navigator.of(context).pushNamed(UserRoutes.challan);
      case UserBottomNavTab.profile:
        Navigator.of(context).pushNamed(UserRoutes.profile);
    }
  }

  void _onWalletTap() {
    Navigator.of(context).pushNamed(UserRoutes.wallet);
  }

  @override
  Widget build(BuildContext context) {
    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: false,
      background: const ColoredBox(color: Colors.black),
      body: FigmaScreenCanvas(
        builder: (context, s) {
          return SizedBox(
            width: s.viewportWidth,
            height: s.artboardHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Image.asset(
                    AppAssets.userDashboardFull,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                Positioned(
                  left: s.s(263.5),
                  top: s.s(61),
                  width: s.s(40),
                  height: s.s(40),
                  child: GestureDetector(
                    onTap: _onWalletTap,
                    behavior: HitTestBehavior.opaque,
                  ),
                ),
                if (_preference == UserDashboardPreference.educational)
                  Positioned(
                    left: s.s(52),
                    top: s.s(380),
                    child: UserDashboardPreferenceToggle(
                      scale: s,
                      selected: _preference,
                      onChanged: (value) =>
                          setState(() => _preference = value),
                    ),
                  )
                else
                  Positioned(
                    left: s.s(52),
                    top: s.s(380),
                    width: s.s(251),
                    height: s.s(39),
                    child: Row(
                      children: [
                        const Expanded(child: SizedBox()),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(
                              () => _preference =
                                  UserDashboardPreference.educational,
                            ),
                            behavior: HitTestBehavior.opaque,
                          ),
                        ),
                      ],
                    ),
                  ),
                UserBottomNavHitZones(
                  scale: s,
                  onTap: _onNavTap,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
