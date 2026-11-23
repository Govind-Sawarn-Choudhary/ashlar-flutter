import 'package:ashlar_lawyer_hub/core/consultation/consultation_models.dart';
import 'package:ashlar_lawyer_hub/core/notifications/app_notification_models.dart';
import 'package:ashlar_lawyer_hub/core/notifications/notification_inbox_notifier.dart';
import 'package:ashlar_lawyer_hub/features/user/data/models/user_marketplace_models.dart';
import 'package:ashlar_lawyer_hub/features/user/data/user_repository.dart';

class UserDashboardData {
  const UserDashboardData({
    required this.walletBalance,
    required this.featuredLawyers,
    required this.recentAppointments,
    required this.unreadNotifications,
    this.userName,
  });

  final double walletBalance;
  final List<UserLawyerSummary> featuredLawyers;
  final List<ConsultationAppointment> recentAppointments;
  final int unreadNotifications;
  final String? userName;
}

typedef UserNotificationItem = AppNotificationItem;

Future<UserDashboardData> loadUserDashboard() async {
  final json = await UserRepository.instance.getDashboard();
  final me = await UserRepository.instance.getMe();
  final unread = json['unreadNotifications'] as int? ?? 0;
  NotificationInboxNotifier.instance.setUnread(unread);

  final lawyersJson = json['featuredLawyers'] as List<dynamic>? ?? [];
  final apptsJson = json['recentAppointments'] as List<dynamic>? ?? [];

  return UserDashboardData(
    walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0,
    userName: me.profile.fullName,
    unreadNotifications: unread,
    featuredLawyers: lawyersJson
        .map((e) => UserLawyerSummary.fromJson(e as Map<String, dynamic>))
        .toList(),
    recentAppointments: apptsJson
        .map((e) => ConsultationAppointment.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Future<List<UserNotificationItem>> loadUserNotifications() async {
  final inbox = await UserRepository.instance.fetchNotificationInbox();
  NotificationInboxNotifier.instance.setUnread(inbox.unreadCount);
  return inbox.items;
}
