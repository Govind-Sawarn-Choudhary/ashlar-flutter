import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/core/widgets/auth_buttons.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/auth/widgets/user_auth_widgets.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/auth/widgets/user_login_glow_background.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/widgets/user_design_tokens.dart';
import 'package:ashlar_lawyer_hub/features/user/user_routes.dart';
import 'package:flutter/material.dart';

/// User onboarding intro — premium welcome before login.
class UserOnboardingScreen extends StatelessWidget {
  const UserOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = FigmaScale.fromViewport(MediaQuery.sizeOf(context));

    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: true,
      background: const UserLoginGlowBackground(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: scale.s(20)),
          child: Column(
            children: [
              SizedBox(height: scale.s(24)),
              UserClientBadge(scale: scale),
              SizedBox(height: scale.s(28)),
              Expanded(
                child: Image.asset(
                  AppAssets.userOnboardingLogo,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
              SizedBox(height: scale.s(20)),
              Text(
                'Legal Help,\nOne Tap Away',
                textAlign: TextAlign.center,
                style: AppTypography.openSans(
                  color: UserDesignTokens.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: scale.fs(30),
                  height: 1.2,
                ).copyWith(
                  shadows: const [
                    Shadow(color: Color(0x1A000000), blurRadius: 18),
                  ],
                ),
              ),
              SizedBox(height: scale.s(12)),
              Text(
                'Find trusted lawyers, book consultations, pay challans, and access legal documents — all in one place.',
                textAlign: TextAlign.center,
                style: AppTypography.openSans(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontWeight: FontWeight.w400,
                  fontSize: scale.fs(15),
                  height: 1.45,
                ),
              ),
              SizedBox(height: scale.s(28)),
              SizedBox(
                width: double.infinity,
                height: scale.s(56),
                child: GetStartedButton(
                  label: 'Get Started',
                  onComplete: () {
                    Navigator.of(context).pushNamed(UserRoutes.login);
                  },
                ),
              ),
              SizedBox(height: scale.s(16)),
            ],
          ),
        ),
      ),
    );
  }
}
