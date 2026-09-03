import 'package:ashlar_lawyer_hub/core/widgets/figma_glow_background.dart';
import 'package:flutter/material.dart';

/// Splash glow — re-exports unified Figma background for `7125:5439`.
class SplashGlowBackground extends StatelessWidget {
  const SplashGlowBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const FigmaGlowBackground(layout: FigmaGlowLayout.splash);
  }
}
