import 'package:flutter/material.dart';

/// Premium dark-gold design tokens for the user/client app.
abstract final class UserDesignTokens {
  static const background = Color(0xFF0A0A0C);
  static const surface = Color(0xFF141418);
  static const surfaceElevated = Color(0xFF1C1C22);
  static const gold = Color(0xFFD4AF37);
  static const goldSoft = Color(0x33D4AF37);
  static const goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8C547), Color(0xFFB8941F)],
  );
  static const cardBorder = Color(0x22FFFFFF);
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xFFB0B0BC);
  static const textMuted = Color(0xFF78788C);
  static const success = Color(0xFF4ADE80);
  static const error = Color(0xFFF87171);

  static const radiusSm = 10.0;
  static const radiusMd = 14.0;
  static const radiusLg = 20.0;
  static const radiusXl = 24.0;

  static List<BoxShadow> get cardShadow => const [
        BoxShadow(
          color: Color(0x40000000),
          blurRadius: 20,
          offset: Offset(0, 8),
        ),
      ];

  static BoxDecoration premiumCard({Color? tint}) => BoxDecoration(
        color: tint ?? surfaceElevated,
        borderRadius: BorderRadius.circular(radiusMd),
        border: Border.all(color: cardBorder),
        boxShadow: cardShadow,
      );

  static BoxDecoration goldAccentCard() => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gold.withValues(alpha: 0.18),
            surfaceElevated,
          ],
        ),
        borderRadius: BorderRadius.circular(radiusMd),
        border: Border.all(color: gold.withValues(alpha: 0.35)),
      );
}
