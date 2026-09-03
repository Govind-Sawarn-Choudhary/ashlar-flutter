import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Figma `7125:6805` text styles.
abstract final class ManageProfileTypography {
  static const brandGold = Color(0xFFBA8220);

  /// Field values — Inter Medium 16.
  static TextStyle fieldValue(FigmaScale s) => AppTypography.inter(
        fontSize: s.fs(16),
        fontWeight: FontWeight.w500,
        color: Colors.black,
        height: 1,
        letterSpacing: 0,
      );

  /// Continue button — Inter Bold 16 gold.
  static TextStyle continueLabel(FigmaScale s) => AppTypography.inter(
        fontSize: s.fs(16),
        fontWeight: FontWeight.w700,
        color: brandGold,
        height: 1,
        letterSpacing: 0,
      );
}
