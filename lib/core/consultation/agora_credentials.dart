class AgoraCredentials {
  const AgoraCredentials({
    required this.enabled,
    this.appId,
    this.chatAppKey,
    this.channelName,
    this.uid,
    this.rtcToken,
    this.chatToken,
    this.chatUserId,
    this.peerChatUserId,
    this.error,
  });

  factory AgoraCredentials.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AgoraCredentials(enabled: false, error: 'Missing Agora config');
    }

    return AgoraCredentials(
      enabled: json['enabled'] as bool? ?? false,
      appId: json['appId'] as String?,
      chatAppKey: json['chatAppKey'] as String?,
      channelName: json['channelName'] as String?,
      uid: json['uid'] as int?,
      rtcToken: json['rtcToken'] as String?,
      chatToken: json['chatToken'] as String?,
      chatUserId: json['chatUserId'] as String?,
      peerChatUserId: json['peerChatUserId'] as String?,
      error: json['error'] as String?,
    );
  }

  final bool enabled;
  final String? appId;
  final String? chatAppKey;
  final String? channelName;
  final int? uid;
  final String? rtcToken;
  final String? chatToken;
  final String? chatUserId;
  final String? peerChatUserId;
  final String? error;

  bool get isReady =>
      enabled &&
      appId != null &&
      chatAppKey != null &&
      channelName != null &&
      uid != null &&
      rtcToken != null &&
      chatToken != null &&
      chatUserId != null &&
      peerChatUserId != null;
}
