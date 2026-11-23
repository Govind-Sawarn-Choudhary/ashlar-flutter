import 'dart:async';

import 'package:ashlar_lawyer_hub/core/consultation/consultation_models.dart';
import 'package:ashlar_lawyer_hub/core/consultation/consultation_repository.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/lawyer_routes.dart';
import 'package:flutter/material.dart';

/// Polls for clients waiting in consultation and shows pick-up UI (Astrotalk-style).
class LawyerIncomingCallHost extends StatefulWidget {
  const LawyerIncomingCallHost({super.key, required this.child});

  final Widget child;

  @override
  State<LawyerIncomingCallHost> createState() => _LawyerIncomingCallHostState();
}

class _LawyerIncomingCallHostState extends State<LawyerIncomingCallHost>
    with WidgetsBindingObserver {
  Timer? _timer;
  bool _sheetOpen = false;
  final Set<int> _dismissedAppointmentIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => _pollIncoming());
    WidgetsBinding.instance.addPostFrameCallback((_) => _pollIncoming());
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _pollIncoming();
    }
  }

  Future<void> _pollIncoming() async {
    if (_sheetOpen || !mounted) {
      return;
    }
    try {
      final list = await ConsultationRepository.lawyer.listIncoming();
      if (!mounted || list.isEmpty) {
        return;
      }
      final pending = list
          .where((item) => !_dismissedAppointmentIds.contains(item.appointmentId))
          .toList();
      if (pending.isEmpty) {
        return;
      }
      final call = pending.first;
      await _showIncoming(call);
    } catch (_) {}
  }

  Future<void> _showIncoming(LawyerIncomingCall call) async {
    if (_sheetOpen || !mounted) {
      return;
    }
    setState(() => _sheetOpen = true);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: const Color(0xFF1A1A1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                call.consultationType == 'video'
                    ? Icons.videocam_rounded
                    : call.consultationType == 'chat'
                        ? Icons.chat_rounded
                        : Icons.call_rounded,
                color: AppColors.gold,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Incoming ${call.callLabel}',
                style: AppTypography.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                call.clientName,
                style: AppTypography.inter(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Client is waiting to connect',
                textAlign: TextAlign.center,
                style: AppTypography.inter(fontSize: 14, color: Colors.white54),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(this.context).pushNamed(
                      LawyerRoutes.consultation,
                      arguments: ConsultationScreenArgs(
                        appointmentId: call.appointmentId,
                        isLawyer: true,
                        peerName: call.clientName,
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Accept & join'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  _dismissedAppointmentIds.add(call.appointmentId);
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Not now',
                  style: AppTypography.inter(color: Colors.white54),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (mounted) {
      setState(() => _sheetOpen = false);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}