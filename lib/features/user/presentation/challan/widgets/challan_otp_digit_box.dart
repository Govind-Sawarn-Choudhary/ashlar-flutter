import 'dart:math' as math;

import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Transparent digit overlay on PNG OTP cells — Figma `7125:2205`–`7125:2208`.
class ChallanOtpDigitBox extends StatelessWidget {
  const ChallanOtpDigitBox({
    super.key,
    required this.scale,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final FigmaScale scale;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final size = s.s(63.581661224365234);
    final fontSize = s.fs(24);
    final verticalPad = math.max(0.0, (size - fontSize) / 2 - 1);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Center(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                textAlign: TextAlign.center,
                textAlignVertical: TextAlignVertical.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: AppTypography.inter(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: fontSize,
                  height: 1.1,
                ),
                strutStyle: StrutStyle(
                  fontSize: fontSize,
                  height: 1.1,
                  forceStrutHeight: true,
                ),
                cursorColor: Colors.black,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                buildCounter: (
                  context, {
                  required currentLength,
                  required isFocused,
                  required maxLength,
                }) =>
                    null,
                decoration: InputDecoration(
                  counterText: '',
                  isDense: true,
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: EdgeInsets.symmetric(vertical: verticalPad),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                onChanged: onChanged,
              ),
            ),
          ),
          if (!focusNode.hasFocus && controller.text.isEmpty)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: focusNode.requestFocus,
              ),
            ),
        ],
      ),
    );
  }
}
