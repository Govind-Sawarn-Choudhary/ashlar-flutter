/// Arguments for [UserChallanVerifyOtpScreen] after mobile confirmation.
class UserChallanVerifyOtpArgs {
  const UserChallanVerifyOtpArgs({
    required this.vehicleNumber,
    required this.mobileNumber,
  });

  final String vehicleNumber;
  final String mobileNumber;
}
