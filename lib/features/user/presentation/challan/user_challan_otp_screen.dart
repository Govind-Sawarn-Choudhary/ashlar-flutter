import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/features/user/data/user_repository.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/auth/widgets/user_auth_widgets.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/challan/user_challan_verify_otp_screen.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/widgets/user_design_tokens.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/widgets/user_premium_widgets.dart';
import 'package:flutter/material.dart';

class UserChallanOtpScreen extends StatefulWidget {
  const UserChallanOtpScreen({
    super.key,
    required this.vehicleNumber,
  });

  final String vehicleNumber;

  @override
  State<UserChallanOtpScreen> createState() => _UserChallanOtpScreenState();
}

class _UserChallanOtpScreenState extends State<UserChallanOtpScreen> {
  final _mobileController = TextEditingController();
  final _mobileFocus = FocusNode();
  bool _submitting = false;

  @override
  void dispose() {
    _mobileController.dispose();
    _mobileFocus.dispose();
    super.dispose();
  }

  Future<void> _onConfirm() async {
    FocusScope.of(context).unfocus();
    final mobile = _mobileController.text.trim();
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(mobile)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid 10-digit mobile number')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await UserRepository.instance.sendChallanOtp(
        vehicleNumber: widget.vehicleNumber,
        mobile: mobile,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP sent to +91 $mobile (demo OTP: 1234)')),
      );
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => UserChallanVerifyOtpScreen(
            vehicleNumber: widget.vehicleNumber,
            mobileNumber: mobile,
          ),
        ),
      );
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = FigmaScale.fromViewport(MediaQuery.sizeOf(context));

    return UserPremiumScaffold(
      appBar: UserPremiumAppBar(
        title: 'Verify vehicle',
        subtitle: widget.vehicleNumber,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: UserDesignTokens.textPrimary, size: 20),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: UserDesignTokens.goldAccentCard(),
            child: Text(
              'Enter the mobile number registered with this vehicle to receive an OTP.',
              style: AppTypography.inter(
                fontSize: 14,
                height: 1.45,
                color: UserDesignTokens.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          UserAuthPhoneField(
            scale: scale,
            controller: _mobileController,
            focusNode: _mobileFocus,
            validator: validateIndianMobile,
            onSubmitted: _onConfirm,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _submitting ? null : _onConfirm,
              style: FilledButton.styleFrom(
                backgroundColor: UserDesignTokens.gold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : Text(
                      'Send OTP',
                      style: AppTypography.inter(fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
