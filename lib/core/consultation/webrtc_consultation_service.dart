import 'dart:async';
import 'dart:convert';

import 'package:ashlar_lawyer_hub/core/consultation/consultation_repository.dart';
import 'package:ashlar_lawyer_hub/core/consultation/webrtc_credentials.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';

class WebRtcConsultationService {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  Timer? _signalTimer;
  int _lastSignalId = 0;
  bool _offerSent = false;
  bool _remoteDescriptionSet = false;

  ConsultationRepository? _repo;
  int _sessionId = 0;
  int _actorUserId = 0;
  bool _isInitiator = false;
  bool _videoEnabled = false;
  VoidCallback? _onConnected;
  VoidCallback? _onDisconnected;
  ValueChanged<MediaStream?>? _onRemoteStream;

  MediaStream? get localStream => _localStream;
  MediaStream? get remoteStream => _remoteStream;
  bool get isConnected => _remoteStream != null;

  Future<void> requestPermissions({required bool needCamera}) async {
    final permissions = <Permission>[Permission.microphone];
    if (needCamera) {
      permissions.add(Permission.camera);
    }
    await permissions.request();
  }

  Future<void> start({
    required ConsultationRepository repo,
    required WebRtcCredentials credentials,
    required int actorUserId,
    required bool videoEnabled,
    required VoidCallback onConnected,
    required VoidCallback onDisconnected,
    required ValueChanged<MediaStream?> onRemoteStream,
  }) async {
    _repo = repo;
    _sessionId = credentials.sessionId;
    _actorUserId = actorUserId;
    _isInitiator = credentials.isInitiator;
    _videoEnabled = videoEnabled;
    _onConnected = onConnected;
    _onDisconnected = onDisconnected;
    _onRemoteStream = onRemoteStream;

    _peerConnection = await createPeerConnection({
      'iceServers': credentials.iceServers,
      'sdpSemantics': 'unified-plan',
    });

    _peerConnection!.onIceCandidate = (candidate) {
      final candidateStr = candidate.candidate;
      if (candidateStr == null || candidateStr.isEmpty) {
        return;
      }
      unawaited(
        _repo!.postWebRtcSignal(
          _sessionId,
          signalType: 'ice',
          payload: jsonEncode(candidate.toMap()),
        ),
      );
    };

    _peerConnection!.onTrack = (event) {
      if (event.streams.isEmpty) {
        return;
      }
      _remoteStream = event.streams.first;
      _onRemoteStream?.call(_remoteStream);
      _onConnected?.call();
    };

    _peerConnection!.onConnectionState = (state) {
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        _onConnected?.call();
      } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateClosed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
        _onDisconnected?.call();
      }
    };

    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': videoEnabled,
    });

    for (final track in _localStream!.getTracks()) {
      await _peerConnection!.addTrack(track, _localStream!);
    }

    if (!videoEnabled) {
      await Helper.setSpeakerphoneOn(true);
    }

    _signalTimer = Timer.periodic(const Duration(milliseconds: 800), (_) {
      unawaited(_pollSignals());
    });
  }

  Future<void> onPeerAvailable() async {
    if (!_isInitiator || _offerSent) {
      return;
    }
    await _createOffer();
  }

  Future<void> _createOffer() async {
    final pc = _peerConnection;
    if (pc == null || _offerSent) {
      return;
    }

    _offerSent = true;
    final offer = await pc.createOffer({
      'offerToReceiveAudio': true,
      'offerToReceiveVideo': _videoEnabled,
    });
    await pc.setLocalDescription(offer);
    await _repo!.postWebRtcSignal(
      _sessionId,
      signalType: 'offer',
      payload: jsonEncode(offer.toMap()),
    );
  }

  Future<void> _pollSignals() async {
    final repo = _repo;
    final pc = _peerConnection;
    if (repo == null || pc == null) {
      return;
    }

    try {
      final signals = await repo.listWebRtcSignals(
        _sessionId,
        afterId: _lastSignalId,
      );

      for (final signal in signals) {
        if (signal.senderId == _actorUserId) {
          _lastSignalId = signal.id;
          continue;
        }

        _lastSignalId = signal.id;
        final data = jsonDecode(signal.payload) as Map<String, dynamic>;

        if (signal.signalType == 'offer') {
          await pc.setRemoteDescription(
            RTCSessionDescription(data['sdp'] as String, data['type'] as String),
          );
          _remoteDescriptionSet = true;
          final answer = await pc.createAnswer();
          await pc.setLocalDescription(answer);
          await repo.postWebRtcSignal(
            _sessionId,
            signalType: 'answer',
            payload: jsonEncode(answer.toMap()),
          );
        } else if (signal.signalType == 'answer') {
          if (!_remoteDescriptionSet) {
            await pc.setRemoteDescription(
              RTCSessionDescription(data['sdp'] as String, data['type'] as String),
            );
            _remoteDescriptionSet = true;
          }
        } else if (signal.signalType == 'ice') {
          await pc.addCandidate(
            RTCIceCandidate(
              data['candidate'] as String?,
              data['sdpMid'] as String?,
              data['sdpMLineIndex'] as int?,
            ),
          );
        }
      }
    } catch (_) {
      // Signaling poll errors are non-fatal; next tick retries.
    }
  }

  Future<void> setSpeakerphone(bool enabled) async {
    await Helper.setSpeakerphoneOn(enabled);
  }

  Future<void> setMuted(bool muted) async {
    final stream = _localStream;
    if (stream == null) {
      return;
    }
    for (final track in stream.getAudioTracks()) {
      track.enabled = !muted;
    }
  }

  Future<void> setCameraEnabled(bool enabled) async {
    final stream = _localStream;
    if (stream == null) {
      return;
    }
    for (final track in stream.getVideoTracks()) {
      track.enabled = enabled;
    }
  }

  Future<void> dispose() async {
    _signalTimer?.cancel();
    _signalTimer = null;

    for (final track in _localStream?.getTracks() ?? []) {
      await track.stop();
    }
    await _localStream?.dispose();
    _localStream = null;

    await _remoteStream?.dispose();
    _remoteStream = null;

    await _peerConnection?.close();
    _peerConnection = null;
  }
}

class WebRtcSignal {
  const WebRtcSignal({
    required this.id,
    required this.senderId,
    required this.signalType,
    required this.payload,
  });

  factory WebRtcSignal.fromJson(Map<String, dynamic> json) {
    return WebRtcSignal(
      id: json['id'] as int,
      senderId: json['senderId'] as int,
      signalType: json['signalType'] as String? ?? '',
      payload: json['payload'] as String? ?? '',
    );
  }

  final int id;
  final int senderId;
  final String signalType;
  final String payload;
}
