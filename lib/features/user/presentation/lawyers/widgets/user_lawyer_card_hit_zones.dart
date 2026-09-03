import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Transparent tap targets for lawyer profile cards on the lawyers list.
class UserLawyerCardHitZones extends StatelessWidget {
  const UserLawyerCardHitZones({
    super.key,
    required this.scale,
    required this.lawyerNames,
    required this.onCardTap,
  });

  final FigmaScale scale;
  final List<String> lawyerNames;
  final ValueChanged<int> onCardTap;

  static const _cards = <(double left, double top, double width, double height)>[
    (16, 429, 329, 243),
    (15, 692, 329, 213),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (var i = 0; i < _cards.length; i++)
          if (i < lawyerNames.length) ...[
            Positioned(
              left: scale.s(_cards[i].$1),
              top: scale.s(_cards[i].$2),
              width: scale.s(_cards[i].$3),
              height: scale.s(_cards[i].$4),
              child: GestureDetector(
                onTap: () => onCardTap(i),
                behavior: HitTestBehavior.opaque,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.all(scale.s(16)),
                    child: Text(
                      lawyerNames[i],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.inter(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: scale.fs(14),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
      ],
    );
  }
}
