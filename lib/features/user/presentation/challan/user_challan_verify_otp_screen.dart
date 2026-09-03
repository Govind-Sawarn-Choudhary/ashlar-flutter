import 'dart:async';

import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/features/user/data/user_repository.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/challan/challan_typography.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/challan/user_challan_status_screen.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/challan/widgets/challan_otp_digit_box.dart';
import 'package:flutter/material.dart';

/// OTP Verification — Figma [`7125:2188`](https://www.figma.com/design/3PtNxJn9gYGj6S0yAHBce3/ashlarlawyerhub-To-Share--Copy-?node-id=7125-2188) (360×800).
///
/// Full artboard PNG + transparent OTP overlays, masked dynamic phone + resend timer.
class UserChallanVerifyOtpScreen extends StatefulWidget {
  const UserChallanVerifyOtpScreen({
    super.key,
    required this.vehicleNumber,
    required this.mobileNumber,
  });

  final String vehicleNumber;
  final String mobileNumber;

  @override
  State<UserChallanVerifyOtpScreen> createState() =>
      _UserChallanVerifyOtpScreenState();
}

class _UserChallanVerifyOtpScreenState extends State<UserChallanVerifyOtpScreen> {
  static const _designWidth = 360.0;
  static const _designHeight = 800.0;
  static const _otpLength = 4;
  static const _maskColor = Color(0xFF0C0B09);

  static const _otpCellLefts = <double>[20, 104.47, 188.9453125, 273.41796875];

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  Timer? _resendTimer;
  int _secondsRemaining = 55;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(_otpLength, (_) => FocusNode());
    for (final node in _focusNodes) {
      node.addListener(() => setState(() {}));
    }
    for (final controller in _controllers) {
      controller.addListener(() => setState(() {}));
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

  void _onResendTap() {
    if (_secondsRemaining > 0) {
      return;
    }
    _startResendTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP resent')),
    );
  }

  Future<void> _onVerify() async {
    FocusScope.of(context).unfocus();
    if (_otp.length != _otpLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 4-digit OTP')),
      );
      return;
    }

    try {
      await UserRepository.instance.verifyChallanOtp(
        vehicleNumber: widget.vehicleNumber,
        mobile: widget.mobileNumber,
        otp: _otp,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => UserChallanStatusScreen(
            vehicleNumber: widget.vehicleNumber,
            mobileNumber: widget.mobileNumber,
          ),
        ),
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

  @override
  Widget build(BuildContext context) {
    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: false,
      resizeToAvoidBottomInset: false,
      background: const ColoredBox(color: Colors.black),
      body: FigmaScreenCanvas(
        designWidth: _designWidth,
        designHeight: _designHeight,
        builder: (context, s) {
          return SizedBox(
            width: s.viewportWidth,
            height: s.s(_designHeight),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Image.asset(
                    AppAssets.userChallanVerifyOtpFull,
                    width: s.viewportWidth,
                    height: s.s(_designHeight),
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high,
                    alignment: Alignment.topCenter,
                  ),
                ),
                _tapZone(
                  s,
                  left: 20,
                  top: 66,
                  width: 40,
                  height: 40,
                  onTap: () => Navigator.of(context).pop(),
                ),
                Positioned(
                  left: s.s(20),
                  top: s.s(238),
                  width: s.s(334),
                  height: s.s(26),
                  child: ColoredBox(
                    color: _maskColor,
                    child: Center(
                      child: Text(
                        'your number +91 ${widget.mobileNumber}.',
                        textAlign: TextAlign.center,
                        style: ChallanTypography.otpPhoneLine(s),
                      ),
                    ),
                  ),
                ),
                for (var i = 0; i < _otpLength; i++)
                  Positioned(
                    left: s.s(_otpCellLefts[i]),
                    top: s.s(290),
                    child: ChallanOtpDigitBox(
                      scale: s,
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      onChanged: (value) => _onOtpChanged(i, value),
                    ),
                  ),
                Positioned(
                  left: s.s(158),
                  top: s.s(358),
                  width: s.s(182),
                  height: s.s(18),
                  child: ColoredBox(
                    color: _maskColor,
                    child: GestureDetector(
                      onTap: _onResendTap,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Resend OTP',
                                style: ChallanTypography.resendActive(s),
                              ),
                              if (_secondsRemaining > 0)
                                TextSpan(
                                  text: ' available in $_secondsRemaining sec',
                                  style: ChallanTypography.resendCountdown(s),
                                ),
                            ],
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: s.s(20),
                  top: s.s(428),
                  width: s.s(324),
                  height: s.s(52),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _onVerify,
                      borderRadius: BorderRadius.circular(s.s(10)),
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

  Widget _tapZone(
    FigmaScale s, {
    required double left,
    required double top,
    required double width,
    required double height,
    required VoidCallback onTap,
  }) {
    return Positioned(
      left: s.s(left),
      top: s.s(top),
      width: s.s(width),
      height: s.s(height),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: const ColoredBox(color: Colors.transparent),
      ),
    );
  }
}
