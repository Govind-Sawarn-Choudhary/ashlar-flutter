import 'package:ashlar_lawyer_hub/core/payments/razorpay_payment_service.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/lawyers/models/user_payment_result.dart';

/// Booking / challan / wallet payments via Razorpay checkout.
abstract final class UserPaymentService {
  static Future<UserPaymentResult> processBookingPayment({
    required double amount,
    required int lawyerId,
    required String mode,
    required String consultationType,
    String? lawyerName,
  }) async {
    final result = await RazorpayPaymentService.instance.pay(
      paymentType: 'booking',
      amount: amount,
      metadata: {
        'lawyerId': lawyerId,
        'mode': mode,
        'consultationType': consultationType,
      },
      description: lawyerName != null
          ? 'Booking with $lawyerName'
          : 'Lawyer consultation booking',
    );

    return RazorpayPaymentService.toPaymentResult(result);
  }

  static Future<UserPaymentResult> processChallanPayment({
    required int challanId,
    required double amount,
    String? title,
  }) async {
    final result = await RazorpayPaymentService.instance.pay(
      paymentType: 'challan',
      amount: amount,
      metadata: {'challanId': challanId},
      description: title ?? 'Challan payment',
    );

    return RazorpayPaymentService.toPaymentResult(result);
  }

  static Future<UserPaymentResult> processWalletTopup({
    required double amount,
  }) async {
    final result = await RazorpayPaymentService.instance.pay(
      paymentType: 'wallet_topup',
      amount: amount,
      description: 'Wallet top-up',
    );

    return RazorpayPaymentService.toPaymentResult(result);
  }

  static Future<UserPaymentResult> processDocumentPayment({
    required int productId,
    required double amount,
    String? productName,
  }) async {
    final result = await RazorpayPaymentService.instance.pay(
      paymentType: 'document',
      amount: amount,
      metadata: {'productId': productId},
      description: productName ?? 'Document purchase',
    );

    return RazorpayPaymentService.toPaymentResult(result);
  }
}
