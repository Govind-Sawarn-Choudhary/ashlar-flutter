import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:flutter/material.dart';

/// Availability + weekly calls — Figma `7125:6680` @ (31, 405), 300×67.
///
/// Uses the full card export from Figma so rings, icons, and labels match
/// the design pixel-for-pixel.
class LawyerHitRateCard extends StatelessWidget {
  const LawyerHitRateCard({super.key, required this.scale});

  final FigmaScale scale;

  static const _designWidth = 300.0;
  static const _designHeight = 67.0;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.dashboardHitRateCard,
      width: scale.s(_designWidth),
      height: scale.s(_designHeight),
      fit: BoxFit.fill,
      filterQuality: FilterQuality.high,
    );
  }
}
