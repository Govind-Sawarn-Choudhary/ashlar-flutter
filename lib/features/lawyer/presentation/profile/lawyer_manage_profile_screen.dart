import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_profile_repository.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/auth/widgets/lawyer_login_glow_background.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/manage_profile_typography.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/widgets/lawyer_section_heading.dart';
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
    if (_fullNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name')),
      );
      return;
    }

    if (_isSaving) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      await LawyerProfileRepository.instance.saveDetails(
        fullName: _fullNameController.text.trim(),
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
      background: const LawyerLoginGlowBackground(),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : FigmaScreenCanvas(
              designHeight: 807,
              builder: (context, s) {
                final readOnly = !_isEditing;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: s.s(8),
                      top: s.s(35),
                      width: s.s(56),
                      height: s.s(56),
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).maybePop(),
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
                      left: 0,
                      top: s.s(113),
                      child: LawyerSectionHeading(
                        title: 'Manage Profile',
                        scale: s,
                        titleWidth: 143,
                      ),
                    ),
                    Positioned(
                      left: s.s(23),
                      top: s.s(183),
                      child: _ManageProfileField(
                        scale: s,
                        controller: _fullNameController,
                        locked: readOnly,
                      ),
                    ),
                    Positioned(
                      left: s.s(22),
                      top: s.s(258),
                      child: _ManageProfileField(
                        scale: s,
                        controller: _phoneController,
                        locked: true,
                        muted: true,
                      ),
                    ),
                    Positioned(
                      left: s.s(22),
                      top: s.s(333),
                      child: _ManageProfileField(
                        scale: s,
                        controller: _practiceAreaController,
                        locked: true,
                        onTap: _isEditing ? _pickPracticeArea : null,
                        suffixIcon: _isEditing
                            ? Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: AppColors.gold,
                                size: s.s(18),
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      left: s.s(22),
                      top: s.s(408),
                      child: _ManageProfileField(
                        scale: s,
                        controller: _experienceController,
                        locked: readOnly,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                    Positioned(
                      left: s.s(22),
                      top: s.s(483),
                      child: _ManageProfileField(
                        scale: s,
                        controller: _bioController,
                        height: 103,
                        maxLines: 4,
                        contentPaddingLeft: 20,
                        contentPaddingTop: 15,
                        locked: readOnly,
                      ),
                    ),
                    Positioned(
                      left: s.s(20),
                      top: s.s(610),
                      width: s.s(324),
                      height: s.s(52),
                      child: _ContinueButton(
                        scale: s,
                        label: _isEditing
                            ? (_isSaving ? 'Saving…' : 'Save')
                            : 'Edit',
                        onTap: _onPrimaryAction,
                      ),
                    ),
                  ],
                );
              },
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

    return SizedBox(
      width: s.s(320),
      height: s.s(height),
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
            onTap: onTap,
            maxLines: maxLines,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
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
  final VoidCallback onTap;

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
