import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Three chevron arrows matching Figma `Frame 742` (22.5 × 11.5).
class TripleChevronIcon extends StatelessWidget {
  const TripleChevronIcon({
    super.key,
    required this.color,
    this.width = 21,
    this.height = 10,
    this.opacities = const [1.0, 1.0, 1.0],
  });

  final Color color;
  final double width;
  final double height;
  final List<double> opacities;

  static const whiteFade = [0.4, 0.7, 1.0];

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _TripleChevronPainter(
        color: color,
        opacities: opacities,
      ),
    );
  }
}

class _TripleChevronPainter extends CustomPainter {
  _TripleChevronPainter({
    required this.color,
    required this.opacities,
  });

  final Color color;
  final List<double> opacities;

  static const _designWidth = 22.5;
  static const _designHeight = 11.5;
  static const _xOffsets = [0.75, 8.75, 16.75];

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / _designWidth;
    final scaleY = size.height / _designHeight;
    final strokeWidth = 1.5 * scaleX;

    for (var i = 0; i < 3; i++) {
      final paint = Paint()
        ..color = color.withValues(alpha: opacities[i])
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final x = _xOffsets[i] * scaleX;
      final path = Path()
        ..moveTo(x, 10.75 * scaleY)
        ..lineTo(x + 5 * scaleX, 5.75 * scaleY)
        ..lineTo(x, 0.75 * scaleY);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TripleChevronPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.opacities != opacities;
  }
}

/// Figma frame `7125:5453` — Get Started pill with sliding gold knob.
class GetStartedButton extends StatefulWidget {
  const GetStartedButton({
    super.key,
    required this.label,
    required this.onComplete,
  });

  final String label;
  final VoidCallback onComplete;

  static const _height = 60.0;
  static const _radius = 32.0;
  static const _circleInset = 4.0;

  @override
  State<GetStartedButton> createState() => _GetStartedButtonState();
}

