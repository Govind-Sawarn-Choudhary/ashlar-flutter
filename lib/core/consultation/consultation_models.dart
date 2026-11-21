import 'package:ashlar_lawyer_hub/core/consultation/agora_credentials.dart';
import 'package:ashlar_lawyer_hub/core/consultation/webrtc_credentials.dart';

class ConsultationBillingInfo {
  const ConsultationBillingInfo({
    required this.model,
    this.ratePerMinute,
    this.minWalletMinutes,
    this.minWalletBalance,
    this.walletBalance,
    this.billedMinutes,
    this.maxMinutes,
  });

  factory ConsultationBillingInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null || (json['model'] as String?) != 'per_minute') {
      return const ConsultationBillingInfo(model: 'prepaid');
    }
    return ConsultationBillingInfo(
      model: 'per_minute',
      ratePerMinute: (json['ratePerMinute'] as num?)?.toDouble(),
      minWalletMinutes: json['minWalletMinutes'] as int?,
      minWalletBalance: (json['minWalletBalance'] as num?)?.toDouble(),
      walletBalance: (json['walletBalance'] as num?)?.toDouble(),
      billedMinutes: json['billedMinutes'] as int?,
      maxMinutes: json['maxMinutes'] as int?,
    );
  }

  final String model;
  final double? ratePerMinute;
  final int? minWalletMinutes;
  final double? minWalletBalance;
  final double? walletBalance;
  final int? billedMinutes;
  final int? maxMinutes;

  bool get isPerMinute => model == 'per_minute';
}

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
    this.billedMinutes = 0,
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
      billedMinutes: json['billedMinutes'] as int? ?? 0,
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
  final int billedMinutes;

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
    this.scheduledAt,
    this.notes,
    this.billingModel,
    this.ratePerMinute,
  });

  factory ConsultationAppointment.fromJson(Map<String, dynamic> json) {
    return ConsultationAppointment(
      id: json['id'] as int,
      consultationType: json['consultationType'] as String? ?? 'chat',
      status: json['status'] as String? ?? 'confirmed',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      durationMinutes: json['durationMinutes'] as int? ?? 30,
      billingModel: json['billingModel'] as String?,
      ratePerMinute: (json['ratePerMinute'] as num?)?.toDouble(),
      userName: json['userName'] as String?,
      lawyerName: json['lawyerName'] as String?,
      mode: json['mode'] as String?,
      scheduledAt: json['scheduledAt'] as String?,
      notes: json['notes'] as String?,
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
  final String? scheduledAt;
  final String? notes;
  final String? billingModel;
  final double? ratePerMinute;

  bool get isPerMinuteBilling => billingModel == 'per_minute';

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
    required this.webrtc,
    required this.mediaProvider,
    required this.actor,
    this.billing = const ConsultationBillingInfo(model: 'prepaid'),
  });

  factory ConsultationJoinPayload.fromJson(Map<String, dynamic> json) {
    final provider = json['mediaProvider'] as String? ?? 'agora';
    return ConsultationJoinPayload(
      appointment: ConsultationAppointment.fromJson(
        json['appointment'] as Map<String, dynamic>,
      ),
      session: ConsultationSession.fromJson(
        json['session'] as Map<String, dynamic>,
      ),
      peerJoined: json['peerJoined'] as bool? ?? false,
      agora: AgoraCredentials.fromJson(json['agora'] as Map<String, dynamic>?),
      webrtc: WebRtcCredentials.fromJson(json['webrtc'] as Map<String, dynamic>?),
      mediaProvider: provider == 'webrtc'
          ? ConsultationMediaProvider.webrtc
          : ConsultationMediaProvider.agora,
      actor: ConsultationActor.fromJson(json['actor'] as Map<String, dynamic>?),
      billing: ConsultationBillingInfo.fromJson(
        json['billing'] as Map<String, dynamic>?,
      ),
    );
  }

  final ConsultationAppointment appointment;
  final ConsultationSession session;
  final bool peerJoined;
  final AgoraCredentials agora;
  final WebRtcCredentials webrtc;
  final ConsultationMediaProvider mediaProvider;
  final ConsultationActor actor;
  final ConsultationBillingInfo billing;
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
