import 'package:ashlar_lawyer_hub/core/config/dev_auth.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_auth_layout.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Lawyer login — Figma frame `7125:5478` (360×800).
class LawyerLoginScreen extends StatefulWidget {
  const LawyerLoginScreen({super.key});

  @override
  State<LawyerLoginScreen> createState() => _LawyerLoginScreenState();
}

class _LawyerLoginScreenState extends State<LawyerLoginScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    if (DevAuth.enabled) {
      _phoneController.text = DevAuth.phone;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_formKey.currentState?.validate() != true) {
      final phone = _phoneController.text.trim();
      if (phone.length != 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phone number must be exactly 10 digits'),
          ),
        );
      }
      return;
    }

    if (_isSending) {
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
        const SnackBar(content: Text('Could not send OTP. Check backend connection.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: false,
      background: const LawyerLoginGlowBackground(),
      body: Form(
        key: _formKey,
        child: FigmaScreenCanvas(
          builder: (context, s) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                FigmaLoginHeroIllustration(scale: s),

                Positioned(
                  left: s.s(19),
                  top: s.s(391),
                  child: AuthPageIndicator(
                    activeIndex: 0,
                    scaleX: s.scale,
                  ),
                ),

                Positioned(
                  left: s.s(19),
                  top: s.s(424),
                  child: Text(
                    'Hi Welcome!',
                    style: AppTypography.openSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: s.fs(24),
                      height: 25 / 24,
                    ),
                  ),
                ),

                Positioned(
                  left: s.s(19),
                  top: s.s(456),
                  child: Text(
                    'Submit your Phone Number',
                    style: AppTypography.openSans(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                      fontSize: s.fs(16),
                      height: 25 / 16,
                    ),
                  ),
                ),

                FigmaLoginSignupDivider(scale: s),

                Positioned(
                  left: s.s(19),
                  top: s.s(554),
                  width: s.s(320),
                  height: s.s(52),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(s.s(10)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x40000000),
                          blurRadius: 4,
                          offset: Offset.zero,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(s.s(10)),
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        style: AppTypography.openSans(
                          color: Colors.black,
                          fontSize: s.fs(16),
                          height: 19 / 16,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Phone Number',
                          hintStyle: AppTypography.openSans(
                            color: AppColors.textMuted,
                            fontSize: s.fs(16),
                            height: 19 / 16,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          isDense: true,
                          contentPadding: EdgeInsets.fromLTRB(
                            s.s(22),
                            s.s(17),
                            s.s(22),
                            s.s(16),
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                        ),
                        validator: (value) {
                          final phone = value?.trim() ?? '';
                          if (phone.isEmpty) {
                            return 'Enter your phone number';
                          }
                          if (phone.length != 10) {
                            return 'Phone number must be exactly 10 digits';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),

                Positioned(
                  left: s.s(19),
                  top: s.s(621),
                  width: s.s(324),
                  height: s.s(52),
                  child: GoldActionButton(
                    label: _isSending ? 'Sending…' : 'Send OTP',
                    onTap: _sendOtp,
                    scaleX: s.scale,
                    scaleY: s.scale,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
