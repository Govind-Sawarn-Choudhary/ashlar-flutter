import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

enum UserDashboardPreference { law, educational }

/// Law / Educational pill — Figma `7125:1767` @ (52, 380), 251×39.
class UserDashboardPreferenceToggle extends StatelessWidget {
  const UserDashboardPreferenceToggle({
    super.key,
    required this.scale,
    required this.selected,
    required this.onChanged,
  });

  final FigmaScale scale;
  final UserDashboardPreference selected;
  final ValueChanged<UserDashboardPreference> onChanged;

  @override
  Widget build(BuildContext context) {
    final width = scale.s(251);
    final height = scale.s(39);
    final radius = scale.s(50);
    final thumbW = scale.s(116.872);
    final thumbH = scale.s(33);
    final thumbLeft = scale.s(57.49 - 52);
    final thumbTop = scale.s(383 - 380);

    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 4,
              offset: Offset.zero,
            ),
          ],
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              left: selected == UserDashboardPreference.law
                  ? thumbLeft
                  : width - thumbLeft - thumbW,
              top: thumbTop,
              width: thumbW,
              height: thumbH,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(radius),
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
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => onChanged(UserDashboardPreference.law),
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: Text(
                        'Law',
                        style: AppTypography.inter(
                          color: selected == UserDashboardPreference.law
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: scale.fs(14),
                          height: 19 / 14,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => onChanged(UserDashboardPreference.educational),
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: Text(
                        'Educational',
                        style: AppTypography.inter(
                          color:
                              selected == UserDashboardPreference.educational
                                  ? Colors.white
                                  : Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: scale.fs(14),
                          height: 17 / 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
