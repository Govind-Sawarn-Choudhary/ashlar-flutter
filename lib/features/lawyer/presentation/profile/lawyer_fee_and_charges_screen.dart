import 'package:ashlar_lawyer_hub/core/auth/auth_session.dart';
import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/core/widgets/auth_buttons.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_auth_repository.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_profile_helpers.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_profile_repository.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/lawyer_routes.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/auth/widgets/lawyer_login_glow_background.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/lawyer_add_consultation_fee_screen.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/lawyer_consultation_fees_store.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/lawyer_onboarding_skip.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/models/lawyer_consultation_fee_type.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/widgets/lawyer_fee_charges_panel.dart';
import 'package:flutter/material.dart';

/// Fee & Charges — onboarding final step or profile update.
enum LawyerFeeAndChargesMode { registration, update }

class LawyerFeeAndChargesScreen extends StatefulWidget {
  const LawyerFeeAndChargesScreen({
    super.key,
    this.mode = LawyerFeeAndChargesMode.registration,
  });

  final LawyerFeeAndChargesMode mode;

  @override
  State<LawyerFeeAndChargesScreen> createState() =>
      _LawyerFeeAndChargesScreenState();
}

class _LawyerFeeAndChargesScreenState extends State<LawyerFeeAndChargesScreen> {
  late Map<String, LawyerConsultationFeeResult?> _fees;
  Map<String, LawyerConsultationFeeResult?> _serverFees = {};
  bool _isSaving = false;
  bool _loading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _fees = {
      for (final type in LawyerConsultationFeeType.all) type.id: null,
    };
    _loadFees();
  }

  Future<void> _loadFees() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });

    try {
      final response = await LawyerProfileRepository.instance.getMe();
      final mapped = LawyerProfileHelpers.mapFees(response.fees);
      _serverFees = Map<String, LawyerConsultationFeeResult?>.from(mapped);
      if (widget.mode == LawyerFeeAndChargesMode.update ||
          response.fees.isNotEmpty) {
        _fees = Map<String, LawyerConsultationFeeResult?>.from(mapped);
        LawyerConsultationFeesStore.instance.saveAll(_fees);
      }
    } on ApiException catch (e) {
      _loadError = e.message;
      if (widget.mode == LawyerFeeAndChargesMode.update) {
        _fees = LawyerConsultationFeesStore.instance.copyFees();
        _serverFees = Map<String, LawyerConsultationFeeResult?>.from(_fees);
      }
    } catch (_) {
      _loadError = 'Could not load your fees';
      if (widget.mode == LawyerFeeAndChargesMode.update) {
        _fees = LawyerConsultationFeesStore.instance.copyFees();
        _serverFees = Map<String, LawyerConsultationFeeResult?>.from(_fees);
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Map<String, LawyerConsultationFeeResult?> _mergedFees() {
    return {
      for (final type in LawyerConsultationFeeType.all)
        type.id: _fees[type.id] ?? _serverFees[type.id],
    };
  }

  String? _missingFeeLabel(Map<String, LawyerConsultationFeeResult?> fees) {
    for (final type in LawyerConsultationFeeType.all) {
      final fee = fees[type.id];
      if (fee == null || fee.amount.trim().isEmpty) {
        return type.title;
      }
    }
    return null;
  }

  Future<bool> _persistFees({bool showFeedback = false}) async {
    final merged = _mergedFees();
    final missing = _missingFeeLabel(merged);
    if (missing != null) {
      if (showFeedback && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please set a fee for $missing')),
        );
      }
      return false;
    }

    if (_isSaving) {
      return false;
    }

    setState(() => _isSaving = true);

    try {
      await LawyerProfileRepository.instance.saveFees(merged);
      _serverFees = Map<String, LawyerConsultationFeeResult?>.from(merged);
      _fees = Map<String, LawyerConsultationFeeResult?>.from(merged);
      LawyerConsultationFeesStore.instance.saveAll(_fees);

      if (showFeedback && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Charges updated successfully'),
          ),
        );
      }
      return true;
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
      return false;
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _onAddFee(String id) async {
    final type = LawyerConsultationFeeType.fromId(id);
    if (type == null) {
      return;
    }

    final existing = _fees[id] ?? _serverFees[id];
    final result = await Navigator.of(context).pushNamed<LawyerConsultationFeeResult>(
      LawyerRoutes.addConsultationFee,
      arguments: LawyerAddConsultationFeeArgs(
        consultationType: type,
        initialAmount: existing?.amount,
        initialDuration: existing?.duration,
        initialLocation: existing?.location,
      ),
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() => _fees[id] = result);

    if (widget.mode == LawyerFeeAndChargesMode.update) {
      await _persistFees(showFeedback: true);
    }
  }

  Future<void> _onContinue() async {
    final merged = _mergedFees();
    final missing = _missingFeeLabel(merged);
    if (missing != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add fee for $missing')),
      );
      return;
    }

    if (widget.mode == LawyerFeeAndChargesMode.update) {
      final saved = await _persistFees(showFeedback: true);
      if (saved && mounted) {
        Navigator.of(context).pop(true);
      }
      return;
    }

    if (_isSaving) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      LawyerConsultationFeesStore.instance.saveAll(merged);
      final response = await LawyerProfileRepository.instance.saveFees(merged);
      _serverFees = Map<String, LawyerConsultationFeeResult?>.from(merged);
      _fees = Map<String, LawyerConsultationFeeResult?>.from(merged);

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
        const SnackBar(content: Text('Could not save fees. Try again.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _signOut() async {
    await AuthSession.instance.clear();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/role-select',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUpdate = widget.mode == LawyerFeeAndChargesMode.update;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final isBusy = _isSaving;

    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: false,
      dismissKeyboardOnTap: true,
      resizeToAvoidBottomInset: true,
      background: const LawyerLoginGlowBackground(),
      body: _loading
          ? const SafeArea(child: Center(child: CircularProgressIndicator()))
          : FigmaScreenCanvas(
              builder: (context, s) {
                if (_loadError != null && !isUpdate) {
                  return SafeArea(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(s.s(24)),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _loadError!,
                              textAlign: TextAlign.center,
                              style: AppTypography.inter(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: s.s(16)),
                            TextButton(
                              onPressed: _loadFees,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isUpdate)
                        Padding(
                          padding: EdgeInsets.fromLTRB(s.s(8), s.s(4), s.s(8), 0),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                behavior: HitTestBehavior.opaque,
                                child: Padding(
                                  padding: EdgeInsets.only(left: s.s(7)),
                                  child: Image.asset(
                                    AppAssets.walletBackButton,
                                    width: s.s(40),
                                    height: s.s(40),
                                    fit: BoxFit.contain,
                                    filterQuality: FilterQuality.high,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Fee & Charges',
                                  textAlign: TextAlign.center,
                                  style: AppTypography.inter(
                                    color: AppColors.gold,
                                    fontWeight: FontWeight.w700,
                                    fontSize: s.fs(18),
                                  ),
                                ),
                              ),
                              SizedBox(width: s.s(47)),
                            ],
                          ),
                        ),
                      if (!isUpdate)
                        Padding(
                          padding: EdgeInsets.fromLTRB(s.s(20), s.s(12), s.s(20), 0),
                          child: Container(
                            padding: EdgeInsets.all(s.s(14)),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.gold.withValues(alpha: 0.16),
                                  Colors.white.withValues(alpha: 0.04),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(s.s(14)),
                              border: Border.all(
                                color: AppColors.gold.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: s.s(44),
                                  height: s.s(44),
                                  decoration: BoxDecoration(
                                    color: AppColors.gold.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(s.s(12)),
                                  ),
                                  child: Icon(
                                    Icons.account_balance_wallet_outlined,
                                    color: AppColors.gold,
                                    size: s.s(22),
                                  ),
                                ),
                                SizedBox(width: s.s(12)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Fee & Charges',
                                        style: AppTypography.inter(
                                          color: AppColors.gold,
                                          fontWeight: FontWeight.w800,
                                          fontSize: s.fs(18),
                                        ),
                                      ),
                                      SizedBox(height: s.s(2)),
                                      Text(
                                        'Final step · Complete your lawyer profile',
                                        style: AppTypography.inter(
                                          color: Colors.white70,
                                          fontSize: s.fs(11),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (!isUpdate) SizedBox(height: s.s(12)),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          s.s(20),
                          s.s(isUpdate ? 12 : 0),
                          s.s(20),
                          0,
                        ),
                        child: Text(
                          isUpdate
                              ? 'Tap any consultation type to edit. Changes save automatically.'
                              : 'Set competitive rates for each consultation mode. All four are required before you go live.',
                          style: AppTypography.inter(
                            color: Colors.white70,
                            fontSize: s.fs(13),
                            height: 1.4,
                          ),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: EdgeInsets.fromLTRB(
                            s.s(16),
                            s.s(16),
                            s.s(16),
                            s.s(8),
                          ),
                          child: LawyerFeeChargesPanel(
                            fees: _mergedFees(),
                            onAddFee: _onAddFee,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          s.s(18),
                          s.s(8),
                          s.s(18),
                          s.s(12) + (keyboardInset > 0 ? keyboardInset : 0),
                        ),
                        child: Opacity(
                          opacity: isBusy ? 0.55 : 1,
                          child: IgnorePointer(
                            ignoring: isBusy,
                            child: SizedBox(
                              width: double.infinity,
                              height: s.s(52),
                              child: GoldActionButton(
                                label: _isSaving
                                    ? 'Saving…'
                                    : isUpdate
                                        ? 'Save Changes'
                                        : 'Save & Finish',
                                onTap: _onContinue,
                                scaleX: s.scale,
                                scaleY: s.scale,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (!isUpdate)
                        Center(
                          child: TextButton(
                            onPressed: isBusy
                                ? null
                                : () => skipLawyerOnboardingToDashboard(context),
                            child: Text(
                              'Skip to dashboard',
                              style: AppTypography.inter(
                                color: AppColors.gold,
                                fontWeight: FontWeight.w600,
                                fontSize: s.fs(13),
                              ),
                            ),
                          ),
                        ),
                      if (!isUpdate)
                        Center(
                          child: TextButton(
                            onPressed: isBusy ? null : _signOut,
                            child: Text(
                              'Sign out',
                              style: AppTypography.inter(
                                color: Colors.white54,
                                fontSize: s.fs(13),
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: s.s(4)),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
