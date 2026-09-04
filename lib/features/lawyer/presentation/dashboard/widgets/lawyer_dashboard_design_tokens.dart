import 'package:flutter/material.dart';

/// Shared visual tokens for the lawyer dashboard.
abstract final class LawyerDashboardTokens {
  static const surface = Colors.white;
  static const surfaceBorder = Color(0xFFF0F0F5);
  static const textPrimary = Color(0xFF171725);
  static const textSecondary = Color(0xFF92929D);
  static const radiusLg = 24.0;
  static const radiusMd = 16.0;
  static const radiusSm = 12.0;

  static List<BoxShadow> get surfaceShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static BoxDecoration surfaceDecoration({double radius = radiusLg}) {
    return BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: surfaceBorder),
      boxShadow: surfaceShadow,
    );
  }
}
