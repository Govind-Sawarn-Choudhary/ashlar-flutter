import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/home/widgets/user_bottom_nav_hit_zones.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/home/widgets/user_dashboard_preference_toggle.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/widgets/user_shell_scope.dart';
import 'package:ashlar_lawyer_hub/features/user/user_routes.dart';
import 'package:flutter/material.dart';

/// Figma `7125:1745` — user home dashboard artboard (360×800).
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
                left: s.s(20),
                top: s.s(59),
                width: s.s(64),
                height: s.s(64),
                child: Image.asset(
                  AppAssets.splashLogo,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
              Positioned(
                left: s.s(92),
                top: s.s(63),
                right: s.s(120),
                child: Text(
                  _heyLine,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.inter(
                    fontSize: s.fs(18),
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    height: 22 / 18,
                  ),
                ),
              ),
              Positioned(
                left: s.s(92),
                top: s.s(87),
                right: s.s(100),
                child: Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: s.s(14), color: Colors.white),
                    SizedBox(width: s.s(4)),
                    Expanded(
                      child: Text(
                        _locationLine,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.inter(
                          fontSize: s.fs(14),
                          color: Colors.white.withValues(alpha: 0.92),
                          height: 18 / 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: s.s(263.5),
                top: s.s(61),
                width: s.s(40),
                height: s.s(40),
                child: _HeaderIconTap(
                  icon: Icons.account_balance_wallet_outlined,
                  onTap: widget.onWalletTap,
                ),
              ),
              Positioned(
                left: s.s(311),
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
                left: s.s(15),
                top: s.s(118),
                width: s.s(330),
                height: s.s(204),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(s.s(12)),
                  child: Image.asset(
                    AppAssets.userDashboardPromoCard,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
              Positioned(
                left: s.s(161),
                top: s.s(335),
                width: s.s(38),
                height: s.s(6),
                child: Image.asset(
                  AppAssets.userDashboardCarouselDots,
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                left: s.s(52),
                top: s.s(360),
                width: s.s(76),
                height: s.s(1),
                child: Image.asset(
                  AppAssets.userDashboardSectionDivider,
                  fit: BoxFit.fill,
                ),
              ),
              Positioned(
                left: s.s(136),
                top: s.s(352),
                child: Text(
                  'Switch Preference',
                  style: AppTypography.inter(
                    fontSize: s.fs(14),
                    fontWeight: FontWeight.w600,
                    color: AppColors.gold,
                    height: 17 / 14,
                  ),
                ),
              ),
              Positioned(
                right: s.s(52),
                top: s.s(360),
                width: s.s(76),
                height: s.s(1),
                child: Image.asset(
                  AppAssets.userDashboardSectionDivider,
                  fit: BoxFit.fill,
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
                top: s.s(448),
                child: Text(
                  'Category',
                  style: AppTypography.inter(
                    fontSize: s.fs(16),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                right: s.s(22),
                top: s.s(448),
                child: GestureDetector(
                  onTap: _openLawyers,
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    'view all',
                    style: AppTypography.inter(
                      fontSize: s.fs(12),
                      color: AppColors.gold,
                    ).copyWith(
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.gold,
                    ),
                  ),
                ),
              ),
              _categoryRow(
                s,
                top: 481,
                assets: const [
                  AppAssets.userDashboardCategoryContractR1,
                  AppAssets.userDashboardCategoryFamilyR1,
                  AppAssets.userDashboardCategoryProsecutorR1,
                  AppAssets.userDashboardCategoryBusinessR1,
                ],
              ),
              _categoryRow(
                s,
                top: 606,
                assets: const [
                  AppAssets.userDashboardCategoryContractR2,
                  AppAssets.userDashboardCategoryFamilyR2,
                  AppAssets.userDashboardCategoryProsecutorR2,
                  AppAssets.userDashboardCategoryBusinessR2,
                ],
              ),
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

  Widget _categoryRow(
    FigmaScale s, {
    required double top,
    required List<String> assets,
  }) {
    const lefts = [22.0, 104.0, 186.0, 268.0];
    const size = 70.0;

    return Stack(
      children: [
        for (var i = 0; i < assets.length; i++)
          Positioned(
            left: s.s(lefts[i]),
            top: s.s(top),
            width: s.s(size),
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
          ),
      ],
    );
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
            Icon(icon, color: Colors.white, size: 28),
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