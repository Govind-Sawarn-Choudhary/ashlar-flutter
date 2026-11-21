class WebRtcCredentials {
  const WebRtcCredentials({
    required this.enabled,
    required this.sessionId,
    required this.iceServers,
    required this.isInitiator,
  });

  factory WebRtcCredentials.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const WebRtcCredentials(
        enabled: false,
        sessionId: 0,
        iceServers: [],
        isInitiator: false,
      );
    }

    final servers = json['iceServers'] as List<dynamic>? ?? [];
    return WebRtcCredentials(
      enabled: json['enabled'] as bool? ?? true,
      sessionId: json['sessionId'] as int? ?? 0,
      iceServers: servers
          .whereType<Map<String, dynamic>>()
          .map(
            (item) => {
              'urls': item['urls'],
              if (item['username'] != null) 'username': item['username'],
              if (item['credential'] != null) 'credential': item['credential'],
            },
          )
          .toList(),
      isInitiator: json['isInitiator'] as bool? ?? false,
    );
  }

  final bool enabled;
  final int sessionId;
  final List<Map<String, dynamic>> iceServers;
  final bool isInitiator;
}

enum ConsultationMediaProvider { agora, webrtc }

class ConsultationActor {
  const ConsultationActor({required this.id, required this.role});

  factory ConsultationActor.fromJson(Map<String, dynamic>? json) {
    return ConsultationActor(
      id: json?['id'] as int? ?? 0,
      role: json?['role'] as String? ?? 'user',
    );
  }

  final int id;
  final String role;
}
