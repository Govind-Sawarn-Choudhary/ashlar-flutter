import 'package:ashlar_lawyer_hub/core/widgets/figma_glow_background.dart';
import 'package:flutter/material.dart';

/// Login glow — Figma `7125:757` ellipses on `7125:614`.
class UserLoginGlowBackground extends StatelessWidget {
  const UserLoginGlowBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const FigmaGlowBackground(
      layout: FigmaGlowLayout.auth,
      alignToArtboard: true,
    );
  }
}
