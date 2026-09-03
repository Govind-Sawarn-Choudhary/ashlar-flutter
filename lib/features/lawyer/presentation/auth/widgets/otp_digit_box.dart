import 'dart:math' as math;

import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Single OTP cell — Figma `Rectangle 25126` @ 63.58×63, radius 14.
class OtpDigitBox extends StatelessWidget {
  const OtpDigitBox({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.size = 63.581661224365234,
    this.borderRadius = 14,
    this.fontSize = 24,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final double size;
  final double borderRadius;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final verticalPad = math.max(0.0, (size - fontSize) / 2 - 1);

    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.otpBoxGradientTop,
              AppColors.otpBoxGradientBottom,
            ],
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Center(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: AppTypography.openSans(
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
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
              ),
              onChanged: onChanged,
            ),
          ),
        ),
      ),
    );
  }
}
