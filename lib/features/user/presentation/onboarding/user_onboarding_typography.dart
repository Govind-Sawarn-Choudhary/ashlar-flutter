import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Figma `7125:585` text styles.
abstract final class UserOnboardingTypography {
  static const _textShadow = Shadow(
    color: Color(0x1A000000),
    blurRadius: 18,
  );

  /// `7125:589` — Inter Bold 30 white.
  static TextStyle title(FigmaScale s) => AppTypography.inter(
        fontSize: s.fs(30),
        fontWeight: FontWeight.w700,
        color: Colors.white,
        height: 1,
        letterSpacing: 0,
      ).copyWith(shadows: const [_textShadow]);

  /// `7125:590` — Inter Regular 16 white @ 70%.
  static TextStyle subtitle(FigmaScale s) => AppTypography.inter(
        fontSize: s.fs(16),
        fontWeight: FontWeight.w400,
        color: Colors.white.withValues(alpha: 0.7),
        height: 1,
        letterSpacing: 0,
      ).copyWith(shadows: const [_textShadow]);
}
