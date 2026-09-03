import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Figma `7125:6603` text styles — Inter family, exact size/weight/line-height.
abstract final class NotificationTypography {
  static const brandGold = Color(0xFFBA8220);
  static const rejectRed = Color(0xFFEE404C);
  static const textPrimary = Color(0xFF070707);
  static const textSecondary = Color(0xFF808080);
  static const surfaceComponent = Color(0xFFF5F5F5);

  /// `7125:6644` — Inter Regular 16, leading normal.
  static TextStyle screenTitle(FigmaScale s) => AppTypography.inter(
        fontSize: s.fs(16),
        fontWeight: FontWeight.w400,
        color: Colors.white,
        height: 1,
        letterSpacing: 0,
      );

  /// `7125:6608` — Inter Bold 12, leading normal.
  static TextStyle pushLabel(FigmaScale s) => AppTypography.inter(
        fontSize: s.fs(12),
        fontWeight: FontWeight.w700,
        color: textSecondary,
        height: 1,
        letterSpacing: 0,
      );

  /// Content switcher selected — Inter Bold 12.
  static TextStyle tabSelected(FigmaScale s) => AppTypography.inter(
        fontSize: s.fs(12),
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1,
        letterSpacing: 0,
      );

  /// Content switcher unselected — Inter Bold 12.
  static TextStyle tabUnselected(FigmaScale s) => AppTypography.inter(
        fontSize: s.fs(12),
        fontWeight: FontWeight.w700,
        color: textSecondary,
        height: 1,
        letterSpacing: 0,
      );

  /// `7125:6617` — Inter Semi Bold 14, line-height 20px.
  static TextStyle cardTitle(FigmaScale s) => AppTypography.inter(
        fontSize: s.fs(14),
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 20 / 14,
        letterSpacing: 0,
      );

  /// `7125:6618` — Inter Regular 12, line-height 16px, tracking 0.12px.
  static TextStyle cardBody(FigmaScale s) => AppTypography.inter(
        fontSize: s.fs(12),
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 16 / 12,
        letterSpacing: 0.12,
      );

  /// `7125:6637` — Inter Regular 12, black.
  static TextStyle timestamp(FigmaScale s) => AppTypography.inter(
        fontSize: s.fs(12),
        fontWeight: FontWeight.w400,
        color: Colors.black,
        height: 16 / 12,
        letterSpacing: 0.12,
      );

  /// Accept / Reject — Inter Semi Bold 10.
  static TextStyle actionSmall(FigmaScale s, Color color) => AppTypography.inter(
        fontSize: s.fs(10),
        fontWeight: FontWeight.w600,
        color: color,
        height: 1,
        letterSpacing: 0,
      );

  /// `7125:6640` — Inter Semi Bold 12.
  static TextStyle markAllRead(FigmaScale s) => AppTypography.inter(
        fontSize: s.fs(12),
        fontWeight: FontWeight.w600,
        color: brandGold,
        height: 1,
        letterSpacing: 0,
      );
}
