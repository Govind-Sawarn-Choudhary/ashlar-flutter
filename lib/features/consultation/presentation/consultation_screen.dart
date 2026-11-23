import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:ashlar_lawyer_hub/core/consultation/agora_consultation_service.dart';
import 'package:ashlar_lawyer_hub/core/consultation/consultation_models.dart';
import 'package:ashlar_lawyer_hub/core/consultation/consultation_repository.dart';
import 'package:ashlar_lawyer_hub/core/consultation/webrtc_consultation_service.dart';
import 'package:ashlar_lawyer_hub/core/consultation/webrtc_credentials.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({
    super.key,
    required this.appointmentId,
    required this.isLawyer,
    this.peerName,
  });

  final int appointmentId;
  final bool isLawyer;
  final String? peerName;

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  final AgoraConsultationService _agora = AgoraConsultationService();
  final WebRtcConsultationService _webrtc = WebRtcConsultationService();
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  ConsultationRepository get _repo =>
      widget.isLawyer ? ConsultationRepository.lawyer : ConsultationRepository.user;

  ConsultationJoinPayload? _payload;
  final List<ConsultationUiMessage> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _sessionTimer;
  Timer? _chatTimer;
  Timer? _billingTimer;
  int _billedMinutes = 0;
  double? _ratePerMinute;
  double? _walletBalance;
  double _sessionCharged = 0;
  int? _remoteUid;
  int _lastChatId = 0;
  bool _loading = true;
  bool _sending = false;
  bool _muted = false;
  bool _speakerOn = true;
  bool _cameraOff = false;
  bool _useRestChat = false;
  bool _peerConnected = false;
  bool _renderersReady = false;
  String? _errorMessage;
  ConsultationMediaProvider? _mediaProvider;

  @override
  void initState() {
    super.initState();
    unawaited(_initRenderers());
    _bootstrap();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    if (mounted) {
      setState(() => _renderersReady = true);
    }
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _chatTimer?.cancel();
    _billingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    unawaited(_agora.disposeAll());
    unawaited(_webrtc.dispose());
    unawaited(_localRenderer.dispose());
    unawaited(_remoteRenderer.dispose());
    super.dispose();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final payload = await _repo.joinSession(widget.appointmentId);
      if (!mounted) {
        return;
      }

      final type = payload.appointment.consultationType;
      final videoEnabled = type == 'video';
      final needsMedia = type == 'audio' || type == 'video';

      if (needsMedia) {
        await _agora.requestPermissions(needCamera: videoEnabled);
      }

      await _setupChat(payload);
      if (needsMedia) {
        await _setupMedia(payload, videoEnabled: videoEnabled);
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _payload = payload;
        _loading = false;
        _peerConnected = payload.peerJoined;
        _billedMinutes = payload.session.billedMinutes;
        _ratePerMinute = payload.billing.ratePerMinute;
        _walletBalance = payload.billing.walletBalance;
        _sessionCharged = _billedMinutes * (payload.billing.ratePerMinute ?? 0);
      });
      _startSessionTimer();
      _maybeStartPerMinuteBilling(payload);
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _setupChat(ConsultationJoinPayload payload) async {
    if (payload.agora.isChatReady) {
      try {
        await _agora.initChat(
          credentials: payload.agora,
          onMessagesReceived: _onAgoraMessages,
        );
        await _agora.loginChat(payload.agora);
        _useRestChat = false;
        return;
      } catch (_) {
        // Fall through to REST chat.
      }
    }

    _useRestChat = true;
    await _loadRestMessages(payload.session.id, payload.actor.id);
    _startChatPolling(payload.session.id, payload.actor.id);
  }

  Future<void> _setupMedia(
    ConsultationJoinPayload payload, {
    required bool videoEnabled,
  }) async {
    if (payload.agora.isRtcReady) {
      try {
        await _agora.initRtc(
          credentials: payload.agora,
          onRemoteUserJoined: (remoteUid) {
            if (mounted) {
              setState(() {
                _remoteUid = remoteUid;
                _peerConnected = true;
              });
            }
          },
          onRemoteUserOffline: () {
            if (mounted) {
              setState(() {
                _remoteUid = null;
                _peerConnected = false;
              });
            }
          },
          onRemoteVideoReady: (connection, remoteUid) {
            if (mounted) {
              setState(() {
                _remoteUid = remoteUid;
                _peerConnected = true;
              });
            }
          },
        );
        await _agora.joinRtcChannel(
          credentials: payload.agora,
          videoEnabled: videoEnabled,
        );
        if (!videoEnabled) {
          await _agora.setSpeakerphone(true);
        }
        _mediaProvider = ConsultationMediaProvider.agora;
        return;
      } catch (_) {
        // Fall through to WebRTC.
      }
    }

    _mediaProvider = ConsultationMediaProvider.webrtc;
    await _webrtc.start(
      repo: _repo,
      credentials: payload.webrtc,
      actorUserId: payload.actor.id,
      videoEnabled: videoEnabled,
      onConnected: () {
        if (mounted) {
          setState(() => _peerConnected = true);
        }
      },
      onDisconnected: () {
        if (mounted) {
          setState(() => _peerConnected = false);
        }
      },
      onRemoteStream: (stream) {
        _remoteRenderer.srcObject = stream;
        if (mounted) {
          setState(() => _peerConnected = stream != null);
        }
      },
    );

    _localRenderer.srcObject = _webrtc.localStream;

    if (payload.peerJoined) {
      await _webrtc.onPeerAvailable();
    }
  }

  Future<void> _loadRestMessages(int sessionId, int actorUserId) async {
    final messages = await _repo.listMessages(sessionId, afterId: _lastChatId);
    if (!mounted || messages.isEmpty) {
      return;
    }

    setState(() {
      for (final message in messages) {
        _lastChatId = message.id;
        final ui = _restMessageToUi(message, actorUserId);
        if (!_messages.any((item) => item.id == ui.id)) {
          _messages.add(ui);
        }
      }
    });
    _scrollToBottom();
  }

  void _startChatPolling(int sessionId, int actorUserId) {
    _chatTimer?.cancel();
    _chatTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (!mounted || !_useRestChat) {
        return;
      }
      try {
        await _loadRestMessages(sessionId, actorUserId);
      } catch (_) {}
    });
  }

  ConsultationUiMessage _restMessageToUi(ChatMessage message, int actorUserId) {
    return ConsultationUiMessage(
      id: 'rest-${message.id}',
      body: message.body,
      isMine: message.senderId == actorUserId,
    );
  }

  void _onAgoraMessages(List<ConsultationUiMessage> incoming) {
    if (!mounted || incoming.isEmpty) {
      return;
    }

    setState(() {
      for (final message in incoming) {
        if (_messages.any((item) => item.id == message.id)) {
          continue;
        }
        _messages.add(message);
      }
    });

    _scrollToBottom();
  }

  void _maybeStartPerMinuteBilling(ConsultationJoinPayload payload) {
  if (!payload.billing.isPerMinute) {
    return;
  }
  if (!payload.session.isActive) {
    return;
  }

  _billingTimer?.cancel();
  unawaited(_tickPerMinuteBilling());
  _billingTimer = Timer.periodic(const Duration(seconds: 60), (_) {
    unawaited(_tickPerMinuteBilling());
  });
}

  Future<void> _tickPerMinuteBilling() async {
    final payload = _payload;
    if (payload == null || !payload.billing.isPerMinute || !payload.session.isActive) {
      return;
    }

    try {
      final result = await _repo.billConsultationMinute(payload.session.id);
      if (!mounted) {
        return;
      }

      if (result['skipped'] == true) {
        return;
      }

      final billed = result['billedMinutes'] as int? ?? _billedMinutes;
      final rate = (result['ratePerMinute'] as num?)?.toDouble() ?? _ratePerMinute;
      final wallet = (result['walletBalance'] as num?)?.toDouble();
      final total = (result['totalCharged'] as num?)?.toDouble();

      setState(() {
        _billedMinutes = billed;
        _ratePerMinute = rate;
        _walletBalance = wallet;
        _sessionCharged = total ?? (billed * (rate ?? 0));
      });
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      _billingTimer?.cancel();
      if (e.message.contains('Insufficient') || e.message.contains('wallet')) {
        await _agora.disposeAll();
        await _webrtc.dispose();
        _showEndedDialog(message: e.message);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (_) {}
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!mounted || _payload == null) {
        return;
      }

      try {
        final payload = await _repo.joinSession(widget.appointmentId);
        if (!mounted) {
          return;
        }

        final peerJustJoined = payload.peerJoined && !_peerConnected;
        final wasActive = _payload?.session.isActive ?? false;
        setState(() => _payload = payload);

        if (!wasActive && payload.session.isActive) {
          _maybeStartPerMinuteBilling(payload);
        }

        if (_mediaProvider == ConsultationMediaProvider.webrtc &&
            payload.peerJoined) {
          await _webrtc.onPeerAvailable();
        }

        if (peerJustJoined && _mediaProvider == ConsultationMediaProvider.agora) {
          setState(() => _peerConnected = true);
        }

        if (payload.session.isEnded) {
          _sessionTimer?.cancel();
          _chatTimer?.cancel();
          await _agora.disposeAll();
          await _webrtc.dispose();
          _showEndedDialog();
        }
      } catch (_) {}
    });
  }

  Future<void> _sendMessage() async {
    final payload = _payload;
    final text = _messageController.text.trim();
    if (payload == null || text.isEmpty || _sending) {
      return;
    }

    setState(() => _sending = true);
    try {
      if (_useRestChat) {
        final message = await _repo.sendMessage(payload.session.id, text);
        _messageController.clear();
        if (!mounted) {
          return;
        }
        final ui = _restMessageToUi(message, payload.actor.id);
        setState(() {
          _lastChatId = message.id;
          if (!_messages.any((item) => item.id == ui.id)) {
            _messages.add(ui);
          }
          _sending = false;
        });
      } else {
        final credentials = payload.agora;
        if (!credentials.isChatReady) {
          throw StateError('Chat is unavailable');
        }
        final message = await _agora.sendChatText(
          peerChatUserId: credentials.peerChatUserId!,
          content: text,
        );
        _messageController.clear();
        if (!mounted) {
          return;
        }
        setState(() {
          if (!_messages.any((item) => item.id == message.id)) {
            _messages.add(message);
          }
          _sending = false;
        });
      }
      _scrollToBottom();
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _toggleSpeaker() async {
    final next = !_speakerOn;
    if (_mediaProvider == ConsultationMediaProvider.webrtc) {
      await _webrtc.setSpeakerphone(next);
    } else {
      await _agora.setSpeakerphone(next);
    }
    if (mounted) {
      setState(() => _speakerOn = next);
    }
  }

  Future<void> _toggleMute() async {
    final next = !_muted;
    if (_mediaProvider == ConsultationMediaProvider.webrtc) {
      await _webrtc.setMuted(next);
    } else {
      await _agora.setMuted(next);
    }
    if (mounted) {
      setState(() => _muted = next);
    }
  }

  Future<void> _toggleCamera() async {
    final next = !_cameraOff;
    if (_mediaProvider == ConsultationMediaProvider.webrtc) {
      await _webrtc.setCameraEnabled(!next);
    } else {
      await _agora.setCameraEnabled(!next);
    }
    if (mounted) {
      setState(() => _cameraOff = next);
    }
  }

  Future<void> _endSession() async {
    final session = _payload?.session;
    if (session == null) {
      if (mounted) {
        Navigator.of(context).pop();
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End consultation?'),
        content: const Text('This will close the session for both parties.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('End')),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      await _agora.disposeAll();
      await _webrtc.dispose();
      await _repo.endSession(session.id);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  void _showEndedDialog({String? message}) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Session ended'),
        content: Text(message ?? 'Your consultation session has ended.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String get _peerLabel {
    final appointment = _payload?.appointment;
    if (widget.isLawyer) {
      return appointment?.userName ?? widget.peerName ?? 'Client';
    }
    return appointment?.lawyerName ?? widget.peerName ?? 'Lawyer';
  }

  String get _consultationType => _payload?.appointment.consultationType ?? 'chat';

  Duration? get _remaining {
    final endsAt = _payload?.session.endsAt;
    if (endsAt == null) {
      return null;
    }
    final end = DateTime.tryParse(endsAt);
    if (end == null) {
      return null;
    }
    return end.difference(DateTime.now());
  }

  String get _liveLabel {
    if (_mediaProvider == ConsultationMediaProvider.webrtc) {
      return 'WebRTC Live';
    }
    if (_mediaProvider == ConsultationMediaProvider.agora) {
      return 'Agora Live';
    }
    return 'Live';
  }

  String get _chatLabel {
    if (_useRestChat) {
      return 'Secure chat';
    }
    return 'Agora Chat';
  }

  bool get _mediaConnected {
    if (_mediaProvider == ConsultationMediaProvider.webrtc) {
      return _peerConnected || _webrtc.isConnected;
    }
    return _remoteUid != null || _peerConnected;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        await _endSession();
      },
      child: AppDarkScaffold(
        showGlow: false,
        body: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? _buildError()
                  : Column(
                      children: [
                        _buildHeader(),
                        if (_consultationType == 'video') _buildVideoArea(),
                        if (_consultationType == 'audio') _buildAudioPanel(),
                        Expanded(child: _buildMessages()),
                        if (_consultationType == 'audio' ||
                            _consultationType == 'video')
                          _buildCallControlBar(),
                        _buildComposer(),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: AppTypography.inter(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextButton(onPressed: _bootstrap, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final appointment = _payload!.appointment;
    final session = _payload!.session;
    final remaining = _remaining;
    final statusText = session.isEnded
        ? 'Ended'
        : session.isActive
            ? _liveLabel
            : _mediaConnected || _payload!.peerJoined
                ? 'Peer connected'
                : 'Waiting for ${_peerLabel.split(' ').first}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF2A2A2A))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _endSession,
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            tooltip: 'Disconnect',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _peerLabel,
                  style: AppTypography.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  appointment.isPerMinuteBilling
                      ? '${appointment.typeLabel} · ₹${(appointment.ratePerMinute ?? _ratePerMinute ?? 0).toStringAsFixed(0)}/min · $_billedMinutes min · ₹${_sessionCharged.toStringAsFixed(0)} charged'
                      : '${appointment.typeLabel} · ₹${appointment.amount.toStringAsFixed(0)} · ${appointment.durationMinutes} min',
                  style: AppTypography.inter(color: Colors.white54, fontSize: 12),
                ),
                if (_payload!.billing.isPerMinute &&
                    !widget.isLawyer &&
                    _walletBalance != null)
                  Text(
                    'Wallet: ₹${_walletBalance!.toStringAsFixed(0)}',
                    style: AppTypography.inter(color: Colors.white38, fontSize: 11),
                  ),
                Text(
                  '$statusText${remaining != null && remaining.inSeconds > 0 ? ' · ${_formatDuration(remaining)} left' : ''}',
                  style: AppTypography.inter(
                    color: session.isActive ? const Color(0xFF7CFF9B) : Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _endSession,
            child: Text(
              'Disconnect',
              style: AppTypography.inter(
                color: const Color(0xFFFF6B6B),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoArea() {
    if (_mediaProvider == ConsultationMediaProvider.webrtc) {
      if (!_renderersReady) {
        return const SizedBox(height: 220);
      }

      return SizedBox(
        height: 220,
        child: Stack(
          children: [
            Positioned.fill(
              child: _mediaConnected
                  ? RTCVideoView(
                      _remoteRenderer,
                      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    )
                  : Container(
                      color: const Color(0xFF151515),
                      alignment: Alignment.center,
                      child: Text(
                        'Waiting for video…',
                        style: AppTypography.inter(color: Colors.white54),
                      ),
                    ),
            ),
            if (!_cameraOff && _webrtc.localStream != null)
              Positioned(
                right: 12,
                top: 12,
                width: 96,
                height: 128,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: RTCVideoView(
                    _localRenderer,
                    mirror: true,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  ),
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CallActionButton(
                    icon: _muted ? Icons.mic_off : Icons.mic,
                    label: _muted ? 'Unmute' : 'Mute',
                    onTap: _toggleMute,
                  ),
                  const SizedBox(width: 16),
                  _CallActionButton(
                    icon: _cameraOff ? Icons.videocam_off : Icons.videocam,
                    label: _cameraOff ? 'Camera on' : 'Camera off',
                    onTap: _toggleCamera,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final engine = _agora.engine;
    if (engine == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 220,
      child: Stack(
        children: [
          Positioned.fill(
            child: _remoteUid != null
                ? AgoraVideoView(
                    controller: VideoViewController.remote(
                      rtcEngine: engine,
                      canvas: VideoCanvas(uid: _remoteUid),
                      connection: RtcConnection(
                        channelId: _payload!.agora.channelName!,
                      ),
                    ),
                  )
                : Container(
                    color: const Color(0xFF151515),
                    alignment: Alignment.center,
                    child: Text(
                      'Waiting for video…',
                      style: AppTypography.inter(color: Colors.white54),
                    ),
                  ),
          ),
          if (!_cameraOff)
            Positioned(
              right: 12,
              top: 12,
              width: 96,
              height: 128,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: engine,
                    canvas: const VideoCanvas(uid: 0),
                  ),
                ),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CallActionButton(
                  icon: _muted ? Icons.mic_off : Icons.mic,
                  label: _muted ? 'Unmute' : 'Mute',
                  onTap: _toggleMute,
                ),
                const SizedBox(width: 16),
                _CallActionButton(
                  icon: _cameraOff ? Icons.videocam_off : Icons.videocam,
                  label: _cameraOff ? 'Camera on' : 'Camera off',
                  onTap: _toggleCamera,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioPanel() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _mediaConnected ? const Color(0xFFD4AF37) : const Color(0xFF2A2A2A),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.call,
            size: 48,
            color: _mediaConnected ? const Color(0xFFD4AF37) : Colors.white38,
          ),
          const SizedBox(height: 8),
          Text(
            _mediaConnected
                ? '${_mediaProvider == ConsultationMediaProvider.webrtc ? 'WebRTC' : 'Agora'} audio connected'
                : 'Waiting for ${_peerLabel.split(' ').first}…',
            style: AppTypography.inter(color: Colors.white),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CallActionButton(
                icon: _speakerOn ? Icons.volume_up : Icons.volume_off,
                label: _speakerOn ? 'Speaker' : 'Earpiece',
                onTap: _toggleSpeaker,
              ),
              const SizedBox(width: 20),
              _CallActionButton(
                icon: _muted ? Icons.mic_off : Icons.mic,
                label: _muted ? 'Unmute' : 'Mute',
                onTap: _toggleMute,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCallControlBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        border: Border(top: BorderSide(color: Color(0xFF2A2A2A))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _CallActionButton(
              icon: _speakerOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              label: _speakerOn ? 'Speaker' : 'Earpiece',
              onTap: _toggleSpeaker,
            ),
            _CallActionButton(
              icon: _muted ? Icons.mic_off_rounded : Icons.mic_rounded,
              label: _muted ? 'Unmute' : 'Mute',
              onTap: _toggleMute,
            ),
            _DisconnectButton(onTap: _endSession),
          ],
        ),
      ),
    );
  }

  Widget _buildMessages() {
    if (_messages.isEmpty) {
      return Center(
        child: Text(
          '$_chatLabel — send a message to ${_peerLabel.split(' ').first}.',
          textAlign: TextAlign.center,
          style: AppTypography.inter(color: Colors.white54, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return Align(
          alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.75),
            decoration: BoxDecoration(
              color: message.isMine ? const Color(0xFFD4AF37) : const Color(0xFF222222),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              message.body,
              style: AppTypography.inter(
                color: message.isMine ? Colors.black : Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildComposer() {
    final session = _payload?.session;
    final disabled = session == null || session.isEnded;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                enabled: !disabled,
                style: AppTypography.inter(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Type a message…',
                  hintStyle: AppTypography.inter(color: Colors.white38, fontSize: 14),
                  filled: true,
                  fillColor: const Color(0xFF151515),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: disabled || _sending ? null : _sendMessage,
              icon: _sending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send, color: Color(0xFFD4AF37)),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _DisconnectButton extends StatelessWidget {
  const _DisconnectButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: const Color(0xFFE53935),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: const SizedBox(
              width: 56,
              height: 56,
              child: Icon(Icons.call_end_rounded, color: Colors.white, size: 28),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Disconnect',
          style: AppTypography.inter(
            color: const Color(0xFFFF8A80),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CallActionButton extends StatelessWidget {
  const _CallActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: const Color(0xFF222222),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 48,
              height: 48,
              child: Icon(icon, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTypography.inter(color: Colors.white54, fontSize: 11)),
      ],
    );
  }
}
