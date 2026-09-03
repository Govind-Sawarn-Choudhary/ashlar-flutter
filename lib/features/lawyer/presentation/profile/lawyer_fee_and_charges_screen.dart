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
      if (widget.mode == LawyerFeeAndChargesMode.update ||
          response.fees.isNotEmpty) {
        _fees = mapped;
        LawyerConsultationFeesStore.instance.saveAll(_fees);
      }
    } catch (_) {
      if (widget.mode == LawyerFeeAndChargesMode.update) {
        _fees = LawyerConsultationFeesStore.instance.copyFees();
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _onAddFee(String id) async {
    final type = LawyerConsultationFeeType.fromId(id);
    if (type == null) {
      return;
    }

    final existing = _fees[id];
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
  }

  void _onContinue() async {
    final hasMissingFees = _fees.values.any((fee) => fee == null);
    if (hasMissingFees) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add fees for all consultation types'),
        ),
      );
      return;
    }

    if (_isSaving) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      LawyerConsultationFeesStore.instance.saveAll(_fees);

      if (widget.mode == LawyerFeeAndChargesMode.update) {
        await LawyerProfileRepository.instance.saveFees(_fees);
        if (!mounted) {
          return;
        }
        Navigator.of(context).pop(true);
        return;
      }

      final response = await LawyerProfileRepository.instance.saveFees(_fees);

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
      for (final entry in _fees.entries)
        entry.key: entry.value?.amount,
    };

    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: false,
      background: const LawyerLoginGlowBackground(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : FigmaScreenCanvas(
        builder: (context, s) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              if (widget.mode == LawyerFeeAndChargesMode.update)
                Positioned(
                  left: s.s(8),
                  top: s.s(35),
                  width: s.s(56),
                  height: s.s(56),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    behavior: HitTestBehavior.opaque,
                    child: Align(
                      alignment: Alignment.centerLeft,
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
                  ),
                ),
              Positioned(
                left: 0,
                top: s.s(112),
                child: LawyerSectionHeading(
                  title: 'Fee & Charges',
                  scale: s,
                  titleWidth: 110,
                  titleX: 120,
                  titleY: 112,
                ),
              ),
              Positioned(
                left: s.s(16),
                top: s.s(207),
                width: s.s(325),
                child: LawyerFeeChargesPanel(
                  scale: s,
                  fees: feeLabels,
                  onAddFee: _onAddFee,
                ),
              ),
              Positioned(
                left: s.s(16),
                top: s.s(460),
                width: s.s(324),
                height: s.s(52),
                child: ProfileContinueButton(
                  label: _isSaving ? 'Saving…' : 'Continue',
                  onTap: _onContinue,
                  scaleX: s.scale,
                  scaleY: s.scale,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
