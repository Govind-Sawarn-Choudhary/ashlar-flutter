import 'package:ashlar_lawyer_hub/core/consultation/agora_credentials.dart';
import 'package:ashlar_lawyer_hub/core/consultation/consultation_models.dart';
import 'package:ashlar_lawyer_hub/core/network/api_client.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:dio/dio.dart';

class ConsultationRepository {
  ConsultationRepository._({required this.basePath});

  static final ConsultationRepository user = ConsultationRepository._(
    basePath: '/api/user',
  );

  static final ConsultationRepository lawyer = ConsultationRepository._(
    basePath: '/api/lawyer',
  );

  final String basePath;

  Future<List<ConsultationAppointment>> listConsultations({
    String? status,
    String? consultationType,
  }) async {
    try {
      final json = await ApiClient.instance.getJson(
        '$basePath/consultations',
        query: {
          if (status != null) 'status': status,
          if (consultationType != null) 'consultationType': consultationType,
        },
      );
      final list = json['appointments'] as List<dynamic>? ?? [];
      return list
          .map((item) => ConsultationAppointment.fromJson(
                item as Map<String, dynamic>,
              ))
          .toList();
    } on DioException catch (e) {
      throw _wrap(e, 'Failed to load consultations');
    }
  }

  Future<ConsultationJoinPayload> joinSession(int appointmentId) async {
    try {
      final json = await ApiClient.instance.postJson(
        '$basePath/appointments/$appointmentId/consultation/join',
      );
      return ConsultationJoinPayload.fromJson(json);
    } on DioException catch (e) {
      throw _wrap(e, 'Failed to join consultation');
    }
  }

  Future<ConsultationJoinPayload> getSession(int appointmentId) async {
    try {
      final json = await ApiClient.instance.getJson(
        '$basePath/appointments/$appointmentId/consultation',
      );
      return ConsultationJoinPayload(
        appointment: ConsultationAppointment.fromJson(
          json['appointment'] as Map<String, dynamic>,
        ),
        session: ConsultationSession.fromJson(
          json['session'] as Map<String, dynamic>,
        ),
        peerJoined: false,
        agora: AgoraCredentials.fromJson(json['agora'] as Map<String, dynamic>?),
      );
    } on DioException catch (e) {
      throw _wrap(e, 'Failed to load consultation');
    }
  }

  Future<List<ChatMessage>> listMessages(int sessionId, {int afterId = 0}) async {
    try {
      final json = await ApiClient.instance.getJson(
        '$basePath/consultations/$sessionId/messages',
        query: {'afterId': afterId},
      );
      final list = json['messages'] as List<dynamic>? ?? [];
      return list
          .map((item) => ChatMessage.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _wrap(e, 'Failed to load messages');
    }
  }

  Future<ChatMessage> sendMessage(int sessionId, String body) async {
    try {
      final json = await ApiClient.instance.postJson(
        '$basePath/consultations/$sessionId/messages',
        body: {'body': body},
      );
      return ChatMessage.fromJson(json['message'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _wrap(e, 'Failed to send message');
    }
  }

  Future<ConsultationSession> endSession(int sessionId) async {
    try {
      final json = await ApiClient.instance.postJson(
        '$basePath/consultations/$sessionId/end',
      );
      return ConsultationSession.fromJson(json['session'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _wrap(e, 'Failed to end consultation');
    }
  }

  ApiException _wrap(DioException e, String fallback) {
    return e.error is ApiException
        ? e.error as ApiException
        : ApiException(e.message ?? fallback);
  }
}
