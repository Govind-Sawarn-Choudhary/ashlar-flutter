import 'dart:io';

import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/core/widgets/keyboard_dismissible.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_profile_repository.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/auth/widgets/lawyer_login_glow_background.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/my_documents_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

/// My Documents — update optional certificates (Bar Council & name are locked).
class LawyerMyDocumentsScreen extends StatefulWidget {
  const LawyerMyDocumentsScreen({super.key});

  @override
  State<LawyerMyDocumentsScreen> createState() => _LawyerMyDocumentsScreenState();
}

class _LawyerMyDocumentsScreenState extends State<LawyerMyDocumentsScreen> {
  static const _rows = [
    _DocumentRowLayout(
      label: 'Profile photo',
      docType: 'passport_photo',
    ),
    _DocumentRowLayout(
      label: 'Identity Proof (Aadhar/Pan)',
      docType: 'identity_proof',
    ),
    _DocumentRowLayout(
      label: 'Law Degree',
      docType: 'law_degree',
    ),
  ];

  final _picker = ImagePicker();
  bool _isUploading = false;
  final Set<String> _uploadedDocTypes = {};

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    try {
      final response = await LawyerProfileRepository.instance.getMe();
      if (!mounted) {
        return;
      }
      setState(() {
        _uploadedDocTypes
          ..clear()
          ..addAll(response.documents.map((doc) => doc.docType));
      });
    } catch (_) {
      // Ignore.
    }
  }

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

      await _loadDocuments();

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
      dismissKeyboardOnTap: true,
      background: const LawyerLoginGlowBackground(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final scale = FigmaScale.fromViewport(
            Size(constraints.maxWidth, constraints.maxHeight),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(scale.s(8), scale.s(8), scale.s(8), 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: EdgeInsets.only(left: scale.s(7)),
                          child: Image.asset(
                            AppAssets.walletBackButton,
                            width: scale.s(40),
                            height: scale.s(40),
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'My Documents',
                              style: MyDocumentsTypography.title(scale),
                            ),
                            SizedBox(height: scale.s(6)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: scale.s(72),
                                  height: scale.s(1.5),
                                  color: AppColors.gold,
                                ),
                                SizedBox(width: scale.s(16)),
                                Container(
                                  width: scale.s(72),
                                  height: scale.s(1.5),
                                  color: AppColors.gold,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: scale.s(47)),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: KeyboardAwareScrollView(
                  stickyFooter: true,
                  padding: EdgeInsets.fromLTRB(
                    scale.s(16),
                    scale.s(20),
                    scale.s(16),
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LockedInfoBanner(scale: scale),
                      SizedBox(height: scale.s(16)),
                      Text(
                        'Update documents',
                        style: MyDocumentsTypography.title(scale).copyWith(
                          fontSize: scale.fs(14),
                        ),
                      ),
                      SizedBox(height: scale.s(12)),
                      for (final row in _rows) ...[
                        _DocumentRow(
                          scale: scale,
                          label: row.label,
                          uploaded: _uploadedDocTypes.contains(row.docType),
                          onUpdate: _isUploading
                              ? null
                              : () => _pickDocument(row.label, row.docType),
                        ),
                        SizedBox(height: scale.s(12)),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: stickyFooterPadding(
                  context,
                  horizontal: scale.s(20),
                  top: scale.s(8),
                  extra: scale.s(16),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: scale.s(52),
                  child: _UploadButton(
                    scale: scale,
                    onTap: _isUploading ? null : _onUpload,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LockedInfoBanner extends StatelessWidget {
  const _LockedInfoBanner({required this.scale});

  final FigmaScale scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(s.s(14)),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(s.s(12)),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline_rounded, color: AppColors.gold, size: s.s(18)),
          SizedBox(width: s.s(10)),
          Expanded(
            child: Text(
              'Bar Council certificate, enrollment number and your verified name are set during onboarding and cannot be changed here. You can update your profile photo below.',
              style: MyDocumentsTypography.rowLabel(s).copyWith(
                color: Colors.white70,
                fontSize: s.fs(11),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentRow extends StatelessWidget {
  const _DocumentRow({
    required this.scale,
    required this.label,
    required this.uploaded,
    required this.onUpdate,
  });

  final FigmaScale scale;
  final String label;
  final bool uploaded;
  final VoidCallback? onUpdate;

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
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: s.s(16), vertical: s.s(14)),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: MyDocumentsTypography.rowLabel(s),
              ),
            ),
            if (uploaded) ...[
              Icon(
                Icons.check_circle_rounded,
                color: const Color(0xFF2E7D32),
                size: s.s(16),
              ),
              SizedBox(width: s.s(6)),
            ],
            GestureDetector(
              onTap: onUpdate,
              behavior: HitTestBehavior.opaque,
              child: Text(
                uploaded ? 'Replace' : 'Update',
                style: MyDocumentsTypography.updateAction(s).copyWith(
                  color: onUpdate == null
                      ? MyDocumentsTypography.brandGold.withValues(alpha: 0.45)
                      : MyDocumentsTypography.brandGold,
                ),
              ),
            ),
          ],
        ),
      ),
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
      color: onTap == null ? Colors.white54 : Colors.white,
      borderRadius: BorderRadius.circular(s.s(10)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              'Save',
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
    required this.label,
    required this.docType,
  });

  final String label;
  final String docType;
}
