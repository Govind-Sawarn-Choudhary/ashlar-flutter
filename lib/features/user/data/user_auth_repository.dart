import 'package:ashlar_lawyer_hub/core/auth/auth_session.dart';
import 'package:ashlar_lawyer_hub/core/network/api_client.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/features/user/data/models/user_auth_response.dart';
import 'package:ashlar_lawyer_hub/features/user/user_routes.dart';
import 'package:dio/dio.dart';

class UserAuthRepository {
  UserAuthRepository._();

  static final UserAuthRepository instance = UserAuthRepository._();

  Future<void> sendOtp(String phone) async {
    try {
      await ApiClient.instance.postJson(
        '/api/auth/send-otp',
        body: {'phone': phone, 'role': 'user'},
      );
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(e.message ?? 'Failed to send OTP');
    }
  }

  Future<UserAuthResponse> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final json = await ApiClient.instance.postJson(
        '/api/auth/verify-otp',
        body: {'phone': phone, 'otp': otp, 'role': 'user'},
      );

      final response = UserAuthResponse.fromJson(json);
      await AuthSession.instance.saveSession(
        token: response.token,
        role: 'user',
        nextRoute: response.nextRoute,
      );
      return response;
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(e.message ?? 'OTP verification failed');
    }
  }

  Future<UserAuthResponse> saveProfile({
    required String fullName,
    required String location,
    required String email,
    required String language,
  }) async {
    try {
      final json = await ApiClient.instance.putJson(
        '/api/user/profile',
        body: {
          'fullName': fullName,
          'location': location,
          'email': email,
          'language': language,
        },
      );
      return UserAuthResponse.fromJson({
        ...json,
        'token': '',
        'isNewUser': false,
      });
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(e.message ?? 'Failed to save profile');
    }
  }

  Future<UserAuthResponse> getMe() async {
    try {
      final json = await ApiClient.instance.getJson('/api/user/me');
      return UserAuthResponse.fromJson({
        ...json,
        'token': '',
        'isNewUser': false,
      });
    } on DioException catch (e) {
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException(e.message ?? 'Failed to load profile');
    }
  }

  String routeForNextStep(String nextRoute) {
    switch (nextRoute) {
      case 'create_account':
        return UserRoutes.createAccount;
      case 'home':
        return UserRoutes.home;
      default:
        return UserRoutes.createAccount;
    }
  }
}
