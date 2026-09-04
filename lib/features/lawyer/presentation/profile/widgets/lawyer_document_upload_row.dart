import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Document upload row — tap to pick and upload a file.
class LawyerDocumentUploadRow extends StatelessWidget {
  const LawyerDocumentUploadRow({
    super.key,
    required this.scale,
    required this.label,
    required this.onTap,
    this.labelPaddingLeft = 22,
    this.isUploaded = false,
    this.fileName,
    this.width = double.infinity,
    this.isUploading = false,
    this.isOptional = false,
    this.subtitle,
  });

  final FigmaScale scale;
  final String label;
  final VoidCallback? onTap;
  final double labelPaddingLeft;
  final bool isUploaded;
  final String? fileName;
  final double width;
  final bool isUploading;
  final bool isOptional;
  final String? subtitle;

  static const _designRadius = 10.0;
  static const _iconSize = 30.0;

  @override
  Widget build(BuildContext context) {
    final radius = scale.s(_designRadius);
    final fieldWidth = width.isFinite ? scale.s(width) : width;
    final borderColor = isUploaded
        ? Colors.green.withValues(alpha: 0.55)
        : Colors.transparent;
    final backgroundColor =
        isUploaded ? const Color(0xFFF1F8E9) : AppColors.inputBackground;
    final labelColor = isUploaded ? const Color(0xFF2E7D32) : AppColors.textMuted;

    return SizedBox(
      width: fieldWidth,
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
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
            side: BorderSide(color: borderColor, width: isUploaded ? 1.2 : 0),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: isUploading ? null : onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: scale.s(labelPaddingLeft),
                vertical: scale.s(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                label,
                                style: AppTypography.openSans(
                                  color: labelColor,
                                  fontWeight: isUploaded
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  fontSize: scale.fs(15),
                                  height: 1.2,
                                ),
                              ),
                            ),
                            if (isOptional)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: scale.s(8),
                                  vertical: scale.s(2),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius:
                                      BorderRadius.circular(scale.s(999)),
                                ),
                                child: Text(
                                  'Optional',
                                  style: AppTypography.inter(
                                    color: Colors.white54,
                                    fontSize: scale.fs(9),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (subtitle?.isNotEmpty == true) ...[
                          SizedBox(height: scale.s(2)),
                          Text(
                            subtitle!,
                            style: AppTypography.inter(
                              color: const Color(0xFF757575),
                              fontSize: scale.fs(10),
                              height: 1.3,
                            ),
                          ),
                        ],
                        if (isUploaded && fileName?.isNotEmpty == true) ...[
                          SizedBox(height: scale.s(2)),
                          Text(
                            fileName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.inter(
                              color: const Color(0xFF558B2F),
                              fontSize: scale.fs(10),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isUploading)
                    SizedBox(
                      width: scale.s(22),
                      height: scale.s(22),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.gold,
                      ),
                    )
                  else if (isUploaded)
                    Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green.shade700,
                      size: scale.s(24),
                    )
                  else
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
