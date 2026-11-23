import 'dart:async';

import 'package:agora_chat_sdk/agora_chat_sdk.dart' as agora_chat;
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:ashlar_lawyer_hub/core/consultation/agora_credentials.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class ConsultationUiMessage {
  const ConsultationUiMessage({
    required this.id,
    required this.body,
    required this.isMine,
  });

  final String id;
  final String body;
  final bool isMine;
}

class AgoraConsultationService {
  RtcEngine? _engine;
  bool _chatLoggedIn = false;
  String? _chatUserId;
  Completer<void>? _joinCompleter;

  Future<void> requestPermissions({required bool needCamera}) async {
    final mic = await Permission.microphone.request();
    if (!mic.isGranted) {
      throw StateError(
        mic.isPermanentlyDenied
            ? 'Microphone access is blocked. Open Settings and allow microphone for Ashlar.'
            : 'Microphone permission is required for calls.',
      );
    }

    if (needCamera) {
      final camera = await Permission.camera.request();
      if (!camera.isGranted) {
        throw StateError(
          camera.isPermanentlyDenied
              ? 'Camera access is blocked. Open Settings to allow camera for video calls.'
              : 'Camera permission is required for video calls.',
        );
      }
    }
  }

  Future<void> _releaseRtcEngine() async {
    try {
      await _engine?.leaveChannel();
      await _engine?.release();
    } catch (_) {}
    _engine = null;
    _joinCompleter = null;
  }

  Future<void> initRtc({
    required AgoraCredentials credentials,
    required void Function(int remoteUid) onRemoteUserJoined,
    required VoidCallback onRemoteUserOffline,
    required void Function(RtcConnection connection, int remoteUid) onRemoteVideoReady,
    VoidCallback? onPeerLeftChannel,
  }) async {
    if (!credentials.isRtcReady) {
      throw StateError(credentials.error ?? 'RTC credentials incomplete');
    }

    await _releaseRtcEngine();

    _engine = createAgoraRtcEngine();
    await _engine!.initialize(
      RtcEngineContext(
        appId: credentials.appId!,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );

    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          if (_joinCompleter != null && !_joinCompleter!.isCompleted) {
            _joinCompleter!.complete();
          }
        },
        onError: (err, msg) {
          if (kDebugMode) {
            debugPrint('RtcEngine onError: $err $msg');
          }
          if (_joinCompleter != null && !_joinCompleter!.isCompleted) {
            _joinCompleter!.completeError(StateError('$err $msg'));
          }
        },
        onConnectionStateChanged: (connection, state, reason) {
          if (state == ConnectionStateType.connectionStateFailed &&
              _joinCompleter != null &&
              !_joinCompleter!.isCompleted) {
            _joinCompleter!.completeError(StateError('$reason'));
          }
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          onRemoteUserJoined(remoteUid);
        },
        onUserOffline: (connection, remoteUid, reason) {
          onRemoteUserOffline();
          onPeerLeftChannel?.call();
        },
        onRemoteVideoStateChanged: (connection, remoteUid, state, reason, elapsed) {
          if (state == RemoteVideoState.remoteVideoStateStarting ||
              state == RemoteVideoState.remoteVideoStateDecoding) {
            onRemoteVideoReady(connection, remoteUid);
          }
        },
      ),
    );
  }

  Future<void> joinRtcChannel({
    required AgoraCredentials credentials,
    required bool videoEnabled,
  }) async {
    final engine = _engine;
    if (engine == null) {
      throw StateError('RTC engine not initialized');
    }

    _joinCompleter = Completer<void>();

    await engine.enableAudio();
    if (videoEnabled) {
      await engine.enableVideo();
      await engine.startPreview();
    } else {
      await engine.disableVideo();
    }

    await engine.joinChannel(
      token: credentials.rtcTokenRequired ? credentials.rtcToken! : '',
      channelId: credentials.channelName!,
      uid: credentials.uid!,
      options: ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileCommunication,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        publishCameraTrack: videoEnabled,
        publishMicrophoneTrack: true,
        autoSubscribeAudio: true,
        autoSubscribeVideo: videoEnabled,
      ),
    );

    await _joinCompleter!.future.timeout(
      const Duration(seconds: 25),
      onTimeout: () => throw StateError('Call connection timed out'),
    );

    await engine.setDefaultAudioRouteToSpeakerphone(true);
    await engine.setEnableSpeakerphone(true);
  }

  Future<void> setSpeakerphone(bool enabled) async {
    await _engine?.setEnableSpeakerphone(enabled);
  }

  RtcEngine? get engine => _engine;

  Future<void> setMuted(bool muted) async {
    await _engine?.muteLocalAudioStream(muted);
  }

  Future<void> setCameraEnabled(bool enabled) async {
    await _engine?.muteLocalVideoStream(!enabled);
    if (enabled) {
      await _engine?.startPreview();
    }
  }

  Future<void> initChat({
    required AgoraCredentials credentials,
    required void Function(List<ConsultationUiMessage> messages) onMessagesReceived,
  }) async {
    if (!credentials.isChatReady) {
      throw StateError(credentials.error ?? 'Agora Chat credentials incomplete');
    }

    _chatUserId = credentials.chatUserId;
    await agora_chat.ChatClient.getInstance.init(
      agora_chat.ChatOptions.withAppKey(
        credentials.chatAppKey!,
        autoLogin: false,
      ),
    );

    agora_chat.ChatClient.getInstance.chatManager.addEventHandler(
      'ashlar_consultation',
      agora_chat.ChatEventHandler(
        onMessagesReceived: (messages) {
          onMessagesReceived(
            messages.map((message) {
              final body = message.body;
              final text = body is agora_chat.ChatTextMessageBody
                  ? body.content
                  : '[Unsupported message]';
              return ConsultationUiMessage(
                id: message.msgId,
                body: text,
                isMine: message.from == _chatUserId,
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Future<void> loginChat(AgoraCredentials credentials) async {
    await agora_chat.ChatClient.getInstance.loginWithToken(
      credentials.chatUserId!,
      credentials.chatToken!,
    );
    _chatLoggedIn = true;
  }

  Future<ConsultationUiMessage> sendChatText({
    required String peerChatUserId,
    required String content,
  }) async {
    final message = agora_chat.ChatMessage.createTxtSendMessage(
      targetId: peerChatUserId,
      content: content,
    );
    await agora_chat.ChatClient.getInstance.chatManager.sendMessage(message);
    return ConsultationUiMessage(
      id: message.msgId,
      body: content,
      isMine: true,
    );
  }

  Future<void> disposeAll() async {
    await _releaseRtcEngine();

    if (_chatLoggedIn) {
      agora_chat.ChatClient.getInstance.chatManager.removeEventHandler(
        'ashlar_consultation',
      );
      try {
        await agora_chat.ChatClient.getInstance.logout();
      } catch (_) {}
      _chatLoggedIn = false;
    }
  }
}