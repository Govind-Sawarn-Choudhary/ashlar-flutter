import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Figma `7125:6839` text styles.
abstract final class MyDocumentsTypography {
  static const brandGold = Color(0xFFBA8220);
  static const updateRed = Colors.red;

  /// `7125:6852` — Open Sans SemiBold 16.
  static TextStyle title(FigmaScale s) => AppTypography.openSans(
        fontSize: s.fs(16),
        fontWeight: FontWeight.w600,
        color: brandGold,
        height: 1,
        letterSpacing: 0,
      );

  /// `7125:6871` — Inter Medium 14.
  static TextStyle rowLabel(FigmaScale s) => AppTypography.inter(
        fontSize: s.fs(14),
        fontWeight: FontWeight.w500,
        color: Colors.black,
        height: 1,
        letterSpacing: 0,
      );

  /// `7125:6873` — Inter SemiBold 14 red.
  static TextStyle updateAction(FigmaScale s) => AppTypography.inter(
        fontSize: s.fs(14),
        fontWeight: FontWeight.w600,
        color: updateRed,
        height: 1,
        letterSpacing: 0,
      );

  /// `7125:6842` — Inter Bold 16 gold.
  static TextStyle uploadLabel(FigmaScale s) => AppTypography.inter(
        fontSize: s.fs(16),
        fontWeight: FontWeight.w700,
        color: brandGold,
        height: 1,
        letterSpacing: 0,
      );
}
