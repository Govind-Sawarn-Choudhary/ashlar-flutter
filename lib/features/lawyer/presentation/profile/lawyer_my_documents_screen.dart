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
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/widgets/lawyer_bar_council_verification_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

/// My Documents (profile update) with Bar Council verification.
class LawyerMyDocumentsScreen extends StatefulWidget {
  const LawyerMyDocumentsScreen({super.key});

  @override
  State<LawyerMyDocumentsScreen> createState() => _LawyerMyDocumentsScreenState();
}

class _LawyerMyDocumentsScreenState extends State<LawyerMyDocumentsScreen> {
  static const _rows = [
    _DocumentRowLayout(
      label: 'Bar Council Certificate',
      docType: 'bar_council_certificate',
    ),
    _DocumentRowLayout(
      label: 'Identity Proof (Aadhar/Pan)',
      docType: 'identity_proof',
    ),
    _DocumentRowLayout(
      label: 'Law Degree',
      docType: 'law_degree',
    ),
    _DocumentRowLayout(
      label: 'Passport size photo',
      docType: 'passport_photo',
    ),
  ];

  final _picker = ImagePicker();
  bool _isUploading = false;
  bool _barCertUploaded = false;
  int _refreshKey = 0;

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
        _barCertUploaded = response.documents.any(
          (doc) => doc.docType == 'bar_council_certificate',
        );
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

      if (docType == 'bar_council_certificate') {
        setState(() {
          _barCertUploaded = true;
          _refreshKey++;
        });
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
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: false,
      dismissKeyboardOnTap: true,
      background: const LawyerLoginGlowBackground(),
      body: FigmaScreenCanvas(
        designHeight: 807,
        builder: (context, s) {
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(s.s(8), s.s(35), s.s(8), 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      behavior: HitTestBehavior.opaque,
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
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'My Documents',
                            style: MyDocumentsTypography.title(s),
                          ),
                          SizedBox(height: s.s(6)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: s.s(72),
                                height: s.s(1.5),
                                color: AppColors.gold,
                              ),
                              SizedBox(width: s.s(16)),
                              Container(
                                width: s.s(72),
                                height: s.s(1.5),
                                color: AppColors.gold,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: s.s(47)),
                  ],
                ),
              ),
              Expanded(
                child: KeyboardAwareScrollView(
                  padding: EdgeInsets.fromLTRB(s.s(16), s.s(20), s.s(16), 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LawyerBarCouncilVerificationCard(
                        key: ValueKey(_refreshKey),
                        scale: s,
                        barCertUploaded: _barCertUploaded,
                        onUploadCertificate: () => _pickDocument(
                          _rows[0].label,
                          _rows[0].docType,
                        ),
                        onVerified: () {
                          setState(() => _refreshKey++);
                        },
                      ),
                      SizedBox(height: s.s(18)),
                      Text(
                        'Update documents',
                        style: MyDocumentsTypography.title(s).copyWith(
                          fontSize: s.fs(14),
                        ),
                      ),
                      SizedBox(height: s.s(12)),
                      for (final row in _rows) ...[
                        _DocumentRow(
                          scale: s,
                          label: row.label,
                          onUpdate: _isUploading
                              ? null
                              : () => _pickDocument(row.label, row.docType),
                        ),
                        SizedBox(height: s.s(12)),
                      ],
                      SizedBox(height: s.s(12)),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  s.s(20),
                  s.s(8),
                  s.s(20),
                  s.s(24) + (keyboardInset > 0 ? keyboardInset : 0),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: s.s(52),
                  child: _UploadButton(
                    scale: s,
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

class _DocumentRow extends StatelessWidget {
  const _DocumentRow({
    required this.scale,
    required this.label,
    required this.onUpdate,
  });

  final FigmaScale scale;
  final String label;
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
            GestureDetector(
              onTap: onUpdate,
              behavior: HitTestBehavior.opaque,
              child: Text(
                'Update',
                style: MyDocumentsTypography.updateAction(s),
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
      color: Colors.white,
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
