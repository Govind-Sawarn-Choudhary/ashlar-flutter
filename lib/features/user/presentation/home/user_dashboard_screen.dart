import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/features/user/data/user_premium_repository.dart';
import 'package:ashlar_lawyer_hub/features/user/data/user_repository.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/home/widgets/user_bottom_nav_hit_zones.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/home/widgets/user_dashboard_preference_toggle.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/widgets/user_shell_scope.dart';
import 'package:ashlar_lawyer_hub/features/user/user_routes.dart';
import 'package:flutter/material.dart';

/// User home — Figma `7125:1745` (360×800): full artboard + live header text.
class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key, this.embeddedInShell = false});

  final bool embeddedInShell;

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  UserDashboardPreference _preference = UserDashboardPreference.law;
  String? _userName;
  String? _location;
  int _unreadNotifications = 0;

  static const _figmaNavTop = 725.0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await loadUserDashboard();
      final me = await UserRepository.instance.getMe();
      if (!mounted) {
        return;
      }
      setState(() {
        _userName = me.profile.fullName;
        _location = me.profile.location;
        _unreadNotifications = data.unreadNotifications;
      });
    } on ApiException {
      // Static Figma artboard still renders.
    } catch (_) {}
  }

  String get _heyLine {
    final raw = _userName?.trim();
    if (raw == null || raw.isEmpty) {
      return 'Hey, there';
    }
    final first = raw.split(RegExp(r'\s+')).first;
    return 'Hey, $first';
  }

  String get _locationLine {
    final loc = _location?.trim();
    if (loc != null && loc.isNotEmpty) {
      return loc;
    }
    return 'Set your location';
  }

  void _onNavTap(UserBottomNavTab tab) {
    if (widget.embeddedInShell) {
      UserShellScope.maybeOf(context)?.switchTab(tab);
      return;
    }
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

  @override
  Widget build(BuildContext context) {
    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: false,
      background: const ColoredBox(color: Colors.black),
      body: FigmaScreenCanvas(
        builder: (context, s) {
          final artboardH =
              widget.embeddedInShell ? s.s(_figmaNavTop) : s.artboardHeight;

          return SizedBox(
            width: s.viewportWidth,
            height: artboardH,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: artboardH,
                  child: Image.asset(
                    AppAssets.userDashboardFull,
                    fit: BoxFit.fill,
                    alignment: Alignment.topCenter,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                Positioned(
                  left: s.s(86),
                  top: s.s(55),
                  width: s.s(178),
                  height: s.s(58),
                  child: ColoredBox(
                    color: Colors.black,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: s.s(6),
                        top: s.s(7),
                        right: s.s(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _heyLine,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.inter(
                              fontSize: s.fs(18),
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: s.s(6)),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: s.fs(14),
                                color: Colors.white,
                              ),
                              SizedBox(width: s.s(3)),
                              Expanded(
                                child: Text(
                                  _locationLine,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.inter(
                                    fontSize: s.fs(14),
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: s.s(263.5),
                  top: s.s(61),
                  width: s.s(40),
                  height: s.s(40),
                  child: GestureDetector(
                    onTap: () =>
                        Navigator.of(context).pushNamed(UserRoutes.wallet),
                    behavior: HitTestBehavior.opaque,
                  ),
                ),
                Positioned(
                  left: s.s(311),
                  top: s.s(61),
                  width: s.s(40),
                  height: s.s(40),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context)
                        .pushNamed(UserRoutes.notifications),
                    behavior: HitTestBehavior.opaque,
                    child: _unreadNotifications > 0
                        ? Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              width: s.s(8),
                              height: s.s(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF87171),
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
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
                if (!widget.embeddedInShell) ...[
                  UserBottomNavHitZones(scale: s, onTap: _onNavTap),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}