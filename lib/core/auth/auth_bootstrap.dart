import 'package:ashlar_lawyer_hub/core/auth/auth_session.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_auth_repository.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_profile_repository.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/lawyer_routes.dart';
import 'package:ashlar_lawyer_hub/features/user/data/user_auth_repository.dart';
import 'package:ashlar_lawyer_hub/features/user/user_routes.dart';

/// Resolves where to send the user after splash based on a saved JWT session.
abstract final class AuthBootstrap {
  static Future<String> resolveInitialRoute() async {
    final token = await AuthSession.instance.getToken();
    final role = await AuthSession.instance.getRole();

    if (token == null || token.isEmpty || role == null || role.isEmpty) {
      return '/role-select';
    }

    try {
      if (role == 'lawyer') {
        final me = await LawyerProfileRepository.instance.getMe();
        await AuthSession.instance.saveNextRoute(me.nextRoute);
        return LawyerAuthRepository.instance.routeForNextStep(me.nextRoute);
      }

      if (role == 'user') {
        final me = await UserAuthRepository.instance.getMe();
        await AuthSession.instance.saveNextRoute(me.nextRoute);
        return UserAuthRepository.instance.routeForNextStep(me.nextRoute);
      }
    } on ApiException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403) {
        await AuthSession.instance.clear();
        return '/role-select';
      }

      return _fallbackRoute(role);
    } catch (_) {
      return _fallbackRoute(role);
    }

    await AuthSession.instance.clear();
    return '/role-select';
  }

  static Future<String> _fallbackRoute(String role) async {
    final saved = await AuthSession.instance.getNextRoute();
    if (saved != null && saved.isNotEmpty) {
      if (role == 'lawyer') {
        return LawyerAuthRepository.instance.routeForNextStep(saved);
      }
      if (role == 'user') {
        return UserAuthRepository.instance.routeForNextStep(saved);
      }
    }

    if (role == 'lawyer') {
      return LawyerRoutes.dashboard;
    }
    if (role == 'user') {
      return UserRoutes.home;
    }

    return '/role-select';
  }
}
