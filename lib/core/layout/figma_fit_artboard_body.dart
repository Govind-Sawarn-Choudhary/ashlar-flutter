import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:flutter/material.dart';

/// Letterboxes a 360×[designHeight] artboard so the full design fits on screen.
class FigmaFitArtboardBody extends StatelessWidget {
  const FigmaFitArtboardBody({
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
    final scale = FigmaScale.fitViewport(
      viewport,
      designWidth: designWidth,
      designHeight: designHeight,
    );
    final artboardWidth = designWidth * scale.scale;
    final offsetX = (viewport.width - artboardWidth) / 2;

    return ColoredBox(
      color: backgroundColor,
      child: Stack(
        children: [
          Positioned(
            left: offsetX,
            top: scale.artboardTop,
            width: artboardWidth,
            height: scale.artboardHeight,
            child: builder(context, scale),
          ),
        ],
      ),
    );
  }
}
