import 'dart:io';

import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_profile_repository.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/auth/widgets/lawyer_login_glow_background.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/my_documents_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

/// My Documents (profile update) — Figma [`7125:6839`](https://www.figma.com/design/3PtNxJn9gYGj6S0yAHBce3/ashlarlawyerhub-To-Share--Copy-?node-id=7125-6839) (360×800).
class LawyerMyDocumentsScreen extends StatefulWidget {
  const LawyerMyDocumentsScreen({super.key});

  @override
  State<LawyerMyDocumentsScreen> createState() => _LawyerMyDocumentsScreenState();
}

class _LawyerMyDocumentsScreenState extends State<LawyerMyDocumentsScreen> {
  static const _rows = [
    _DocumentRowLayout(
      cardX: 23,
      cardY: 182.78125,
      cardW: 320,
      labelX: 45,
      labelY: 199.78125,
      updateX: 279,
      updateY: 200.78125,
      label: 'Bar Counil Certificate',
      docType: 'bar_council_certificate',
    ),
    _DocumentRowLayout(
      cardX: 23,
      cardY: 256.78125,
      cardW: 320,
      labelX: 45,
      labelY: 273.78125,
      updateX: 279,
      updateY: 274.78125,
      label: 'Identity Proof (Aadhar/Pan)',
      docType: 'identity_proof',
    ),
    _DocumentRowLayout(
      cardX: 22,
      cardY: 330.78125,
      cardW: 320,
      labelX: 44,
      labelY: 347.78125,
      updateX: 279,
      updateY: 348.78125,
      label: 'Law Degree',
      docType: 'law_degree',
    ),
    _DocumentRowLayout(
      cardX: 20,
      cardY: 404.78125,
      cardW: 320,
      labelX: 42,
      labelY: 421.78125,
      updateX: 279,
      updateY: 421.78125,
      label: 'Passport size photo',
      docType: 'passport_photo',
    ),
  ];

  final _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickDocument(String label, String docType) async {
    if (_isUploading) {
      return;
    }

    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) {
      return;
    }

    setState(() => _isUploading = true);

    try {
      await LawyerProfileRepository.instance.uploadDocument(
        docType: docType,
        file: File(picked.path),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label uploaded')),
      );
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _onUpload() {
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: false,
      background: const LawyerLoginGlowBackground(),
      body: FigmaScreenCanvas(
        builder: (context, s) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: s.s(8),
                top: s.s(35),
                width: s.s(56),
                height: s.s(56),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  behavior: HitTestBehavior.opaque,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: s.s(7)),
                      child: Image.asset(
                        AppAssets.walletBackButton,
                        width: s.s(40),
                        height: s.s(40),
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: s.s(121),
                top: s.s(113),
                child: Text(
                  'My Documents',
                  style: MyDocumentsTypography.title(s),
                ),
              ),
              Positioned(
                left: s.s(33),
                top: s.s(130),
                width: s.s(72),
                height: s.s(1.5),
                child: const ColoredBox(color: AppColors.gold),
              ),
              Positioned(
                left: s.s(265),
                top: s.s(130),
                width: s.s(72),
                height: s.s(1.5),
                child: const ColoredBox(color: AppColors.gold),
              ),
              for (final row in _rows) ...[
                Positioned(
                  left: s.s(row.cardX),
                  top: s.s(row.cardY),
                  width: s.s(row.cardW),
                  height: s.s(52),
                  child: _DocumentCard(scale: s),
                ),
                Positioned(
                  left: s.s(row.labelX),
                  top: s.s(row.labelY),
                  child: Text(
                    row.label,
                    style: MyDocumentsTypography.rowLabel(s),
                  ),
                ),
                Positioned(
                  left: s.s(row.updateX),
                  top: s.s(row.updateY),
                  child: GestureDetector(
                    onTap: _isUploading
                        ? null
                        : () => _pickDocument(row.label, row.docType),
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      'Update',
                      style: MyDocumentsTypography.updateAction(s),
                    ),
                  ),
                ),
              ],
              Positioned(
                left: s.s(20),
                top: s.s(536.78125),
                width: s.s(324),
                height: s.s(52),
                child: _UploadButton(
                  scale: s,
                  onTap: _isUploading ? null : _onUpload,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.scale});

  final FigmaScale scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(s.s(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: s.s(4),
          ),
        ],
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _UploadButton extends StatelessWidget {
  const _UploadButton({
    required this.scale,
    required this.onTap,
  });

  final FigmaScale scale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(s.s(10)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              'Upload',
              style: MyDocumentsTypography.uploadLabel(s),
            ),
            Positioned(
              right: s.s(22),
              child: SvgPicture.asset(
                AppAssets.profileUploadChevrons,
                width: s.s(21),
                height: s.s(10),
                fit: BoxFit.contain,
                colorFilter: const ColorFilter.mode(
                  MyDocumentsTypography.brandGold,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentRowLayout {
  const _DocumentRowLayout({
    required this.cardX,
    required this.cardY,
    required this.cardW,
    required this.labelX,
    required this.labelY,
    required this.updateX,
    required this.updateY,
    required this.label,
    required this.docType,
  });

  final double cardX;
  final double cardY;
  final double cardW;
  final double labelX;
  final double labelY;
  final double updateX;
  final double updateY;
  final String label;
  final String docType;
}
