import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AuthPageIndicator extends StatelessWidget {
  const AuthPageIndicator({
    super.key,
    required this.activeIndex,
    this.itemCount = 3,
    this.scaleX = 1,
    this.inactiveColor,
  });

  final int activeIndex;
  final int itemCount;
  final double scaleX;
  final Color? inactiveColor;

  @override
  Widget build(BuildContext context) {
    final dotHeight = 6 * scaleX;
    final gap = 8 * scaleX;
    final radius = 16 * scaleX;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(itemCount, (index) {
        final isActive = index == activeIndex;
        return Container(
          width: (isActive ? 40 : 12) * scaleX,
          height: dotHeight,
          margin: EdgeInsets.only(right: index == itemCount - 1 ? 0 : gap),
          decoration: BoxDecoration(
            color: isActive
                ? Colors.white
                : (inactiveColor ?? AppColors.indicatorInactive),
            borderRadius: BorderRadius.circular(radius),
          ),
        );
      }),
    );
  }
}
