import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/features/user/data/user_repository.dart';
import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/manage_profile_typography.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:flutter/material.dart';

/// Manage Profile — Figma [`7125:3675`](https://www.figma.com/design/3PtNxJn9gYGj6S0yAHBce3/ashlarlawyerhub-To-Share--Copy-?node-id=7125-3675) (360×800).
///
/// Full artboard PNG (`7125:3674`) + editable field overlays at Figma positions.
class UserManageProfileScreen extends StatefulWidget {
  const UserManageProfileScreen({super.key});

  @override
  State<UserManageProfileScreen> createState() => _UserManageProfileScreenState();
}

class _UserManageProfileScreenState extends State<UserManageProfileScreen> {
  static const _languages = ['Hindi', 'English', 'Punjabi', 'Tamil'];

  late final TextEditingController _fullNameController;
  late final TextEditingController _locationController;
  late final TextEditingController _emailController;
  late final TextEditingController _languageController;

  bool _loading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _locationController = TextEditingController();
    _emailController = TextEditingController();
    _languageController = TextEditingController();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final response = await UserRepository.instance.getMe();
      _fullNameController.text = response.profile.fullName ?? '';
      _locationController.text = response.profile.location ?? '';
      _emailController.text = response.profile.email ?? '';
      _languageController.text = response.profile.language ?? 'Hindi';
    } catch (_) {
      // Keep empty defaults if offline.
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _languageController.dispose();
    super.dispose();
  }

  Future<void> _pickLanguage() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final language in _languages)
                ListTile(
                  title: Text(language),
                  onTap: () => Navigator.of(context).pop(language),
                ),
            ],
          ),
        );
      },
    );

    if (picked != null) {
      _languageController.text = picked;
    }
  }

  Future<void> _onUpdate() async {
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
      await UserRepository.instance.saveProfile(
        fullName: _fullNameController.text.trim(),
        location: _locationController.text.trim(),
        email: _emailController.text.trim(),
        language: _languageController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const AppDarkScaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.gold)),
      );
    }

    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: false,
      background: const ColoredBox(color: Colors.black),
      body: FigmaScreenCanvas(
        builder: (context, s) {
          return SizedBox(
            width: s.viewportWidth,
            height: s.artboardHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Image.asset(
                    AppAssets.userManageProfileFull,
                    width: s.viewportWidth,
                    height: s.artboardHeight,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high,
                    alignment: Alignment.topCenter,
                  ),
                ),
                Positioned(
                  left: s.s(21),
                  top: s.s(68),
                  width: s.s(40),
                  height: s.s(40),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    behavior: HitTestBehavior.opaque,
                  ),
                ),
                Positioned(
                  left: s.s(26),
                  top: s.s(224),
                  child: _ProfileField(
                    scale: s,
                    controller: _fullNameController,
                  ),
                ),
                Positioned(
                  left: s.s(26),
                  top: s.s(310),
                  child: _ProfileField(
                    scale: s,
                    controller: _locationController,
                  ),
                ),
                Positioned(
                  left: s.s(25),
                  top: s.s(391),
                  child: _ProfileField(
                    scale: s,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                Positioned(
                  left: s.s(25),
                  top: s.s(477),
                  child: _ProfileField(
                    scale: s,
                    controller: _languageController,
                    readOnly: true,
                    onTap: _pickLanguage,
                    suffixIcon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.gold,
                      size: s.s(18),
                    ),
                  ),
                ),
                Positioned(
                  left: s.s(22),
                  top: s.s(590),
                  width: s.s(324),
                  height: s.s(52),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _onUpdate,
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.scale,
    required this.controller,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
  });

  final FigmaScale scale;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final radius = s.s(10);

    return SizedBox(
      width: s.s(320),
      height: s.s(52),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: Colors.white,
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
            readOnly: readOnly,
            onTap: onTap,
            keyboardType: keyboardType,
            style: ManageProfileTypography.fieldValue(s),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              isDense: true,
              contentPadding: EdgeInsets.fromLTRB(
                s.s(22),
                s.s(17),
                suffixIcon != null ? s.s(40) : s.s(22),
                s.s(16),
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
