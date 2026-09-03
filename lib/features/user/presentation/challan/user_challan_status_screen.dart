import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/features/user/data/models/user_marketplace_models.dart';
import 'package:ashlar_lawyer_hub/features/user/data/user_repository.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/challan/user_challan_payment_success_screen.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/lawyers/services/user_payment_service.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/challan/widgets/challan_filter_bar.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/lawyers/models/user_payment_result.dart';
import 'package:flutter/material.dart';

/// Challan Status — Figma [`7125:2216`](https://www.figma.com/design/3PtNxJn9gYGj6S0yAHBce3/ashlarlawyerhub-To-Share--Copy-?node-id=7125-2216) (pending),
/// [`7125:2262`](https://www.figma.com/design/3PtNxJn9gYGj6S0yAHBce3/ashlarlawyerhub-To-Share--Copy-?node-id=7125-2262) (settled).
class UserChallanStatusScreen extends StatefulWidget {
  const UserChallanStatusScreen({
    super.key,
    required this.vehicleNumber,
    required this.mobileNumber,
  });

  final String vehicleNumber;
  final String mobileNumber;

  @override
  State<UserChallanStatusScreen> createState() => _UserChallanStatusScreenState();
}

class _UserChallanStatusScreenState extends State<UserChallanStatusScreen> {
  static const _designWidth = 360.0;
  static const _designHeight = 800.0;

  UserChallanFilter _filter = UserChallanFilter.pending;
  List<UserChallanItem> _challans = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadChallans();
  }

  Future<void> _loadChallans() async {
    try {
      final challans = await UserRepository.instance.listChallans(
        vehicleNumber: widget.vehicleNumber,
      );
      if (mounted) {
        setState(() {
          _challans = challans;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String get _statusKey => switch (_filter) {
        UserChallanFilter.pending => 'pending',
        UserChallanFilter.inProgress => 'in_progress',
        UserChallanFilter.settled => 'settled',
      };

  List<UserChallanItem> get _filteredChallans =>
      _challans.where((c) => c.status == _statusKey).toList();

  Future<void> _onPayNow() async {
    final pending = _challans.where((c) => c.status == 'pending').toList();
    if (pending.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pending challan to pay')),
      );
      return;
    }

    final challan = pending.first;
    try {
      var payFromWallet = false;
      final wallet = await UserRepository.instance.getWallet();
      if (wallet.balance >= challan.amount && mounted) {
        payFromWallet = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Pay with wallet?'),
                content: Text(
                  'Use ₹${challan.amount.toStringAsFixed(0)} from wallet '
                  '(balance ₹${wallet.balance.toStringAsFixed(0)})?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Pay directly'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Use wallet'),
                  ),
                ],
              ),
            ) ??
            false;
      }

      UserPaymentResult payment;

      if (payFromWallet) {
        final result = await UserRepository.instance.payChallan(
          challan.id,
          challan.amount,
          payFromWallet: true,
        );
        payment = UserPaymentResult(
          isSuccess: true,
          amount: result.amount,
          refNumber: result.reference,
          paymentTime: result.paymentTime,
        );
      } else {
        payment = await UserPaymentService.processChallanPayment(
          challanId: challan.id,
          amount: challan.amount,
          title: challan.title,
        );
      }

      if (!mounted) {
        return;
      }
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => UserChallanPaymentSuccessScreen(payment: payment),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundAsset = switch (_filter) {
      UserChallanFilter.settled => AppAssets.userChallanStatusSettledFull,
      UserChallanFilter.pending || UserChallanFilter.inProgress =>
        AppAssets.userChallanStatusPendingFull,
    };

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
                    backgroundAsset,
                    width: s.viewportWidth,
                    height: s.s(_designHeight),
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high,
                    alignment: Alignment.topCenter,
                  ),
                ),
                _tapZone(
                  s,
                  left: 22,
                  top: 60,
                  width: 40,
                  height: 40,
                  onTap: () => Navigator.of(context).pop(),
                ),
                if (_filter == UserChallanFilter.pending) ..._pendingOverlays(s),
                if (_filter == UserChallanFilter.settled) ..._settledOverlays(s),
                if (_filter == UserChallanFilter.inProgress) ..._inProgressOverlays(s),
                if (!_loading && _filteredChallans.isNotEmpty)
                  Positioned(
                    left: s.s(24),
                    top: s.s(220),
                    right: s.s(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final challan in _filteredChallans.take(3))
                          Padding(
                            padding: EdgeInsets.only(bottom: s.s(8)),
                            child: Text(
                              '${challan.title} · ₹${challan.amount.toStringAsFixed(0)}',
                              style: AppTypography.inter(
                                color: Colors.white,
                                fontSize: s.fs(12),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _pendingOverlays(FigmaScale s) => [
        _tapZone(
          s,
          left: 24,
          top: 145,
          width: 90,
          height: 32,
          onTap: () => setState(() => _filter = UserChallanFilter.pending),
        ),
        _tapZone(
          s,
          left: 130,
          top: 145,
          width: 90,
          height: 32,
          onTap: () => setState(() => _filter = UserChallanFilter.inProgress),
        ),
        _tapZone(
          s,
          left: 236,
          top: 145,
          width: 78,
          height: 32,
          onTap: () => setState(() => _filter = UserChallanFilter.settled),
        ),
        _tapZone(
          s,
          left: 256,
          top: 352,
          width: 78,
          height: 25,
          onTap: _onPayNow,
        ),
      ];

  List<Widget> _settledOverlays(FigmaScale s) => [
        _tapZone(
          s,
          left: 21,
          top: 145,
          width: 78,
          height: 32,
          onTap: () => setState(() => _filter = UserChallanFilter.settled),
        ),
        _tapZone(
          s,
          left: 109,
          top: 145,
          width: 90,
          height: 32,
          onTap: () => setState(() => _filter = UserChallanFilter.pending),
        ),
        _tapZone(
          s,
          left: 209,
          top: 145,
          width: 90,
          height: 32,
          onTap: () => setState(() => _filter = UserChallanFilter.inProgress),
        ),
      ];

  List<Widget> _inProgressOverlays(FigmaScale s) => [
        Positioned(
          left: s.s(24),
          top: s.s(145),
          child: ChallanFilterBar(
            scale: s,
            selected: _filter,
            onChanged: (value) => setState(() => _filter = value),
          ),
        ),
        Positioned(
          left: s.s(24),
          top: s.s(219),
          width: s.s(320),
          height: s.s(170),
          child: const ColoredBox(color: Colors.black),
        ),
        Positioned(
          left: s.s(24),
          top: s.s(280),
          width: s.s(320),
          child: Text(
            'No challans in progress',
            textAlign: TextAlign.center,
            style: AppTypography.inter(
              color: Colors.white70,
              fontSize: s.fs(14),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ];

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
