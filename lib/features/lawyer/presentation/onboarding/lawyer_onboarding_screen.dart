import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/core/widgets/auth_buttons.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/lawyer_routes.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/onboarding/widgets/lawyer_onboarding_glow_background.dart';
import 'package:flutter/material.dart';

/// Lawyer onboarding — pixel layout from Figma frame `7125:5447` (360×800).
class LawyerOnboardingScreen extends StatelessWidget {
  const LawyerOnboardingScreen({super.key});

  static const _designWidth = 360.0;
  static const _designHeight = 800.0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scaleX = size.width / _designWidth;
    final scaleY = size.height / _designHeight;

    final logoTop = 139 * scaleY;
    final logoHeight = 358 * scaleY;
    final textTop = 572 * scaleY;
    final buttonTop = 692 * scaleY;
    final horizontalInset = 19 * scaleX;
    final contentWidth = 324 * scaleX;
    final buttonHeight = 60 * scaleY;

    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: false,
      background: const LawyerOnboardingGlowBackground(),
      body: Stack(
        children: [
          Positioned(
            left: 0,
            top: logoTop,
            width: size.width,
            height: logoHeight,
            child: Image.asset(
              AppAssets.lawyerOnboardingLogo,
              fit: BoxFit.contain,
              alignment: Alignment.topCenter,
              filterQuality: FilterQuality.high,
            ),
          ),
          Positioned(
            left: horizontalInset,
            right: horizontalInset,
            top: textTop,
            child: SizedBox(
              width: contentWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Advocate Plus',
                    textAlign: TextAlign.center,
                    style: AppTypography.openSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 30 * scaleX,
                      height: 1.2,
                    ).copyWith(
                      shadows: const [
                        Shadow(
                          color: Color(0x1A000000),
                          blurRadius: 18,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8 * scaleY),
                  Text(
                    'Built for modern advocates to simplify legal practice and client support.',
                    textAlign: TextAlign.center,
                    style: AppTypography.openSans(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w400,
                      fontSize: 16 * scaleX,
                      height: 1.2,
                    ).copyWith(
                      shadows: const [
                        Shadow(
                          color: Color(0x1A000000),
                          blurRadius: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: horizontalInset,
            top: buttonTop,
            width: contentWidth,
            height: buttonHeight,
            child: GetStartedButton(
              label: 'Get Started',
              onComplete: () {
                Navigator.of(context).pushNamed(LawyerRoutes.login);
              },
            ),
          ),
        ],
      ),
    );
  }
}
