import 'dart:io';

import 'package:ashlar_lawyer_hub/core/auth/auth_session.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/core/utils/profile_photo_compressor.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/core/widgets/auth_buttons.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_auth_repository.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_profile_repository.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/auth/widgets/lawyer_login_glow_background.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/widgets/lawyer_bar_council_verification_card.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/widgets/lawyer_document_upload_row.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/lawyer_onboarding_skip.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/widgets/lawyer_setup_step_bar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Lawyer profile step 2 — upload documents + Bar Council enrollment verify.
class LawyerUploadDocumentsScreen extends StatefulWidget {
  const LawyerUploadDocumentsScreen({super.key});

  @override
  State<LawyerUploadDocumentsScreen> createState() =>
      _LawyerUploadDocumentsScreenState();
}

class _LawyerUploadDocumentsScreenState
    extends State<LawyerUploadDocumentsScreen> {
  static const _barCouncilDocType = 'bar_council_certificate';
  static const _profilePhotoDocType = 'passport_photo';

  static const _requiredDocTypes = [
    _barCouncilDocType,
    _profilePhotoDocType,
  ];

  static const _optionalDocuments = <({String label, String docType})>[
    (label: 'Identity Proof (Aadhar/PAN)', docType: 'identity_proof'),
    (label: 'Law Degree', docType: 'law_degree'),
  ];

  final _picker = ImagePicker();
  final _barEnrollmentController = TextEditingController();
  final _scrollController = ScrollController();
  final Map<String, String> _uploadedFiles = {};
  String? _uploadingDocType;
  bool _isSubmitting = false;
  bool _barVerified = false;
  bool _loading = true;
  String? _loadError;
  String _barState = 'UP';

  @override
  void initState() {
    super.initState();
    _loadExistingDocuments();
  }

  @override
  void dispose() {
    _barEnrollmentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool get _barCertUploaded => _uploadedFiles.containsKey(_barCouncilDocType);

  int get _requiredUploadedCount =>
      _requiredDocTypes.where(_uploadedFiles.containsKey).length;

  Future<void> _loadExistingDocuments() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });

    try {
      final response = await LawyerProfileRepository.instance.getMe();
      final profile = response.lawyer;
      _barState = profile.barState ?? 'UP';
      _barEnrollmentController.text = profile.barEnrollmentNumber ?? '';
      _barVerified = profile.barEnrollmentVerified;
      _uploadedFiles.clear();

      for (final doc in response.documents) {
        _uploadedFiles[doc.docType] = doc.fileName;
      }
    } on ApiException catch (e) {
      _loadError = e.message;
    } catch (_) {
      _loadError = 'Could not load your documents';
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<ImageSource?> _pickImageSource({required bool allowCamera}) async {
    if (!allowCamera) {
      return ImageSource.gallery;
    }

    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Profile Photo',
                  style: AppTypography.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Take a photo or choose from gallery. We compress it under 20 KB.',
                  style: AppTypography.inter(
                    color: Colors.white54,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined, color: AppColors.gold),
                  title: const Text('Take photo', style: TextStyle(color: Colors.white)),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined, color: AppColors.gold),
                  title: const Text('Choose from gallery', style: TextStyle(color: Colors.white)),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickProfilePhoto() async {
    if (_uploadingDocType != null || _isSubmitting) {
      return;
    }

    final source = await _pickImageSource(allowCamera: true);
    if (source == null) {
      return;
    }

    final picked = await _picker.pickImage(
      source: source,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 90,
    );
    if (picked == null) {
      return;
    }

    setState(() => _uploadingDocType = _profilePhotoDocType);

    try {
      final compressed = await ProfilePhotoCompressor.compress(File(picked.path));
      await _uploadFile(
        label: 'Profile Photo',
        docType: _profilePhotoDocType,
        file: compressed,
        successMessage: 'Profile photo uploaded (under 20 KB)',
      );
    } on StateError catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not prepare profile photo')),
      );
    } finally {
      if (mounted) {
        setState(() => _uploadingDocType = null);
      }
    }
  }

  Future<void> _pickOptionalDocument(String label, String docType) async {
    if (_uploadingDocType != null || _isSubmitting) {
      return;
    }

    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) {
      return;
    }

    setState(() => _uploadingDocType = docType);

    try {
      await _uploadFile(
        label: label,
        docType: docType,
        file: File(picked.path),
      );
    } finally {
      if (mounted) {
        setState(() => _uploadingDocType = null);
      }
    }
  }

  Future<void> _pickBarCouncilCertificate() async {
    await _pickOptionalDocument('Bar Council Certificate', _barCouncilDocType);
  }

  Future<void> _uploadFile({
    required String label,
    required String docType,
    required File file,
    String? successMessage,
  }) async {
    try {
      final response = await LawyerProfileRepository.instance.uploadDocument(
        docType: docType,
        file: file,
      );

      if (!mounted) {
        return;
      }

      for (final doc in response.documents) {
        _uploadedFiles[doc.docType] = doc.fileName;
      }

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage ?? '$label uploaded')),
      );
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not upload $label')),
      );
    }
  }

  Future<void> _refreshBarStatus() async {
    try {
      final response = await LawyerProfileRepository.instance.getMe();
      if (!mounted) {
        return;
      }
      setState(() {
        _barVerified = response.lawyer.barEnrollmentVerified;
        _barEnrollmentController.text =
            response.lawyer.barEnrollmentNumber ?? _barEnrollmentController.text;
      });
    } catch (_) {
      // Ignore refresh errors.
    }
  }

  List<String> _missingRequiredDocumentLabels() {
    final missing = <String>[];
    if (!_barCertUploaded) {
      missing.add('Bar Council Certificate');
    }
    if (!_uploadedFiles.containsKey(_profilePhotoDocType)) {
      missing.add('Profile Photo');
    }
    return missing;
  }

  Future<void> _onContinue() async {
    FocusScope.of(context).unfocus();

    if (_isSubmitting || _loading || _uploadingDocType != null) {
      return;
    }

    final missing = _missingRequiredDocumentLabels();
    if (missing.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please upload: ${missing.join(', ')}'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final enrollment = _barEnrollmentController.text.trim();
      final response = await LawyerProfileRepository.instance.completeDocuments(
        enrollmentNumber: enrollment.isNotEmpty && !_barVerified ? enrollment : null,
        state: _barState,
      );

      if (!mounted) {
        return;
      }

      final route = LawyerAuthRepository.instance.routeForNextStep(
        response.nextRoute,
      );
      Navigator.of(context).pushReplacementNamed(route);
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not continue. Try again.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _signOut() async {
    await AuthSession.instance.clear();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/role-select',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final isBusy = _isSubmitting || _uploadingDocType != null;
    final canSkip = canSkipLawyerOnboarding(
      barCertUploaded: _barCertUploaded,
      profilePhotoUploaded:
          _uploadedFiles.containsKey(_profilePhotoDocType),
    );

    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: false,
      dismissKeyboardOnTap: true,
      resizeToAvoidBottomInset: true,
      background: const LawyerLoginGlowBackground(),
      body: FigmaScreenCanvas(
        builder: (context, s) {
          if (_loading) {
            return const SafeArea(
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (_loadError != null) {
            return SafeArea(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(s.s(24)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _loadError!,
                        textAlign: TextAlign.center,
                        style: AppTypography.inter(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: s.s(16)),
                      TextButton(
                        onPressed: _loadExistingDocuments,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: s.s(8)),
                LawyerSetupStepBar(
                  scale: s,
                  activeStep: 1,
                  showProgressTracks: true,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(s.s(20), s.s(16), s.s(20), 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upload Documents',
                        style: AppTypography.inter(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w700,
                          fontSize: s.fs(20),
                        ),
                      ),
                      SizedBox(height: s.s(6)),
                      Text(
                        'Step 2 of 3 — Bar Council certificate and profile photo are required. Other documents are optional.',
                        style: AppTypography.inter(
                          color: Colors.white70,
                          fontSize: s.fs(13),
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: s.s(10)),
                      _UploadProgressChip(
                        scale: s,
                        uploaded: _requiredUploadedCount,
                        total: _requiredDocTypes.length,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(s.s(20), s.s(16), s.s(20), s.s(8)),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(s.s(16)),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(s.s(12)),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LawyerBarCouncilVerificationCard(
                            scale: s,
                            barCertUploaded: _barCertUploaded,
                            enrollmentController: _barEnrollmentController,
                            onUploadCertificate: _pickBarCouncilCertificate,
                            onVerified: _refreshBarStatus,
                          ),
                          SizedBox(height: s.s(20)),
                          Text(
                            'Profile photo',
                            style: AppTypography.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: s.fs(13),
                            ),
                          ),
                          SizedBox(height: s.s(4)),
                          Text(
                            'Required — camera or gallery. Saved under 20 KB.',
                            style: AppTypography.inter(
                              color: Colors.white54,
                              fontSize: s.fs(11),
                            ),
                          ),
                          SizedBox(height: s.s(12)),
                          LawyerDocumentUploadRow(
                            scale: s,
                            label: 'Profile Photo',
                            subtitle: 'Tap to take photo or choose from gallery',
                            isUploaded:
                                _uploadedFiles.containsKey(_profilePhotoDocType),
                            fileName: _uploadedFiles[_profilePhotoDocType],
                            isUploading:
                                _uploadingDocType == _profilePhotoDocType,
                            onTap: _pickProfilePhoto,
                          ),
                          SizedBox(height: s.s(20)),
                          Text(
                            'Optional documents',
                            style: AppTypography.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: s.fs(13),
                            ),
                          ),
                          SizedBox(height: s.s(4)),
                          Text(
                            'You can skip these and upload later if needed.',
                            style: AppTypography.inter(
                              color: Colors.white54,
                              fontSize: s.fs(11),
                            ),
                          ),
                          SizedBox(height: s.s(12)),
                          for (var i = 0; i < _optionalDocuments.length; i++) ...[
                            if (i > 0) SizedBox(height: s.s(12)),
                            LawyerDocumentUploadRow(
                              scale: s,
                              label: _optionalDocuments[i].label,
                              isOptional: true,
                              isUploaded: _uploadedFiles
                                  .containsKey(_optionalDocuments[i].docType),
                              fileName:
                                  _uploadedFiles[_optionalDocuments[i].docType],
                              isUploading: _uploadingDocType ==
                                  _optionalDocuments[i].docType,
                              onTap: () => _pickOptionalDocument(
                                _optionalDocuments[i].label,
                                _optionalDocuments[i].docType,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    s.s(18),
                    s.s(8),
                    s.s(18),
                    s.s(12) + (keyboardInset > 0 ? keyboardInset : 0),
                  ),
                  child: Opacity(
                    opacity: isBusy ? 0.55 : 1,
                    child: IgnorePointer(
                      ignoring: isBusy,
                      child: SizedBox(
                        width: double.infinity,
                        height: s.s(52),
                        child: GoldActionButton(
                          label: _isSubmitting
                              ? 'Saving…'
                              : _uploadingDocType != null
                                  ? 'Uploading…'
                                  : 'Save & Continue',
                          onTap: _onContinue,
                          scaleX: s.scale,
                          scaleY: s.scale,
                        ),
                      ),
                    ),
                  ),
                ),
                if (canSkip)
                  Center(
                    child: TextButton(
                      onPressed: isBusy
                          ? null
                          : () => skipLawyerOnboardingToDashboard(context),
                      child: Text(
                        'Skip to dashboard',
                        style: AppTypography.inter(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w600,
                          fontSize: s.fs(13),
                        ),
                      ),
                    ),
                  ),
                Center(
                  child: TextButton(
                    onPressed: isBusy ? null : _signOut,
                    child: Text(
                      'Sign out',
                      style: AppTypography.inter(
                        color: Colors.white54,
                        fontSize: s.fs(13),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: s.s(4)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _UploadProgressChip extends StatelessWidget {
  const _UploadProgressChip({
    required this.scale,
    required this.uploaded,
    required this.total,
  });

  final FigmaScale scale;
  final int uploaded;
  final int total;

  @override
  Widget build(BuildContext context) {
    final complete = uploaded >= total;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: scale.s(12),
        vertical: scale.s(8),
      ),
      decoration: BoxDecoration(
        color: complete
            ? Colors.green.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(scale.s(999)),
        border: Border.all(
          color: complete
              ? Colors.green.withValues(alpha: 0.4)
              : Colors.white24,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            complete ? Icons.check_circle_outline : Icons.upload_file_outlined,
            color: complete ? Colors.greenAccent : AppColors.gold,
            size: scale.s(16),
          ),
          SizedBox(width: scale.s(8)),
          Text(
            '$uploaded of $total required uploaded',
            style: AppTypography.inter(
              color: complete ? Colors.greenAccent : Colors.white70,
              fontWeight: FontWeight.w600,
              fontSize: scale.fs(12),
            ),
          ),
        ],
      ),
    );
  }
}
