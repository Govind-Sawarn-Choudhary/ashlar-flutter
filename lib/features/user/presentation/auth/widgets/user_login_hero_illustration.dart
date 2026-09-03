import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:flutter/material.dart';

/// User login hero — Figma `7125:617` @ (23, 33), 325×325.
class UserLoginHeroIllustration extends StatelessWidget {
  const UserLoginHeroIllustration({super.key, required this.scale});

  final FigmaScale scale;

  static const _designX = 23.0;
  static const _designY = 33.0;
  static const _designSize = 325.0;

  @override
  Widget build(BuildContext context) {
    final size = scale.s(_designSize);

    return Positioned(
      left: scale.s(_designX),
      top: scale.s(_designY),
      width: size,
      height: size,
      child: Image.asset(
        AppAssets.userLoginIllustration,
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
