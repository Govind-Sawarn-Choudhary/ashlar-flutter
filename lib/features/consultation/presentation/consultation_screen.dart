import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:ashlar_lawyer_hub/core/consultation/agora_consultation_service.dart';
import 'package:ashlar_lawyer_hub/core/consultation/consultation_models.dart';
import 'package:ashlar_lawyer_hub/core/consultation/consultation_repository.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:flutter/material.dart';

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
  ConsultationRepository get _repo =>
      widget.isLawyer ? ConsultationRepository.lawyer : ConsultationRepository.user;

  ConsultationJoinPayload? _payload;
  final List<ConsultationUiMessage> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _sessionTimer;
  int? _remoteUid;
  bool _loading = true;
  bool _sending = false;
  bool _muted = false;
  bool _cameraOff = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    _agora.disposeAll();
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

      if (!payload.agora.isReady) {
        setState(() {
          _payload = payload;
          _loading = false;
          _errorMessage = payload.agora.error ??
              'Agora is not configured. Add AGORA_APP_ID and AGORA_APP_CERTIFICATE in backend .env';
        });
        return;
      }

      final type = payload.appointment.consultationType;
      final videoEnabled = type == 'video';

      await _agora.requestPermissions(needCamera: videoEnabled);

      await _agora.initChat(
        credentials: payload.agora,
        onMessagesReceived: _onAgoraMessages,
      );
      await _agora.loginChat(payload.agora);

      if (type == 'audio' || type == 'video') {
        await _agora.initRtc(
          credentials: payload.agora,
          onRemoteUserJoined: (remoteUid) {
            if (mounted) {
              setState(() => _remoteUid = remoteUid);
            }
          },
          onRemoteUserOffline: () {
            if (mounted) {
              setState(() => _remoteUid = null);
            }
          },
          onRemoteVideoReady: (connection, remoteUid) {
            if (mounted) {
              setState(() => _remoteUid = remoteUid);
            }
          },
        );
        await _agora.joinRtcChannel(
          credentials: payload.agora,
          videoEnabled: videoEnabled,
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _payload = payload;
        _loading = false;
      });
      _startSessionTimer();
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
        setState(() => _payload = payload);
        if (payload.session.isEnded) {
          _sessionTimer?.cancel();
          await _agora.disposeAll();
          _showEndedDialog();
        }
      } catch (_) {}
    });
  }

  Future<void> _sendMessage() async {
    final credentials = _payload?.agora;
    final text = _messageController.text.trim();
    if (credentials == null || !credentials.isReady || text.isEmpty || _sending) {
      return;
    }

    setState(() => _sending = true);
    try {
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

  Future<void> _toggleMute() async {
    final next = !_muted;
    await _agora.setMuted(next);
    if (mounted) {
      setState(() => _muted = next);
    }
  }

  Future<void> _toggleCamera() async {
    final next = !_cameraOff;
    await _agora.setCameraEnabled(!next);
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
        content: const Text('This will close the Agora session for both parties.'),
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

  void _showEndedDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Session ended'),
        content: const Text('Your paid consultation time is over.'),
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

  @override
  Widget build(BuildContext context) {
    return AppDarkScaffold(
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
                      _buildComposer(),
                    ],
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
            ? 'Agora Live'
            : _remoteUid != null || _payload!.peerJoined
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
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                  '${appointment.typeLabel} · ₹${appointment.amount.toStringAsFixed(0)} · ${appointment.durationMinutes} min',
                  style: AppTypography.inter(color: Colors.white54, fontSize: 12),
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
          TextButton(onPressed: _endSession, child: const Text('End')),
        ],
      ),
    );
  }

  Widget _buildVideoArea() {
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
          color: _remoteUid != null ? const Color(0xFFD4AF37) : const Color(0xFF2A2A2A),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.call,
            size: 48,
            color: _remoteUid != null ? const Color(0xFFD4AF37) : Colors.white38,
          ),
          const SizedBox(height: 8),
          Text(
            _remoteUid != null ? 'Agora audio connected' : 'Waiting for ${_peerLabel.split(' ').first}…',
            style: AppTypography.inter(color: Colors.white),
          ),
          const SizedBox(height: 12),
          _CallActionButton(
            icon: _muted ? Icons.mic_off : Icons.mic,
            label: _muted ? 'Unmute' : 'Mute',
            onTap: _toggleMute,
          ),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    if (_messages.isEmpty) {
      return Center(
        child: Text(
          'Agora Chat — send a message to ${_peerLabel.split(' ').first}.',
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
