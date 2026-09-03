import 'package:ashlar_lawyer_hub/core/widgets/figma_glow_background.dart';
import 'package:flutter/material.dart';

/// Onboarding glow — Figma `7125:609` ellipses on `7125:585`.
class UserOnboardingGlowBackground extends StatelessWidget {
  const UserOnboardingGlowBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const FigmaGlowBackground(layout: FigmaGlowLayout.onboarding);
  }
}
