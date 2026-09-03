import 'dart:ui';

import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Figma glow layouts on 360×800 artboards — ellipse `#897F39` @ 34%, blur 88.
enum FigmaGlowLayout {
  splash,
  onboarding,
  auth,
  roleSelect,
}

/// Shared dark background + golden glow orbs matching Figma exports.
class FigmaGlowBackground extends StatelessWidget {
  const FigmaGlowBackground({
    super.key,
    required this.layout,
    this.alignToArtboard = false,
  });

  final FigmaGlowLayout layout;

  /// When true, orbs use uniform artboard scale + vertical centering (login/OTP).
  final bool alignToArtboard;

  static const _orbDiameter = 276.0;
  static const _blurSigma = 88.0;

  @override
  Widget build(BuildContext context) {
    final viewport = MediaQuery.sizeOf(context);
    final figma = FigmaScale.fromViewport(
      viewport,
      align: FigmaArtboardAlign.top,
    );
    final orbs = _orbsFor(layout);

    return ColoredBox(
      color: AppColors.background,
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          for (final orb in orbs)
            Positioned(
              left: orb.x * figma.scale,
              top: (alignToArtboard ? figma.artboardTop : 0) +
                  orb.y * figma.scale,
              child: _GlowOrb(diameter: _orbDiameter * figma.scale),
            ),
        ],
      ),
    );
  }

  static List<_OrbPosition> _orbsFor(FigmaGlowLayout layout) {
    return switch (layout) {
      FigmaGlowLayout.splash => const [
        _OrbPosition(-47, 531),
        _OrbPosition(193, 0),
      ],
      FigmaGlowLayout.onboarding => const [
        _OrbPosition(-78, 543),
        _OrbPosition(162, 12),
      ],
      FigmaGlowLayout.auth => const [
        _OrbPosition(0, 531),
        _OrbPosition(240, 0),
      ],
      FigmaGlowLayout.roleSelect => const [
        _OrbPosition(-78, 543),
        _OrbPosition(210, -59),
      ],
    };
  }
}

class _OrbPosition {
  const _OrbPosition(this.x, this.y);

  final double x;
  final double y;
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.diameter});

  final double diameter;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(
        sigmaX: FigmaGlowBackground._blurSigma,
        sigmaY: FigmaGlowBackground._blurSigma,
      ),
      child: Container(
        width: diameter,
        height: diameter,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.glowOrb,
        ),
      ),
    );
  }
}
