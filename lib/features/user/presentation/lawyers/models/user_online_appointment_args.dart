enum UserOnlineAppointmentOption { call, videoCall, chat }

class UserOnlineAppointmentArgs {
  const UserOnlineAppointmentArgs({required this.option});

  final UserOnlineAppointmentOption option;

  String get label => switch (option) {
        UserOnlineAppointmentOption.call => 'Call',
        UserOnlineAppointmentOption.videoCall => 'Video Call',
        UserOnlineAppointmentOption.chat => 'Chat',
      };
}
