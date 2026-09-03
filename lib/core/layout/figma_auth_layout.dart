import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Login hero — Figma `7125:5506` at (-13, 28), 395×400, image insets 7.38% / 85.24%.
class FigmaLoginHeroIllustration extends StatelessWidget {
  const FigmaLoginHeroIllustration({super.key, required this.scale});

  final FigmaScale scale;

  static const _designX = -13.0;
  static const _designY = 28.0;
  static const _designW = 395.0;
  static const _designH = 400.0;
  static const _insetTopFraction = 0.0738;
  static const _visibleHeightFraction = 0.8524;

  @override
  Widget build(BuildContext context) {
    final frameW = scale.s(_designW);
    final frameH = scale.s(_designH);
    final insetTop = frameH * _insetTopFraction;
    final visibleH = frameH * _visibleHeightFraction;

    return Positioned(
      left: scale.s(_designX),
      top: scale.s(_designY),
      width: frameW,
      height: frameH,
      child: ClipRect(
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              top: insetTop,
              left: 0,
              width: frameW,
              height: visibleH,
              child: Image.asset(
                AppAssets.lawyerLoginIllustration,
                width: frameW,
                height: visibleH,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                filterQuality: FilterQuality.high,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// OTP hero — Figma `7125:6134` / user `7125:826` @ (36, 81), 288×288.
class FigmaOtpHeroIllustration extends StatelessWidget {
  const FigmaOtpHeroIllustration({
    super.key,
    required this.scale,
    this.asset = AppAssets.lawyerOtpIllustration,
  });

  final FigmaScale scale;
  final String asset;

  static const _designX = 36.0;
  static const _designY = 81.0;
  static const _designW = 288.0;
  static const _designH = 288.0;

  @override
  Widget build(BuildContext context) {
    final w = scale.s(_designW);
    final h = scale.s(_designH);

    return Positioned(
      left: scale.s(_designX),
      top: scale.s(_designY),
      width: w,
      height: h,
      child: ClipRect(
        child: Image.asset(
          asset,
          width: w,
          height: h,
          fit: BoxFit.contain,
          alignment: Alignment.center,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}

/// Gold label + lines — Figma `7125:5483` / `5484` / `5485`.
class FigmaLoginSignupDivider extends StatelessWidget {
  const FigmaLoginSignupDivider({super.key, required this.scale});

  final FigmaScale scale;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: scale.s(107),
          top: scale.s(502),
          child: Text(
            'Log in or Sign up',
            style: AppTypography.openSans(
              color: AppColors.gold,
              fontWeight: FontWeight.w600,
              fontSize: scale.fs(16),
              height: 22 / 16,
            ),
          ),
        ),
        Positioned(
          left: scale.s(19),
          top: scale.s(519),
          child: Container(
            width: scale.s(72),
            height: scale.s(1.5),
            color: AppColors.gold,
          ),
        ),
        Positioned(
          left: scale.s(251),
          top: scale.s(519),
          child: Container(
            width: scale.s(72),
            height: scale.s(1.5),
            color: AppColors.gold,
          ),
        ),
      ],
    );
  }
}
