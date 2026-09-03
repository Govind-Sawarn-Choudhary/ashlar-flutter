import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Figma `7125:6786` text styles.
abstract final class ManageAppointmentsTypography {
  static const brandGold = Color(0xFFBA8220);
  static const textPrimary = Color(0xFF070707);
  static const textSecondary = Color(0xFF808080);
  static const borderGrey = Color(0xFFE6E6E6);

  /// Header — Inter Regular 16 white.
  static TextStyle screenTitle(FigmaScale s) => AppTypography.inter(
        fontSize: s.fs(16),
        fontWeight: FontWeight.w400,
        color: Colors.white,
        height: 1,
        letterSpacing: 0,
      );

  /// Week label — Inter Bold 12.
  static TextStyle weekLabel(FigmaScale s) => AppTypography.inter(
        fontSize: s.fs(12),
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1,
        letterSpacing: 0,
      );

  /// Week value — Inter Regular 14, line-height 20.
  static TextStyle weekValue(FigmaScale s) => AppTypography.inter(
        fontSize: s.fs(14),
        fontWeight: FontWeight.w400,
        color: textPrimary,
        height: 20 / 14,
        letterSpacing: 0,
      );

  /// Week range — Inter Regular 12.
  static TextStyle weekRange(FigmaScale s) => AppTypography.inter(
        fontSize: s.fs(12),
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 16 / 12,
        letterSpacing: 0.12,
      );

  /// Card date — Inter Bold 14.
  static TextStyle cardDate(FigmaScale s) => AppTypography.inter(
        fontSize: s.fs(14),
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1,
        letterSpacing: 0,
      );

  /// Time label — Inter Regular 14.
  static TextStyle timeLabel(FigmaScale s) => AppTypography.inter(
        fontSize: s.fs(14),
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 20 / 14,
        letterSpacing: 0,
      );

  /// Time value — Inter Bold 14.
  static TextStyle timeValue(FigmaScale s) => AppTypography.inter(
        fontSize: s.fs(14),
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1,
        letterSpacing: 0,
      );

  /// Slot time — Inter Regular 14.
  static TextStyle slotTime(FigmaScale s) => AppTypography.inter(
        fontSize: s.fs(14),
        fontWeight: FontWeight.w400,
        color: textPrimary,
        height: 20 / 14,
        letterSpacing: 0,
      );
}
