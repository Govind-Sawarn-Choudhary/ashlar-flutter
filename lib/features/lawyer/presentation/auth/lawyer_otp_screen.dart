import 'dart:async';
import 'dart:math' as math;

import 'package:ashlar_lawyer_hub/core/config/dev_auth.dart';
import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
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

/// Lawyer OTP verification — responsive layout matching Figma `7125:5631`.
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

  /// Figma content inset — `7125:5631`.
  static const _figmaLeft = 19.0;
  static const _buttonHorizontalMargin = 20.0;
  static const _designWidth = 360.0;

  /// OTP group `7125:5651` — widened for 6 digits @ 317×63.
  static const _otpGroupWidth = 316.9996337890625;
  static const _otpGroupHeight = 63.0;
  static const _otpCellSize = 48.0;
  static const _otpBorderRadius = 14.0;

  List<double> get _otpCellXInGroup {
    final gap = (_otpGroupWidth - _otpLength * _otpCellSize) /
        (_otpLength - 1);
    return List.generate(
      _otpLength,
      (index) => index * (_otpCellSize + gap),
    );
  }

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  Timer? _resendTimer;
  int _secondsRemaining = 55;
  bool _isVerifying = false;

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
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _secondsRemaining = 55);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
        return;
      }
      setState(() => _secondsRemaining--);
    });
  }

  String get _otp => _controllers.map((c) => c.text).join();

  Future<void> _verifyOtp() async {
    if (_otp.length != _otpLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit OTP')),
      );
      return;
    }

    if (_isVerifying) {
      return;
    }

    setState(() => _isVerifying = true);

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP verification failed. Check backend connection.')),
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
      _startResendTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP resent')),
      );
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  void _onOtpChanged(int index, String value) {
    if (value.length > 1) {
      _controllers[index].text = value[value.length - 1];
      _controllers[index].selection = const TextSelection.collapsed(offset: 1);
    }

    if (value.isNotEmpty && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Widget _buildResendText(double fontSize) {
    return GestureDetector(
      onTap: _onResendTap,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Resend OTP',
              style: AppTypography.openSans(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: fontSize,
                height: 15 / 12,
              ),
            ),
            if (_secondsRemaining > 0)
              TextSpan(
                text: ' available in $_secondsRemaining sec',
                style: AppTypography.openSans(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w400,
                  fontSize: fontSize,
                  height: 15 / 12,
                ),
              ),
          ],
        ),
        textAlign: TextAlign.right,
      ),
    );
  }

  /// Figma group `7125:5651` — 317×63, cells 63.58×63, radius 14.
  Widget _buildOtpGroup(double scale) {
    final cellSize = _otpCellSize * scale;
    final radius = _otpBorderRadius * scale;

    return SizedBox(
      width: _otpGroupWidth * scale,
      height: _otpGroupHeight * scale,
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
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final scale = width / _designWidth;
    final heroSize = math.min(288.0 * scale, width - 72);

    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: false,
      background: const LawyerLoginGlowBackground(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 48 * scale),
                  Center(
                    child: Image.asset(
                      AppAssets.lawyerOtpIllustration,
                      width: heroSize,
                      height: heroSize,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  SizedBox(height: 22 * scale),
                  Padding(
                    padding: EdgeInsets.only(left: _figmaLeft * scale),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AuthPageIndicator(
                          activeIndex: 1,
                          scaleX: scale,
                        ),
                        SizedBox(height: 19 * scale),
                        Padding(
                          padding: EdgeInsets.only(right: _figmaLeft * scale),
                          child: Text(
                            'OTP Verification!',
                            style: AppTypography.openSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 24 * scale,
                              height: 25 / 24,
                            ),
                          ),
                        ),
                        SizedBox(height: 18 * scale),
                        Padding(
                          padding: EdgeInsets.only(right: _figmaLeft * scale),
                          child: SizedBox(
                            width: 334 * scale,
                            child: Text(
                              'Enter the 6 digit code that you received on your number +91 ${widget.phoneNumber}.',
                              style: AppTypography.openSans(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w400,
                                fontSize: 16 * scale,
                                height: 45 / 16,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 27 * scale),
                        _buildOtpGroup(scale),
                        SizedBox(height: 8 * scale),
                        SizedBox(
                          width: _otpGroupWidth * scale,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: _buildResendText(12 * scale),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32 * scale),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _buttonHorizontalMargin,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52 * scale,
                      child: GoldActionButton(
                        label: _isVerifying ? 'Verifying…' : 'Verify OTP',
                        onTap: _verifyOtp,
                        scaleX: scale,
                        scaleY: scale,
                      ),
                    ),
                  ),
                  SizedBox(height: 24 * scale),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