class _GetStartedButtonState extends State<GetStartedButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _snapController;

  double _progress = 0;
  bool _hasCompleted = false;
  bool _isDragging = false;

  static const _completeThreshold = 0.88;
  static const _snapDuration = Duration(milliseconds: 280);

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: _snapDuration,
    );
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  Future<void> _snapTo(double target) async {
    if (_hasCompleted || !mounted) {
      return;
    }

    final begin = _progress;
    final animation = Tween<double>(begin: begin, end: target).animate(
      CurvedAnimation(
        parent: _snapController,
        curve: Curves.easeOutCubic,
      ),
    );

    void listener() {
      if (mounted) {
        setState(() => _progress = animation.value);
      }
    }

    animation.addListener(listener);
    _snapController
      ..duration = _snapDuration
      ..reset();
    await _snapController.forward();
    animation.removeListener(listener);
    _snapController.reset();

    if (!mounted || _hasCompleted) {
      return;
    }

    if (target >= 1.0) {
      _hasCompleted = true;
      HapticFeedback.mediumImpact();
      widget.onComplete();
    }
  }

  void _onDragStart(DragStartDetails details) {
    if (_hasCompleted) {
      return;
    }
    _snapController.stop();
    setState(() => _isDragging = true);
  }

  void _onDragUpdate(DragUpdateDetails details, double maxSlide) {
    if (_hasCompleted || maxSlide <= 0) {
      return;
    }

    setState(() {
      _progress = (_progress + details.delta.dx / maxSlide).clamp(0.0, 1.0);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_hasCompleted) {
      return;
    }

    setState(() => _isDragging = false);

    final velocity = details.velocity.pixelsPerSecond.dx;
    if (_progress >= _completeThreshold || velocity > 800) {
      _snapTo(1);
    } else if (velocity < -800) {
      _snapTo(0);
    } else {
      _snapTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final inset = height * (GetStartedButton._circleInset / GetStartedButton._height);
        final circleSize = height - inset * 2;
        final maxSlide = constraints.maxWidth - circleSize - inset;
        final knobLeft = inset + maxSlide * _progress;
        final labelOpacity = 1.0 - (_progress * 0.85);
        final radius = height * (GetStartedButton._radius / GetStartedButton._height);

        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
          clipBehavior: Clip.antiAlias,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: _onDragStart,
            onHorizontalDragUpdate: (d) => _onDragUpdate(d, maxSlide),
            onHorizontalDragEnd: _onDragEnd,
            child: SizedBox(
              height: constraints.maxHeight,
              width: double.infinity,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedPositioned(
                    duration: _isDragging
                        ? Duration.zero
                        : const Duration(milliseconds: 16),
                    curve: Curves.easeOut,
                    left: knobLeft,
                    top: inset,
                    child: Material(
                      elevation: _isDragging ? 4 : 0,
                      shadowColor: Colors.black26,
                      color: AppColors.gold,
                      shape: const CircleBorder(),
                      child: SizedBox(
                        width: circleSize,
                        height: circleSize,
                        child: Center(
                          child: TripleChevronIcon(
                            color: Colors.white,
                            width: circleSize * 0.404,
                            height: circleSize * 0.192,
                            opacities: TripleChevronIcon.whiteFade,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Opacity(
                      opacity: labelOpacity,
                      child: Text(
                        widget.label,
                        style: AppTypography.inter(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: constraints.maxHeight * 0.267,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: constraints.maxWidth * 0.035,
                    top: 0,
                    bottom: 0,
                    child: Opacity(
                      opacity: 0.35 + _progress * 0.65,
                      child: Center(
                        child: TripleChevronIcon(
                          color: AppColors.gold,
                          width: constraints.maxWidth * 0.065,
                          height: constraints.maxHeight * 0.167,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Profile flow continue — Figma `7125:5805` (324×52, white, radius 10).
class ProfileContinueButton extends StatelessWidget {
  const ProfileContinueButton({
    super.key,
    required this.label,
    required this.onTap,
    this.scaleX = 1,
    this.scaleY = 1,
  });

  final String label;
  final VoidCallback onTap;
  final double scaleX;
  final double scaleY;

  static const _designHeight = 52.0;
  static const _designRadius = 10.0;
  static const _chevronLeft = 281.0;

  @override
  Widget build(BuildContext context) {
    final height = _designHeight * scaleY;
    final radius = _designRadius * scaleY;
    final fontSize = 16 * scaleX;
    final chevronW = 21 * scaleX;
    final chevronH = 10 * scaleY;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(radius),
          ),
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(
                  child: Text(
                    label,
                    style: AppTypography.inter(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w700,
                      fontSize: fontSize,
                      height: 1,
                    ),
                  ),
                ),
                Positioned(
                  left: _chevronLeft * scaleX,
                  top: (height - chevronH) / 2,
                  child: TripleChevronIcon(
                    color: AppColors.gold,
                    width: chevronW,
                    height: chevronH,
                    opacities: TripleChevronIcon.whiteFade,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GoldActionButton extends StatelessWidget {
  const GoldActionButton({
    super.key,
    required this.label,
    required this.onTap,
    this.showChevrons = true,
    this.scaleX = 1,
    this.scaleY = 1,
  });

  final String label;
  final VoidCallback onTap;
  final bool showChevrons;
  final double scaleX;
  final double scaleY;

  @override
  Widget build(BuildContext context) {
    final height = 52 * scaleY;
    final radius = height / 2;
    final fontSize = 16 * scaleX;
    final chevronRight = 11.5 * scaleX;
    final chevronW = 21 * scaleX;
    final chevronH = 10 * scaleY;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.buttonGradientStart,
                AppColors.buttonGradientEnd,
              ],
            ),
          ),
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  label,
                  style: AppTypography.inter(
                    color: AppColors.buttonLabelGold,
                    fontWeight: FontWeight.w700,
                    fontSize: fontSize,
                    height: 1,
                  ),
                ),
                if (showChevrons)
                  Positioned(
                    right: chevronRight,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: TripleChevronIcon(
                        color: AppColors.buttonLabelGold,
                        width: chevronW,
                        height: chevronH,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
