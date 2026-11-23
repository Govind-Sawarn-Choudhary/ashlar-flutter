import 'package:ashlar_lawyer_hub/core/widgets/figma_glow_background.dart';
import 'package:flutter/material.dart';

/// Figma `7125:1791` ambient gold glow on user dashboard.
class UserDashboardGlowBackground extends StatelessWidget {
  const UserDashboardGlowBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const FigmaGlowBackground(layout: FigmaGlowLayout.userDashboard);
  }
}