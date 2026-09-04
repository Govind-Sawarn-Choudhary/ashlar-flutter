import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_profile_helpers.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_profile_repository.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/models/lawyer_auth_response.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/widgets/lawyer_form_field.dart';
import 'package:flutter/material.dart';

/// Prominent Bar Council verification block with clear editable input.
class LawyerBarCouncilVerificationCard extends StatefulWidget {
  const LawyerBarCouncilVerificationCard({
    super.key,
    required this.scale,
    required this.barCertUploaded,
    this.enrollmentController,
    this.onUploadCertificate,
    this.onVerified,
  });

  final FigmaScale scale;
  final bool barCertUploaded;
  final TextEditingController? enrollmentController;
  final VoidCallback? onUploadCertificate;
  final VoidCallback? onVerified;

  @override
  State<LawyerBarCouncilVerificationCard> createState() =>
      _LawyerBarCouncilVerificationCardState();
}

class _LawyerBarCouncilVerificationCardState
    extends State<LawyerBarCouncilVerificationCard> {
  late final TextEditingController _enrollmentController;
  final _enrollmentFocus = FocusNode();
  bool _ownsController = false;

  bool _loading = true;
  bool _isVerifying = false;
  bool _barVerified = false;
  bool _barVerifyAttempted = false;
  String? _barStatusMessage;
  String? _lawyerFullName;
  String? _portalAdvocateName;
  String? _portalDistrict;
  String? _portalEnrollmentDate;
  String _barState = 'UP';
  LawyerProfileSnapshot? _profile;

  @override
  void initState() {
    super.initState();
    if (widget.enrollmentController != null) {
      _enrollmentController = widget.enrollmentController!;
    } else {
      _enrollmentController = TextEditingController();
      _ownsController = true;
    }
    _enrollmentFocus.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (_enrollmentFocus.hasFocus && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          Scrollable.ensureVisible(
            context,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment: 0.35,
          );
        });
      }
    });
    _loadProfile();
  }

  @override
  void dispose() {
    if (_ownsController) {
      _enrollmentController.dispose();
    }
    _enrollmentFocus.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final response = await LawyerProfileRepository.instance.getMe();
      final profile = response.lawyer;
      _profile = profile;
      _lawyerFullName = profile.fullName;
      _barState = profile.barState ?? 'UP';
      _enrollmentController.text = profile.barEnrollmentNumber ?? '';
      _barVerified = profile.barEnrollmentVerified;
      _barVerifyAttempted = profile.barEnrollmentNumber?.isNotEmpty == true ||
          profile.barManualReview ||
          profile.barVerifiedName != null;
      _portalAdvocateName = profile.barVerifiedName;
      _portalDistrict = profile.location;
      _portalEnrollmentDate = profile.barVerifiedEnrollmentDate;

      if (profile.barEnrollmentVerified) {
        _barStatusMessage = 'Verified with Bar Council records';
      } else if (profile.barManualReview) {
        _barStatusMessage =
            'Auto-verify pending — admin will review your certificate';
      }
    } catch (_) {
      // Keep defaults for first-time onboarding.
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _verifyBarEnrollment() async {
    final enrollment = _enrollmentController.text.trim().toUpperCase();

    if (!widget.barCertUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload Bar Council certificate first')),
      );
      return;
    }

    if (enrollment.isEmpty) {
      _enrollmentFocus.requestFocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your Bar Council enrollment number')),
      );
      return;
    }

    if (_isVerifying) {
      return;
    }

    setState(() => _isVerifying = true);

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
      _profile = profile;

      setState(() {
        _barVerified = result.verified;
        _barVerifyAttempted = true;
        _barStatusMessage = result.message;
        _enrollmentController.text = result.inputEnrollmentNumber.isNotEmpty
            ? result.inputEnrollmentNumber
            : enrollment;
        _lawyerFullName = profile.fullName ?? result.advocateName;
        _portalAdvocateName = result.advocateName ?? profile.barVerifiedName;
        _portalDistrict = result.district ?? profile.location;
        _portalEnrollmentDate =
            result.enrollmentDate ?? profile.barVerifiedEnrollmentDate;
      });

      widget.onVerified?.call();

      if (result.verified) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor:
                result.nameMatched == false ? Colors.orange : Colors.green,
            content: Text(
              result.nameMatched == false
                  ? 'Name corrected to: ${profile.fullName ?? result.advocateName ?? 'Bar Council name'}'
                  : 'Bar Council verified: ${profile.fullName ?? result.advocateName ?? 'Success'}',
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
        setState(() => _isVerifying = false);
      }
    }
  }

  Color _statusColor() {
    if (_barVerified) {
      return const Color(0xFF43A047);
    }
    if (_barVerifyAttempted) {
      return const Color(0xFFFFB74D);
    }
    return AppColors.gold;
  }

  String _statusLabel() {
    if (_profile != null) {
      return LawyerProfileHelpers.barVerificationLabel(_profile!);
    }
    if (_barVerified) {
      return 'Bar Council verified';
    }
    if (_barVerifyAttempted) {
      return 'Verification pending';
    }
    return 'Not verified yet';
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;

    if (_loading) {
      return SizedBox(
        height: s.s(120),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2),
        ),
      );
    }

    final canEditEnrollment = !_barVerified;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(s.s(14)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.gold.withValues(alpha: 0.18),
            Colors.white.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(s.s(14)),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.55), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.12),
            blurRadius: s.s(18),
            offset: Offset(0, s.s(6)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: s.s(36),
                height: s.s(36),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(s.s(10)),
                ),
                child: Icon(
                  Icons.verified_user_rounded,
                  color: AppColors.gold,
                  size: s.s(20),
                ),
              ),
              SizedBox(width: s.s(10)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bar Council Verification',
                      style: AppTypography.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: s.fs(14),
                      ),
                    ),
                    SizedBox(height: s.s(2)),
                    Text(
                      'Required for lawyer profile approval',
                      style: AppTypography.inter(
                        color: Colors.white60,
                        fontWeight: FontWeight.w400,
                        fontSize: s.fs(10),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: s.s(10),
                  vertical: s.s(5),
                ),
                decoration: BoxDecoration(
                  color: _statusColor().withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: _statusColor().withValues(alpha: 0.45)),
                ),
                child: Text(
                  _statusLabel(),
                  style: AppTypography.inter(
                    color: _statusColor(),
                    fontWeight: FontWeight.w600,
                    fontSize: s.fs(9),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: s.s(14)),
          if (!widget.barCertUploaded) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(s.s(12)),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(s.s(10)),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step 1: Upload certificate',
                    style: AppTypography.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: s.fs(12),
                    ),
                  ),
                  SizedBox(height: s.s(4)),
                  Text(
                    'Upload your Bar Council certificate first. After that, enter your enrollment number below.',
                    style: AppTypography.inter(
                      color: Colors.white60,
                      fontSize: s.fs(10),
                      height: 1.35,
                    ),
                  ),
                  if (widget.onUploadCertificate != null) ...[
                    SizedBox(height: s.s(10)),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: widget.onUploadCertificate,
                        icon: Icon(Icons.upload_file_rounded, size: s.s(16)),
                        label: const Text('Upload Bar Council Certificate'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.gold,
                          side: BorderSide(color: AppColors.gold.withValues(alpha: 0.7)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: s.s(12)),
          ],
          Text(
            'Enrollment Number',
            style: AppTypography.inter(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: s.fs(12),
            ),
          ),
          SizedBox(height: s.s(4)),
          Text(
            canEditEnrollment
                ? 'Tap the field below to enter number, then press Verify'
                : 'Verified enrollment number',
            style: AppTypography.inter(
              color: Colors.white54,
              fontSize: s.fs(10),
            ),
          ),
          SizedBox(height: s.s(8)),
          Row(
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(s.s(10)),
                    boxShadow: _enrollmentFocus.hasFocus
                        ? [
                            BoxShadow(
                              color: AppColors.gold.withValues(alpha: 0.35),
                              blurRadius: s.s(10),
                            ),
                          ]
                        : null,
                  ),
                  child: LawyerFormField(
                    scale: s,
                    hint: 'Ex: UP0003B/19',
                    controller: _enrollmentController,
                    focusNode: _enrollmentFocus,
                    width: double.infinity,
                    readOnly: !canEditEnrollment,
                  ),
                ),
              ),
              SizedBox(width: s.s(8)),
              SizedBox(
                height: s.s(52),
                child: ElevatedButton(
                  onPressed: !canEditEnrollment || _isVerifying
                      ? null
                      : _verifyBarEnrollment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.white24,
                    disabledForegroundColor: Colors.white54,
                    padding: EdgeInsets.symmetric(horizontal: s.s(14)),
                  ),
                  child: Text(
                    _barVerified
                        ? 'Verified'
                        : _isVerifying
                            ? '...'
                            : 'Verify',
                    style: TextStyle(
                      fontSize: s.fs(12),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_barStatusMessage != null) ...[
            SizedBox(height: s.s(8)),
            Text(
              _barStatusMessage!,
              style: AppTypography.inter(
                color: _statusColor(),
                fontSize: s.fs(10),
                height: 1.35,
              ),
            ),
          ],
          if (_barVerifyAttempted &&
              (_portalAdvocateName?.isNotEmpty == true ||
                  _portalDistrict?.isNotEmpty == true)) ...[
            SizedBox(height: s.s(10)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(s.s(10)),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(s.s(10)),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Matched from Bar Council portal',
                    style: AppTypography.inter(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      fontSize: s.fs(10),
                    ),
                  ),
                  if (_portalAdvocateName?.isNotEmpty == true) ...[
                    SizedBox(height: s.s(4)),
                    Text(
                      'Name: $_portalAdvocateName',
                      style: AppTypography.inter(
                        color: Colors.white,
                        fontSize: s.fs(11),
                      ),
                    ),
                  ],
                  if (_portalDistrict?.isNotEmpty == true) ...[
                    SizedBox(height: s.s(2)),
                    Text(
                      'District: $_portalDistrict',
                      style: AppTypography.inter(
                        color: Colors.white70,
                        fontSize: s.fs(10),
                      ),
                    ),
                  ],
                  if (_portalEnrollmentDate?.isNotEmpty == true) ...[
                    SizedBox(height: s.s(2)),
                    Text(
                      'Enrolled: $_portalEnrollmentDate',
                      style: AppTypography.inter(
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
      ),
    );
  }
}
