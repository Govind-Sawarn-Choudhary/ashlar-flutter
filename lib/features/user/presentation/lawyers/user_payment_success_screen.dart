import 'package:ashlar_lawyer_hub/core/consultation/consultation_models.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/lawyers/models/user_payment_result.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/lawyers/widgets/user_booking_flow_widgets.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/widgets/user_design_tokens.dart';
import 'package:ashlar_lawyer_hub/features/user/user_routes.dart';
import 'package:flutter/material.dart';

class UserPaymentSuccessScreen extends StatelessWidget {
  const UserPaymentSuccessScreen({
    super.key,
    required this.payment,
  });

  final UserPaymentResult payment;

  void _onGoToDashboard(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      UserRoutes.home,
      (route) => false,
    );
  }

  void _onStartConsultation(BuildContext context) {
    if (!payment.canStartOnlineConsultation) {
      _onGoToDashboard(context);
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil(
      UserRoutes.consultation,
      (route) => route.settings.name == UserRoutes.home,
      arguments: ConsultationScreenArgs(
        appointmentId: payment.appointmentId!,
        isLawyer: false,
        peerName: payment.lawyerName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPhysical = payment.mode == 'offline';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _onGoToDashboard(context);
        }
      },
      child: UserBookingScaffold(
        title: payment.billingPerMinute ? 'Booking confirmed' : 'Payment successful',
        subtitle: payment.billingPerMinute
            ? '₹${payment.amount.toStringAsFixed(0)}/min — wallet billed during consult'
            : payment.lawyerName ?? 'Booking confirmed',
        onBack: () => _onGoToDashboard(context),
        bottomBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (payment.canStartOnlineConsultation)
              UserBookingPrimaryButton(
                label: 'Start consultation',
                onPressed: () => _onStartConsultation(context),
              )
            else
              UserBookingPrimaryButton(
                label: isPhysical ? 'View appointments' : 'Go to home',
                onPressed: () {
                  if (isPhysical) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      UserRoutes.myAppointments,
                      (route) => route.settings.name == UserRoutes.home,
                    );
                  } else {
                    _onGoToDashboard(context);
                  }
                },
              ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextButton(
                onPressed: () => _onGoToDashboard(context),
                child: Text(
                  'Back to home',
                  style: AppTypography.inter(
                    color: UserDesignTokens.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: UserDesignTokens.success.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: UserDesignTokens.success,
                  size: 64,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isPhysical
                  ? 'Your in-person appointment request has been sent.'
                  : 'Your consultation is booked!',
              textAlign: TextAlign.center,
              style: AppTypography.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: UserDesignTokens.textPrimary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: UserDesignTokens.premiumCard(),
              child: Column(
                children: [
                  UserBookingSummaryRow(
                    label: payment.billingPerMinute ? 'Rate' : 'Amount paid',
                    value: payment.billingPerMinute
                        ? '₹${payment.amount.toStringAsFixed(0)} / min'
                        : payment.formattedAmount,
                    highlight: true,
                  ),
                  const Divider(color: UserDesignTokens.cardBorder),
                  UserBookingSummaryRow(
                    label: 'Reference',
                    value: payment.refNumber,
                  ),
                  const Divider(color: UserDesignTokens.cardBorder),
                  UserBookingSummaryRow(
                    label: 'Date & time',
                    value: payment.formattedPaymentTime.replaceAll('\n', ' '),
                  ),
                  if (payment.lawyerName != null) ...[
                    const Divider(color: UserDesignTokens.cardBorder),
                    UserBookingSummaryRow(
                      label: 'Lawyer',
                      value: payment.lawyerName!,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
