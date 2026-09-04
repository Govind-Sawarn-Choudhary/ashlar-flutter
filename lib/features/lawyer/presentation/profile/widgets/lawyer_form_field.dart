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
    this.readOnly = false,
    this.label,
    this.helperText,
    this.textInputAction,
    this.onSubmitted,
    this.maxLength,
    this.validator,
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
  final bool readOnly;
  final String? label;
  final String? helperText;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final int? maxLength;
  final FormFieldValidator<String>? validator;

  static const _designRadius = 10.0;

  @override
  Widget build(BuildContext context) {
    final radius = scale.s(_designRadius);
    final fieldWidth = width.isFinite ? scale.s(width) : width;

    final field = SizedBox(
      width: fieldWidth,
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
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            readOnly: readOnly,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            maxLines: maxLines,
            maxLength: maxLength,
            textInputAction: textInputAction,
            onFieldSubmitted: onSubmitted,
            validator: validator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
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
              fillColor: readOnly ? const Color(0xFFF5F5F5) : AppColors.inputBackground,
              isDense: true,
              counterText: maxLength != null ? '' : null,
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
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius),
                borderSide: BorderSide(
                  color: AppColors.gold.withValues(alpha: 0.75),
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius),
                borderSide: const BorderSide(color: Color(0xFFE53935)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius),
                borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.5),
              ),
              errorStyle: AppTypography.inter(
                color: const Color(0xFFFFCDD2),
                fontSize: scale.fs(11),
              ),
            ),
          ),
        ),
      ),
    );

    if (label == null && helperText == null) {
      return field;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: EdgeInsets.only(left: scale.s(2), bottom: scale.s(6)),
            child: Text(
              label!,
              style: AppTypography.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: scale.fs(13),
              ),
            ),
          ),
        field,
        if (helperText != null) ...[
          SizedBox(height: scale.s(6)),
          Text(
            helperText!,
            style: AppTypography.inter(
              color: Colors.white54,
              fontSize: scale.fs(11),
              height: 1.35,
            ),
          ),
        ],
      ],
    );
  }
}
