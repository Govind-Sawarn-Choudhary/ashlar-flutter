import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/consultation/consultation_models.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_marketplace_repository.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/lawyer_routes.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/auth/widgets/lawyer_login_glow_background.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/dashboard/widgets/lawyer_bottom_nav_bar.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/manage_appointments_typography.dart';
import 'dart:async';

import 'package:flutter/material.dart';

/// Manage Appointments — live bookings from API.
class LawyerManageAppointmentsScreen extends StatefulWidget {
  const LawyerManageAppointmentsScreen({super.key, this.embeddedInShell = false});

  final bool embeddedInShell;

  @override
  State<LawyerManageAppointmentsScreen> createState() =>
      _LawyerManageAppointmentsScreenState();
}

class _LawyerManageAppointmentsScreenState
    extends State<LawyerManageAppointmentsScreen> {
  List<Map<String, dynamic>> _appointments = [];
  bool _loading = true;
  String? _errorMessage;
  String? _statusFilter;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
    _refreshTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (mounted && !_loading) {
        _loadAppointments(quiet: true);
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAppointments({bool quiet = false}) async {
    if (!quiet) {
      setState(() {
        _loading = true;
        _errorMessage = null;
      });
    }

    try {
      final items = await LawyerMarketplaceRepository.instance.listAppointments(
        status: _statusFilter,
      );
      if (mounted) {
        setState(() {
          _appointments = items;
          _loading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMessage = e.message;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMessage = 'Could not load appointments';
        });
      }
    }
  }

  Future<void> _updateStatus(int id, String status) async {
    try {
      await LawyerMarketplaceRepository.instance.updateAppointmentStatus(id, status);
      await _loadAppointments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appointment $status')),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  void _joinConsultation(Map<String, dynamic> appt) {
    final type = appt['consultationType'] as String? ?? '';
    if (type == 'physical') {
      return;
    }

    Navigator.of(context).pushNamed(
      LawyerRoutes.consultation,
      arguments: ConsultationScreenArgs(
        appointmentId: appt['id'] as int,
        isLawyer: true,
        peerName: appt['userName'] as String?,
      ),
    );
  }

  String _formatScheduledAt(String? raw) {
    if (raw == null || raw.isEmpty) {
      return 'Date/time not set';
    }
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      return raw;
    }
    final local = parsed.toLocal();
    return '${local.day}/${local.month}/${local.year} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: false,
      background: const LawyerLoginGlowBackground(),
      body: FigmaScreenCanvas(
        builder: (context, s) {
          return SizedBox(
            width: s.viewportWidth,
            height: s.artboardHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: s.s(15),
                  top: s.s(95),
                  width: s.s(336),
                  bottom: widget.embeddedInShell
                      ? LawyerBottomNavBar.reservedBottomPadding(context, scale: s)
                      : 0,
                  child: _buildBody(s),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: s.s(54),
                  child: IgnorePointer(
                    child: Text(
                      'Manage Appointments',
                      textAlign: TextAlign.center,
                      style: ManageAppointmentsTypography.screenTitle(s),
                    ),
                  ),
                ),
                if (!widget.embeddedInShell)
                  Positioned(
                    left: s.s(8),
                    top: s.s(35),
                    width: s.s(56),
                    height: s.s(56),
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      behavior: HitTestBehavior.opaque,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: s.s(7)),
                          child: Image.asset(
                            AppAssets.walletBackButton,
                            width: s.s(40),
                            height: s.s(40),
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterBar(FigmaScale s) {
    Widget chip(String label, String? value) {
      final selected = _statusFilter == value;
      return Padding(
        padding: EdgeInsets.only(right: s.s(8)),
        child: FilterChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) {
            setState(() => _statusFilter = value);
            _loadAppointments();
          },
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          chip('All', null),
          chip('Pending', 'pending'),
          chip('Confirmed', 'confirmed'),
          chip('Completed', 'completed'),
          chip('Cancelled', 'cancelled'),
        ],
      ),
    );
  }

  Widget _buildBody(FigmaScale s) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: AppTypography.inter(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _loadAppointments,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFilterBar(s),
        SizedBox(height: s.s(8)),
        Expanded(
          child: _appointments.isEmpty
              ? Center(
                  child: Text(
                    'No appointments yet.\nBookings from users will appear here.',
                    textAlign: TextAlign.center,
                    style: AppTypography.inter(color: Colors.white70, fontSize: 14, height: 1.5),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadAppointments,
                  child: ListView.separated(
                    padding: EdgeInsets.only(bottom: s.s(24)),
                    itemCount: _appointments.length,
                    separatorBuilder: (_, __) => SizedBox(height: s.s(8)),
                    itemBuilder: (context, index) {
                      final appt = _appointments[index];
                      final status = appt['status'] as String? ?? 'pending';
                      final isPending = status == 'pending';
                      final isConfirmed = status == 'confirmed';
                      final consultationType = appt['consultationType'] as String? ?? '';
                      final isPhysical = consultationType == 'physical';
                      final canJoin = isConfirmed && !isPhysical;
                      final scheduledAt = appt['scheduledAt'] as String?;
                      final notes = appt['notes'] as String?;

                      return Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(s.s(12)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(s.s(10)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${appt['userName'] ?? appt['userPhone']} · $consultationType',
                              style: ManageAppointmentsTypography.slotTime(s),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${appt['amount']} · $status',
                              style: ManageAppointmentsTypography.slotTime(s),
                            ),
                            if (isPhysical) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Meeting: ${_formatScheduledAt(scheduledAt)}',
                                style: ManageAppointmentsTypography.slotTime(s),
                              ),
                            ],
                            if (notes != null && notes.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Notes: $notes',
                                style: ManageAppointmentsTypography.slotTime(s),
                              ),
                            ],
                            if (canJoin) ...[
                              SizedBox(height: s.s(8)),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => _joinConsultation(appt),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD4AF37),
                                    foregroundColor: Colors.black,
                                  ),
                                  child: Text(
                                    'Accept — ${consultationType == 'chat' ? 'Chat' : consultationType == 'video' ? 'Video' : 'Call'}',
                                  ),
                                ),
                              ),
                            ],
                            if (isPending) ...[
                              SizedBox(height: s.s(8)),
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () => _updateStatus(
                                      appt['id'] as int,
                                      'confirmed',
                                    ),
                                    child: const Text('Confirm'),
                                  ),
                                  TextButton(
                                    onPressed: () => _updateStatus(
                                      appt['id'] as int,
                                      'cancelled',
                                    ),
                                    child: const Text('Decline'),
                                  ),
                                ],
                              ),
                            ] else if (isConfirmed) ...[
                              SizedBox(height: s.s(8)),
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () => _updateStatus(
                                      appt['id'] as int,
                                      'completed',
                                    ),
                                    child: const Text('Mark complete'),
                                  ),
                                  if (!isPhysical)
                                    TextButton(
                                      onPressed: () => _updateStatus(
                                        appt['id'] as int,
                                        'cancelled',
                                      ),
                                      child: const Text('Cancel'),
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
