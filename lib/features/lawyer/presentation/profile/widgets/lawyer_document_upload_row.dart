import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Document upload row — Figma `Rectangle 15` + 30×30 upload icon.
class LawyerDocumentUploadRow extends StatelessWidget {
  const LawyerDocumentUploadRow({
    super.key,
    required this.scale,
    required this.label,
    required this.onTap,
    this.labelPaddingLeft = 22,
  });

  final FigmaScale scale;
  final String label;
  final VoidCallback onTap;
  final double labelPaddingLeft;

  static const _designWidth = 320.0;
  static const _designHeight = 52.0;
  static const _designRadius = 10.0;
  static const _iconSize = 30.0;

  @override
  Widget build(BuildContext context) {
    final radius = scale.s(_designRadius);

    return SizedBox(
      width: scale.s(_designWidth),
      height: scale.s(_designHeight),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 4,
              offset: Offset.zero,
            ),
          ],
        ),
        child: Material(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(radius),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                scale.s(labelPaddingLeft),
                scale.s(17),
                scale.s(20),
                scale.s(17),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: AppTypography.openSans(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w400,
                        fontSize: scale.fs(16),
                        height: 17 / 16,
                      ),
                    ),
                  ),
                  Image.asset(
                    AppAssets.lawyerDocumentUploadIcon,
                    width: scale.s(_iconSize),
                    height: scale.s(_iconSize),
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
