import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Metric tile — Figma `7125:6700` @ 145×123, radius 20, white fill.
class LawyerDashboardStatCard extends StatelessWidget {
  const LawyerDashboardStatCard({
    super.key,
    required this.scale,
    required this.title,
    required this.amount,
    this.subtitle,
    this.subtitleLines,
    this.amountColor = const Color(0xFF171725),
  }) : assert(
          subtitle != null || subtitleLines != null,
          'Provide subtitle or subtitleLines',
        );

  final FigmaScale scale;
  final String title;
  final String amount;
  final String? subtitle;
  final List<String>? subtitleLines;
  final Color amountColor;

  static const _designWidth = 145.0;
  static const _designHeight = 123.0;
  static const _designRadius = 20.0;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final w = s.s(_designWidth);
    final h = s.s(_designHeight);
    final radius = s.s(_designRadius);

    return Container(
      width: w,
      height: h,
      padding: EdgeInsets.fromLTRB(
        s.s(15),
        s.s(16),
        s.s(12),
        s.s(12),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.inter(
              color: const Color(0xFF171725),
              fontWeight: FontWeight.w600,
              fontSize: s.fs(12),
              height: 1,
              letterSpacing: 0.1,
            ),
          ),
          SizedBox(height: s.s(8)),
          Text(
            amount,
            style: AppTypography.inter(
              color: amountColor,
              fontWeight: FontWeight.w600,
              fontSize: s.fs(22),
              height: 1,
              letterSpacing: 0.1,
            ),
          ),
          const Spacer(),
          if (subtitleLines != null)
            ...subtitleLines!.map(
              (line) => Text(
                line,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.inter(
                  color: const Color(0xFF92929D),
                  fontWeight: FontWeight.w400,
                  fontSize: s.fs(11),
                  height: 16 / 11,
                  letterSpacing: 0.0688,
                ),
              ),
            )
          else
            Text(
              subtitle!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.inter(
                color: const Color(0xFF92929D),
                fontWeight: FontWeight.w400,
                fontSize: s.fs(11),
                height: 16 / 11,
                letterSpacing: 0.0688,
              ),
            ),
        ],
      ),
    );
  }
}
