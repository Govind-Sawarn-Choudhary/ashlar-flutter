import 'dart:io';

import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/core/widgets/auth_buttons.dart';
import 'package:ashlar_lawyer_hub/core/widgets/keyboard_dismissible.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_auth_repository.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_profile_repository.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/auth/widgets/lawyer_login_glow_background.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/widgets/lawyer_bar_council_verification_card.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/widgets/lawyer_document_upload_row.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/widgets/lawyer_section_heading.dart';
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

  static const _documents = <({String label, String docType})>[
    (label: 'Bar Council Certificate', docType: _barCouncilDocType),
    (label: 'Identity Proof (Aadhar/Pan)', docType: 'identity_proof'),
    (label: 'Law Degree', docType: 'law_degree'),
    (label: 'Passport size photo', docType: 'passport_photo'),
  ];

  final _picker = ImagePicker();
  final _barEnrollmentController = TextEditingController();
  final _scrollController = ScrollController();
  final Map<String, String> _uploadedFiles = {};
  bool _isUploading = false;
  bool _isSubmitting = false;
  bool _barVerified = false;
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

  Future<void> _loadExistingDocuments() async {
    try {
      final response = await LawyerProfileRepository.instance.getMe();
      final profile = response.lawyer;
      _barState = profile.barState ?? 'UP';
      _barEnrollmentController.text = profile.barEnrollmentNumber ?? '';
      _barVerified = profile.barEnrollmentVerified;

      for (final doc in response.documents) {
        _uploadedFiles[doc.docType] = doc.fileName;
      }
      if (mounted) {
        setState(() {});
      }
    } catch (_) {
      // Ignore — user may be on first visit.
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
      final response = await LawyerProfileRepository.instance.uploadDocument(
        docType: docType,
        file: File(picked.path),
      );

      if (!mounted) {
        return;
      }

      for (final doc in response.documents) {
        _uploadedFiles[doc.docType] = doc.fileName;
      }

      setState(() {});

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

  Future<void> _onUpload() async {
    if (_isSubmitting) {
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
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
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
        builder: (context, s) {
          return Column(
            children: [
              SizedBox(height: s.s(113)),
              LawyerSectionHeading(
                title: 'Verify Your Details',
                scale: s,
                titleWidth: 143,
              ),
              SizedBox(height: s.s(8)),
              LawyerSetupStepBar(scale: s, activeStep: 1),
              Expanded(
                child: KeyboardAwareScrollView(
                  controller: _scrollController,
                  padding: EdgeInsets.fromLTRB(s.s(15), s.s(16), s.s(15), 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LawyerBarCouncilVerificationCard(
                        scale: s,
                        barCertUploaded: _barCertUploaded,
                        enrollmentController: _barEnrollmentController,
                        onUploadCertificate: () => _pickDocument(
                          _documents[0].label,
                          _documents[0].docType,
                        ),
                        onVerified: _refreshBarStatus,
                      ),
                      SizedBox(height: s.s(16)),
                      LawyerDocumentUploadRow(
                        scale: s,
                        label: _documentLabel(0),
                        onTap: () => _pickDocument(
                          _documents[0].label,
                          _documents[0].docType,
                        ),
                      ),
                      SizedBox(height: s.s(12)),
                      LawyerDocumentUploadRow(
                        scale: s,
                        label: _documentLabel(1),
                        onTap: () => _pickDocument(
                          _documents[1].label,
                          _documents[1].docType,
                        ),
                      ),
                      SizedBox(height: s.s(12)),
                      LawyerDocumentUploadRow(
                        scale: s,
                        label: _documentLabel(2),
                        onTap: () => _pickDocument(
                          _documents[2].label,
                          _documents[2].docType,
                        ),
                      ),
                      SizedBox(height: s.s(12)),
                      LawyerDocumentUploadRow(
                        scale: s,
                        label: _documentLabel(3),
                        labelPaddingLeft: 24,
                        onTap: () => _pickDocument(
                          _documents[3].label,
                          _documents[3].docType,
                        ),
                      ),
                      SizedBox(height: s.s(24)),
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
                  child: GoldActionButton(
                    label: _isSubmitting
                        ? 'Uploading…'
                        : _isUploading
                            ? 'Please wait…'
                            : 'Upload',
                    onTap: _onUpload,
                    scaleX: s.scale,
                    scaleY: s.scale,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _documentLabel(int index) {
    final doc = _documents[index];
    final uploaded = _uploadedFiles[doc.docType];
    if (uploaded == null) {
      return doc.label;
    }
    return '${doc.label} ✓';
  }
}
