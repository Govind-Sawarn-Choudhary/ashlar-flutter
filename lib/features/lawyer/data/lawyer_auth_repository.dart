import 'package:ashlar_lawyer_hub/core/auth/auth_session.dart';
import 'package:ashlar_lawyer_hub/core/network/api_client.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/models/lawyer_auth_response.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/lawyer_routes.dart';
import 'package:dio/dio.dart';

class LawyerAuthRepository {
  LawyerAuthRepository._();

  static final LawyerAuthRepository instance = LawyerAuthRepository._();

  Future<void> sendOtp(String phone) async {
    try {
      await ApiClient.instance.postJson(
        '/api/auth/send-otp',
        body: {'phone': phone, 'role': 'lawyer'},
      );
    } on DioException catch (e) {
      throw e.error is ApiException ? e.error as ApiException : ApiException(e.message ?? 'Failed to send OTP');
    }
  }

  Future<LawyerAuthResponse> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final json = await ApiClient.instance.postJson(
        '/api/auth/verify-otp',
        body: {'phone': phone, 'otp': otp, 'role': 'lawyer'},
      );

      final response = LawyerAuthResponse.fromJson(json);
      await AuthSession.instance.saveSession(
        token: response.token,
        role: 'lawyer',
        nextRoute: response.nextRoute,
      );
      return response;
    } on DioException catch (e) {
      throw e.error is ApiException ? e.error as ApiException : ApiException(e.message ?? 'OTP verification failed');
    }
  }

  String routeForNextStep(String nextRoute) {
    switch (nextRoute) {
      case 'verify_details':
        return LawyerRoutes.verifyDetails;
      case 'upload_documents':
        return LawyerRoutes.uploadDocuments;
      case 'select_availability':
        return LawyerRoutes.selectAvailability;
      case 'fee_and_charges':
        return LawyerRoutes.feeAndCharges;
      case 'pending_approval':
      case 'rejected':
        return LawyerRoutes.verificationStatus;
      case 'dashboard':
        return LawyerRoutes.dashboard;
      default:
        return LawyerRoutes.verifyDetails;
    }
  }
}
