/// Result returned after a booking payment attempt (Razorpay in future).
class UserPaymentResult {
  const UserPaymentResult({
    required this.isSuccess,
    required this.amount,
    required this.refNumber,
    required this.paymentTime,
  });

  final bool isSuccess;
  final double amount;
  final String refNumber;
  final DateTime paymentTime;

  String get formattedAmount {
    final whole = amount.truncateToDouble() == amount;
    return whole
        ? 'Rs. ${amount.toStringAsFixed(0)}'
        : 'Rs. ${amount.toStringAsFixed(2)}';
  }

  String get formattedPaymentDateLine {
    final d = paymentTime;
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final year = d.year;
    return '$day-$month-$year,';
  }

  String get formattedPaymentClockLine {
    final d = paymentTime;
    final hour = d.hour.toString().padLeft(2, '0');
    final minute = d.minute.toString().padLeft(2, '0');
    final second = d.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  String get formattedPaymentTime {
    return '$formattedPaymentDateLine\n$formattedPaymentClockLine';
  }

  /// Figma `7125:3399` preview values for wallet entry from dashboard.
  factory UserPaymentResult.walletPreview() {
    return UserPaymentResult(
      isSuccess: true,
      amount: 1500,
      refNumber: '000085752257',
      paymentTime: DateTime(2023, 2, 25, 13, 22, 16),
    );
  }
}
