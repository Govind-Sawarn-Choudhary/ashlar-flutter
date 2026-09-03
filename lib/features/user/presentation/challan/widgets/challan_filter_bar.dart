import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

enum UserChallanFilter { pending, inProgress, settled }

/// Figma `7125:2226`–`7125:2231` — filter chips @ y=145.
class ChallanFilterBar extends StatelessWidget {
  const ChallanFilterBar({
    super.key,
    required this.scale,
    required this.selected,
    required this.onChanged,
    this.pendingCount = 1,
    this.settledCount = 2,
  });

  final FigmaScale scale;
  final UserChallanFilter selected;
  final ValueChanged<UserChallanFilter> onChanged;
  final int pendingCount;
  final int settledCount;

  static const _inactiveFill = Color(0xFFF1F3F6);

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final radius = s.s(25);

    return Row(
      children: [
        _Chip(
          scale: s,
          width: 90,
          radius: radius,
          label: 'Pending($pendingCount)',
          selected: selected == UserChallanFilter.pending,
          onTap: () => onChanged(UserChallanFilter.pending),
        ),
        SizedBox(width: s.s(16)),
        _Chip(
          scale: s,
          width: 90,
          radius: radius,
          label: 'Inprogress',
          selected: selected == UserChallanFilter.inProgress,
          onTap: () => onChanged(UserChallanFilter.inProgress),
        ),
        SizedBox(width: s.s(16)),
        _Chip(
          scale: s,
          width: 78,
          radius: radius,
          label: 'Settled($settledCount)',
          selected: selected == UserChallanFilter.settled,
          onTap: () => onChanged(UserChallanFilter.settled),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.scale,
    required this.width,
    required this.radius,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final FigmaScale scale;
  final double width;
  final double radius;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Material(
      color: selected ? AppColors.gold : ChallanFilterBar._inactiveFill,
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: s.s(width),
          height: s.s(32),
          child: Center(
            child: Text(
              label,
              style: AppTypography.nunito(
                fontSize: s.fs(14),
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.gold,
                height: 20.02 / 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
