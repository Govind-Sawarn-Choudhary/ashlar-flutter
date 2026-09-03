import 'package:ashlar_lawyer_hub/features/user/presentation/lawyers/models/user_online_appointment_args.dart';

/// Booking context passed through lawyer discovery → payment flow.
class UserBookingContext {
  const UserBookingContext({
    required this.lawyerId,
    required this.lawyerName,
    required this.mode,
    required this.consultationType,
    this.amount,
  });

  final int lawyerId;
  final String lawyerName;
  final String mode;
  final String consultationType;
  final double? amount;

  static String consultationTypeFromOption(UserOnlineAppointmentOption option) {
    return switch (option) {
      UserOnlineAppointmentOption.call => 'audio',
      UserOnlineAppointmentOption.videoCall => 'video',
      UserOnlineAppointmentOption.chat => 'chat',
    };
  }

  UserBookingContext copyWith({
    String? mode,
    String? consultationType,
    double? amount,
  }) {
    return UserBookingContext(
      lawyerId: lawyerId,
      lawyerName: lawyerName,
      mode: mode ?? this.mode,
      consultationType: consultationType ?? this.consultationType,
      amount: amount ?? this.amount,
    );
  }
}
