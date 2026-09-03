import 'package:ashlar_lawyer_hub/core/auth/auth_session.dart';
import 'package:ashlar_lawyer_hub/core/config/api_config.dart';
import 'package:ashlar_lawyer_hub/core/navigation/app_navigator.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:dio/dio.dart';

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  late final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await AuthSession.instance.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final statusCode = error.response?.statusCode;
          if (statusCode == 401 || statusCode == 403) {
            await AuthSession.instance.clear();
            AppNavigator.toRoleSelect();
          }

          final data = error.response?.data;
          final message = data is Map && data['error'] is String
              ? data['error'] as String
              : error.message ?? 'Network request failed';
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              type: error.type,
              error: ApiException(message, statusCode: error.response?.statusCode),
            ),
          );
        },
      ),
    );

  Dio get dio => _dio;

  Future<Map<String, dynamic>> getJson(String path,
      {Map<String, dynamic>? query}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: query,
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(path, data: body);
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> putJson(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(path, data: body);
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required FormData formData,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      path,
      data: formData,
    );
    return response.data ?? {};
  }
}
