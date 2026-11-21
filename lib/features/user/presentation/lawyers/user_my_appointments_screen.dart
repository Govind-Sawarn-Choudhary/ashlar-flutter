import 'package:ashlar_lawyer_hub/core/consultation/consultation_models.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_messenger.dart';
import 'package:ashlar_lawyer_hub/features/user/data/user_repository.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/widgets/user_design_tokens.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/widgets/user_premium_widgets.dart';
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
  String? _statusFilter;

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
      final items = await UserRepository.instance.listAppointments(
        status: _statusFilter,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _appointments = items;
        _loading = false;
      });
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

  bool _canJoin(ConsultationAppointment item) {
    if (item.mode == 'offline' || item.consultationType == 'physical') {
      return false;
    }
    return item.status == 'confirmed' || item.status == 'completed';
  }

  String _statusLabel(String status) => switch (status) {
        'pending' => 'Awaiting lawyer',
        'confirmed' => 'Confirmed',
        'completed' => 'Completed',
        'cancelled' => 'Cancelled',
        _ => status,
      };

  Color _statusColor(String status) => switch (status) {
        'pending' => UserDesignTokens.gold,
        'confirmed' => UserDesignTokens.success,
        'cancelled' => UserDesignTokens.error,
        _ => UserDesignTokens.textMuted,
      };

  bool _canCancel(ConsultationAppointment item) {
    return item.status == 'pending' || item.status == 'confirmed';
  }

  Future<void> _cancelAppointment(ConsultationAppointment item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: UserDesignTokens.surfaceElevated,
        title: const Text(
          'Cancel appointment?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          item.status == 'pending'
              ? 'Your meeting request will be cancelled and the amount refunded to your wallet.'
              : 'This appointment will be cancelled and refunded to your wallet.',
          style: const TextStyle(color: Colors.white70, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Cancel booking',
              style: TextStyle(color: UserDesignTokens.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      await UserRepository.instance.cancelAppointment(item.id);
      if (mounted) {
        AppMessenger.show(
          context,
          'Appointment cancelled. Refund added to wallet.',
          type: AppMessageType.success,
        );
        await _load();
      }
    } on ApiException catch (e) {
      if (mounted) {
        AppMessenger.show(context, e.message, type: AppMessageType.error);
      }
    }
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
    return UserPremiumScaffold(
      appBar: UserPremiumAppBar(
        title: 'My appointments',
        subtitle: 'Track and join consultations',
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: UserDesignTokens.textPrimary),
        ),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Row(
              children: [
                for (final filter in [null, 'pending', 'confirmed', 'completed'])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter ?? 'All'),
                      selected: _statusFilter == filter,
                      onSelected: (_) {
                        setState(() => _statusFilter = filter);
                        _load();
                      },
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: UserDesignTokens.gold),
                  )
                : _errorMessage != null
                    ? UserEmptyState(
                        icon: Icons.error_outline,
                        title: 'Could not load',
                        subtitle: _errorMessage!,
                        actionLabel: 'Retry',
                        onAction: _load,
                      )
                    : _appointments.isEmpty
                        ? UserEmptyState(
                            icon: Icons.calendar_month_outlined,
                            title: 'No appointments yet',
                            subtitle:
                                'Book a lawyer from the home screen to get started.',
                            actionLabel: 'Find lawyers',
                            onAction: () => Navigator.of(context)
                                .pushReplacementNamed(UserRoutes.home),
                          )
                        : RefreshIndicator(
                            color: UserDesignTokens.gold,
                            onRefresh: _load,
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                              itemCount: _appointments.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final item = _appointments[index];
                                final canJoin = _canJoin(item);
                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap:
                                        canJoin ? () => _openConsultation(item) : null,
                                    borderRadius: BorderRadius.circular(
                                      UserDesignTokens.radiusMd,
                                    ),
                                    child: Ink(
                                      decoration: UserDesignTokens.premiumCard(),
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '${item.lawyerName ?? 'Lawyer'} · ${item.typeLabel}',
                                                  style: AppTypography.inter(
                                                    fontWeight: FontWeight.w700,
                                                    color: UserDesignTokens
                                                        .textPrimary,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: _statusColor(item.status)
                                                      .withValues(alpha: 0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  _statusLabel(item.status),
                                                  style: AppTypography.inter(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        _statusColor(item.status),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            item.isPerMinuteBilling
                                                ? '₹${(item.ratePerMinute ?? item.amount).toStringAsFixed(0)}/min · up to ${item.durationMinutes} min'
                                                : '₹${item.amount.toStringAsFixed(0)}'
                                                    '${item.mode == 'offline' ? ' · In-person' : ' · ${item.durationMinutes} min'}',
                                            style: AppTypography.inter(
                                              fontSize: 13,
                                              color: UserDesignTokens.textMuted,
                                            ),
                                          ),
                                          if (item.scheduledAt?.isNotEmpty ==
                                              true) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              'Meeting: ${item.scheduledAt}',
                                              style: AppTypography.inter(
                                                fontSize: 12,
                                                color: UserDesignTokens.gold,
                                              ),
                                            ),
                                          ],
                                          const SizedBox(height: 12),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              if (_canCancel(item))
                                                TextButton(
                                                  onPressed: () =>
                                                      _cancelAppointment(item),
                                                  child: Text(
                                                    'Cancel',
                                                    style: AppTypography.inter(
                                                      color: UserDesignTokens
                                                          .error,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              if (canJoin)
                                                FilledButton(
                                                  onPressed: () =>
                                                      _openConsultation(item),
                                                  style: FilledButton.styleFrom(
                                                    backgroundColor:
                                                        UserDesignTokens.gold,
                                                    foregroundColor:
                                                        Colors.black,
                                                  ),
                                                  child: const Text('Join now'),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
