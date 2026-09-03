import 'package:ashlar_lawyer_hub/core/widgets/figma_glow_background.dart';
import 'package:flutter/material.dart';

/// Onboarding glow — Figma `7125:5447`.
class LawyerOnboardingGlowBackground extends StatelessWidget {
  const LawyerOnboardingGlowBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const FigmaGlowBackground(layout: FigmaGlowLayout.onboarding);
  }
}
