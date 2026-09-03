import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Figma `7225:1909` text styles.
abstract final class RoleSelectTypography {
  /// `7225:1913` — Inter Bold 30 white.
  static TextStyle welcome(FigmaScale s) => AppTypography.inter(
        fontSize: s.fs(30),
        fontWeight: FontWeight.w700,
        color: Colors.white,
        height: 1,
        letterSpacing: 0,
      );

  /// `7225:1914` — Inter Regular 16 white @ 70%.
  static TextStyle subtitle(FigmaScale s) => AppTypography.inter(
        fontSize: s.fs(16),
        fontWeight: FontWeight.w400,
        color: Colors.white.withValues(alpha: 0.7),
        height: 1,
        letterSpacing: 0,
      );

  /// Card title — Inter Bold 16 black.
  static TextStyle cardTitle(FigmaScale s) => AppTypography.inter(
        fontSize: s.fs(16),
        fontWeight: FontWeight.w700,
        color: Colors.black,
        height: 1,
        letterSpacing: 0,
      );

  /// Card subtitle — Inter Regular 10 black @ 70%.
  static TextStyle cardSubtitle(FigmaScale s) => AppTypography.inter(
        fontSize: s.fs(10),
        fontWeight: FontWeight.w400,
        color: Colors.black.withValues(alpha: 0.7),
        height: 1,
        letterSpacing: 0,
      );
}
