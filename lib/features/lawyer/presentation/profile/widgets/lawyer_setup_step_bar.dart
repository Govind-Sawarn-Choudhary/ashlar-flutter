import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Three-step bar — Figma `7125:5695` / `5701` / `5707` @ y=164.
class LawyerSetupStepBar extends StatelessWidget {
  const LawyerSetupStepBar({
    super.key,
    required this.scale,
    this.activeStep = 0,
    this.showProgressTracks = false,
  });

  final FigmaScale scale;
  final int activeStep;
  final bool showProgressTracks;

  static const _designTop = 164.0;
  static const _wrapperH = 82.0;
  static const _paddingTop = 16.0;
  static const _circleSize = 20.0;
  static const _labelTop = 46.0;
  static const _labelH = 20.0;
  static const _connectorH = 1.0;

  static const _steps = [
    _StepWrapperLayout(
      left: 18,
      width: 75,
      circleLeft: 27.5,
      labelLeft: 1.5,
      labelWidth: 72,
      label: 'Personal info',
    ),
    _StepWrapperLayout(
      left: 140,
      width: 86,
      circleLeft: 33,
      labelLeft: -8.5,
      labelWidth: 103,
      label: 'Upload Documents',
    ),
    _StepWrapperLayout(
      left: 257,
      width: 86,
      circleLeft: 33,
      labelLeft: -4.5,
      labelWidth: 95,
      label: 'Select Availability',
    ),
  ];

  double _circleAbsoluteLeft(int index) =>
      _steps[index].left + _steps[index].circleLeft;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: scale.viewportWidth,
      height: scale.s(_wrapperH),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (showProgressTracks) ...[
            _progressTrack(left: 92, width: 57),
            _progressTrack(left: 219, width: 52),
          ],
          _connectorLine(0, 1),
          _connectorLine(1, 2),
          for (var i = 0; i < _steps.length; i++)
            _buildStepWrapper(i, _steps[i]),
        ],
      ),
    );
  }

  /// Figma `7125:5789` / `7125:5790` — grey track @ y=188.
  Widget _progressTrack({required double left, required double width}) {
    return Positioned(
      left: scale.s(left),
      top: scale.s(188 - _designTop),
      width: scale.s(width),
      height: scale.s(3),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFCFD6DC),
          borderRadius: BorderRadius.circular(scale.s(2)),
        ),
      ),
    );
  }

  Widget _connectorLine(int fromIndex, int toIndex) {
    final fromRight = _circleAbsoluteLeft(fromIndex) + _circleSize;
    final toLeft = _circleAbsoluteLeft(toIndex);
    final lineTop = _designTop + _paddingTop + (_circleSize - _connectorH) / 2;

    return Positioned(
      left: scale.s(fromRight),
      top: scale.s(lineTop - _designTop),
      width: scale.s(toLeft - fromRight),
      height: scale.s(_connectorH),
      child: const ColoredBox(color: Colors.white),
    );
  }

  Widget _buildStepWrapper(int index, _StepWrapperLayout step) {
    final isActive = index == activeStep;
    final accent = isActive ? AppColors.gold : Colors.white;

    return Positioned(
      left: scale.s(step.left),
      top: 0,
      width: scale.s(step.width),
      height: scale.s(_wrapperH),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: scale.s(step.circleLeft),
            top: scale.s(_paddingTop),
            child: _StepNumberCircle(
              scale: scale,
              number: index + 1,
              accent: accent,
            ),
          ),
          Positioned(
            left: scale.s(step.labelLeft),
            top: scale.s(_labelTop),
            width: scale.s(step.labelWidth),
            height: scale.s(_labelH),
            child: Text(
              step.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.roboto(
                color: accent,
                fontWeight: FontWeight.w500,
                fontSize: scale.fs(12),
                height: 20 / 12,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Figma `Step Number Small` — 20×20, 1px border, radius 10.
class _StepNumberCircle extends StatelessWidget {
  const _StepNumberCircle({
    required this.scale,
    required this.number,
    required this.accent,
  });

  final FigmaScale scale;
  final int number;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: scale.s(LawyerSetupStepBar._circleSize),
      height: scale.s(LawyerSetupStepBar._circleSize),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: accent,
          width: scale.s(1),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: AppTypography.roboto(
          color: accent,
          fontWeight: FontWeight.w500,
          fontSize: scale.fs(14),
          height: 20 / 14,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _StepWrapperLayout {
  const _StepWrapperLayout({
    required this.left,
    required this.width,
    required this.circleLeft,
    required this.labelLeft,
    required this.labelWidth,
    required this.label,
  });

  final double left;
  final double width;
  final double circleLeft;
  final double labelLeft;
  final double labelWidth;
  final String label;
}
