import 'package:ashlar_lawyer_hub/core/network/api_client.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/features/user/data/models/user_marketplace_models.dart';
import 'package:dio/dio.dart';

class LawyerMarketplaceRepository {
  LawyerMarketplaceRepository._();

  static final LawyerMarketplaceRepository instance =
      LawyerMarketplaceRepository._();

  Future<({
    double earningsThisMonth,
    int callsThisMonth,
    int overallCalls,
    int missedLeads,
    double walletBalance,
  })> getDashboardStats() async {
    try {
      final json = await ApiClient.instance.getJson('/api/lawyer/dashboard');
      final stats = json['stats'] as Map<String, dynamic>? ?? {};
      return (
        earningsThisMonth:
            (stats['earningsThisMonth'] as num?)?.toDouble() ?? 0,
        callsThisMonth: stats['callsThisMonth'] as int? ?? 0,
        overallCalls: stats['overallCalls'] as int? ?? 0,
        missedLeads: stats['missedLeads'] as int? ?? 0,
        walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0,
      );
    } on DioException catch (e) {
      throw _wrap(e, 'Failed to load dashboard');
    }
  }

  Future<({double balance, List<UserWalletTransaction> transactions})> getWallet({
    String filter = 'all',
  }) async {
    try {
      final json = await ApiClient.instance.getJson(
        '/api/lawyer/wallet',
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

  Future<List<Map<String, dynamic>>> listAppointments({String? status}) async {
    try {
      final json = await ApiClient.instance.getJson(
        '/api/lawyer/appointments',
        query: status == null ? null : {'status': status},
      );
      return (json['appointments'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw _wrap(e, 'Failed to load appointments');
    }
  }

  Future<List<Map<String, dynamic>>> listNotifications() async {
    try {
      final json = await ApiClient.instance.getJson('/api/lawyer/notifications');
      return (json['notifications'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw _wrap(e, 'Failed to load notifications');
    }
  }

  Future<void> markAllNotificationsRead() async {
    try {
      await ApiClient.instance.dio.patch('/api/lawyer/notifications/read-all');
    } on DioException catch (e) {
      throw _wrap(e, 'Failed to mark notifications read');
    }
  }

  Future<void> updateAppointmentStatus(int id, String status) async {
    try {
      await ApiClient.instance.dio.patch(
        '/api/lawyer/appointments/$id/status',
        data: {'status': status},
      );
    } on DioException catch (e) {
      throw _wrap(e, 'Failed to update appointment');
    }
  }

  Future<double> withdrawWallet(double amount) async {
    try {
      final json = await ApiClient.instance.postJson(
        '/api/lawyer/wallet/withdraw',
        body: {'amount': amount},
      );
      return (json['balance'] as num?)?.toDouble() ?? 0;
    } on DioException catch (e) {
      throw _wrap(e, 'Withdrawal failed');
    }
  }

  ApiException _wrap(DioException e, String fallback) {
    return e.error is ApiException
        ? e.error as ApiException
        : ApiException(e.message ?? fallback);
  }
}
