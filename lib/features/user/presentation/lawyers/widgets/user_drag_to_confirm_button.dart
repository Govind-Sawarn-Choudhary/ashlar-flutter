import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/widgets/auth_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Transparent swipe overlay — Figma black pill @ 324×60 with gold knob (52×52).
///
/// PNG underneath shows track + label; only the draggable knob is drawn here.
class UserDragToConfirmButton extends StatefulWidget {
  const UserDragToConfirmButton({
    super.key,
    required this.onComplete,
  });

  final VoidCallback onComplete;

  static const designHeight = 60.0;
  static const designKnobInset = 4.0;

  @override
  State<UserDragToConfirmButton> createState() => _UserDragToConfirmButtonState();
}

class _UserDragToConfirmButtonState extends State<UserDragToConfirmButton>
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
    } else {
      _snapTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final inset = height * (UserDragToConfirmButton.designKnobInset /
            UserDragToConfirmButton.designHeight);
        final circleSize = height - inset * 2;
        final maxSlide = constraints.maxWidth - circleSize - inset;
        final knobLeft = inset + maxSlide * _progress;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: _onDragStart,
          onHorizontalDragUpdate: (d) => _onDragUpdate(d, maxSlide),
          onHorizontalDragEnd: _onDragEnd,
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedPositioned(
                  duration:
                      _isDragging ? Duration.zero : const Duration(milliseconds: 16),
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
              ],
            ),
          ),
        );
      },
    );
  }
}
