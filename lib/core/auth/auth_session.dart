import 'package:shared_preferences/shared_preferences.dart';

class AuthSession {
  AuthSession._();

  static final AuthSession instance = AuthSession._();

  static const _tokenKey = 'auth_token';
  static const _roleKey = 'auth_role';
  static const _nextRouteKey = 'auth_next_route';
  static const _lawyerUnverifiedPopupPrefix = 'lawyer_unverified_popup_shown_';

  Future<void> saveSession({
    required String token,
    required String role,
    String? nextRoute,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_roleKey, role);
    if (nextRoute != null && nextRoute.isNotEmpty) {
      await prefs.setString(_nextRouteKey, nextRoute);
    }
  }

  Future<void> saveNextRoute(String nextRoute) async {
    if (nextRoute.isEmpty) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nextRouteKey, nextRoute);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  Future<String?> getNextRoute() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nextRouteKey);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_nextRouteKey);
  }

  Future<bool> shouldShowLawyerUnverifiedPopup(String userKey) async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('$_lawyerUnverifiedPopupPrefix$userKey') ?? false);
  }

  Future<void> markLawyerUnverifiedPopupShown(String userKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_lawyerUnverifiedPopupPrefix$userKey', true);
  }
}
