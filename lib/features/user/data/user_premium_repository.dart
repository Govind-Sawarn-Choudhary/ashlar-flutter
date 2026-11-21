import 'package:ashlar_lawyer_hub/core/consultation/consultation_models.dart';
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

class UserNotificationItem {
  const UserNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    this.createdAt,
  });

  factory UserNotificationItem.fromJson(Map<String, dynamic> json) {
    return UserNotificationItem(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      isRead: json['isRead'] as bool? ?? false,
      createdAt: json['createdAt'] as String?,
    );
  }

  final int id;
  final String title;
  final String body;
  final bool isRead;
  final String? createdAt;
}

Future<UserDashboardData> loadUserDashboard() async {
  final json = await UserRepository.instance.getDashboard();
  final me = await UserRepository.instance.getMe();
  final notifications = await loadUserNotifications();
  final unread = notifications.where((n) => !n.isRead).length;

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
  final list = await UserRepository.instance.listNotifications();
  return list.map(UserNotificationItem.fromJson).toList();
}
