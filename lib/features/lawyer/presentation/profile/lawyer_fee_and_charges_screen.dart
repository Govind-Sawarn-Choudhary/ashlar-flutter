import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/core/widgets/auth_buttons.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_auth_repository.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_profile_helpers.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_profile_repository.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/lawyer_routes.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/auth/widgets/lawyer_login_glow_background.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/lawyer_add_consultation_fee_screen.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/lawyer_consultation_fees_store.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/models/lawyer_consultation_fee_type.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/widgets/lawyer_fee_charges_panel.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/widgets/lawyer_section_heading.dart';
import 'package:flutter/material.dart';

/// Fee & Charges — Figma [`7125:5866`](https://www.figma.com/design/3PtNxJn9gYGj6S0yAHBce3/ashlarlawyerhub-To-Share--Copy-?node-id=7125-5866) (360×800).
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

  @override
  void initState() {
    super.initState();
    _fees = {
      for (final type in LawyerConsultationFeeType.all) type.id: null,
    };
    _loadFees();
  }

  Future<void> _loadFees() async {
    try {
      final response = await LawyerProfileRepository.instance.getMe();
      final mapped = LawyerProfileHelpers.mapFees(response.fees);
      _serverFees = Map<String, LawyerConsultationFeeResult?>.from(mapped);
      if (widget.mode == LawyerFeeAndChargesMode.update ||
          response.fees.isNotEmpty) {
        _fees = Map<String, LawyerConsultationFeeResult?>.from(mapped);
        LawyerConsultationFeesStore.instance.saveAll(_fees);
      }
    } catch (_) {
      if (widget.mode == LawyerFeeAndChargesMode.update) {
        _fees = LawyerConsultationFeesStore.instance.copyFees();
        _serverFees = Map<String, LawyerConsultationFeeResult?>.from(_fees);
      }
      if (mounted && widget.mode == LawyerFeeAndChargesMode.update) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load saved charges')),
        );
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
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final feeLabels = {
      for (final entry in _mergedFees().entries)
        entry.key: entry.value?.amount,
    };
    final isUpdate = widget.mode == LawyerFeeAndChargesMode.update;

    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: false,
      dismissKeyboardOnTap: true,
      background: const LawyerLoginGlowBackground(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : FigmaScreenCanvas(
              builder: (context, s) {
                return Column(
                  children: [
                    if (isUpdate)
                      Padding(
                        padding: EdgeInsets.fromLTRB(s.s(8), s.s(35), s.s(8), 0),
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
                              child: LawyerSectionHeading(
                                title: 'Fee & Charges',
                                scale: s,
                                titleWidth: 110,
                                titleX: 120,
                                titleY: 112,
                              ),
                            ),
                            SizedBox(width: s.s(47)),
                          ],
                        ),
                      )
                    else ...[
                      SizedBox(height: s.s(112)),
                      LawyerSectionHeading(
                        title: 'Fee & Charges',
                        scale: s,
                        titleWidth: 110,
                        titleX: 120,
                        titleY: 112,
                      ),
                    ],
                    if (isUpdate)
                      Padding(
                        padding: EdgeInsets.fromLTRB(s.s(16), s.s(12), s.s(16), 0),
                        child: Text(
                          'Tap any consultation type to edit. Changes save automatically.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: s.fs(11),
                            height: 1.35,
                          ),
                        ),
                      ),
                    SizedBox(height: s.s(isUpdate ? 16 : 95)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: s.s(16)),
                      child: LawyerFeeChargesPanel(
                        scale: s,
                        fees: feeLabels,
                        onAddFee: _onAddFee,
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: EdgeInsets.fromLTRB(s.s(16), 0, s.s(16), s.s(24)),
                      child: SizedBox(
                        width: double.infinity,
                        height: s.s(52),
                        child: ProfileContinueButton(
                          label: _isSaving
                              ? 'Saving…'
                              : isUpdate
                                  ? 'Save Changes'
                                  : 'Continue',
                          onTap: _onContinue,
                          scaleX: s.scale,
                          scaleY: s.scale,
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
