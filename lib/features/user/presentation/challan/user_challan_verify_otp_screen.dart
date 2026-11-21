import 'dart:async';

import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/auth/widgets/otp_digit_box.dart';
import 'package:ashlar_lawyer_hub/features/user/data/user_repository.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/challan/user_challan_status_screen.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/widgets/user_design_tokens.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/widgets/user_premium_widgets.dart';
import 'package:flutter/material.dart';

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
  static const _otpLength = 4;

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  Timer? _resendTimer;
  int _secondsRemaining = 55;
  bool _verifying = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(_otpLength, (_) => FocusNode());
    _startResendTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNodes.first.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _focusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

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

  void _onOtpChanged(int index, String value) {
    setState(() => _error = null);
    if (value.length > 1) {
      _controllers[index].text = value[value.length - 1];
    }
    if (value.isNotEmpty && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isNotEmpty && index == _otpLength - 1 && _otp.length == _otpLength) {
      _verify();
    }
  }

  Future<void> _verify() async {
    if (_otp.length != _otpLength || _verifying) {
      setState(() => _error = 'Enter the 4-digit OTP');
      return;
    }

    setState(() {
      _verifying = true;
      _error = null;
    });

    try {
      await UserRepository.instance.verifyChallanOtp(
        vehicleNumber: widget.vehicleNumber,
        mobile: widget.mobileNumber,
        otp: _otp,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => UserChallanStatusScreen(
            vehicleNumber: widget.vehicleNumber,
            mobileNumber: widget.mobileNumber,
          ),
        ),
      );
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _error = e.message);
      }
    } finally {
      if (mounted) {
        setState(() => _verifying = false);
      }
    }
  }

  Future<void> _resend() async {
    if (_secondsRemaining > 0) {
      return;
    }
    try {
      await UserRepository.instance.sendChallanOtp(
        vehicleNumber: widget.vehicleNumber,
        mobile: widget.mobileNumber,
      );
      if (mounted) {
        _startResendTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP resent')),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return UserPremiumScaffold(
      appBar: UserPremiumAppBar(
        title: 'Enter OTP',
        subtitle: '+91 ${widget.mobileNumber}',
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: UserDesignTokens.textPrimary, size: 20),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text(
            'Enter the 4-digit OTP sent to your registered mobile number.',
            style: AppTypography.inter(
              fontSize: 14,
              height: 1.45,
              color: UserDesignTokens.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < _otpLength; i++)
                OtpDigitBox(
                  size: 64,
                  borderRadius: 14,
                  fontSize: 24,
                  controller: _controllers[i],
                  focusNode: _focusNodes[i],
                  onChanged: (v) => _onOtpChanged(i, v),
                  showFocusRing: true,
                ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: AppTypography.inter(
                color: UserDesignTokens.error,
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _secondsRemaining > 0 ? null : _resend,
              child: Text(
                _secondsRemaining > 0
                    ? 'Resend in ${_secondsRemaining}s'
                    : 'Resend OTP',
                style: AppTypography.inter(
                  color: UserDesignTokens.gold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _verifying ? null : _verify,
              style: FilledButton.styleFrom(
                backgroundColor: UserDesignTokens.gold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _verifying
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : Text(
                      'Verify OTP',
                      style: AppTypography.inter(fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
