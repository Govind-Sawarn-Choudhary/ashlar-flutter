import 'dart:async';

import 'package:ashlar_lawyer_hub/core/network/api_client.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/features/user/data/user_auth_repository.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/lawyers/models/user_payment_result.dart';
import 'package:dio/dio.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayCheckoutResult {
  const RazorpayCheckoutResult({
    required this.payment,
    required this.fulfillment,
  });

  final Map<String, dynamic> payment;
  final Map<String, dynamic> fulfillment;
}

/// End-to-end Razorpay checkout: create order → open SDK → verify on backend.
class RazorpayPaymentService {
  RazorpayPaymentService._();

  static final RazorpayPaymentService instance = RazorpayPaymentService._();

  Razorpay? _razorpay;
  Completer<RazorpayCheckoutResult>? _activeCheckout;
  int? _activePaymentId;

  Future<RazorpayCheckoutResult> pay({
    required String paymentType,
    required double amount,
    Map<String, dynamic>? metadata,
    String? description,
  }) async {
    final order = await _createOrder(
      paymentType: paymentType,
      amount: amount,
      metadata: metadata,
    );

    _activePaymentId = order['paymentId'] as int?;
    final profile = await UserAuthRepository.instance.getMe();
    final contact = profile.phone;
    final email = profile.profile.email?.trim();

    final checkout = Completer<RazorpayCheckoutResult>();
    _activeCheckout = checkout;
    _razorpay?.clear();
    _razorpay = Razorpay()
      ..on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess)
      ..on(Razorpay.EVENT_PAYMENT_ERROR, _onError)
      ..on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);

    _razorpay!.open({
      'key': order['keyId'],
      'amount': ((order['amount'] as num) * 100).round(),
      'currency': order['currency'] ?? 'INR',
      'order_id': order['orderId'],
      'name': 'Ashlar Lawyer Hub',
      'description': description ?? 'Payment',
      'prefill': {
        if (contact != null && contact.isNotEmpty) 'contact': contact,
        if (email != null && email.isNotEmpty) 'email': email,
      },
      'theme': {'color': '#D4AF37'},
    });

    return checkout.future;
  }

  Future<Map<String, dynamic>> _createOrder({
    required String paymentType,
    required double amount,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      return await ApiClient.instance.postJson(
        '/api/user/payments/razorpay/order',
        body: {
          'paymentType': paymentType,
          if (paymentType == 'wallet_topup') 'amount': amount,
          'metadata': metadata ?? {},
        },
      );
    } on DioException catch (e) {
      throw _wrap(e, 'Failed to create payment order');
    }
  }

  Future<void> _onSuccess(PaymentSuccessResponse response) async {
    final checkout = _activeCheckout;
    final paymentId = _activePaymentId;
    if (checkout == null || checkout.isCompleted || paymentId == null) {
      return;
    }

    try {
      final order = await ApiClient.instance.postJson(
        '/api/user/payments/razorpay/verify',
        body: {
          'paymentId': paymentId,
          'razorpay_order_id': response.orderId,
          'razorpay_payment_id': response.paymentId,
          'razorpay_signature': response.signature,
        },
      );

      _disposeRazorpay();
      checkout.complete(
        RazorpayCheckoutResult(
          payment: Map<String, dynamic>.from(order['payment'] as Map),
          fulfillment: Map<String, dynamic>.from(order['fulfillment'] as Map),
        ),
      );
    } catch (error) {
      _disposeRazorpay();
      checkout.completeError(error);
    }
  }

  void _onError(PaymentFailureResponse response) {
    final checkout = _activeCheckout;
    if (checkout == null || checkout.isCompleted) {
      return;
    }

    _disposeRazorpay();
    checkout.completeError(
      ApiException(response.message ?? 'Payment cancelled'),
    );
  }

  void _onExternalWallet(ExternalWalletResponse response) {}

  void _disposeRazorpay() {
    _razorpay?.clear();
    _razorpay = null;
    _activeCheckout = null;
    _activePaymentId = null;
  }

  ApiException _wrap(DioException e, String fallback) {
    return e.error is ApiException
        ? e.error as ApiException
        : ApiException(e.message ?? fallback);
  }

  static UserPaymentResult toPaymentResult(RazorpayCheckoutResult result) {
    final payment = result.payment;
    final fulfillment = result.fulfillment;
    final appointment = fulfillment['appointment'] as Map<String, dynamic>?;
    return UserPaymentResult(
      isSuccess: true,
      amount: (payment['amount'] as num?)?.toDouble() ?? 0,
      refNumber: payment['reference'] as String? ?? '',
      paymentTime: DateTime.tryParse(payment['createdAt'] as String? ?? '') ??
          DateTime.now(),
      appointmentId: appointment?['id'] as int?,
      consultationType: appointment?['consultationType'] as String?,
      lawyerName: appointment?['lawyerName'] as String?,
      durationMinutes: appointment?['durationMinutes'] as int?,
      mode: appointment?['mode'] as String?,
    );
  }
}
