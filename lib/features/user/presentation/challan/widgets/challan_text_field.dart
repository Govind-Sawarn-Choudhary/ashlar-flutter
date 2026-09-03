import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/challan/challan_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Figma white input row — 320×52, radius 10, shadow (`7125:2136` / `7125:2175`).
class ChallanTextField extends StatelessWidget {
  const ChallanTextField({
    super.key,
    required this.scale,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
  });

  final FigmaScale scale;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final radius = s.s(10);
    final showFieldChrome = focusNode.hasFocus || controller.text.isNotEmpty;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (showFieldChrome)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 4,
                    offset: Offset.zero,
                  ),
                ],
              ),
            ),
          ),
        Positioned.fill(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            textCapitalization: textCapitalization,
            style: ChallanTypography.fieldValue(s),
            cursorColor: Colors.black,
            decoration: InputDecoration(
              isCollapsed: true,
              contentPadding: EdgeInsets.fromLTRB(
                s.s(22),
                s.s(17),
                s.s(16),
                s.s(16),
              ),
              hintText: showFieldChrome ? hintText : null,
              hintStyle: ChallanTypography.fieldHint(s),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
        if (!showFieldChrome)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: focusNode.requestFocus,
            ),
          ),
      ],
    );
  }
}
