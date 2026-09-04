import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Premium metric tile for the lawyer dashboard.
class LawyerDashboardStatCard extends StatelessWidget {
  const LawyerDashboardStatCard({
    super.key,
    required this.scale,
    required this.title,
    required this.amount,
    this.subtitle,
    this.subtitleLines,
    this.amountColor = const Color(0xFF171725),
    this.accentColor = const Color(0xFF1976D2),
    this.icon = Icons.insights_rounded,
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
  final Color accentColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Container(
      padding: EdgeInsets.fromLTRB(
        s.s(14),
        s.s(14),
        s.s(12),
        s.s(12),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            accentColor.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(s.s(20)),
        border: Border.all(color: accentColor.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: s.s(30),
                height: s.s(30),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(s.s(9)),
                ),
                child: Icon(icon, color: accentColor, size: s.s(16)),
              ),
              const Spacer(),
            ],
          ),
          SizedBox(height: s.s(10)),
          Text(
            title,
            style: AppTypography.inter(
              color: const Color(0xFF171725),
              fontWeight: FontWeight.w600,
              fontSize: s.fs(11),
              height: 1.1,
            ),
          ),
          SizedBox(height: s.s(6)),
          Text(
            amount,
            style: AppTypography.inter(
              color: amountColor,
              fontWeight: FontWeight.w800,
              fontSize: s.fs(22),
              height: 1,
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
                  fontSize: s.fs(10),
                  height: 1.25,
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
                fontSize: s.fs(10),
                height: 1.25,
              ),
            ),
        ],
      ),
    );
  }
}
