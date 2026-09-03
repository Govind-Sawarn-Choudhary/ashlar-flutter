import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// White rounded input — Figma `Rectangle 15` (320×52, radius 10, shadow).
class LawyerFormField extends StatelessWidget {
  const LawyerFormField({
    super.key,
    required this.scale,
    required this.hint,
    this.controller,
    this.focusNode,
    this.height = 52,
    this.maxLines = 1,
    this.suffixIcon,
    this.keyboardType,
    this.inputFormatters,
    this.hintPaddingLeft = 22,
    this.hintPaddingTop = 17,
    this.width = 320,
  });

  final FigmaScale scale;
  final String hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final double height;
  final int maxLines;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final double hintPaddingLeft;
  final double hintPaddingTop;
  final double width;

  static const _designRadius = 10.0;

  @override
  Widget build(BuildContext context) {
    final radius = scale.s(_designRadius);

    return SizedBox(
      width: scale.s(width),
      height: scale.s(height),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 4,
              offset: Offset.zero,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            maxLines: maxLines,
            style: AppTypography.openSans(
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: scale.fs(16),
              height: 19 / 16,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTypography.openSans(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w400,
                fontSize: scale.fs(16),
                height: 19 / 16,
              ),
              filled: true,
              fillColor: AppColors.inputBackground,
              isDense: true,
              contentPadding: EdgeInsets.fromLTRB(
                scale.s(hintPaddingLeft),
                scale.s(hintPaddingTop),
                suffixIcon != null ? scale.s(40) : scale.s(hintPaddingLeft),
                scale.s(maxLines > 1 ? 14 : 16),
              ),
              suffixIcon: suffixIcon == null
                  ? null
                  : Padding(
                      padding: EdgeInsets.only(right: scale.s(16)),
                      child: suffixIcon,
                    ),
              suffixIconConstraints: BoxConstraints(
                minWidth: scale.s(18),
                minHeight: scale.s(18),
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}
