import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/lawyer_add_consultation_fee_screen.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/models/lawyer_consultation_fee_type.dart';
import 'package:flutter/material.dart';

/// Premium consultation fee list for onboarding and profile updates.
class LawyerFeeChargesPanel extends StatelessWidget {
  const LawyerFeeChargesPanel({
    super.key,
    required this.fees,
    required this.onAddFee,
  });

  final Map<String, LawyerConsultationFeeResult?> fees;
  final ValueChanged<String> onAddFee;

  static const _total = 4;

  int get _configuredCount =>
      LawyerConsultationFeeType.all.where((type) => _hasFee(type.id)).length;

  double get _progress => _configuredCount / _total;

  bool _hasFee(String id) {
    final fee = fees[id];
    return fee != null && fee.amount.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final complete = _configuredCount == _total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ProgressHero(
          configured: _configuredCount,
          total: _total,
          progress: _progress,
          complete: complete,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.gold.withValues(alpha: 0.25),
                          AppColors.gold.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: AppColors.gold,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your consultation rates',
                          style: AppTypography.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          'Tap a card to set price & duration',
                          style: AppTypography.inter(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              for (var i = 0; i < LawyerConsultationFeeType.all.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                _FeeCard(
                  data: LawyerConsultationFeeType.all[i],
                  fee: fees[LawyerConsultationFeeType.all[i].id],
                  accent: _accentFor(LawyerConsultationFeeType.all[i].id),
                  onTap: () => onAddFee(LawyerConsultationFeeType.all[i].id),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        _ClientPreviewSection(
          fees: fees,
          hasFee: _hasFee,
          onAddFee: onAddFee,
        ),
      ],
    );
  }

  static Color _accentFor(String id) {
    return switch (id) {
      'chat' => const Color(0xFF1976D2),
      'audio' => const Color(0xFF7B1FA2),
      'video' => const Color(0xFFD84315),
      'physical' => const Color(0xFF388E3C),
      _ => AppColors.gold,
    };
  }
}

class _ProgressHero extends StatelessWidget {
  const _ProgressHero({
    required this.configured,
    required this.total,
    required this.progress,
    required this.complete,
  });

  final int configured;
  final int total;
  final double progress;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.gold.withValues(alpha: 0.22),
            Colors.white.withValues(alpha: 0.04),
            const Color(0xFF1A1A2E).withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 4,
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                    color: complete ? Colors.greenAccent : AppColors.gold,
                  ),
                ),
                Text(
                  '$configured/$total',
                  style: AppTypography.inter(
                    color: complete ? Colors.greenAccent : AppColors.gold,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    complete ? 'All fees configured' : 'Almost there',
                    style: AppTypography.inter(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  complete
                      ? 'Your profile is ready for client bookings'
                      : 'Set all $total consultation types to finish onboarding',
                  style: AppTypography.inter(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeeCard extends StatelessWidget {
  const _FeeCard({
    required this.data,
    required this.fee,
    required this.accent,
    required this.onTap,
  });

  final LawyerConsultationFeeType data;
  final LawyerConsultationFeeResult? fee;
  final Color accent;
  final VoidCallback onTap;

  bool get _hasFee => fee != null && fee!.amount.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: _hasFee
                  ? [
                      accent.withValues(alpha: 0.14),
                      Colors.white.withValues(alpha: 0.95),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.97),
                      Colors.white.withValues(alpha: 0.92),
                    ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hasFee
                  ? accent.withValues(alpha: 0.45)
                  : Colors.white.withValues(alpha: 0.25),
              width: _hasFee ? 1.2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (_hasFee ? accent : Colors.black).withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accent.withValues(alpha: 0.22),
                        accent.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accent.withValues(alpha: 0.25)),
                  ),
                  alignment: Alignment.center,
                  child: Image.asset(
                    data.iconAsset,
                    width: 26,
                    height: 26,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              data.title,
                              style: AppTypography.inter(
                                color: const Color(0xFF1A1A1A),
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          if (_hasFee)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Set',
                                style: AppTypography.inter(
                                  color: accent,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data.subtitle,
                        style: AppTypography.inter(
                          color: const Color(0xFF757575),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (_hasFee)
                        Row(
                          children: [
                            Text(
                              '₹${fee!.amount}',
                              style: AppTypography.inter(
                                color: accent,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '· ${fee!.duration}',
                              style: AppTypography.inter(
                                color: const Color(0xFF616161),
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          'Tap to add fee',
                          style: AppTypography.inter(
                            color: accent.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      if (_hasFee && fee!.location?.trim().isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 12,
                              color: accent.withValues(alpha: 0.8),
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                fee!.location!.trim(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.inter(
                                  color: const Color(0xFF616161),
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _hasFee
                        ? accent.withValues(alpha: 0.12)
                        : AppColors.gold.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _hasFee ? Icons.edit_rounded : Icons.add_rounded,
                    color: _hasFee ? accent : AppColors.gold,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ClientPreviewSection extends StatelessWidget {
  const _ClientPreviewSection({
    required this.fees,
    required this.hasFee,
    required this.onAddFee,
  });

  final Map<String, LawyerConsultationFeeResult?> fees;
  final bool Function(String id) hasFee;
  final ValueChanged<String> onAddFee;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.gold.withValues(alpha: 0.14),
            Colors.white.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.visibility_rounded,
                  color: AppColors.gold,
                  size: 15,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Client booking preview',
                style: AppTypography.inter(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'This is how your rates appear when clients book you',
            style: AppTypography.inter(
              color: Colors.white54,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final type in LawyerConsultationFeeType.all)
                _PreviewChip(
                  type: type,
                  fee: fees[type.id],
                  configured: hasFee(type.id),
                  accent: LawyerFeeChargesPanel._accentFor(type.id),
                  onTap: () => onAddFee(type.id),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewChip extends StatelessWidget {
  const _PreviewChip({
    required this.type,
    required this.fee,
    required this.configured,
    required this.accent,
    required this.onTap,
  });

  final LawyerConsultationFeeType type;
  final LawyerConsultationFeeResult? fee;
  final bool configured;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: (MediaQuery.sizeOf(context).width - 64) / 2,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: configured
                ? accent.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: configured
                  ? accent.withValues(alpha: 0.35)
                  : Colors.white12,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(type.iconAsset, width: 16, height: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      type.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                configured ? '₹${fee!.amount}' : '—',
                style: AppTypography.inter(
                  color: configured ? accent : Colors.white38,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              Text(
                configured ? fee!.duration : 'Tap to set',
                style: AppTypography.inter(
                  color: configured ? Colors.white70 : Colors.white38,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
