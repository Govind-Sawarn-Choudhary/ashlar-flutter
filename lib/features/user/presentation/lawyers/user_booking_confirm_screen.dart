import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/features/user/data/models/user_booking_context.dart';
import 'package:ashlar_lawyer_hub/features/user/data/user_repository.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/lawyers/models/user_payment_result.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/lawyers/services/user_payment_service.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/lawyers/widgets/user_booking_flow_widgets.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/widgets/user_design_tokens.dart';
import 'package:ashlar_lawyer_hub/features/user/user_routes.dart';
import 'package:flutter/material.dart';

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
  bool _isProcessingPayment = false;

  Future<void> _onPayNow() async {
    if (_isProcessingPayment) {
      return;
    }

    final ratePerMinute = widget.bookingContext.amount ?? 0;
    if (ratePerMinute <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid consultation rate')),
      );
      return;
    }

    setState(() => _isProcessingPayment = true);

    try {
      UserPaymentResult paymentResult;
      final isMetered = !widget.bookingContext.isPhysical;

      if (isMetered) {
        final result = await UserRepository.instance.createBooking(
          widget.bookingContext,
          payFromWallet: false,
        );
        paymentResult = UserPaymentResult(
          isSuccess: true,
          amount: ratePerMinute,
          refNumber: result.reference.isNotEmpty ? result.reference : 'METERED',
          paymentTime: result.paymentTime,
          appointmentId: result.appointmentId,
          consultationType: widget.bookingContext.consultationType,
          lawyerName: widget.bookingContext.lawyerName,
          durationMinutes: result.durationMinutes,
          mode: widget.bookingContext.mode,
          billingPerMinute: true,
        );
      } else {
        var payFromWallet = false;
        final wallet = await UserRepository.instance.getWallet();
        if (wallet.balance >= ratePerMinute && mounted) {
          payFromWallet = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Pay with wallet?'),
                  content: Text(
                    'Use ₹${ratePerMinute.toStringAsFixed(0)} from wallet '
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
          paymentResult = await UserPaymentService.processBookingPayment(
            amount: ratePerMinute,
            lawyerId: widget.bookingContext.lawyerId,
            mode: widget.bookingContext.mode,
            consultationType: widget.bookingContext.consultationType,
            lawyerName: widget.bookingContext.lawyerName,
            scheduledAt: widget.bookingContext.scheduledAt,
            notes: widget.bookingContext.notes,
          );
        }
      }

      if (!mounted) {
        return;
      }

      if (!paymentResult.isSuccess) {
        setState(() => _isProcessingPayment = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment was not completed')),
        );
        return;
      }

      await Navigator.of(context).pushReplacementNamed(
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
    final scheduled = widget.bookingContext.scheduledAt;
    final isMetered = !widget.bookingContext.isPhysical;

    return UserBookingScaffold(
      title: 'Confirm booking',
      subtitle: isMetered ? 'Per-minute wallet billing' : 'Review before payment',
      bottomBar: UserBookingPrimaryButton(
        label: isMetered ? 'Continue · ₹${amount.toStringAsFixed(0)}/min' : 'Pay ₹${amount.toStringAsFixed(0)}',
        loading: _isProcessingPayment,
        onPressed: _onPayNow,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: UserDesignTokens.goldAccentCard(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.bookingContext.lawyerName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: UserDesignTokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${consultationTypeLabel(widget.bookingContext.consultationType)} · '
                  '${modeLabel(widget.bookingContext.mode)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: UserDesignTokens.gold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: UserDesignTokens.premiumCard(),
            child: Column(
              children: [
                UserBookingSummaryRow(
                  label: 'Lawyer',
                  value: widget.bookingContext.lawyerName,
                ),
                const Divider(color: UserDesignTokens.cardBorder),
                UserBookingSummaryRow(
                  label: 'Type',
                  value: consultationTypeLabel(
                    widget.bookingContext.consultationType,
                  ),
                ),
                const Divider(color: UserDesignTokens.cardBorder),
                UserBookingSummaryRow(
                  label: 'Mode',
                  value: modeLabel(widget.bookingContext.mode),
                ),
                if (scheduled != null) ...[
                  const Divider(color: UserDesignTokens.cardBorder),
                  UserBookingSummaryRow(
                    label: 'Scheduled',
                    value: scheduled.replaceFirst('T', ' ').substring(0, 16),
                  ),
                ],
                const Divider(color: UserDesignTokens.cardBorder),
                UserBookingSummaryRow(
                  label: isMetered ? 'Rate' : 'Total',
                  value: isMetered
                      ? '₹${amount.toStringAsFixed(0)} / min (wallet)'
                      : '₹${amount.toStringAsFixed(0)}',
                  highlight: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
