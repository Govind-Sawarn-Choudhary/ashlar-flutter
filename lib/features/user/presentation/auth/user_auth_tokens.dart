import 'package:flutter/material.dart';

/// Shared tokens for user auth screens — Figma `7125:585` / `614` / `760`.
abstract final class UserAuthTokens {
  static const inactiveDotColor = Color(0x80FFFFFF);

  static const phoneFieldShadow = [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 4,
      offset: Offset.zero,
    ),
  ];
}
