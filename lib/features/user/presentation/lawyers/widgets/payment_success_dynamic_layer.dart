import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/lawyers/models/user_payment_result.dart';
import 'package:flutter/material.dart';

/// Figma `7125:4019` / `7125:3399` dynamic value positions on the white card.
abstract final class PaymentSuccessLayout {
  static const cardLeft = 10.0;
  static const cardTop = 116.0;

  /// `7125:4056` — Rs. amount row.
  static const amountLeft = 34.0;
  static const amountTop = 342.231;
  static const amountWidth = 294.0;
  static const amountHeight = 54.0;

  /// Right column masking PNG values for ref + time (`7125:4045`, `7125:4048`).
  static const valuesLeft = 211.0;
  static const valuesTop = 421.0;
  static const valuesWidth = 135.0;
  static const valuesHeight = 113.315;
  static const refRowHeight = 30.0;
  static const rowGap = 23.315;
  static const timeRowHeight = 60.0;

  /// `7125:4025` — swipe track.
  static const dragLeft = 22.0;
  static const dragTop = 565.0;
  static const dragWidth = 324.0;
  static const dragHeight = 60.0;
}

/// Masks baked PNG values and renders live payment data at Figma coordinates.
class PaymentSuccessDynamicLayer extends StatelessWidget {
  const PaymentSuccessDynamicLayer({
    super.key,
    required this.scale,
    required this.payment,
    this.showAmount = true,
  });

  final FigmaScale scale;
  final UserPaymentResult payment;
  final bool showAmount;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final valueStyle = AppTypography.poppins(
      color: const Color(0xFF121212),
      fontWeight: FontWeight.w500,
      fontSize: s.fs(17),
      height: 29.977 / 17,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (showAmount)
          Positioned(
            left: s.s(PaymentSuccessLayout.amountLeft),
            top: s.s(PaymentSuccessLayout.amountTop),
            width: s.s(PaymentSuccessLayout.amountWidth),
            height: s.s(PaymentSuccessLayout.amountHeight),
            child: ColoredBox(
              color: Colors.white,
              child: Center(
                child: Text(
                  payment.formattedAmount,
                  textAlign: TextAlign.center,
                  style: AppTypography.poppins(
                    color: const Color(0xFF121212),
                    fontWeight: FontWeight.w500,
                    fontSize: s.fs(33),
                    height: 53.293 / 33,
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          left: s.s(PaymentSuccessLayout.valuesLeft),
          top: s.s(PaymentSuccessLayout.valuesTop),
          width: s.s(PaymentSuccessLayout.valuesWidth),
          height: s.s(PaymentSuccessLayout.valuesHeight),
          child: ColoredBox(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  height: s.s(PaymentSuccessLayout.refRowHeight),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      payment.refNumber,
                      textAlign: TextAlign.right,
                      style: valueStyle,
                    ),
                  ),
                ),
                SizedBox(height: s.s(PaymentSuccessLayout.rowGap)),
                SizedBox(
                  height: s.s(PaymentSuccessLayout.timeRowHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        payment.formattedPaymentDateLine,
                        textAlign: TextAlign.right,
                        style: valueStyle,
                      ),
                      Text(
                        payment.formattedPaymentClockLine,
                        textAlign: TextAlign.right,
                        style: valueStyle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
