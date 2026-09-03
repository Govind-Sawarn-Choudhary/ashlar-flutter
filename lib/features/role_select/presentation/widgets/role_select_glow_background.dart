import 'package:ashlar_lawyer_hub/core/widgets/figma_glow_background.dart';
import 'package:flutter/material.dart';

/// Role select glow — Figma `7225:1933` ellipses on `7225:1909`.
class RoleSelectGlowBackground extends StatelessWidget {
  const RoleSelectGlowBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const FigmaGlowBackground(layout: FigmaGlowLayout.roleSelect);
  }
}
