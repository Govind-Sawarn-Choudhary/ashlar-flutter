import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

enum AppMessageType { info, success, error }

/// Consistent dark-gold toasts for the whole app (no default white snackbars).
abstract final class AppMessenger {
  static SnackBarThemeData get theme => SnackBarThemeData(
        backgroundColor: const Color(0xFF1C1C22),
        contentTextStyle: AppTypography.inter(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.35,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: AppColors.goldLight.withValues(alpha: 0.35)),
        ),
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        actionTextColor: AppColors.goldLight,
        dismissDirection: DismissDirection.down,
      );

  static void show(
    BuildContext context,
    String message, {
    AppMessageType type = AppMessageType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      return;
    }

    messenger.hideCurrentSnackBar();

    final accent = switch (type) {
      AppMessageType.success => const Color(0xFF4ADE80),
      AppMessageType.error => const Color(0xFFF87171),
      AppMessageType.info => AppColors.goldLight,
    };

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(_iconFor(type), color: accent, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppTypography.inter(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1C1C22),
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: accent.withValues(alpha: 0.45)),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      ),
    );
  }

  static IconData _iconFor(AppMessageType type) {
    return switch (type) {
      AppMessageType.success => Icons.check_circle_outline_rounded,
      AppMessageType.error => Icons.error_outline_rounded,
      AppMessageType.info => Icons.info_outline_rounded,
    };
  }
}
