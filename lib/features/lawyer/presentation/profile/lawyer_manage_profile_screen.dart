import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/core/widgets/keyboard_dismissible.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_profile_repository.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_profile_helpers.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/auth/widgets/lawyer_login_glow_background.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/dashboard/widgets/lawyer_dashboard_design_tokens.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/manage_profile_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LawyerManageProfileScreen extends StatefulWidget {
  const LawyerManageProfileScreen({super.key});

  @override
  State<LawyerManageProfileScreen> createState() =>
      _LawyerManageProfileScreenState();
}

class _LawyerManageProfileScreenState extends State<LawyerManageProfileScreen> {
  static const _practiceAreas = [
    'Divorce Lawyer',
    'Criminal Lawyer',
    'Civil Lawyer',
    'Corporate Lawyer',
  ];

  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _practiceAreaController;
  late final TextEditingController _experienceController;
  late final TextEditingController _bioController;

  bool _loading = true;
  bool _isSaving = false;
  bool _isEditing = false;
  String _barVerificationLabel = 'Bar Council not verified';
  bool _barVerified = false;
  String _enrollmentNumber = '';

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _phoneController = TextEditingController();
    _practiceAreaController = TextEditingController();
    _experienceController = TextEditingController();
    _bioController = TextEditingController();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final response = await LawyerProfileRepository.instance.getMe();
      final lawyer = response.lawyer;
      _fullNameController.text = lawyer.fullName ?? '';
      _phoneController.text = _formatPhone(response.userPhone);
      _practiceAreaController.text = lawyer.practiceAreas ?? '';
      _experienceController.text = lawyer.experienceYears ?? '';
      _bioController.text = lawyer.bio ?? '';
      _barVerified = lawyer.barEnrollmentVerified;
      _barVerificationLabel = LawyerProfileHelpers.barVerificationLabel(lawyer);
      _enrollmentNumber = lawyer.barEnrollmentNumber ?? '';
    } catch (_) {
      // Keep empty fields if fetch fails.
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String _formatPhone(String? phone) {
    final digits = phone?.replaceAll(RegExp(r'\D'), '') ?? '';
    if (digits.length == 10) {
      return '+91 $digits';
    }
    return phone ?? '';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _practiceAreaController.dispose();
    _experienceController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickPracticeArea() async {
    if (!_isEditing) {
      return;
    }

    final picked = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final area in _practiceAreas)
                ListTile(
                  title: Text(area),
                  onTap: () => Navigator.of(context).pop(area),
                ),
            ],
          ),
        );
      },
    );

    if (picked != null) {
      setState(() => _practiceAreaController.text = picked);
    }
  }

  Future<void> _onSave() async {
    final fullName = _fullNameController.text.trim();
    if (fullName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile name is missing. Contact support.')),
      );
      return;
    }

    if (_isSaving) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      await LawyerProfileRepository.instance.saveDetails(
        fullName: fullName,
        practiceAreas: _practiceAreaController.text.trim(),
        experienceYears: _experienceController.text.trim(),
        bio: _bioController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isEditing = false;
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
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
        setState(() => _isSaving = false);
      }
    }
  }

  void _onPrimaryAction() {
    if (_isEditing) {
      _onSave();
    } else {
      setState(() => _isEditing = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: false,
      dismissKeyboardOnTap: true,
      background: const LawyerLoginGlowBackground(),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : LayoutBuilder(
              builder: (context, constraints) {
                final scale = FigmaScale.fromViewport(
                  Size(constraints.maxWidth, constraints.maxHeight),
                );
                final readOnly = !_isEditing;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          scale.s(16),
                          scale.s(8),
                          scale.s(16),
                          scale.s(12),
                        ),
                        child: Row(
                          children: [
                            _BackButton(
                              scale: scale,
                              onTap: () => Navigator.of(context).maybePop(),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    'Manage Profile',
                                    textAlign: TextAlign.center,
                                    style: ManageProfileTypography.fieldValue(scale).copyWith(
                                      color: AppColors.gold,
                                      fontWeight: FontWeight.w600,
                                      fontSize: scale.fs(16),
                                    ),
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
                            SizedBox(width: scale.s(40)),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: KeyboardAwareScrollView(
                        stickyFooter: true,
                        padding: EdgeInsets.fromLTRB(
                          scale.s(22),
                          scale.s(16),
                          scale.s(22),
                          0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _BarCouncilPromptCard(
                              scale: scale,
                              label: _barVerificationLabel,
                              verified: _barVerified,
                              enrollmentNumber: _enrollmentNumber,
                            ),
                            SizedBox(height: scale.s(16)),
                            Text(
                              'Full name (verified)',
                              style: ManageProfileTypography.fieldValue(scale).copyWith(
                                color: Colors.white60,
                                fontSize: scale.fs(11),
                              ),
                            ),
                            SizedBox(height: scale.s(6)),
                            _ManageProfileField(
                              scale: scale,
                              controller: _fullNameController,
                              locked: true,
                              muted: true,
                            ),
                            SizedBox(height: scale.s(16)),
                            _ManageProfileField(
                              scale: scale,
                              controller: _phoneController,
                              locked: true,
                              muted: true,
                            ),
                            SizedBox(height: scale.s(16)),
                            _ManageProfileField(
                              scale: scale,
                              controller: _practiceAreaController,
                              locked: true,
                              onTap: _isEditing ? _pickPracticeArea : null,
                              suffixIcon: _isEditing
                                  ? Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: AppColors.gold,
                                      size: scale.s(18),
                                    )
                                  : null,
                            ),
                            SizedBox(height: scale.s(16)),
                            _ManageProfileField(
                              scale: scale,
                              controller: _experienceController,
                              locked: readOnly,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                            SizedBox(height: scale.s(16)),
                            _ManageProfileField(
                              scale: scale,
                              controller: _bioController,
                              height: 103,
                              maxLines: 4,
                              contentPaddingLeft: 20,
                              contentPaddingTop: 15,
                              locked: readOnly,
                            ),
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
                        child: _ContinueButton(
                          scale: scale,
                          label: _isEditing
                              ? (_isSaving ? 'Saving…' : 'Save')
                              : 'Edit',
                          onTap: _isSaving ? null : _onPrimaryAction,
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

class _BackButton extends StatelessWidget {
  const _BackButton({required this.scale, required this.onTap});

  final FigmaScale scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = scale.s(40);

    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            Icons.arrow_back_rounded,
            color: LawyerDashboardTokens.textPrimary,
            size: scale.s(20),
          ),
        ),
      ),
    );
  }
}

class _BarCouncilPromptCard extends StatelessWidget {
  const _BarCouncilPromptCard({
    required this.scale,
    required this.label,
    required this.verified,
    required this.enrollmentNumber,
  });

  final FigmaScale scale;
  final String label;
  final bool verified;
  final String enrollmentNumber;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final color = verified ? const Color(0xFF43A047) : AppColors.gold;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(s.s(14)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(s.s(12)),
        border: Border.all(color: color.withValues(alpha: 0.55)),
        color: color.withValues(alpha: 0.12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            verified ? Icons.verified_rounded : Icons.lock_outline_rounded,
            color: color,
            size: s.s(22),
          ),
          SizedBox(width: s.s(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bar Council Verification',
                  style: ManageProfileTypography.fieldValue(s).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: s.fs(13),
                  ),
                ),
                SizedBox(height: s.s(3)),
                Text(
                  label,
                  style: ManageProfileTypography.fieldValue(s).copyWith(
                    color: color,
                    fontSize: s.fs(11),
                  ),
                ),
                if (enrollmentNumber.isNotEmpty) ...[
                  SizedBox(height: s.s(3)),
                  Text(
                    'Enrollment: $enrollmentNumber',
                    style: ManageProfileTypography.fieldValue(s).copyWith(
                      color: Colors.white70,
                      fontSize: s.fs(10),
                    ),
                  ),
                ],
                SizedBox(height: s.s(3)),
                Text(
                  'Locked after onboarding — contact admin to change',
                  style: ManageProfileTypography.fieldValue(s).copyWith(
                    color: Colors.white54,
                    fontSize: s.fs(10),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ManageProfileField extends StatelessWidget {
  const _ManageProfileField({
    required this.scale,
    required this.controller,
    this.height = 52,
    this.maxLines = 1,
    this.locked = false,
    this.muted = false,
    this.onTap,
    this.suffixIcon,
    this.contentPaddingLeft = 22,
    this.contentPaddingTop = 17,
    this.keyboardType,
    this.inputFormatters,
  });

  final FigmaScale scale;
  final TextEditingController controller;
  final double height;
  final int maxLines;
  final bool locked;
  final bool muted;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final double contentPaddingLeft;
  final double contentPaddingTop;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final radius = s.s(10);

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: s.s(height)),
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: TextField(
            controller: controller,
            readOnly: locked,
            canRequestFocus: !locked,
            enableInteractiveSelection: !locked,
            onTap: onTap,
            maxLines: maxLines,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            scrollPadding: EdgeInsets.only(bottom: s.s(120)),
            style: ManageProfileTypography.fieldValue(s).copyWith(
              color: muted ? const Color(0xFF92929D) : Colors.black,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: muted
                  ? const Color(0xFFF5F5F5)
                  : AppColors.inputBackground,
              isDense: true,
              contentPadding: EdgeInsets.fromLTRB(
                s.s(contentPaddingLeft),
                s.s(contentPaddingTop),
                suffixIcon != null ? s.s(40) : s.s(contentPaddingLeft),
                s.s(maxLines > 1 ? 14 : 16),
              ),
              suffixIcon: suffixIcon == null
                  ? null
                  : Padding(
                      padding: EdgeInsets.only(right: s.s(16)),
                      child: suffixIcon,
                    ),
              suffixIconConstraints: BoxConstraints(
                minWidth: s.s(18),
                minHeight: s.s(18),
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({
    required this.scale,
    required this.label,
    required this.onTap,
  });

  final FigmaScale scale;
  final String label;
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
              label,
              style: ManageProfileTypography.continueLabel(s),
            ),
            Positioned(
              right: s.s(22),
              child: SvgPicture.asset(
                AppAssets.profileUploadChevrons,
                width: s.s(21),
                height: s.s(10),
                fit: BoxFit.contain,
                colorFilter: const ColorFilter.mode(
                  ManageProfileTypography.brandGold,
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
