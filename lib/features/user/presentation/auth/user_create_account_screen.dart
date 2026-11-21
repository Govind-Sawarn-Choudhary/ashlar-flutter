import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/core/widgets/auth_buttons.dart';
import 'package:ashlar_lawyer_hub/core/widgets/auth_page_indicator.dart';
import 'package:ashlar_lawyer_hub/features/user/data/user_auth_repository.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/auth/user_auth_tokens.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/auth/widgets/user_auth_widgets.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/auth/widgets/user_login_glow_background.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/widgets/user_design_tokens.dart';
import 'package:flutter/material.dart';

/// User profile completion after OTP — keyboard-safe registration form.
class UserCreateAccountScreen extends StatefulWidget {
  const UserCreateAccountScreen({super.key});

  @override
  State<UserCreateAccountScreen> createState() => _UserCreateAccountScreenState();
}

class _UserCreateAccountScreenState extends State<UserCreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _fullNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _emailController = TextEditingController();
  final _languageController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _scrollController.dispose();
    _fullNameController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _languageController.dispose();
    super.dispose();
  }

  Future<void> _pickLanguage() async {
    FocusScope.of(context).unfocus();
    final selected = await showUserLanguagePicker(
      context,
      selected: _languageController.text.trim().isEmpty
          ? null
          : _languageController.text.trim(),
    );
    if (selected != null && mounted) {
      setState(() => _languageController.text = selected);
    }
  }

  Future<void> _onSignUp() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() != true) {
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
      final response = await UserAuthRepository.instance.saveProfile(
        fullName: _fullNameController.text.trim(),
        location: _locationController.text.trim(),
        email: _emailController.text.trim(),
        language: _languageController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      final route = UserAuthRepository.instance.routeForNextStep(response.nextRoute);
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
        const SnackBar(
          content: Text('Could not save profile. Check your connection and try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = FigmaScale.fromViewport(MediaQuery.sizeOf(context));

    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: true,
      dismissKeyboardOnTap: true,
      resizeToAvoidBottomInset: true,
      background: const UserLoginGlowBackground(),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(scale.s(8), scale.s(4), scale.s(16), 0),
              child: UserAuthBackButton(
                onTap: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
                scale: scale,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(scale.s(20), scale.s(8), scale.s(20), scale.s(24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserClientBadge(scale: scale),
                    SizedBox(height: scale.s(16)),
                    Text(
                      'Create Account',
                      style: AppTypography.openSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: scale.fs(26),
                        height: 1.15,
                      ),
                    ),
                    SizedBox(height: scale.s(8)),
                    Text(
                      'Complete your profile to book lawyers, manage appointments, and access legal services.',
                      style: AppTypography.openSans(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                        fontSize: scale.fs(14),
                        height: 1.45,
                      ),
                    ),
                    SizedBox(height: scale.s(20)),
                    UserAuthDivider(scale: scale, label: 'Your details'),
                    SizedBox(height: scale.s(18)),
                    UserAuthTextField(
                      scale: scale,
                      hint: 'Full Name',
                      controller: _fullNameController,
                      textInputAction: TextInputAction.next,
                      validator: (value) => validateRequired(value, 'full name'),
                    ),
                    SizedBox(height: scale.s(14)),
                    UserAuthTextField(
                      scale: scale,
                      hint: 'City / Location',
                      controller: _locationController,
                      textInputAction: TextInputAction.next,
                      validator: (value) => validateRequired(value, 'location'),
                    ),
                    SizedBox(height: scale.s(14)),
                    UserAuthTextField(
                      scale: scale,
                      hint: 'Email Address',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: validateEmail,
                    ),
                    SizedBox(height: scale.s(14)),
                    UserAuthTextField(
                      scale: scale,
                      hint: 'Preferred Language',
                      controller: _languageController,
                      readOnly: true,
                      onTap: _pickLanguage,
                      validator: (value) => validateRequired(value, 'preferred language'),
                      suffixIcon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: UserDesignTokens.gold,
                        size: scale.s(22),
                      ),
                    ),
                    SizedBox(height: scale.s(24)),
                    Center(
                      child: AuthPageIndicator(
                        activeIndex: 2,
                        scaleX: scale.scale,
                        inactiveColor: UserAuthTokens.inactiveDotColor,
                      ),
                    ),
                    SizedBox(height: scale.s(20)),
                    Opacity(
                      opacity: _isSaving ? 0.55 : 1,
                      child: IgnorePointer(
                        ignoring: _isSaving,
                        child: GoldActionButton(
                          label: _isSaving ? 'Creating account…' : 'Complete Registration',
                          onTap: _onSignUp,
                          scaleX: scale.scale,
                          scaleY: scale.scale,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
