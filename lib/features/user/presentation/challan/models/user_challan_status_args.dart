/// Arguments for [UserChallanStatusScreen] after OTP verification.
class UserChallanStatusArgs {
  const UserChallanStatusArgs({
    required this.vehicleNumber,
    required this.mobileNumber,
  });

  final String vehicleNumber;
  final String mobileNumber;
}
