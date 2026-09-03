import 'package:ashlar_lawyer_hub/core/consultation/agora_credentials.dart';

class ConsultationSession {
  const ConsultationSession({
    required this.id,
    required this.appointmentId,
    required this.status,
    this.userJoinedAt,
    this.lawyerJoinedAt,
    this.startedAt,
    this.endsAt,
    this.endedAt,
  });

  factory ConsultationSession.fromJson(Map<String, dynamic> json) {
    return ConsultationSession(
      id: json['id'] as int,
      appointmentId: json['appointmentId'] as int,
      status: json['status'] as String? ?? 'waiting',
      userJoinedAt: json['userJoinedAt'] as String?,
      lawyerJoinedAt: json['lawyerJoinedAt'] as String?,
      startedAt: json['startedAt'] as String?,
      endsAt: json['endsAt'] as String?,
      endedAt: json['endedAt'] as String?,
    );
  }

  final int id;
  final int appointmentId;
  final String status;
  final String? userJoinedAt;
  final String? lawyerJoinedAt;
  final String? startedAt;
  final String? endsAt;
  final String? endedAt;

  bool get isActive => status == 'active';
  bool get isEnded => status == 'ended';
}

class ConsultationAppointment {
  const ConsultationAppointment({
    required this.id,
    required this.consultationType,
    required this.status,
    required this.amount,
    required this.durationMinutes,
    this.userName,
    this.lawyerName,
    this.mode,
  });

  factory ConsultationAppointment.fromJson(Map<String, dynamic> json) {
    return ConsultationAppointment(
      id: json['id'] as int,
      consultationType: json['consultationType'] as String? ?? 'chat',
      status: json['status'] as String? ?? 'confirmed',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      durationMinutes: json['durationMinutes'] as int? ?? 30,
      userName: json['userName'] as String?,
      lawyerName: json['lawyerName'] as String?,
      mode: json['mode'] as String?,
    );
  }

  final int id;
  final String consultationType;
  final String status;
  final double amount;
  final int durationMinutes;
  final String? userName;
  final String? lawyerName;
  final String? mode;

  String get typeLabel => switch (consultationType) {
        'audio' => 'Audio Call',
        'video' => 'Video Call',
        'chat' => 'Chat',
        _ => consultationType,
      };
}

class ConsultationJoinPayload {
  const ConsultationJoinPayload({
    required this.appointment,
    required this.session,
    required this.peerJoined,
    required this.agora,
  });

  factory ConsultationJoinPayload.fromJson(Map<String, dynamic> json) {
    return ConsultationJoinPayload(
      appointment: ConsultationAppointment.fromJson(
        json['appointment'] as Map<String, dynamic>,
      ),
      session: ConsultationSession.fromJson(
        json['session'] as Map<String, dynamic>,
      ),
      peerJoined: json['peerJoined'] as bool? ?? false,
      agora: AgoraCredentials.fromJson(json['agora'] as Map<String, dynamic>?),
    );
  }

  final ConsultationAppointment appointment;
  final ConsultationSession session;
  final bool peerJoined;
  final AgoraCredentials agora;
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.sessionId,
    required this.senderId,
    required this.senderRole,
    required this.body,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as int,
      sessionId: json['sessionId'] as int,
      senderId: json['senderId'] as int,
      senderRole: json['senderRole'] as String? ?? 'user',
      body: json['body'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  final int id;
  final int sessionId;
  final int senderId;
  final String senderRole;
  final String body;
  final String createdAt;
}

class ConsultationScreenArgs {
  const ConsultationScreenArgs({
    required this.appointmentId,
    required this.isLawyer,
    this.peerName,
  });

  final int appointmentId;
  final bool isLawyer;
  final String? peerName;
}
