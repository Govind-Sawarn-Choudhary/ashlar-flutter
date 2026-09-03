import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Figma `7125:6744` text styles.
abstract final class ProfileTypography {
  static const signOutRed = Colors.red;

  /// `7125:6756` — Inter Regular 16.
  static TextStyle screenTitle(FigmaScale s) => AppTypography.inter(
        fontSize: s.fs(16),
        fontWeight: FontWeight.w400,
        color: Colors.white,
        height: 1,
        letterSpacing: 0,
      );

  /// Menu labels — Inter Semi Bold 16.
  static TextStyle menuLabel(FigmaScale s) => AppTypography.inter(
        fontSize: s.fs(16),
        fontWeight: FontWeight.w600,
        color: Colors.black,
        height: 1,
        letterSpacing: 0,
      );

  /// `7125:6775` — Inter Semi Bold 26, tracking -0.24.
  static TextStyle signOut(FigmaScale s) => AppTypography.inter(
        fontSize: s.fs(26),
        fontWeight: FontWeight.w600,
        color: signOutRed,
        height: 1,
        letterSpacing: -0.24,
      );
}
