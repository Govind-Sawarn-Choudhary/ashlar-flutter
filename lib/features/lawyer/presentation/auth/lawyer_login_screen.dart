import 'package:ashlar_lawyer_hub/core/config/dev_auth.dart';
import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/core/widgets/auth_buttons.dart';
import 'package:ashlar_lawyer_hub/core/widgets/auth_page_indicator.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_auth_repository.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/lawyer_routes.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/auth/widgets/lawyer_login_glow_background.dart';
import 'package:ashlar_lawyer_hub/features/user/user_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Lawyer login — secure OTP entry for advocates.
class LawyerLoginScreen extends StatefulWidget {
  const LawyerLoginScreen({super.key});

  @override
  State<LawyerLoginScreen> createState() => _LawyerLoginScreenState();
}

class _LawyerLoginScreenState extends State<LawyerLoginScreen> {
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
    final context = _phoneFieldKey.currentContext;
    if (context == null || !mounted) {
      return;
    }
    await Scrollable.ensureVisible(
      context,
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

  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) {
      return 'Enter your mobile number';
    }
    if (phone.length != 10) {
      return 'Enter a valid 10-digit mobile number';
    }
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(phone)) {
      return 'Mobile number must start with 6, 7, 8, or 9';
    }
    return null;
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
      await LawyerAuthRepository.instance.sendOtp(phone);
      if (!mounted) {
        return;
      }

      Navigator.of(context).pushNamed(
        LawyerRoutes.otp,
        arguments: phone,
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

  void _goToClientLogin() {
    Navigator.of(context).pushReplacementNamed(UserRoutes.login);
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
    final size = MediaQuery.sizeOf(context);
    final scale = FigmaScale.fromViewport(size);

    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: true,
      dismissKeyboardOnTap: true,
      resizeToAvoidBottomInset: true,
      background: const LawyerLoginGlowBackground(),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(scale.s(8), scale.s(4), scale.s(16), 0),
              child: Row(
                children: [
                  _BackButton(onTap: _goBack, scale: scale),
                  const Spacer(),
                  if (compact)
                    _LawyerPortalBadge(scale: scale, compact: true),
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
                      _LawyerPortalBadge(scale: scale),
                      SizedBox(height: scale.s(14)),
                    ],
                    Text(
                      compact ? 'Lawyer login' : 'Welcome, Advocate',
                      style: AppTypography.openSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: scale.fs(compact ? 20 : 24),
                        height: 1.15,
                      ),
                    ),
                    SizedBox(height: scale.s(compact ? 6 : 10)),
                    if (!compact)
                      Text(
                        'Sign in with your registered mobile number to access your dashboard, cases, and consultations.',
                        style: AppTypography.openSans(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                          fontSize: scale.fs(14),
                          height: 1.45,
                        ),
                      )
                    else
                      Text(
                        'Enter your 10-digit mobile number',
                        style: AppTypography.inter(
                          color: Colors.white60,
                          fontSize: scale.fs(13),
                        ),
                      ),
                    SizedBox(height: scale.s(compact ? 16 : 20)),
                    if (!compact) ...[
                      _SecureLoginDivider(scale: scale),
                      SizedBox(height: scale.s(18)),
                    ],
                    KeyedSubtree(
                      key: _phoneFieldKey,
                      child: _PhoneField(
                        scale: scale,
                        controller: _phoneController,
                        focusNode: _phoneFocus,
                        validator: _validatePhone,
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
                    if (compact) ...[
                      SizedBox(height: scale.s(12)),
                      Center(
                        child: TextButton(
                          onPressed: _goToClientLogin,
                          child: Text(
                            'Login as Client',
                            style: AppTypography.inter(
                              color: AppColors.gold,
                              fontWeight: FontWeight.w600,
                              fontSize: scale.fs(13),
                            ),
                          ),
                        ),
                      ),
                    ],
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
                      onPressed: _goToClientLogin,
                      child: Text(
                        'Not a lawyer? Login as Client',
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
            AppAssets.lawyerLoginIllustration,
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

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap, required this.scale});

  final VoidCallback onTap;
  final FigmaScale scale;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(scale.s(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(scale.s(12)),
        child: SizedBox(
          width: scale.s(44),
          height: scale.s(44),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: scale.s(18),
          ),
        ),
      ),
    );
  }
}

class _LawyerPortalBadge extends StatelessWidget {
  const _LawyerPortalBadge({required this.scale, this.compact = false});

  final FigmaScale scale;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: scale.s(compact ? 8 : 10),
        vertical: scale.s(compact ? 4 : 5),
      ),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(scale.s(20)),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            AppAssets.roleSelectLawyerIcon,
            width: scale.s(compact ? 14 : 16),
            height: scale.s(compact ? 14 : 16),
            fit: BoxFit.contain,
          ),
          SizedBox(width: scale.s(6)),
          Text(
            'Lawyer Portal',
            style: AppTypography.inter(
              color: AppColors.gold,
              fontWeight: FontWeight.w700,
              fontSize: scale.fs(compact ? 10 : 11),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _SecureLoginDivider extends StatelessWidget {
  const _SecureLoginDivider({required this.scale});

  final FigmaScale scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(height: 1.5, color: AppColors.gold),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: scale.s(12)),
          child: Text(
            'Secure OTP login',
            style: AppTypography.openSans(
              color: AppColors.gold,
              fontWeight: FontWeight.w600,
              fontSize: scale.fs(15),
            ),
          ),
        ),
        Expanded(
          child: Container(height: 1.5, color: AppColors.gold),
        ),
      ],
    );
  }
}

class _PhoneField extends StatelessWidget {
  const _PhoneField({
    required this.scale,
    required this.controller,
    required this.focusNode,
    required this.validator,
    required this.onSubmitted,
  });

  final FigmaScale scale;
  final TextEditingController controller;
  final FocusNode focusNode;
  final FormFieldValidator<String> validator;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(scale.s(12)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(scale.s(12)),
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => onSubmitted(),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          scrollPadding: EdgeInsets.only(bottom: scale.s(120)),
          style: AppTypography.inter(
            color: const Color(0xFF212121),
            fontWeight: FontWeight.w600,
            fontSize: scale.fs(16),
            letterSpacing: 0.5,
          ),
          decoration: InputDecoration(
            hintText: 'Mobile number',
            hintStyle: AppTypography.inter(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w400,
              fontSize: scale.fs(16),
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: scale.s(14), right: scale.s(8)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '+91',
                    style: AppTypography.inter(
                      color: const Color(0xFF212121),
                      fontWeight: FontWeight.w700,
                      fontSize: scale.fs(16),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: scale.s(22),
                    margin: EdgeInsets.only(left: scale.s(10)),
                    color: const Color(0xFFE0E0E0),
                  ),
                ],
              ),
            ),
            prefixIconConstraints: BoxConstraints(minWidth: scale.s(68)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              vertical: scale.s(16),
              horizontal: scale.s(4),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(scale.s(12)),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(scale.s(12)),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(scale.s(12)),
              borderSide: BorderSide(
                color: AppColors.gold.withValues(alpha: 0.8),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(scale.s(12)),
              borderSide: const BorderSide(color: Color(0xFFE53935)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(scale.s(12)),
              borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.5),
            ),
            errorStyle: AppTypography.inter(
              color: const Color(0xFFFFCDD2),
              fontSize: scale.fs(11),
            ),
            errorMaxLines: 2,
          ),
          validator: validator,
        ),
      ),
    );
  }
}
