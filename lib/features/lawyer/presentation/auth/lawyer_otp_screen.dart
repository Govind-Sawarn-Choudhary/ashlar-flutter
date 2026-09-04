import 'dart:async';
import 'dart:math' as math;

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
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/auth/widgets/lawyer_login_glow_background.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/auth/widgets/otp_digit_box.dart';
import 'package:flutter/material.dart';

/// Lawyer OTP verification — secure 6-digit code entry.
class LawyerOtpScreen extends StatefulWidget {
  const LawyerOtpScreen({
    super.key,
    required this.phoneNumber,
  });

  final String phoneNumber;

  @override
  State<LawyerOtpScreen> createState() => _LawyerOtpScreenState();
}

class _LawyerOtpScreenState extends State<LawyerOtpScreen> {
  static const _otpLength = 6;
  static const _designWidth = 360.0;
  static const _otpGroupWidth = 317.0;
  static const _otpCellSize = 48.0;

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  final _scrollController = ScrollController();
  final _otpGroupKey = GlobalKey();
  Timer? _resendTimer;
  int _secondsRemaining = 55;
  bool _isVerifying = false;
  String? _errorMessage;

  List<double> get _otpCellXInGroup {
    const gap = (_otpGroupWidth - _otpLength * _otpCellSize) / (_otpLength - 1);
    return List.generate(
      _otpLength,
      (index) => index * (_otpCellSize + gap),
    );
  }

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(_otpLength, (_) => FocusNode());
    if (DevAuth.enabled && DevAuth.matchesPhone(widget.phoneNumber)) {
      final digits = DevAuth.otp.split('');
      for (var i = 0; i < _otpLength; i++) {
        _controllers[i].text = digits[i];
      }
    }
    _startResendTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _otp.length < _otpLength) {
        _focusNodes[0].requestFocus();
      }
    });
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _secondsRemaining = 55);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
        return;
      }
      if (mounted) {
        setState(() => _secondsRemaining--);
      }
    });
  }

  String get _otp => _controllers.map((c) => c.text).join();

  bool get _isComplete => _otp.length == _otpLength;

  void _clearOtp() {
    for (final controller in _controllers) {
      controller.clear();
    }
    _focusNodes.first.requestFocus();
  }

  void _fillOtpDigits(String digits) {
    final clean = digits.replaceAll(RegExp(r'\D'), '');
    for (var i = 0; i < _otpLength; i++) {
      _controllers[i].text = i < clean.length ? clean[i] : '';
    }
    setState(() {
      _errorMessage = null;
    });

    if (clean.length >= _otpLength) {
      _focusNodes.last.unfocus();
      _verifyOtp();
      return;
    }

    final nextIndex = clean.length.clamp(0, _otpLength - 1);
    _focusNodes[nextIndex].requestFocus();
  }

  void _onOtpChanged(int index, String value) {
    setState(() => _errorMessage = null);

    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 1) {
      _fillOtpDigits(digits);
      return;
    }

    if (value.length > 1) {
      _controllers[index].text = value[value.length - 1];
      _controllers[index].selection = const TextSelection.collapsed(offset: 1);
    }

    if (value.isNotEmpty && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    if (value.isNotEmpty && index == _otpLength - 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _isComplete) {
          _focusNodes[index].unfocus();
          _verifyOtp();
        }
      });
    }

    setState(() {});
  }

  void _onBackspaceWhenEmpty(int index) {
    if (index <= 0) {
      return;
    }
    _controllers[index - 1].clear();
    _focusNodes[index - 1].requestFocus();
    setState(() => _errorMessage = null);
  }

  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus();

    if (!_isComplete) {
      setState(() => _errorMessage = 'Please enter all 6 digits');
      return;
    }

    if (_isVerifying) {
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final response = await LawyerAuthRepository.instance.verifyOtp(
        phone: widget.phoneNumber,
        otp: _otp,
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
      setState(() => _errorMessage = e.message);
      _clearOtp();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      const message = 'Verification failed. Check your connection and try again.';
      setState(() => _errorMessage = message);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  Future<void> _onResendTap() async {
    if (_secondsRemaining > 0 || _isVerifying) {
      return;
    }

    try {
      await LawyerAuthRepository.instance.sendOtp(widget.phoneNumber);
      if (!mounted) {
        return;
      }
      _clearOtp();
      _startResendTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A new OTP has been sent')),
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
        const SnackBar(content: Text('Could not resend OTP. Try again later.')),
      );
    }
  }

  void _editPhoneNumber() {
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _scrollController.dispose();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String _maskedPhone() {
    final phone = widget.phoneNumber;
    if (phone.length < 4) {
      return phone;
    }
    return '${phone.substring(0, 2)}******${phone.substring(phone.length - 2)}';
  }

  Widget _buildOtpGroup(double scale) {
    final cellSize = _otpCellSize * scale;
    final radius = 14.0 * scale;

    return KeyedSubtree(
      key: _otpGroupKey,
      child: SizedBox(
        width: _otpGroupWidth * scale,
        height: 63 * scale,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (var i = 0; i < _otpLength; i++)
              Positioned(
                left: _otpCellXInGroup[i] * scale,
                top: 0,
                child: OtpDigitBox(
                  size: cellSize,
                  borderRadius: radius,
                  fontSize: 24 * scale,
                  controller: _controllers[i],
                  focusNode: _focusNodes[i],
                  onChanged: (value) => _onOtpChanged(i, value),
                  onBackspaceWhenEmpty: () => _onBackspaceWhenEmpty(i),
                  showFocusRing: true,
                  textInputAction:
                      i == _otpLength - 1 ? TextInputAction.done : TextInputAction.next,
                  onSubmitted: i == _otpLength - 1 ? _verifyOtp : null,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final compact = keyboardOpen || _focusNodes.any((node) => node.hasFocus);
    final size = MediaQuery.sizeOf(context);
    final scale = size.width / _designWidth;
    final figmaScale = FigmaScale.fromViewport(size);

    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: true,
      dismissKeyboardOnTap: true,
      resizeToAvoidBottomInset: true,
      background: const LawyerLoginGlowBackground(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(figmaScale.s(8), figmaScale.s(4), figmaScale.s(16), 0),
                child: Row(
                  children: [
                    _BackButton(onTap: _editPhoneNumber, scale: figmaScale),
                    const Spacer(),
                    TextButton(
                      onPressed: _editPhoneNumber,
                      child: Text(
                        'Edit number',
                        style: AppTypography.inter(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w600,
                          fontSize: figmaScale.fs(13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    19 * scale,
                    compact ? 8 * scale : 12 * scale,
                    19 * scale,
                    24 * scale,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 260),
                        crossFadeState: compact
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        firstChild: Center(
                          child: Image.asset(
                            AppAssets.lawyerOtpIllustration,
                            width: math.min(220 * scale, size.width - 72),
                            height: math.min(220 * scale, size.width - 72),
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                        secondChild: const SizedBox.shrink(),
                      ),
                      SizedBox(height: compact ? 8 * scale : 20 * scale),
                      AuthPageIndicator(activeIndex: 1, scaleX: scale),
                      SizedBox(height: 16 * scale),
                      Text(
                        compact ? 'Enter OTP' : 'OTP Verification',
                        style: AppTypography.openSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: (compact ? 22 : 24) * scale,
                          height: 1.15,
                        ),
                      ),
                      SizedBox(height: 10 * scale),
                      RichText(
                        text: TextSpan(
                          style: AppTypography.openSans(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w400,
                            fontSize: 14 * scale,
                            height: 1.45,
                          ),
                          children: [
                            const TextSpan(text: 'Enter the 6-digit code sent to '),
                            TextSpan(
                              text: '+91 ${_maskedPhone()}',
                              style: AppTypography.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14 * scale,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24 * scale),
                      _buildOtpGroup(scale),
                      if (_errorMessage != null) ...[
                        SizedBox(height: 10 * scale),
                        Text(
                          _errorMessage!,
                          style: AppTypography.inter(
                            color: const Color(0xFFFF8A80),
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      SizedBox(height: 12 * scale),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Opacity(
                          opacity: _secondsRemaining > 0 ? 0.55 : 1,
                          child: GestureDetector(
                            onTap: _onResendTap,
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Resend OTP',
                                    style: AppTypography.openSans(
                                      color: _secondsRemaining > 0
                                          ? Colors.white54
                                          : AppColors.gold,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13 * scale,
                                    ),
                                  ),
                                  if (_secondsRemaining > 0)
                                    TextSpan(
                                      text: ' in ${_secondsRemaining}s',
                                      style: AppTypography.openSans(
                                        color: AppColors.textMuted,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 13 * scale,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 28 * scale),
                      Opacity(
                        opacity: _isComplete && !_isVerifying ? 1 : 0.55,
                        child: IgnorePointer(
                          ignoring: !_isComplete || _isVerifying,
                          child: SizedBox(
                            width: double.infinity,
                            height: 52 * scale,
                            child: GoldActionButton(
                              label: _isVerifying ? 'Verifying…' : 'Verify & Continue',
                              onTap: _verifyOtp,
                              scaleX: scale,
                              scaleY: scale,
                            ),
                          ),
                        ),
                      ),
                    ],
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
