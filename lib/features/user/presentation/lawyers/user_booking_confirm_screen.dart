import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_tall_artboard_body.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/features/user/data/models/user_booking_context.dart';
import 'package:ashlar_lawyer_hub/features/user/data/user_repository.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/lawyers/models/user_payment_result.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/lawyers/services/user_payment_service.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/lawyers/widgets/user_drag_to_confirm_button.dart';
import 'package:ashlar_lawyer_hub/features/user/user_routes.dart';
import 'package:flutter/material.dart';

/// Booking confirmation — Figma [`7125:3276`](https://www.figma.com/design/3PtNxJn9gYGj6S0yAHBce3/ashlarlawyerhub-To-Share--Copy-?node-id=7125-3276) (360×858).
class UserBookingConfirmScreen extends StatefulWidget {
  const UserBookingConfirmScreen({
    super.key,
    required this.bookingContext,
  });

  final UserBookingContext bookingContext;

  @override
  State<UserBookingConfirmScreen> createState() =>
      _UserBookingConfirmScreenState();
}

class _UserBookingConfirmScreenState extends State<UserBookingConfirmScreen> {
  static const _designHeight = 858.0;
  static const _detailPanelLeft = 8.0;
  static const _detailPanelTop = 315.0;

  bool _isProcessingPayment = false;

  Future<void> _onPayNow() async {
    if (_isProcessingPayment) {
      return;
    }

    setState(() => _isProcessingPayment = true);

    try {
      final amount = widget.bookingContext.amount ?? 0;
      var payFromWallet = false;

      if (amount > 0) {
        final wallet = await UserRepository.instance.getWallet();
        if (wallet.balance >= amount && mounted) {
          payFromWallet = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Pay with wallet?'),
                  content: Text(
                    'Use ₹${amount.toStringAsFixed(0)} from wallet '
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
      }

      UserPaymentResult paymentResult;

      if (payFromWallet) {
        final result = await UserRepository.instance.createBooking(
          widget.bookingContext,
          payFromWallet: true,
        );
        paymentResult = UserPaymentResult(
          isSuccess: true,
          amount: result.amount,
          refNumber: result.reference,
          paymentTime: result.paymentTime,
          appointmentId: result.appointmentId,
          consultationType: widget.bookingContext.consultationType,
          lawyerName: widget.bookingContext.lawyerName,
          durationMinutes: result.durationMinutes,
          mode: widget.bookingContext.mode,
        );
      } else {
        final checkout = await UserPaymentService.processBookingPayment(
          amount: amount,
          lawyerId: widget.bookingContext.lawyerId,
          mode: widget.bookingContext.mode,
          consultationType: widget.bookingContext.consultationType,
          lawyerName: widget.bookingContext.lawyerName,
        );
        paymentResult = checkout;
      }

      if (!mounted) {
        return;
      }

      setState(() => _isProcessingPayment = false);

      await Navigator.of(context).pushNamed(
        UserRoutes.paymentSuccess,
        arguments: paymentResult,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _isProcessingPayment = false);
      final message = e is ApiException ? e.message : e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final amount = widget.bookingContext.amount ?? 0;

    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: false,
      background: const ColoredBox(color: Colors.black),
      body: Stack(
        children: [
          FigmaTallArtboardBody(
            designHeight: _designHeight,
            builder: (context, scale) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    width: scale.viewportWidth,
                    height: scale.artboardHeight,
                    child: Image.asset(
                      AppAssets.userBookingConfirmFull,
                      width: scale.viewportWidth,
                      height: scale.artboardHeight,
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.high,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                  Positioned(
                    left: scale.s(15),
                    top: scale.s(43),
                    width: scale.s(40),
                    height: scale.s(40),
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      behavior: HitTestBehavior.opaque,
                      child: Image.asset(
                        AppAssets.walletBackButton,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Positioned(
                    left: scale.s(24),
                    top: scale.s(360),
                    right: scale.s(24),
                    child: Text(
                      'Pay ₹${amount.toStringAsFixed(0)} to book\n'
                      '${widget.bookingContext.lawyerName}',
                      style: AppTypography.inter(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: scale.fs(13),
                        height: 1.35,
                      ),
                    ),
                  ),
                  Positioned(
                    left: scale.s(_detailPanelLeft + 12),
                    top: scale.s(_detailPanelTop + 440),
                    width: scale.s(324),
                    height: scale.s(60),
                    child: IgnorePointer(
                      ignoring: _isProcessingPayment,
                      child: UserDragToConfirmButton(
                        onComplete: _onPayNow,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          if (_isProcessingPayment)
            const ColoredBox(
              color: Color(0x66000000),
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
