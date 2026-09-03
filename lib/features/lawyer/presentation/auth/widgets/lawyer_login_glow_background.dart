import 'package:ashlar_lawyer_hub/core/widgets/figma_glow_background.dart';
import 'package:flutter/material.dart';

/// Auth glow aligned to centered 360×800 artboard — login `7125:5478` / OTP `7125:5631`.
class LawyerLoginGlowBackground extends StatelessWidget {
  const LawyerLoginGlowBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const FigmaGlowBackground(
      layout: FigmaGlowLayout.auth,
      alignToArtboard: true,
    );
  }
}
