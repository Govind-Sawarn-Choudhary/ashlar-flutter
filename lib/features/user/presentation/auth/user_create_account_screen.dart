import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/core/widgets/auth_buttons.dart';
import 'package:ashlar_lawyer_hub/core/widgets/auth_page_indicator.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/widgets/lawyer_form_field.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/widgets/lawyer_section_heading.dart';
import 'package:ashlar_lawyer_hub/features/user/data/user_auth_repository.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/auth/user_auth_tokens.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/auth/widgets/user_login_glow_background.dart';
import 'package:ashlar_lawyer_hub/features/user/user_routes.dart';
import 'package:flutter/material.dart';

/// User create account — Figma [`7125:789`](https://www.figma.com/design/3PtNxJn9gYGj6S0yAHBce3/ashlarlawyerhub-To-Share--Copy-?node-id=7125-789) (360×800).
class UserCreateAccountScreen extends StatefulWidget {
  const UserCreateAccountScreen({super.key});

  @override
  State<UserCreateAccountScreen> createState() =>
      _UserCreateAccountScreenState();
}

class _UserCreateAccountScreenState extends State<UserCreateAccountScreen> {
  final _fullNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _emailController = TextEditingController();
  final _languageController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _languageController.dispose();
    super.dispose();
  }

  Future<void> _onSignUp() async {
    if (_fullNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name')),
      );
      return;
    }
    if (_locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your location')),
      );
      return;
    }
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email')),
      );
      return;
    }
    if (_languageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your preferred language')),
      );
      return;
    }

    if (_isSaving) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      await UserAuthRepository.instance.saveProfile(
        fullName: _fullNameController.text.trim(),
        location: _locationController.text.trim(),
        email: _emailController.text.trim(),
        language: _languageController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacementNamed(UserRoutes.home);
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
    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: false,
      background: const UserLoginGlowBackground(),
      body: FigmaScreenCanvas(
        builder: (context, s) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                top: s.s(113),
                child: LawyerSectionHeading(
                  title: 'Create Account',
                  scale: s,
                  titleWidth: 119,
                ),
              ),
              Positioned(
                left: s.s(66),
                top: s.s(164),
                width: s.s(237),
                child: Text(
                  'Fill your information below to register\nwith your  account',
                  textAlign: TextAlign.center,
                  style: AppTypography.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: s.fs(14),
                    height: 17 / 14,
                    letterSpacing: -0.24,
                  ),
                ),
              ),
              Positioned(
                left: s.s(23),
                top: s.s(246),
                child: LawyerFormField(
                  scale: s,
                  hint: 'Full Name',
                  controller: _fullNameController,
                ),
              ),
              Positioned(
                left: s.s(23),
                top: s.s(332),
                child: LawyerFormField(
                  scale: s,
                  hint: 'Location',
                  controller: _locationController,
                ),
              ),
              Positioned(
                left: s.s(22),
                top: s.s(413),
                child: LawyerFormField(
                  scale: s,
                  hint: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              Positioned(
                left: s.s(22),
                top: s.s(499),
                child: LawyerFormField(
                  scale: s,
                  hint: 'Preffered Language',
                  controller: _languageController,
                  suffixIcon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.gold,
                    size: s.s(18),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: s.s(596),
                child: Center(
                  child: AuthPageIndicator(
                    activeIndex: 2,
                    scaleX: s.scale,
                    inactiveColor: UserAuthTokens.inactiveDotColor,
                  ),
                ),
              ),
              Positioned(
                left: s.s(20),
                top: s.s(626),
                width: s.s(324),
                height: s.s(52),
                child: ProfileContinueButton(
                  label: _isSaving ? 'Signing up…' : 'Sign Up',
                  onTap: _onSignUp,
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
}
