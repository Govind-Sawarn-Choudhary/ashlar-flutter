import 'dart:math' as math;

import 'package:flutter/material.dart';

/// How the 360×800 artboard is placed on the device viewport.
enum FigmaArtboardAlign {
  /// Matches Figma mobile preview — content starts at the top.
  top,

  /// Centers the artboard vertically (adds empty space on tall phones).
  center,
}

/// Uniform scale from Figma 360×800 artboard — preserves exact proportions.
class FigmaScale {
  const FigmaScale._({
    required this.scale,
    required this.artboardTop,
    required this.artboardHeight,
    required this.viewportWidth,
  });

  /// Multiplier (width / 360).
  final double scale;

  /// Y offset when the artboard is vertically centered on the viewport.
  final double artboardTop;

  final double artboardHeight;
  final double viewportWidth;

  factory FigmaScale.fromViewport(
    Size viewport, {
    double designWidth = 360,
    double designHeight = 800,
    FigmaArtboardAlign align = FigmaArtboardAlign.top,
  }) {
    final scale = viewport.width / designWidth;
    final artboardHeight = designHeight * scale;
    final artboardTop = switch (align) {
      FigmaArtboardAlign.top => 0.0,
      FigmaArtboardAlign.center =>
        ((viewport.height - artboardHeight) / 2).clamp(0.0, double.infinity),
    };

    return FigmaScale._(
      scale: scale,
      artboardTop: artboardTop,
      artboardHeight: artboardHeight,
      viewportWidth: viewport.width,
    );
  }

  /// Scales the artboard to fit entirely inside [viewport] (letterboxed).
  factory FigmaScale.fitViewport(
    Size viewport, {
    double designWidth = 360,
    double designHeight = 800,
  }) {
    final widthScale = viewport.width / designWidth;
    final heightScale = viewport.height / designHeight;
    final scale = math.min(widthScale, heightScale);
    final artboardHeight = designHeight * scale;

    return FigmaScale._(
      scale: scale,
      artboardTop: (viewport.height - artboardHeight) / 2,
      artboardHeight: artboardHeight,
      viewportWidth: viewport.width,
    );
  }

  double s(double designValue) => designValue * scale;

  /// Alias helpers for readability in screen layouts.
  double dx(double designX) => s(designX);
  double dy(double designY) => s(designY);
  double fs(double designFontSize) => s(designFontSize);
}

/// Centers the 360×800 artboard on the device; content uses [FigmaScale.s].
class FigmaScreenCanvas extends StatelessWidget {
  const FigmaScreenCanvas({
    super.key,
    required this.builder,
    this.designWidth = 360,
    this.designHeight = 800,
    this.align = FigmaArtboardAlign.top,
  });

  final Widget Function(BuildContext context, FigmaScale scale) builder;
  final double designWidth;
  final double designHeight;
  final FigmaArtboardAlign align;

  @override
  Widget build(BuildContext context) {
    final viewport = MediaQuery.sizeOf(context);
    final scale = FigmaScale.fromViewport(
      viewport,
      designWidth: designWidth,
      designHeight: designHeight,
      align: align,
    );

    return SizedBox(
      width: viewport.width,
      height: viewport.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: scale.artboardTop,
            width: viewport.width,
            height: math.max(
              scale.artboardHeight,
              viewport.height - scale.artboardTop,
            ),
            child: builder(context, scale),
          ),
        ],
      ),
    );
  }
}
