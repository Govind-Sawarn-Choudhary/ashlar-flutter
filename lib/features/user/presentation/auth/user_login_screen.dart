import 'package:ashlar_lawyer_hub/core/config/dev_auth.dart';
import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/core/widgets/auth_buttons.dart';
import 'package:ashlar_lawyer_hub/core/widgets/auth_page_indicator.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/lawyer_routes.dart';
import 'package:ashlar_lawyer_hub/features/user/data/user_auth_repository.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/auth/widgets/user_auth_widgets.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/auth/widgets/user_login_glow_background.dart';
import 'package:ashlar_lawyer_hub/features/user/user_routes.dart';
import 'package:flutter/material.dart';

/// User login — responsive OTP entry for clients.
class UserLoginScreen extends StatefulWidget {
  const UserLoginScreen({super.key});

  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _phoneFocus = FocusNode();
  final _scrollController = ScrollController();
  final _phoneFieldKey = GlobalKey();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    if (DevAuth.enabled) {
      _phoneController.text = DevAuth.phone;
    }
    _phoneController.addListener(_onPhoneChanged);
    _phoneFocus.addListener(_onPhoneFocusChanged);
  }

  void _onPhoneChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onPhoneFocusChanged() {
    if (_phoneFocus.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToPhoneField();
      });
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _scrollToPhoneField() async {
    final fieldContext = _phoneFieldKey.currentContext;
    if (fieldContext == null || !mounted) {
      return;
    }
    await Scrollable.ensureVisible(
      fieldContext,
      alignment: 0.05,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _phoneController
      ..removeListener(_onPhoneChanged)
      ..dispose();
    _phoneFocus
      ..removeListener(_onPhoneFocusChanged)
      ..dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    final phone = _phoneController.text.trim();
    return phone.length == 10 && RegExp(r'^[6-9]\d{9}$').hasMatch(phone);
  }

  Future<void> _sendOtp() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() != true) {
      return;
    }

    if (_isSending || !_canSubmit) {
      return;
    }

    setState(() => _isSending = true);
    final phone = _phoneController.text.trim();

    try {
      await UserAuthRepository.instance.sendOtp(phone);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushNamed(UserRoutes.otp, arguments: phone);
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
          content: Text('Could not send OTP. Check your internet and try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  void _goToLawyerLogin() {
    Navigator.of(context).pushReplacementNamed(LawyerRoutes.login);
  }

  void _goBack() {
    FocusScope.of(context).unfocus();
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pushReplacementNamed('/role-select');
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final compact = keyboardOpen || _phoneFocus.hasFocus;
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
              child: Row(
                children: [
                  UserAuthBackButton(onTap: _goBack, scale: scale),
                  const Spacer(),
                  if (compact) UserClientBadge(scale: scale, compact: true),
                ],
              ),
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 260),
              crossFadeState:
                  compact ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              sizeCurve: Curves.easeOutCubic,
              firstCurve: Curves.easeOutCubic,
              secondCurve: Curves.easeOutCubic,
              firstChild: _LoginHero(scale: scale),
              secondChild: const SizedBox.shrink(),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const ClampingScrollPhysics(),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  scale.s(20),
                  compact ? scale.s(8) : scale.s(12),
                  scale.s(20),
                  scale.s(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!compact) ...[
                      AuthPageIndicator(activeIndex: 0, scaleX: scale.scale),
                      SizedBox(height: scale.s(14)),
                      UserClientBadge(scale: scale),
                      SizedBox(height: scale.s(14)),
                    ],
                    Text(
                      compact ? 'Client login' : 'Hi, Welcome!',
                      style: AppTypography.openSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: scale.fs(compact ? 20 : 24),
                        height: 1.15,
                      ),
                    ),
                    SizedBox(height: scale.s(compact ? 6 : 10)),
                    Text(
                      compact
                          ? 'Enter your 10-digit mobile number'
                          : 'Sign in with your mobile number to book lawyers, manage appointments, and access legal services.',
                      style: AppTypography.openSans(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                        fontSize: scale.fs(compact ? 13 : 14),
                        height: 1.45,
                      ),
                    ),
                    SizedBox(height: scale.s(compact ? 16 : 20)),
                    if (!compact) ...[
                      UserAuthDivider(scale: scale),
                      SizedBox(height: scale.s(18)),
                    ],
                    KeyedSubtree(
                      key: _phoneFieldKey,
                      child: UserAuthPhoneField(
                        scale: scale,
                        controller: _phoneController,
                        focusNode: _phoneFocus,
                        validator: validateIndianMobile,
                        onSubmitted: _sendOtp,
                      ),
                    ),
                    SizedBox(height: scale.s(10)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: scale.s(14),
                          color: AppColors.gold.withValues(alpha: 0.85),
                        ),
                        SizedBox(width: scale.s(6)),
                        Expanded(
                          child: Text(
                            'We\'ll send a secure 6-digit OTP. Standard SMS charges may apply.',
                            style: AppTypography.inter(
                              color: Colors.white54,
                              fontSize: scale.fs(11),
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: scale.s(20)),
                    Opacity(
                      opacity: _canSubmit && !_isSending ? 1 : 0.55,
                      child: IgnorePointer(
                        ignoring: !_canSubmit || _isSending,
                        child: GoldActionButton(
                          label: _isSending ? 'Sending OTP…' : 'Continue with OTP',
                          onTap: _sendOtp,
                          scaleX: scale.scale,
                          scaleY: scale.scale,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!compact)
              Padding(
                padding: EdgeInsets.fromLTRB(scale.s(20), 0, scale.s(20), scale.s(12)),
                child: Column(
                  children: [
                    TextButton(
                      onPressed: _goToLawyerLogin,
                      child: Text(
                        'Are you a lawyer? Login here',
                        style: AppTypography.inter(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w600,
                          fontSize: scale.fs(14),
                        ),
                      ),
                    ),
                    Text(
                      'By continuing, you agree to Ashlar\'s Terms of Service and Privacy Policy.',
                      textAlign: TextAlign.center,
                      style: AppTypography.inter(
                        color: Colors.white38,
                        fontSize: scale.fs(10),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LoginHero extends StatelessWidget {
  const _LoginHero({required this.scale});

  final FigmaScale scale;

  @override
  Widget build(BuildContext context) {
    final height = scale.s(220);
    return SizedBox(
      height: height,
      width: double.infinity,
      child: ClipRect(
        child: Align(
          alignment: Alignment.topCenter,
          child: Image.asset(
            AppAssets.userLoginIllustration,
            width: scale.s(320),
            height: height,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}
