import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:ashlar_lawyer_hub/core/consultation/agora_consultation_service.dart';
import 'package:ashlar_lawyer_hub/core/consultation/consultation_models.dart';
import 'package:ashlar_lawyer_hub/core/consultation/webrtc_credentials.dart';
import 'package:ashlar_lawyer_hub/core/consultation/consultation_repository.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/lawyer_routes.dart';
import 'package:ashlar_lawyer_hub/features/user/user_routes.dart';
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

class _ConsultationScreenState extends State<ConsultationScreen>
    with SingleTickerProviderStateMixin {
  final AgoraConsultationService _agora = AgoraConsultationService();

  ConsultationRepository get _repo =>
      widget.isLawyer ? ConsultationRepository.lawyer : ConsultationRepository.user;

  ConsultationJoinPayload? _payload;
  final List<ConsultationUiMessage> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _sessionTimer;
  Timer? _chatTimer;
  Timer? _billingTimer;
  Timer? _elapsedTicker;
  DateTime? _sessionStartedLocal;
  DateTime? _connectedSince;
  int _billedMinutes = 0;
  double? _ratePerMinute;
  double? _walletBalance;
  double _sessionCharged = 0;
  int? _nextBillAtSeconds;
  int? _remoteUid;
  int _lastChatId = 0;
  bool _loading = true;
  bool _sending = false;
  bool _muted = false;
  bool _speakerOn = true;
  bool _cameraOff = false;
  bool _useRestChat = false;
  bool _peerConnected = false;
  String? _errorMessage;
  ConsultationMediaProvider? _mediaProvider;
  bool _sessionEndedHandled = false;
  bool _peerLeavePending = false;
  late final AnimationController _livePulseController;

  @override
  void initState() {
    super.initState();
    _livePulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _bootstrap();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _chatTimer?.cancel();
    _billingTimer?.cancel();
    _elapsedTicker?.cancel();
    _livePulseController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    unawaited(_agora.disposeAll());
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
      final isCall = needsMedia;

      if (needsMedia) {
        await _agora.requestPermissions(needCamera: videoEnabled);
      }

      if (!isCall) {
        await _setupChat(payload);
      }
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
        _nextBillAtSeconds = payload.billing.nextBillAtSeconds;
      });
      _syncSessionClock(payload);
      _startElapsedTicker();
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
        _errorMessage = _userFacingError(e);
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
    if (!payload.agora.isRtcReady) {
      throw ApiException(_userFacingCallError(payload.agora.error));
    }

    await _agora.initRtc(
      credentials: payload.agora,
      onRemoteUserJoined: (remoteUid) {
        if (mounted) {
          setState(() {
            _remoteUid = remoteUid;
            _peerConnected = true;
            _markCallConnected();
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
      onPeerLeftChannel: () => unawaited(_onPeerLeftChannel()),
      onRemoteVideoReady: (connection, remoteUid) {
        if (mounted) {
          setState(() {
            _remoteUid = remoteUid;
            _peerConnected = true;
            _markCallConnected();
          });
        }
      },
    );
    await _agora.joinRtcChannel(
      credentials: payload.agora,
      videoEnabled: videoEnabled,
    );
    await _agora.setSpeakerphone(true);
    _mediaProvider = ConsultationMediaProvider.agora;
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
    _billingTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      unawaited(_tickPerMinuteBilling());
    });
  }

  void _syncSessionClock(ConsultationJoinPayload payload) {
    final started = payload.session.startedAt;
    if (started != null && payload.session.isActive) {
      _sessionStartedLocal = DateTime.tryParse(started)?.toLocal();
    }
  }

  void _startElapsedTicker() {
    _elapsedTicker?.cancel();
    if (!_isCallMode) {
      return;
    }
    _elapsedTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && (_payload?.session.isActive ?? false)) {
        setState(() {});
      }
    });
  }

  bool get _isCallMode {
    final type = _consultationType;
    return type == 'audio' || type == 'video';
  }

  Duration get _callElapsed {
    if (_sessionStartedLocal == null || !(_payload?.session.isActive ?? false)) {
      return Duration.zero;
    }
    return DateTime.now().difference(_sessionStartedLocal!);
  }

  Duration? get _untilNextBill {
    final billing = _payload?.billing;
    if (billing == null || !billing.isPerMinute || !(_payload?.session.isActive ?? false)) {
      return null;
    }
    final due = _nextBillAtSeconds ?? billing.nextBillAtSeconds ?? (_billedMinutes * 60 + 40);
    final rem = due - _callElapsed.inSeconds;
    if (rem <= 0) {
      return Duration.zero;
    }
    return Duration(seconds: rem);
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
        final nextBill = result['nextBillAtSeconds'] as int?;
        if (nextBill != null) {
          _nextBillAtSeconds = nextBill;
        }
      });
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      _billingTimer?.cancel();
      if (e.message.contains('Insufficient') || e.message.contains('wallet')) {
        await _handleSessionEnded(message: e.message);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (_) {}
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    final interval = _isCallMode ? const Duration(seconds: 1) : const Duration(seconds: 3);
    _sessionTimer = Timer.periodic(interval, (_) => unawaited(_pollSessionState()));
  }

  Future<void> _pollSessionState() async {
    if (!mounted || _payload == null || _sessionEndedHandled) {
      return;
    }

    try {
      final payload = await _repo.getSession(widget.appointmentId);
      if (!mounted || _sessionEndedHandled) {
        return;
      }

      final peerJustJoined = payload.peerJoined && !_peerConnected;
      final wasActive = _payload?.session.isActive ?? false;

      setState(() {
        _payload = payload;
        _billedMinutes = payload.session.billedMinutes;
        if (payload.billing.isPerMinute) {
          _ratePerMinute = payload.billing.ratePerMinute;
          _walletBalance = payload.billing.walletBalance;
          _sessionCharged = payload.session.billedMinutes *
              (payload.billing.ratePerMinute ?? _ratePerMinute ?? 0);
          _nextBillAtSeconds = payload.billing.nextBillAtSeconds;
        }
      });
      _syncSessionClock(payload);

      if (!wasActive && payload.session.isActive) {
        _startElapsedTicker();
        _maybeStartPerMinuteBilling(payload);
      }

        if (peerJustJoined && _mediaProvider == ConsultationMediaProvider.agora) {
          setState(() {
            _peerConnected = true;
            _markCallConnected();
          });
        }

      if (payload.session.isEnded) {
        await _finishCallExperience(message: 'Session ended.');
      }
    } catch (_) {}
  }

  Future<void> _onPeerLeftChannel() async {
    if (!_isCallMode || _peerLeavePending || _sessionEndedHandled) {
      return;
    }
    _peerLeavePending = true;
    await Future<void>.delayed(const Duration(seconds: 2));
    _peerLeavePending = false;
    if (!mounted || _sessionEndedHandled || _remoteUid != null) {
      return;
    }

    try {
      final payload = await _repo.getSession(widget.appointmentId);
      if (payload.session.isEnded) {
        await _finishCallExperience(message: 'The other party ended the call.');
        return;
      }
    } catch (_) {}

    await _finishCallExperience(
      message: 'The other party disconnected.',
      endOnServer: true,
    );
  }

  void _markCallConnected() {
    _connectedSince ??= DateTime.now();
  }

  Duration _connectedDuration() {
    final start = _connectedSince ?? _sessionStartedLocal;
    if (start == null) {
      return Duration.zero;
    }
    return DateTime.now().difference(start);
  }

  Future<void> _syncBillingFromServer() async {
    try {
      final snap = await _repo.getSession(widget.appointmentId);
      if (!mounted) {
        return;
      }
      setState(() {
        _billedMinutes = snap.session.billedMinutes;
        if (snap.billing.isPerMinute) {
          _sessionCharged = snap.session.billedMinutes *
              (snap.billing.ratePerMinute ?? _ratePerMinute ?? 0);
          _walletBalance = snap.billing.walletBalance ?? _walletBalance;
        }
      });
    } catch (_) {}
  }

  Future<void> _finishCallExperience({
    String? message,
    bool endOnServer = false,
  }) async {
    await _handleSessionEnded(
      message: message,
      endOnServer: endOnServer,
      showSummary: _isCallMode,
    );
  }

  Future<void> _handleSessionEnded({
    String? message,
    bool endOnServer = false,
    bool showSummary = false,
  }) async {
    if (_sessionEndedHandled) {
      return;
    }
    _sessionEndedHandled = true;
    _sessionTimer?.cancel();
    _billingTimer?.cancel();
    _chatTimer?.cancel();
    _elapsedTicker?.cancel();

    final session = _payload?.session;
    if (endOnServer && session != null && !session.isEnded) {
      try {
        await _repo.endSession(session.id);
      } catch (_) {}
    }

    await _agora.disposeAll();
    await _syncBillingFromServer();
    if (!mounted) {
      return;
    }
    if (showSummary) {
      await _showCallSummaryDialog(note: message);
    } else {
      _showEndedDialog(
        message: message ?? 'Your consultation session has ended.',
      );
    }
  }

  Future<void> _showCallSummaryDialog({String? note}) async {
    final type = _consultationType;
    final label = type == 'video' ? 'Video call' : 'Audio call';
    final connected = _connectedDuration();
    final billing = _payload?.billing.isPerMinute == true;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '$label ended',
          style: AppTypography.inter(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _summaryRow('Time connected', _formatDurationLong(connected)),
            if (billing) ...[
              const SizedBox(height: 8),
              _summaryRow('Billed', '$_billedMinutes min'),
              _summaryRow(
                'Charged',
                '₹${_sessionCharged.toStringAsFixed(0)}',
              ),
            ],
            if (note != null && note.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                note,
                style: AppTypography.inter(color: Colors.white54, fontSize: 12),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _goToDashboard();
            },
            child: Text(
              'OK — Dashboard',
              style: AppTypography.inter(
                color: const Color(0xFFD4AF37),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.inter(color: Colors.white54, fontSize: 13),
            ),
          ),
          Text(
            value,
            style: AppTypography.inter(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDurationLong(Duration duration) {
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);
    final s = duration.inSeconds.remainder(60);
    if (h > 0) {
      return '${h}h ${m.toString().padLeft(2, '0')}m ${s.toString().padLeft(2, '0')}s';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _goToDashboard() {
    final route = widget.isLawyer ? LawyerRoutes.dashboard : UserRoutes.home;
    Navigator.of(context).pushNamedAndRemoveUntil(route, (_) => false);
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
        SnackBar(content: Text(_userFacingError(e))),
      );
    }
  }

  Future<void> _toggleSpeaker() async {
    final next = !_speakerOn;
    await _agora.setSpeakerphone(next);
    if (mounted) {
      setState(() => _speakerOn = next);
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

    final graceNote = _isCallMode && _payload?.billing.isPerMinute == true
        ? '\n\nCalls under 40 seconds are free. Partial minutes follow wallet rules.'
        : '';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_isCallMode ? 'End call?' : 'End consultation?'),
        content: Text(
          _isCallMode
              ? 'Disconnect ends the call for both sides.$graceNote'
              : 'This will close the session for both parties.',
        ),
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
      await _repo.endSession(session.id);
      _sessionEndedHandled = true;
      await _agora.disposeAll();
      await _syncBillingFromServer();
      if (!mounted) {
        return;
      }
      if (_isCallMode) {
        await _showCallSummaryDialog(note: 'You ended the call.');
      } else {
        _goToDashboard();
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
              _goToDashboard();
            },
            child: const Text('OK — Dashboard'),
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

  String get _liveLabel => 'Live';

  String get _chatLabel => 'Secure chat';

  static String _userFacingCallError(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return 'Call could not start. Please try again or contact support.';
    }
    final lower = raw.toLowerCase();
    if (lower.contains('microphone') ||
        lower.contains('camera') ||
        lower.contains('permission') ||
        lower.contains('settings')) {
      return raw;
    }
    if (lower.contains('timed out') || lower.contains('timeout')) {
      return 'Call connection timed out. Check internet and try again.';
    }
    if (lower.contains('invalid token') ||
        lower.contains('token expired') ||
        lower.contains('errinvalidtoken') ||
        lower.contains('errorcode -2') ||
        raw.contains('110')) {
      return 'Call could not connect. Server call settings may be wrong — contact support.';
    }
    if (lower.contains('agora') || lower.contains('webrtc')) {
      return 'Call could not connect. Please try again.';
    }
    return raw;
  }

  static String _userFacingError(Object error) {
    if (error is ApiException) {
      return _userFacingCallError(error.message);
    }
    final text = error.toString().replaceFirst(RegExp(r'^[^:]+:\s*'), '');
    return _userFacingCallError(text);
  }

  bool get _mediaConnected {
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
                  : _isCallMode
                      ? Column(
                          children: [
                            _buildHeader(),
                            _buildPremiumBillingCard(),
                            if (_consultationType == 'video')
                              Expanded(child: _buildVideoArea(expanded: true))
                            else
                              Expanded(child: _buildAudioPanel()),
                            _buildCallControlBar(),
                          ],
                        )
                      : Column(
                          children: [
                            _buildHeader(),
                            Expanded(child: _buildMessages()),
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
                  _isCallMode
                      ? appointment.typeLabel
                      : appointment.isPerMinuteBilling
                          ? '${appointment.typeLabel} · ₹${(appointment.ratePerMinute ?? _ratePerMinute ?? 0).toStringAsFixed(0)}/min'
                          : '${appointment.typeLabel} · ₹${appointment.amount.toStringAsFixed(0)}',
                  style: AppTypography.inter(color: Colors.white54, fontSize: 12),
                ),
                if (_isCallMode && session.isActive)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: _buildLiveBadge(),
                  )
                else
                  Text(
                    '$statusText${remaining != null && remaining.inSeconds > 0 ? ' · ${_formatDuration(remaining)} session left' : ''}',
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

  Widget _buildPremiumBillingCard() {
    final billing = _payload?.billing;
  final rate = _ratePerMinute ?? billing?.ratePerMinute ?? 0;
    if (billing == null || !billing.isPerMinute) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: _callTimerChip(),
      );
    }

    final until = _untilNextBill;
    final grace = billing.graceSeconds ?? 40;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A2210), Color(0xFF151515)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _callTimerChip()),
              if (sessionIsActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '₹${rate.toStringAsFixed(0)}/min',
                    style: AppTypography.inter(
                      color: const Color(0xFFD4AF37),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _billingStat('Billed', '$_billedMinutes min'),
              const SizedBox(width: 16),
              _billingStat('Charged', '₹${_sessionCharged.toStringAsFixed(0)}'),
              if (!widget.isLawyer && _walletBalance != null) ...[
                const SizedBox(width: 16),
                _billingStat('Wallet', '₹${_walletBalance!.toStringAsFixed(0)}'),
              ],
            ],
          ),
          if (sessionIsActive && _billedMinutes == 0 && _callElapsed.inSeconds < grace) ...[
            const SizedBox(height: 8),
            Text(
              'First ${grace}s free — disconnect before that costs nothing.',
              style: AppTypography.inter(color: Colors.white54, fontSize: 11),
            ),
          ],
          if (sessionIsActive && until != null && rate > 0) ...[
            const SizedBox(height: 6),
            Text(
              until.inSeconds <= 0
                  ? 'Checking next minute charge…'
                  : 'Next ₹${rate.toStringAsFixed(0)} charge in ${_formatDuration(until)}',
              style: AppTypography.inter(color: Colors.white38, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }

  bool get sessionIsActive => _payload?.session.isActive ?? false;

  Widget _callTimerChip() {
    final elapsed = _callElapsed;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.timer_outlined, color: Color(0xFFD4AF37), size: 18),
        const SizedBox(width: 6),
        Text(
          sessionIsActive
              ? _formatDuration(elapsed)
              : '00:00',
          style: AppTypography.inter(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildLiveBadge() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.55, end: 1).animate(_livePulseController),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF2A1515),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFF4D4D).withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFFF4D4D),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'LIVE',
              style: AppTypography.inter(
                color: const Color(0xFFFF6B6B),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _billingStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.inter(color: Colors.white38, fontSize: 10)),
        Text(
          value,
          style: AppTypography.inter(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildVideoArea({bool expanded = false}) {
    final engine = _agora.engine;
    if (engine == null) {
      return const SizedBox.shrink();
    }

    final borderColor =
        _mediaConnected ? const Color(0xFFD4AF37) : const Color(0xFF2A2A2A);

    final content = Stack(
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
                  color: const Color(0xFF0D0D0D),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Color(0xFFD4AF37),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Connecting to ${_peerLabel.split(' ').first}…',
                        style: AppTypography.inter(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 72,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.75),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        if (!_cameraOff)
          Positioned(
            right: 14,
            top: 14,
            width: 100,
            height: 136,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: engine,
                    canvas: const VideoCanvas(uid: 0),
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    if (expanded) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              if (_mediaConnected)
                BoxShadow(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.12),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: content,
          ),
        ),
      );
    }

    return SizedBox(height: 220, child: content);
  }

  Widget _buildAudioPanel() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      alignment: Alignment.center,
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
                ? 'Call connected'
                : 'Waiting for ${_peerLabel.split(' ').first}…',
            style: AppTypography.inter(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            sessionIsActive
                ? 'Secure voice call — use controls below'
                : 'Connecting…',
            style: AppTypography.inter(color: Colors.white38, fontSize: 12),
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
            if (_consultationType == 'video')
              _CallActionButton(
                icon: _cameraOff ? Icons.videocam_off_rounded : Icons.videocam_rounded,
                label: _cameraOff ? 'Camera' : 'Video',
                onTap: _toggleCamera,
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
