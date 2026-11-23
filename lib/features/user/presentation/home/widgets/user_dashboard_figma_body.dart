import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/home/widgets/user_bottom_nav_hit_zones.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/home/widgets/user_dashboard_preference_toggle.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/widgets/user_shell_scope.dart';
import 'package:ashlar_lawyer_hub/features/user/user_routes.dart';
import 'package:flutter/material.dart';

/// User home — Figma `7125:1745` @ 360×800
/// ([file](https://www.figma.com/design/8g6s6o4s3vLdaWTfcChtL0?node-id=7125-1745))
class UserDashboardFigmaBody extends StatefulWidget {
  const UserDashboardFigmaBody({
    super.key,
    required this.scale,
    required this.embeddedInShell,
    this.userName,
    this.location,
    this.unreadNotifications = 0,
    this.bottomPadding = 0,
    this.onWalletTap,
    this.onNotificationsTap,
  });

  final FigmaScale scale;
  final bool embeddedInShell;
  final String? userName;
  final String? location;
  final int unreadNotifications;
  final double bottomPadding;
  final VoidCallback? onWalletTap;
  final VoidCallback? onNotificationsTap;

  @override
  State<UserDashboardFigmaBody> createState() => _UserDashboardFigmaBodyState();
}

class _UserDashboardFigmaBodyState extends State<UserDashboardFigmaBody> {
  UserDashboardPreference _preference = UserDashboardPreference.law;

  static const _goldText = Color(0xFFBA8220);

  String get _heyLine {
    final raw = widget.userName?.trim();
    if (raw == null || raw.isEmpty) {
      return 'Hey, there';
    }
    final first = raw.split(RegExp(r'\s+')).first;
    return 'Hey, $first';
  }

  String get _locationLine {
    final loc = widget.location?.trim();
    if (loc != null && loc.isNotEmpty) {
      return loc;
    }
    return 'Set your location';
  }

  void _switchTab(UserBottomNavTab tab) {
    UserShellScope.maybeOf(context)?.switchTab(tab);
  }

  void _openLawyers() => _switchTab(UserBottomNavTab.lawyers);

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;

    return SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.only(bottom: widget.bottomPadding),
          child: SizedBox(
            width: s.viewportWidth,
            height: s.s(800),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: s.s(11),
                  top: s.s(59),
                  width: s.s(38),
                  height: s.s(34),
                  child: Image.asset(
                    AppAssets.splashLogo,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: s.s(61),
                  child: Text(
                    _heyLine,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.inter(
                      fontSize: s.fs(14),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -0.24,
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: s.s(80),
                  child: Text(
                    _locationLine,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.inter(
                      fontSize: s.fs(12),
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      letterSpacing: -0.24,
                    ),
                  ),
                ),
                Positioned(
                  left: s.s(263),
                  top: s.s(61),
                  width: s.s(40),
                  height: s.s(40),
                  child: _HeaderIconTap(
                    icon: Icons.account_balance_wallet_outlined,
                    onTap: widget.onWalletTap,
                  ),
                ),
                Positioned(
                  left: s.s(305),
                  top: s.s(61),
                  width: s.s(40),
                  height: s.s(40),
                  child: _HeaderIconTap(
                    icon: Icons.notifications_outlined,
                    badge: widget.unreadNotifications > 0,
                    onTap: widget.onNotificationsTap,
                  ),
                ),
                Positioned(
                  left: s.s(15.5),
                  top: s.s(126),
                  width: s.s(329),
                  height: s.s(160),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(s.s(6)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x40000000),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(s.s(6)),
                      child: Image.asset(
                        AppAssets.userDashboardPromoCard,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: s.s(160),
                  top: s.s(300),
                  width: s.s(27),
                  height: s.s(5),
                  child: Image.asset(
                    AppAssets.userDashboardCarouselDots,
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  left: s.s(25),
                  top: s.s(351),
                  width: s.s(72),
                  height: s.s(2),
                  child: Image.asset(
                    AppAssets.userDashboardSectionDivider,
                    fit: BoxFit.fill,
                  ),
                ),
                Positioned(
                  left: s.s(257),
                  top: s.s(351),
                  width: s.s(72),
                  height: s.s(2),
                  child: Image.asset(
                    AppAssets.userDashboardSectionDivider,
                    fit: BoxFit.fill,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: s.s(334),
                  child: Text(
                    'Switch Preference',
                    textAlign: TextAlign.center,
                    style: AppTypography.openSans(
                      fontSize: s.fs(16),
                      fontWeight: FontWeight.w600,
                      color: _goldText,
                    ),
                  ),
                ),
                Positioned(
                  left: s.s(52),
                  top: s.s(380),
                  child: UserDashboardPreferenceToggle(
                    scale: s,
                    selected: _preference,
                    onChanged: (value) => setState(() => _preference = value),
                  ),
                ),
                Positioned(
                  left: s.s(22),
                  top: s.s(441),
                  child: Text(
                    'Category',
                    style: AppTypography.inter(
                      fontSize: s.fs(14),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -0.24,
                    ),
                  ),
                ),
                Positioned(
                  right: s.s(32),
                  top: s.s(444),
                  child: GestureDetector(
                    onTap: _openLawyers,
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      'view all',
                      style: AppTypography.inter(
                        fontSize: s.fs(10),
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        letterSpacing: -0.24,
                      ),
                    ),
                  ),
                ),
                ..._categoryTiles(s, rowTop: 489, isRowTwo: false),
                ..._categoryTiles(s, rowTop: 594, isRowTwo: true),
                if (!widget.embeddedInShell)
                  UserBottomNavHitZones(
                    scale: s,
                    onTap: (tab) {
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
                    },
                  ),
              ],
            ),
          ),
        ),
    );
  }

  List<Widget> _categoryTiles(FigmaScale s,
      {required double rowTop, required bool isRowTwo}) {
    const xs = [22.0, 116.0, 202.0, 287.0];
    final assets = isRowTwo
        ? const [
            AppAssets.userDashboardCategoryContractR2,
            AppAssets.userDashboardCategoryFamilyR2,
            AppAssets.userDashboardCategoryProsecutorR2,
            AppAssets.userDashboardCategoryBusinessR2,
          ]
        : const [
            AppAssets.userDashboardCategoryContractR1,
            AppAssets.userDashboardCategoryFamilyR1,
            AppAssets.userDashboardCategoryProsecutorR1,
            AppAssets.userDashboardCategoryBusinessR1,
          ];

    return List.generate(4, (i) {
      return Positioned(
        left: s.s(xs[i]),
        top: s.s(rowTop),
        width: s.s(70),
        height: s.s(105),
        child: GestureDetector(
          onTap: _openLawyers,
          behavior: HitTestBehavior.opaque,
          child: Image.asset(
            assets[i],
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
      );
    });
  }
}

class _HeaderIconTap extends StatelessWidget {
  const _HeaderIconTap({
    required this.icon,
    required this.onTap,
    this.badge = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 26),
            if (badge)
              const Positioned(
                right: 6,
                top: 6,
                child: CircleAvatar(
                  radius: 4,
                  backgroundColor: Color(0xFFF87171),
                ),
              ),
          ],
        ),
      ),
    );
  }
}