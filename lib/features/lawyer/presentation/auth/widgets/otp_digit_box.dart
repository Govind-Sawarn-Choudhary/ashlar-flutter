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
    this.onBackspaceWhenEmpty,
    this.showFocusRing = false,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback? onBackspaceWhenEmpty;
  final VoidCallback? onSubmitted;
  final double size;
  final double borderRadius;
  final double fontSize;
  final bool showFocusRing;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final verticalPad = math.max(0.0, (size - fontSize) / 2 - 1);

    return ListenableBuilder(
      listenable: focusNode,
      builder: (context, _) {
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
              boxShadow: focusNode.hasFocus && showFocusRing
                  ? [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.35),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: Center(
                child: Focus(
                  onKeyEvent: (node, event) {
                    if (onBackspaceWhenEmpty != null &&
                        event is KeyDownEvent &&
                        event.logicalKey == LogicalKeyboardKey.backspace &&
                        controller.text.isEmpty) {
                      onBackspaceWhenEmpty!();
                      return KeyEventResult.handled;
                    }
                    return KeyEventResult.ignored;
                  },
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    keyboardType: TextInputType.number,
                    textInputAction: textInputAction,
                    maxLength: 6,
                    autofillHints: const [AutofillHints.oneTimeCode],
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
                      focusedBorder: showFocusRing
                          ? OutlineInputBorder(
                              borderRadius: BorderRadius.circular(borderRadius),
                              borderSide: BorderSide(
                                color: AppColors.gold.withValues(alpha: 0.7),
                                width: 1.5,
                              ),
                            )
                          : InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                    ),
                    onChanged: onChanged,
                    onSubmitted: onSubmitted != null ? (_) => onSubmitted!() : null,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
