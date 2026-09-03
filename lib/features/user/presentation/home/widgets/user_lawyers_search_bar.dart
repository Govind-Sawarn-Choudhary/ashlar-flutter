import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Search row — Figma `7125:2318` @ (15, 121), 332×45.
///
/// Figma PNG is always visible; a transparent [TextField] sits over the text area.
class UserLawyersSearchBar extends StatefulWidget {
  const UserLawyersSearchBar({
    super.key,
    required this.scale,
    this.controller,
    this.focusNode,
    this.onFilterTap,
  });

  final FigmaScale scale;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final VoidCallback? onFilterTap;

  @override
  State<UserLawyersSearchBar> createState() => _UserLawyersSearchBarState();
}

class _UserLawyersSearchBarState extends State<UserLawyersSearchBar> {
  static const _textColor = Color(0xFF151A2D);

  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final bool _ownsController;
  late final bool _ownsFocusNode;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _ownsFocusNode = widget.focusNode == null;
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(() => setState(() {}));
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;
    final width = s.s(332);
    final height = s.s(45);
    final fieldWidth = s.s(277);
    final filterWidth = s.s(45);
    final textInset = s.s(16 + 24 + 8);
    final textWidth = fieldWidth - textInset - s.s(16);
    final showTextEntry = _focusNode.hasFocus || _controller.text.isNotEmpty;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Image.asset(
              AppAssets.userLawyersSearchRow,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.high,
            ),
          ),
          if (showTextEntry)
            Positioned(
              left: textInset,
              top: s.s(10),
              width: textWidth,
              height: height - s.s(20),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(s.s(6)),
                ),
              ),
            ),
          Positioned(
            left: textInset,
            top: 0,
            width: textWidth,
            height: height,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              style: AppTypography.inter(
                color: _textColor,
                fontWeight: FontWeight.w400,
                fontSize: s.fs(14),
                height: 1.35,
              ),
              cursorColor: _textColor,
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Positioned(
            left: fieldWidth + s.s(10),
            top: 0,
            width: filterWidth,
            height: height,
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: widget.onFilterTap,
                borderRadius: BorderRadius.circular(s.s(18)),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          if (!showTextEntry)
            Positioned(
              left: 0,
              top: 0,
              width: fieldWidth,
              height: height,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _focusNode.requestFocus,
              ),
            ),
        ],
      ),
    );
  }
}
