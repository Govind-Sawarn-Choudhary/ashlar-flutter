import 'package:ashlar_lawyer_hub/core/auth/auth_session.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/core/widgets/auth_buttons.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_auth_repository.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_profile_repository.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/auth/widgets/lawyer_login_glow_background.dart';
import 'package:flutter/material.dart';

/// Shown after onboarding while admin reviews the lawyer profile.
class LawyerVerificationStatusScreen extends StatefulWidget {
  const LawyerVerificationStatusScreen({super.key});

  @override
  State<LawyerVerificationStatusScreen> createState() =>
      _LawyerVerificationStatusScreenState();
}

class _LawyerVerificationStatusScreenState
    extends State<LawyerVerificationStatusScreen> {
  bool _loading = true;
  bool _refreshing = false;
  String _status = 'pending';
  String? _rejectionReason;
  String? _fullName;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus({bool refresh = false}) async {
    if (refresh) {
      setState(() => _refreshing = true);
    } else {
      setState(() => _loading = true);
    }

    try {
      final response = await LawyerProfileRepository.instance.getMe();
      await AuthSession.instance.saveNextRoute(response.nextRoute);

      if (!mounted) {
        return;
      }

      if (response.lawyer.isApproved) {
        Navigator.of(context).pushReplacementNamed(
          LawyerAuthRepository.instance.routeForNextStep(response.nextRoute),
        );
        return;
      }

      setState(() {
        _status = response.lawyer.verificationStatus;
        _rejectionReason = response.lawyer.rejectionReason;
        _fullName = response.lawyer.fullName ?? response.lawyer.barVerifiedName;
        _loading = false;
        _refreshing = false;
      });
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _refreshing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  Future<void> _signOut() async {
    await AuthSession.instance.clear();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushNamedAndRemoveUntil('/role-select', (route) => false);
  }

  bool get _isRejected => _status == 'rejected';

  @override
  Widget build(BuildContext context) {
    return AppDarkScaffold(
      showGlow: false,
      background: const LawyerLoginGlowBackground(),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    if (_fullName?.isNotEmpty == true)
                      Text(
                        _fullName!,
                        style: AppTypography.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: (_isRejected ? Colors.red : AppColors.gold)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: (_isRejected ? Colors.red : AppColors.gold)
                              .withValues(alpha: 0.35),
                        ),
                      ),
                      child: Text(
                        _isRejected ? 'Application rejected' : 'Pending admin approval',
                        style: AppTypography.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _isRejected ? Colors.redAccent : AppColors.gold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _isRejected
                          ? 'Your profile was not approved. Update your documents or contact support, then sign in again after admin re-review.'
                          : 'Your onboarding is complete. An admin will review your Bar Council documents and profile. You will get full dashboard access once approved.',
                      style: AppTypography.inter(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.white70,
                      ),
                    ),
                    if (_rejectionReason?.isNotEmpty == true) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Reason',
                        style: AppTypography.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white54,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _rejectionReason!,
                        style: AppTypography.inter(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                    const Spacer(),
                    ProfileContinueButton(
                      label: _refreshing ? 'Checking…' : 'Check approval status',
                      onTap: _refreshing
                          ? () {}
                          : () => _loadStatus(refresh: true),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _signOut,
                      child: const Text('Sign out'),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }
}
