import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Center title + gold side lines — Figma `7125:5673` / `5674` / `5675`.
class LawyerSectionHeading extends StatelessWidget {
  const LawyerSectionHeading({
    super.key,
    required this.title,
    required this.scale,
    this.titleWidth,
    this.titleX = 121,
    this.titleY = 113,
  });

  final String title;
  final FigmaScale scale;
  final double? titleWidth;
  final double titleX;
  final double titleY;

  /// Figma `7125:5673` — 16px SemiBold, frame 143×22 @ (121, 113).
  static const _titleFontSize = 16.0;
  static const _titleFrameH = 22.0;
  static const _lineY = 130.0;
  static const _lineLeftX = 33.0;
  static const _lineRightX = 265.0;
  static const _lineW = 72.0;
  static const _lineH = 1.5;

  @override
  Widget build(BuildContext context) {
    final lineTop = scale.s(_lineY - titleY);

    return SizedBox(
      width: scale.viewportWidth,
      height: scale.s(_lineY + _lineH - titleY),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: scale.s(_lineLeftX),
            top: lineTop,
            child: _goldLine(),
          ),
          Positioned(
            left: scale.s(_lineRightX),
            top: lineTop,
            child: _goldLine(),
          ),
          Positioned(
            left: scale.s(titleX),
            top: 0,
            width: titleWidth != null ? scale.s(titleWidth!) : null,
            height: scale.s(_titleFrameH),
            child: Align(
              alignment: Alignment.topCenter,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: AppTypography.openSans(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w600,
                  fontSize: scale.fs(_titleFontSize),
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _goldLine() {
    return Container(
      width: scale.s(_lineW),
      height: scale.s(_lineH),
      color: AppColors.gold,
    );
  }
}
