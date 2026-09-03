import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Figma `7125:6270` text styles — exact family, size, weight, line-height.
abstract final class WalletTypography {
  static const mutedText = Color(0xFF94AFB6);
  static const creditGreen = Color(0xFF41BE06);
  static const balanceGold = Color(0xFFBA8220);

  /// `7125:6278` — Inter Regular 16, leading normal.
  static TextStyle title(FigmaScale s) => AppTypography.inter(
        fontSize: s.fs(16),
        fontWeight: FontWeight.w400,
        color: Colors.white,
        height: 1,
        letterSpacing: 0,
      );

  /// `7125:6324` — Nunito Bold 42, line-height 20.02px.
  static TextStyle balance(FigmaScale s) => AppTypography.nunito(
        fontSize: s.fs(42),
        fontWeight: FontWeight.w700,
        color: balanceGold,
        height: 20.02 / 42,
        letterSpacing: 0,
      );

  /// `7125:6325` — Nunito Bold 14, line-height 20.02px.
  static TextStyle withdraw(FigmaScale s) => AppTypography.nunito(
        fontSize: s.fs(14),
        fontWeight: FontWeight.w700,
        color: Colors.white,
        height: 20.02 / 14,
        letterSpacing: 0,
      );

  /// `7125:6285` — Nunito SemiBold 13, line-height 20.02px.
  static TextStyle date(FigmaScale s) => AppTypography.nunito(
        fontSize: s.fs(13),
        fontWeight: FontWeight.w600,
        color: mutedText,
        height: 20.02 / 13,
        letterSpacing: 0,
      );

  /// `7125:6283` — Nunito SemiBold 17, line-height 20.02px.
  static TextStyle credit(FigmaScale s) => AppTypography.nunito(
        fontSize: s.fs(17),
        fontWeight: FontWeight.w600,
        color: mutedText,
        height: 20.02 / 17,
        letterSpacing: 0,
      );

  /// `7125:6284` — IBM Plex Sans Medium 11, line-height 16px.
  static TextStyle time(FigmaScale s) => AppTypography.ibmPlexSans(
        fontSize: s.fs(11),
        fontWeight: FontWeight.w500,
        color: mutedText,
        height: 16 / 11,
        letterSpacing: 0,
      );

  /// `7125:6282` debit — IBM Plex Sans Regular 14, #EB1F39.
  static TextStyle debitAmount(FigmaScale s) => AppTypography.ibmPlexSans(
        fontSize: s.fs(14),
        fontWeight: FontWeight.w400,
        color: const Color(0xFFEB1F39),
        height: 18 / 14,
        letterSpacing: 0,
      );

  /// `7136:1744` — Nunito Bold 14, white.
  static TextStyle addFunds(FigmaScale s) => AppTypography.nunito(
        fontSize: s.fs(14),
        fontWeight: FontWeight.w700,
        color: Colors.white,
        height: 20.02 / 14,
        letterSpacing: 0,
      );

  /// `7125:6282` — IBM Plex Sans Regular 14, line-height 18px.
  static TextStyle amount(FigmaScale s) => AppTypography.ibmPlexSans(
        fontSize: s.fs(14),
        fontWeight: FontWeight.w400,
        color: creditGreen,
        height: 18 / 14,
        letterSpacing: 0,
      );

  /// Figma vertically centers label text on [designY] (−translate-y-1/2).
  static double centeredLabelTop(double designY, double lineBoxHeight) =>
      designY - (lineBoxHeight / 2);
}
