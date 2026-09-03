import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:flutter/material.dart';

/// Scrollable 360×[designHeight] artboard without iOS stretch / rubber-band distortion.
class FigmaTallArtboardBody extends StatelessWidget {
  const FigmaTallArtboardBody({
    super.key,
    required this.designHeight,
    required this.builder,
    this.designWidth = 360,
    this.backgroundColor = Colors.black,
  });

  final double designHeight;
  final double designWidth;
  final Color backgroundColor;
  final Widget Function(BuildContext context, FigmaScale scale) builder;

  @override
  Widget build(BuildContext context) {
    final viewport = MediaQuery.sizeOf(context);
    final scale = FigmaScale.fromViewport(
      viewport,
      designWidth: designWidth,
      designHeight: designHeight,
    );
    final artboardHeight = scale.artboardHeight;
    final needsScroll = artboardHeight > viewport.height + 0.5;

    final artboard = SizedBox(
      width: viewport.width,
      height: artboardHeight,
      child: builder(context, scale),
    );

    if (!needsScroll) {
      return ColoredBox(color: backgroundColor, child: artboard);
    }

    return ColoredBox(
      color: backgroundColor,
      child: ScrollConfiguration(
        behavior: const _NoStretchScrollBehavior(),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: artboard,
        ),
      ),
    );
  }
}

class _NoStretchScrollBehavior extends MaterialScrollBehavior {
  const _NoStretchScrollBehavior();

  @override
  bool get stretch => false;

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }
}
