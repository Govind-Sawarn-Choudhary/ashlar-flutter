import 'package:ashlar_lawyer_hub/core/network/api_client.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/features/user/data/models/user_booking_context.dart';
import 'package:ashlar_lawyer_hub/features/user/data/models/user_marketplace_models.dart';
import 'package:ashlar_lawyer_hub/features/user/data/user_auth_repository.dart';
import 'package:ashlar_lawyer_hub/features/user/data/models/user_auth_response.dart';
import 'package:dio/dio.dart';

class UserRepository {
  UserRepository._();

  static final UserRepository instance = UserRepository._();

  Future<UserAuthResponse> getMe() => UserAuthRepository.instance.getMe();

  Future<UserAuthResponse> saveProfile({
    required String fullName,
    required String location,
    required String email,
    required String language,
  }) =>
      UserAuthRepository.instance.saveProfile(
        fullName: fullName,
        location: location,
        email: email,
        language: language,
      );

  Future<List<UserLawyerSummary>> listLawyers({String? q}) async {
    try {
      final json = await ApiClient.instance.getJson(
        '/api/user/lawyers',
        query: q == null || q.isEmpty ? null : {'q': q},
      );
      final list = json['lawyers'] as List<dynamic>? ?? [];
      return list
          .map((item) => UserLawyerSummary.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _wrap(e, 'Failed to load lawyers');
    }
  }

  Future<UserLawyerSummary> getLawyer(int id) async {
    try {
      final json = await ApiClient.instance.getJson('/api/user/lawyers/$id');
      return UserLawyerSummary.fromJson(json['lawyer'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _wrap(e, 'Failed to load lawyer');
    }
  }

  Future<bool> toggleFavourite(int lawyerId) async {
    try {
      final json =
          await ApiClient.instance.postJson('/api/user/lawyers/$lawyerId/favourite');
      return json['isFavourite'] as bool? ?? false;
    } on DioException catch (e) {
      throw _wrap(e, 'Failed to update favourite');
    }
  }

  Future<({double balance, List<UserWalletTransaction> transactions})> getWallet({
    String filter = 'all',
  }) async {
    try {
      final json = await ApiClient.instance.getJson(
        '/api/user/wallet',
        query: {'filter': filter},
      );
      final tx = json['transactions'] as List<dynamic>? ?? [];
      return (
        balance: (json['balance'] as num?)?.toDouble() ?? 0,
        transactions: tx
            .map((item) =>
                UserWalletTransaction.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      throw _wrap(e, 'Failed to load wallet');
    }
  }

  Future<double> addWalletFunds(double amount) async {
    try {
      final json = await ApiClient.instance.postJson(
        '/api/user/wallet/add-funds',
        body: {'amount': amount},
      );
      return (json['balance'] as num?)?.toDouble() ?? 0;
    } on DioException catch (e) {
      throw _wrap(e, 'Failed to add funds');
    }
  }

  Future<UserBookingResult> createBooking(
    UserBookingContext context, {
    bool payFromWallet = false,
  }) async {
    try {
      final json = await ApiClient.instance.postJson(
        '/api/user/bookings',
        body: {
          'lawyerId': context.lawyerId,
          'mode': context.mode,
          'consultationType': context.consultationType,
          'payFromWallet': payFromWallet,
        },
      );
      return UserBookingResult.fromJson(json);
    } on DioException catch (e) {
      throw _wrap(e, 'Booking failed');
    }
  }

  Future<List<UserDocumentCategory>> listDocumentCategories() async {
    try {
      final json = await ApiClient.instance.getJson('/api/user/documents/categories');
      final list = json['categories'] as List<dynamic>? ?? [];
      return list
          .map((item) =>
              UserDocumentCategory.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _wrap(e, 'Failed to load document categories');
    }
  }

  Future<List<UserDocumentProduct>> listDocumentProducts(int categoryId) async {
    try {
      final json = await ApiClient.instance.getJson(
        '/api/user/documents/categories/$categoryId/products',
      );
      final list = json['products'] as List<dynamic>? ?? [];
      return list
          .map((item) =>
              UserDocumentProduct.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _wrap(e, 'Failed to load products');
    }
  }

  Future<UserSupportInfo> getSupportInfo() async {
    try {
      final json = await ApiClient.instance.getJson('/api/user/support');
      return UserSupportInfo.fromJson(json);
    } on DioException catch (e) {
      throw _wrap(e, 'Failed to load support info');
    }
  }

  Future<void> lookupChallan(String vehicleNumber) async {
    try {
      await ApiClient.instance.postJson(
        '/api/user/challan/lookup',
        body: {'vehicleNumber': vehicleNumber},
      );
    } on DioException catch (e) {
      throw _wrap(e, 'Vehicle lookup failed');
    }
  }

  Future<void> sendChallanOtp({
    required String vehicleNumber,
    required String mobile,
  }) async {
    try {
      await ApiClient.instance.postJson(
        '/api/user/challan/send-otp',
        body: {'vehicleNumber': vehicleNumber, 'mobile': mobile},
      );
    } on DioException catch (e) {
      throw _wrap(e, 'Failed to send OTP');
    }
  }

  Future<List<UserChallanItem>> verifyChallanOtp({
    required String vehicleNumber,
    required String mobile,
    required String otp,
  }) async {
    try {
      final json = await ApiClient.instance.postJson(
        '/api/user/challan/verify-otp',
        body: {
          'vehicleNumber': vehicleNumber,
          'mobile': mobile,
          'otp': otp,
        },
      );
      final list = json['challans'] as List<dynamic>? ?? [];
      return list
          .map((item) => UserChallanItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _wrap(e, 'OTP verification failed');
    }
  }

  Future<List<UserChallanItem>> listChallans({
    String? vehicleNumber,
    String? status,
  }) async {
    try {
      final json = await ApiClient.instance.getJson(
        '/api/user/challan',
        query: {
          if (vehicleNumber != null) 'vehicleNumber': vehicleNumber,
          if (status != null) 'status': status,
        },
      );
      final list = json['challans'] as List<dynamic>? ?? [];
      return list
          .map((item) => UserChallanItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _wrap(e, 'Failed to load challans');
    }
  }

  Future<UserBookingResult> payChallan(
    int challanId,
    double amount, {
    bool payFromWallet = false,
  }) async {
    try {
      final json = await ApiClient.instance.postJson(
        '/api/user/challan/$challanId/pay',
        body: {'payFromWallet': payFromWallet},
      );
      final payment = json['payment'] as Map<String, dynamic>? ?? {};
      return UserBookingResult(
        appointmentId: challanId,
        amount: (payment['amount'] as num?)?.toDouble() ?? amount,
        reference: payment['reference'] as String? ?? '',
        paymentTime: DateTime.tryParse(payment['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
    } on DioException catch (e) {
      throw _wrap(e, 'Challan payment failed');
    }
  }

  Future<UserBookingResult> purchaseDocument(
    int productId, {
    bool payFromWallet = false,
  }) async {
    try {
      final json = await ApiClient.instance.postJson(
        '/api/user/documents/purchase',
        body: {
          'productId': productId,
          'payFromWallet': payFromWallet,
        },
      );
      final payment = json['payment'] as Map<String, dynamic>? ?? {};
      return UserBookingResult(
        appointmentId: productId,
        amount: (payment['amount'] as num?)?.toDouble() ?? 0,
        reference: payment['reference'] as String? ?? '',
        paymentTime: DateTime.tryParse(payment['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
    } on DioException catch (e) {
      throw _wrap(e, 'Document purchase failed');
    }
  }

  ApiException _wrap(DioException e, String fallback) {
    return e.error is ApiException
        ? e.error as ApiException
        : ApiException(e.message ?? fallback);
  }
}
