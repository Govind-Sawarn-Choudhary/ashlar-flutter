import 'package:ashlar_lawyer_hub/features/user/data/models/user_booking_context.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/lawyers/widgets/user_booking_flow_widgets.dart';
import 'package:ashlar_lawyer_hub/features/user/user_routes.dart';
import 'package:flutter/material.dart';

/// Choose online vs in-person consultation mode.
class UserAppointmentPreferenceScreen extends StatelessWidget {
  const UserAppointmentPreferenceScreen({
    super.key,
    required this.bookingContext,
  });

  final UserBookingContext bookingContext;

  @override
  Widget build(BuildContext context) {
    return UserBookingPickerScreen(
      title: 'How would you like to consult?',
      lawyerName: bookingContext.lawyerName,
      options: [
        UserBookingOptionCard(
          icon: Icons.wifi_rounded,
          title: 'Online',
          subtitle: 'Chat, audio, or video from anywhere',
          onTap: () {
            Navigator.of(context).pushReplacementNamed(
              UserRoutes.onlineAppointment,
              arguments: bookingContext.copyWith(mode: 'online'),
            );
          },
        ),
        const SizedBox(height: 10),
        UserBookingOptionCard(
          icon: Icons.location_on_outlined,
          title: 'In-Person',
          subtitle: 'Meet the lawyer at their office',
          onTap: () {
            Navigator.of(context).pushReplacementNamed(
              UserRoutes.lawyerDetail,
              arguments: bookingContext.copyWith(
                mode: 'offline',
                consultationType: 'physical',
              ),
            );
          },
        ),
      ],
    );
  }
}
