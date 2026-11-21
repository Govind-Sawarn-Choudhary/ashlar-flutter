import 'package:ashlar_lawyer_hub/features/user/data/models/user_booking_context.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/lawyers/models/user_online_appointment_args.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/lawyers/widgets/user_booking_flow_widgets.dart';
import 'package:ashlar_lawyer_hub/features/user/user_routes.dart';
import 'package:flutter/material.dart';

/// Choose online consultation type: call, video, or chat.
class UserOnlineAppointmentScreen extends StatelessWidget {
  const UserOnlineAppointmentScreen({
    super.key,
    required this.bookingContext,
  });

  final UserBookingContext bookingContext;

  void _select(BuildContext context, UserOnlineAppointmentOption option) {
    final updated = bookingContext.copyWith(
      consultationType: UserBookingContext.consultationTypeFromOption(option),
    );
    Navigator.of(context).pushReplacementNamed(
      UserRoutes.lawyerDetail,
      arguments: updated,
    );
  }

  @override
  Widget build(BuildContext context) {
    return UserBookingPickerScreen(
      title: 'Select consultation type',
      lawyerName: bookingContext.lawyerName,
      options: [
        UserBookingOptionCard(
          icon: Icons.phone_in_talk_outlined,
          title: 'Phone Call',
          subtitle: 'Voice consultation with your lawyer',
          onTap: () => _select(context, UserOnlineAppointmentOption.call),
        ),
        const SizedBox(height: 10),
        UserBookingOptionCard(
          icon: Icons.videocam_outlined,
          title: 'Video Call',
          subtitle: 'Face-to-face video consultation',
          onTap: () => _select(context, UserOnlineAppointmentOption.videoCall),
        ),
        const SizedBox(height: 10),
        UserBookingOptionCard(
          icon: Icons.chat_bubble_outline_rounded,
          title: 'Chat',
          subtitle: 'Text-based consultation',
          onTap: () => _select(context, UserOnlineAppointmentOption.chat),
        ),
      ],
    );
  }
}
