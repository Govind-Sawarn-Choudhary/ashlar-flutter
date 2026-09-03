import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class TripleChevron extends StatelessWidget {
  const TripleChevron({
    super.key,
    this.color = AppColors.gold,
    this.size = 10,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        3,
        (index) => Padding(
          padding: EdgeInsets.only(left: index == 0 ? 0 : 2),
          child: Icon(
            Icons.chevron_right,
            color: color,
            size: size,
          ),
        ),
      ),
    );
  }
}
