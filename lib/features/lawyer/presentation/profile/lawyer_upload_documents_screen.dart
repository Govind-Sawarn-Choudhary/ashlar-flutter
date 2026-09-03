import 'dart:io';

import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/core/widgets/auth_buttons.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_auth_repository.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_profile_repository.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/auth/widgets/lawyer_login_glow_background.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/widgets/lawyer_document_upload_row.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/widgets/lawyer_form_field.dart';
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
  final Map<String, String> _uploadedFiles = {};
  bool _isUploading = false;
  bool _isSubmitting = false;
  bool _isVerifyingBar = false;
  bool _barVerified = false;
  bool _barVerifyAttempted = false;
  String? _barStatusMessage;
  String? _lawyerFullName;
  String? _portalAdvocateName;
  String? _portalDistrict;
  String? _portalEnrollmentDate;
  String _barState = 'UP';

  @override
  void initState() {
    super.initState();
    _loadExistingDocuments();
  }

  @override
  void dispose() {
    _barEnrollmentController.dispose();
    super.dispose();
  }

  bool get _barCertUploaded => _uploadedFiles.containsKey(_barCouncilDocType);

  Future<void> _loadExistingDocuments() async {
    try {
      final response = await LawyerProfileRepository.instance.getMe();
      final profile = response.lawyer;
      _lawyerFullName = profile.fullName;
      _barState = profile.barState ?? 'UP';
      _barEnrollmentController.text = profile.barEnrollmentNumber ?? '';
      _barVerified = profile.barEnrollmentVerified;
      _barVerifyAttempted =
          profile.barEnrollmentNumber?.isNotEmpty == true ||
          profile.barManualReview ||
          profile.barVerifiedName != null;
      if (profile.barEnrollmentVerified) {
        _barStatusMessage = 'Bar Council enrollment verified';
      } else if (profile.barManualReview) {
        _barStatusMessage =
            'Could not auto-verify. You can continue — admin will review your profile.';
      }
      _portalAdvocateName = profile.barVerifiedName;
      _portalDistrict = profile.location;

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

  Future<void> _verifyBarEnrollment() async {
    final enrollment = _barEnrollmentController.text.trim().toUpperCase();

    if (!_barCertUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload Bar Council certificate first')),
      );
      return;
    }

    if (enrollment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter Bar Council enrollment number')),
      );
      return;
    }

    if (_isVerifyingBar) {
      return;
    }

    setState(() => _isVerifyingBar = true);

    try {
      final result = await LawyerProfileRepository.instance.verifyBarEnrollment(
        state: _barState,
        enrollmentNumber: enrollment,
        fullName: _lawyerFullName?.trim(),
      );

      if (!mounted) {
        return;
      }

      final profileResponse = await LawyerProfileRepository.instance.getMe();
      if (!mounted) {
        return;
      }

      final profile = profileResponse.lawyer;

      setState(() {
        _barVerified = result.verified;
        _barVerifyAttempted = true;
        _barStatusMessage = result.message;
        _barEnrollmentController.text = result.inputEnrollmentNumber.isNotEmpty
            ? result.inputEnrollmentNumber
            : enrollment;
        _lawyerFullName = profile.fullName ?? result.advocateName;
        _portalAdvocateName = result.advocateName ?? profile.barVerifiedName;
        _portalDistrict = result.district ?? profile.location;
        _portalEnrollmentDate = result.enrollmentDate ?? profile.barVerifiedEnrollmentDate;
      });

      if (result.verified) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: result.nameMatched == false ? Colors.orange : Colors.green,
            content: Text(
              result.nameMatched == false
                  ? 'Name corrected to: ${profile.fullName ?? result.advocateName ?? 'Bar Council name'}'
                  : 'Profile updated: ${profile.fullName ?? result.advocateName ?? 'verified'}',
            ),
          ),
        );
      }
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _barVerifyAttempted = true;
        _barStatusMessage = e.message;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) {
        setState(() => _isVerifyingBar = false);
      }
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

  Color? _barStatusColor() {
    if (_barVerified) {
      return Colors.greenAccent;
    }
    if (_barVerifyAttempted) {
      return Colors.orangeAccent;
    }
    return Colors.white54;
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
                left: 0,
                top: s.s(113),
                child: LawyerSectionHeading(
                  title: 'Verify Your Details',
                  scale: s,
                  titleWidth: 143,
                ),
              ),
              Positioned(
                left: 0,
                top: s.s(164),
                child: LawyerSetupStepBar(scale: s, activeStep: 1),
              ),
              Positioned(
                left: s.s(15),
                top: s.s(210),
                right: s.s(15),
                bottom: s.s(90),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LawyerDocumentUploadRow(
                        scale: s,
                        label: _documentLabel(0),
                        onTap: () => _pickDocument(
                          _documents[0].label,
                          _documents[0].docType,
                        ),
                      ),
                      if (_barCertUploaded) ...[
                        SizedBox(height: s.s(12)),
                        Text(
                          'Bar Council Enrollment Number',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: s.fs(12),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: s.s(6)),
                        Row(
                          children: [
                            Expanded(
                              child: LawyerFormField(
                                scale: s,
                                hint: 'Ex: UP0003B/19',
                                controller: _barEnrollmentController,
                                width: double.infinity,
                              ),
                            ),
                            SizedBox(width: s.s(8)),
                            SizedBox(
                              height: s.s(52),
                              child: ElevatedButton(
                                onPressed:
                                    _isVerifyingBar ? null : _verifyBarEnrollment,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.gold,
                                  foregroundColor: Colors.black,
                                ),
                                child: Text(
                                  _isVerifyingBar ? '...' : 'Verify',
                                  style: TextStyle(fontSize: s.fs(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_barStatusMessage != null) ...[
                          SizedBox(height: s.s(6)),
                          Text(
                            _barStatusMessage!,
                            style: TextStyle(
                              color: _barStatusColor(),
                              fontSize: s.fs(11),
                              height: 1.35,
                            ),
                          ),
                        ] else ...[
                          SizedBox(height: s.s(4)),
                          Text(
                            'Enter enrollment number and tap Verify',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: s.fs(10),
                            ),
                          ),
                        ],
                        if (_barVerifyAttempted &&
                            (_portalAdvocateName?.isNotEmpty == true ||
                                _portalDistrict?.isNotEmpty == true)) ...[
                          SizedBox(height: s.s(10)),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(s.s(12)),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(s.s(10)),
                              border: Border.all(
                                color: Colors.white24,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bar Council records',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: s.fs(11),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (_portalAdvocateName?.isNotEmpty == true) ...[
                                  SizedBox(height: s.s(4)),
                                  Text(
                                    'Name: $_portalAdvocateName',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: s.fs(11),
                                    ),
                                  ),
                                ],
                                if (_portalDistrict?.isNotEmpty == true) ...[
                                  SizedBox(height: s.s(2)),
                                  Text(
                                    'District: $_portalDistrict',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: s.fs(10),
                                    ),
                                  ),
                                ],
                                if (_portalEnrollmentDate?.isNotEmpty == true) ...[
                                  SizedBox(height: s.s(2)),
                                  Text(
                                    'Enrolled: $_portalEnrollmentDate',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: s.fs(10),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ],
                      SizedBox(height: s.s(16)),
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
                    ],
                  ),
                ),
              ),
              Positioned(
                left: s.s(20),
                bottom: s.s(24),
                width: s.s(324),
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
