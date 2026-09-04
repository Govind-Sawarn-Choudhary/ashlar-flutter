import 'package:ashlar_lawyer_hub/core/consultation/consultation_models.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/features/user/data/user_repository.dart';
import 'package:ashlar_lawyer_hub/features/user/user_routes.dart';
import 'package:flutter/material.dart';

class UserMyAppointmentsScreen extends StatefulWidget {
  const UserMyAppointmentsScreen({super.key});

  @override
  State<UserMyAppointmentsScreen> createState() =>
      _UserMyAppointmentsScreenState();
}

class _UserMyAppointmentsScreenState extends State<UserMyAppointmentsScreen> {
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
      final items = await UserRepository.instance.listAppointments();
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
        _errorMessage = 'Could not load appointments';
      });
    }
  }

  bool _canJoin(ConsultationAppointment item) {
    if (item.mode == 'offline') {
      return false;
    }
    return item.status == 'confirmed' || item.status == 'completed';
  }

  void _openConsultation(ConsultationAppointment appointment) {
    Navigator.of(context).pushNamed(
      UserRoutes.consultation,
      arguments: ConsultationScreenArgs(
        appointmentId: appointment.id,
        isLawyer: false,
        peerName: appointment.lawyerName,
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
                    'My Appointments',
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
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white70),
                              ),
                              TextButton(
                                onPressed: _load,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _appointments.isEmpty
                          ? Center(
                              child: Text(
                                'No appointments yet.\nBook a lawyer to get started.',
                                textAlign: TextAlign.center,
                                style: AppTypography.inter(
                                  color: Colors.white54,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _load,
                              child: ListView.separated(
                                padding: const EdgeInsets.all(16),
                                itemCount: _appointments.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final item = _appointments[index];
                                  final canJoin = _canJoin(item);

                                  return ListTile(
                                    tileColor: const Color(0xFF151515),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    title: Text(
                                      '${item.lawyerName ?? 'Lawyer'} · ${item.typeLabel}',
                                      style: AppTypography.inter(
                                        color: Colors.white,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '₹${item.amount.toStringAsFixed(0)} · '
                                      '${item.durationMinutes} min · ${item.status}',
                                      style: AppTypography.inter(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                    ),
                                    trailing: canJoin
                                        ? const Icon(
                                            Icons.chevron_right,
                                            color: Color(0xFFD4AF37),
                                          )
                                        : null,
                                    onTap: canJoin
                                        ? () => _openConsultation(item)
                                        : null,
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
