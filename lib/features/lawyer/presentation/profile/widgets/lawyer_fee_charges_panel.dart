import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/models/lawyer_consultation_fee_type.dart';
import 'package:flutter/material.dart';

/// Consultation fee list card — Figma `7125:5885` @ (16, 207), 325×192.5.
class LawyerFeeChargesPanel extends StatelessWidget {
  const LawyerFeeChargesPanel({
    super.key,
    required this.scale,
    required this.fees,
    required this.onAddFee,
  });

  final FigmaScale scale;
  final Map<String, String?> fees;
  final ValueChanged<String> onAddFee;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(scale.s(_Tokens.panelRadius)),
      ),
      child: Padding(
        padding: EdgeInsets.all(scale.s(_Tokens.panelPad)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < LawyerConsultationFeeType.all.length; i++) ...[
              if (i > 0) SizedBox(height: scale.s(_Tokens.rowGap)),
              _FeeRow(
                scale: scale,
                data: LawyerConsultationFeeType.all[i],
                feeLabel: fees[LawyerConsultationFeeType.all[i].id],
                onAddFee: () => onAddFee(LawyerConsultationFeeType.all[i].id),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

abstract final class _Tokens {
  static const panelRadius = 8.0;
  static const panelPad = 12.0;
  static const rowGap = 13.0;

  static const titleColor = Color(0xFF000000);
  static const subtitleColor = Color(0xFF8F8F8F);
}

class _FeeRow extends StatelessWidget {
  const _FeeRow({
    required this.scale,
    required this.data,
    required this.feeLabel,
    required this.onAddFee,
  });

  final FigmaScale scale;
  final LawyerConsultationFeeType data;
  final String? feeLabel;
  final VoidCallback onAddFee;

  @override
  Widget build(BuildContext context) {
    final iconSize = scale.s(data.iconSize);
    final hasFee = feeLabel != null && feeLabel!.isNotEmpty;
    final actionLabel = hasFee ? '₹ $feeLabel' : 'Add Fee';
    return GestureDetector(
      onTap: onAddFee,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: scale.s(data.rowHeight),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: scale.s(data.id == 'chat' ? 10 : 9)),
            Image.asset(
              data.iconAsset,
              width: iconSize,
              height: iconSize,
              fit: BoxFit.contain,
            ),
            SizedBox(width: scale.s(data.id == 'video' ? 9 : 10)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.title,
                    style: AppTypography.inter(
                      color: _Tokens.titleColor,
                      fontWeight: FontWeight.w600,
                      fontSize: scale.fs(12),
                      height: 1.35,
                    ),
                  ),
                  Text(
                    data.subtitle,
                    style: AppTypography.inter(
                      color: _Tokens.subtitleColor,
                      fontWeight: FontWeight.w600,
                      fontSize: scale.fs(9),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              actionLabel,
              style: AppTypography.inter(
                color: AppColors.gold,
                fontWeight: FontWeight.w600,
                fontSize: scale.fs(10),
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
