import 'package:ashlar_lawyer_hub/core/consultation/consultation_models.dart';
import 'package:ashlar_lawyer_hub/core/navigation/app_navigator.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/lawyer_routes.dart';
import 'package:ashlar_lawyer_hub/features/user/user_routes.dart';

/// Deep-link style routing when a notification is opened (push or in-app).
class NotificationActionRouter {
  NotificationActionRouter._();

  static void open({
    required String role,
    String? actionType,
    int? actionId,
  }) {
    final normalized = (actionType ?? '').toLowerCase();
    if (normalized == 'wallet') {
      if (role == 'lawyer') {
        AppNavigator.pushNamed(LawyerRoutes.wallet);
      } else {
        AppNavigator.pushNamed(UserRoutes.wallet);
      }
      return;
    }
    if (normalized == 'consultation' && actionId != null) {
      final isLawyer = role == 'lawyer';
      AppNavigator.pushNamed(
        isLawyer ? LawyerRoutes.consultation : UserRoutes.consultation,
        arguments: ConsultationScreenArgs(
          appointmentId: actionId,
          isLawyer: isLawyer,
          peerName: '',
        ),
      );
      return;
    }
    if (normalized == 'appointment') {
      if (role == 'lawyer') {
        AppNavigator.pushNamed(LawyerRoutes.manageAppointments);
      } else {
        AppNavigator.pushNamed(UserRoutes.myAppointments);
      }
      return;
    }
    if (normalized == 'document') {
      AppNavigator.pushNamed(UserRoutes.documents);
      return;
    }
    if (role == 'lawyer') {
      AppNavigator.pushNamed(LawyerRoutes.notifications);
    } else {
      AppNavigator.pushNamed(UserRoutes.notifications);
    }
  }

  static void openFromData(Map<String, dynamic> data, {required String role}) {
    final actionType = data['actionType']?.toString();
    final actionIdRaw = data['actionId']?.toString();
    final actionId = actionIdRaw != null && actionIdRaw.isNotEmpty
        ? int.tryParse(actionIdRaw)
        : null;
    open(role: role, actionType: actionType, actionId: actionId);
  }
}