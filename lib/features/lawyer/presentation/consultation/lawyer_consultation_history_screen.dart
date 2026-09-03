import 'package:ashlar_lawyer_hub/core/consultation/consultation_models.dart';
import 'package:ashlar_lawyer_hub/core/consultation/consultation_repository.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/lawyer_routes.dart';
import 'package:flutter/material.dart';

class LawyerConsultationHistoryScreen extends StatefulWidget {
  const LawyerConsultationHistoryScreen({super.key});

  @override
  State<LawyerConsultationHistoryScreen> createState() =>
      _LawyerConsultationHistoryScreenState();
}

class _LawyerConsultationHistoryScreenState
    extends State<LawyerConsultationHistoryScreen> {
  List<ConsultationAppointment> _appointments = [];
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final items = await ConsultationRepository.lawyer.listConsultations();
      if (!mounted) {
        return;
      }
      setState(() {
        _appointments = items;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _errorMessage = e.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _errorMessage = 'Could not load consultations';
      });
    }
  }

  void _openConsultation(ConsultationAppointment appointment) {
    Navigator.of(context).pushNamed(
      LawyerRoutes.consultation,
      arguments: ConsultationScreenArgs(
        appointmentId: appointment.id,
        isLawyer: true,
        peerName: appointment.userName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppDarkScaffold(
      showGlow: false,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Text(
                    'Chat & Call History',
                    style: AppTypography.inter(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_errorMessage!, style: const TextStyle(color: Colors.white70)),
                              TextButton(onPressed: _load, child: const Text('Retry')),
                            ],
                          ),
                        )
                      : _appointments.isEmpty
                          ? Center(
                              child: Text(
                                'No online consultations yet.',
                                style: AppTypography.inter(color: Colors.white54, fontSize: 14),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _load,
                              child: ListView.separated(
                                padding: const EdgeInsets.all(16),
                                itemCount: _appointments.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final item = _appointments[index];
                                  final canJoin = item.status == 'confirmed' ||
                                      item.status == 'completed';

                                  return ListTile(
                                    tileColor: const Color(0xFF151515),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    title: Text(
                                      '${item.userName ?? 'Client'} · ${item.typeLabel}',
                                      style: AppTypography.inter(color: Colors.white),
                                    ),
                                    subtitle: Text(
                                      '₹${item.amount.toStringAsFixed(0)} · ${item.durationMinutes} min · ${item.status}',
                                      style: AppTypography.inter(color: Colors.white54, fontSize: 12),
                                    ),
                                    trailing: canJoin
                                        ? const Icon(Icons.chevron_right, color: Color(0xFFD4AF37))
                                        : null,
                                    onTap: canJoin ? () => _openConsultation(item) : null,
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
