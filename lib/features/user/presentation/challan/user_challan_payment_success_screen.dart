import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/lawyers/models/user_payment_result.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/lawyers/widgets/user_booking_flow_widgets.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/widgets/user_design_tokens.dart';
import 'package:ashlar_lawyer_hub/features/user/user_routes.dart';
import 'package:flutter/material.dart';

class UserChallanPaymentSuccessScreen extends StatelessWidget {
  const UserChallanPaymentSuccessScreen({
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _onGoToDashboard(context);
        }
      },
      child: UserBookingScaffold(
        title: 'Challan paid',
        subtitle: 'Payment successful',
        onBack: () => _onGoToDashboard(context),
        bottomBar: UserBookingPrimaryButton(
          label: 'Back to home',
          onPressed: () => _onGoToDashboard(context),
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
              'Your challan payment was successful.',
              textAlign: TextAlign.center,
              style: AppTypography.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: UserDesignTokens.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: UserDesignTokens.premiumCard(),
              child: Column(
                children: [
                  UserBookingSummaryRow(
                    label: 'Amount paid',
                    value: payment.formattedAmount,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
