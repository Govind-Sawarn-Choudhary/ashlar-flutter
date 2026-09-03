import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Figma `7125:2125` text styles.
abstract final class ChallanTypography {
  /// `7125:2134` — Inter Regular 16 white.
  static TextStyle screenTitle(FigmaScale s) => AppTypography.inter(
        fontSize: s.fs(16),
        fontWeight: FontWeight.w400,
        color: Colors.white,
        height: 1,
      );

  /// `7125:2137` / `7125:2176` — Inter Regular 16 placeholder grey.
  static TextStyle fieldHint(FigmaScale s) => AppTypography.inter(
        fontSize: s.fs(16),
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
        height: 1,
      );

  /// Field input value — Inter Regular 16 black.
  static TextStyle fieldValue(FigmaScale s) => AppTypography.inter(
        fontSize: s.fs(16),
        fontWeight: FontWeight.w400,
        color: Colors.black,
        height: 1,
      );

  /// `7125:2139` / `7125:2194` — Inter Bold 16 gold.
  static TextStyle confirmLabel(FigmaScale s) => AppTypography.inter(
        fontSize: s.fs(16),
        fontWeight: FontWeight.w700,
        color: AppColors.gold,
        height: 1,
      );

  /// `7125:2191` — Open Sans SemiBold 24 white.
  static TextStyle otpTitle(FigmaScale s) => AppTypography.openSans(
        fontSize: s.fs(24),
        fontWeight: FontWeight.w600,
        color: Colors.white,
        height: 25 / 24,
      );

  /// `7125:2192` phone line — Inter Regular 16 `#BEBEBE`.
  static TextStyle otpPhoneLine(FigmaScale s) => AppTypography.inter(
        fontSize: s.fs(16),
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.2,
        letterSpacing: -0.24,
      );

  /// `7125:2209` — Inter SemiBold 12 resend label.
  static TextStyle resendActive(FigmaScale s) => AppTypography.inter(
        fontSize: s.fs(12),
        fontWeight: FontWeight.w600,
        color: Colors.white,
        height: 15 / 12,
        letterSpacing: -0.3,
      );

  /// `7125:2209` — Inter SemiBold 12 muted countdown.
  static TextStyle resendCountdown(FigmaScale s) => AppTypography.inter(
        fontSize: s.fs(12),
        fontWeight: FontWeight.w600,
        color: const Color(0x66FFFFFF),
        height: 15 / 12,
        letterSpacing: -0.3,
      );

  /// `7125:2161` — Open Sans SemiBold 16 gold, two lines.
  static TextStyle faqHeading(FigmaScale s) => AppTypography.openSans(
        fontSize: s.fs(16),
        fontWeight: FontWeight.w600,
        color: AppColors.gold,
        height: 1.375,
      );

  /// `7125:2151` etc. — Montserrat SemiBold 14 black.
  static TextStyle faqQuestion(FigmaScale s) => GoogleFonts.montserrat(
        fontSize: s.fs(14),
        fontWeight: FontWeight.w600,
        color: Colors.black,
        height: 1.2,
      );

  /// `7125:2152` etc. — Montserrat Medium 12 black.
  static TextStyle faqAnswer(FigmaScale s) => GoogleFonts.montserrat(
        fontSize: s.fs(12),
        fontWeight: FontWeight.w500,
        color: Colors.black,
        height: 1.25,
      );
}
