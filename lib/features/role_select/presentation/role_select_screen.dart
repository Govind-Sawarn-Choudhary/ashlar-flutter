import 'package:ashlar_lawyer_hub/core/auth/auth_session.dart';
import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/enums/user_role.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/features/role_select/presentation/role_select_typography.dart';
import 'package:ashlar_lawyer_hub/features/role_select/presentation/widgets/role_select_glow_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Choose your role — Figma [`7225:1909`](https://www.figma.com/design/3PtNxJn9gYGj6S0yAHBce3/ashlarlawyerhub-To-Share--Copy-?node-id=7225-1909) (360×800).
class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: false,
      background: const RoleSelectGlowBackground(),
      body: FigmaScreenCanvas(
        builder: (context, s) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: s.s(97),
                top: s.s(124),
                width: s.s(165),
                height: s.s(164),
                child: Image.asset(
                  AppAssets.roleSelectLogo,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
              Positioned(
                left: s.s(18),
                top: s.s(355),
                width: s.s(324),
                child: Text(
                  'Welcome!',
                  textAlign: TextAlign.center,
                  style: RoleSelectTypography.welcome(s),
                ),
              ),
              Positioned(
                left: s.s(82),
                top: s.s(411),
                width: s.s(208),
                child: Text(
                  'Please choose how you want to login',
                  textAlign: TextAlign.center,
                  style: RoleSelectTypography.subtitle(s),
                ),
              ),
              Positioned(
                left: s.s(18),
                top: s.s(498),
                child: _RoleLoginCard(
                  scale: s,
                  title: 'Login as a lawyer',
                  subtitle:
                      'Access your lawyer dashboard and manage your cases',
                  iconAsset: AppAssets.roleSelectLawyerIcon,
                  onTap: () => _go(context, UserRole.lawyer),
                ),
              ),
              Positioned(
                left: s.s(18),
                top: s.s(629),
                child: _RoleLoginCard(
                  scale: s,
                  title: 'Login as a User/Client',
                  subtitle: 'Access your accounts and manage your legal matters',
                  iconAsset: AppAssets.roleSelectUserIcon,
                  onTap: () => _go(context, UserRole.user),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static Future<void> _go(BuildContext context, UserRole role) async {
    await AuthSession.instance.clear();
    if (!context.mounted) {
      return;
    }

    final route = switch (role) {
      UserRole.user => '/user',
      UserRole.lawyer => '/lawyer',
    };
    Navigator.of(context).pushReplacementNamed(route);
  }
}

class _RoleLoginCard extends StatelessWidget {
  const _RoleLoginCard({
    required this.scale,
    required this.title,
    required this.subtitle,
    required this.iconAsset,
    required this.onTap,
  });

  final FigmaScale scale;
  final String title;
  final String subtitle;
  final String iconAsset;
  final VoidCallback onTap;

  static const _iconCircleColor = Color(0x78BA8220);

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(s.s(10)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: s.s(324),
          height: s.s(104),
          child: Stack(
            children: [
              Positioned(
                left: s.s(17),
                top: s.s(22),
                width: s.s(60),
                height: s.s(60),
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: _iconCircleColor,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(s.s(14)),
                    child: Image.asset(
                      iconAsset,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: s.s(87),
                top: s.s(26),
                right: s.s(56),
                child: Text(
                  title,
                  style: RoleSelectTypography.cardTitle(s),
                ),
              ),
              Positioned(
                left: s.s(87),
                top: s.s(52),
                width: s.s(149),
                child: Text(
                  subtitle,
                  style: RoleSelectTypography.cardSubtitle(s),
                ),
              ),
              Positioned(
                right: s.s(22),
                top: s.s(47),
                child: SvgPicture.asset(
                  AppAssets.roleSelectChevrons,
                  width: s.s(21),
                  height: s.s(10),
                  fit: BoxFit.contain,
                  colorFilter: const ColorFilter.mode(
                    AppColors.gold,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
