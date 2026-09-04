import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Availability + weekly activity — Figma `7125:6680` rebuilt with live data.
class LawyerHitRateCard extends StatelessWidget {
  const LawyerHitRateCard({
    super.key,
    required this.scale,
    required this.availabilityPercent,
    required this.availabilitySubtitle,
    required this.activityValue,
    required this.activitySubtitle,
    this.activityProgress = 0,
  });

  final FigmaScale scale;
  final int availabilityPercent;
  final String availabilitySubtitle;
  final String activityValue;
  final String activitySubtitle;
  final double activityProgress;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final availabilityProgress = (availabilityPercent / 100).clamp(0.0, 1.0);
    final callsProgress = activityProgress.clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: s.s(14),
        vertical: s.s(12),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(s.s(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _MetricRing(
              scale: s,
              progress: availabilityProgress,
              color: const Color(0xFF1976D2),
              icon: Icons.track_changes_rounded,
              value: '$availabilityPercent%',
              subtitle: availabilitySubtitle,
            ),
          ),
          Container(
            width: 1,
            height: s.s(44),
            color: const Color(0xFFE8E8E8),
          ),
          Expanded(
            child: _MetricRing(
              scale: s,
              progress: callsProgress,
              color: const Color(0xFF26A69A),
              icon: Icons.work_outline_rounded,
              value: activityValue,
              subtitle: activitySubtitle,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricRing extends StatelessWidget {
  const _MetricRing({
    required this.scale,
    required this.progress,
    required this.color,
    required this.icon,
    required this.value,
    required this.subtitle,
  });

  final FigmaScale scale;
  final double progress;
  final Color color;
  final IconData icon;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final ringSize = s.s(44);

    return Row(
      children: [
        SizedBox(width: s.s(8)),
        SizedBox(
          width: ringSize,
          height: ringSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: ringSize,
                height: ringSize,
                child: CircularProgressIndicator(
                  value: progress <= 0 ? 0.04 : progress,
                  strokeWidth: s.s(4),
                  backgroundColor: color.withValues(alpha: 0.12),
                  color: color,
                ),
              ),
              Icon(icon, color: color, size: s.s(18)),
            ],
          ),
        ),
        SizedBox(width: s.s(10)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.inter(
                  color: const Color(0xFF171725),
                  fontWeight: FontWeight.w700,
                  fontSize: s.fs(18),
                  height: 1,
                ),
              ),
              SizedBox(height: s.s(4)),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.inter(
                  color: const Color(0xFF92929D),
                  fontWeight: FontWeight.w400,
                  fontSize: s.fs(10),
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
