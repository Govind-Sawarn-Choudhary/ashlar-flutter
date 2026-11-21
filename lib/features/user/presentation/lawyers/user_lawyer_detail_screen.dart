import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/features/user/data/models/user_booking_context.dart';
import 'package:ashlar_lawyer_hub/features/user/data/models/user_marketplace_models.dart';
import 'package:ashlar_lawyer_hub/features/user/data/user_repository.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/lawyers/widgets/user_booking_flow_widgets.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/widgets/user_design_tokens.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/widgets/user_premium_widgets.dart';
import 'package:ashlar_lawyer_hub/features/user/user_routes.dart';
import 'package:flutter/material.dart';

class UserLawyerDetailScreen extends StatefulWidget {
  const UserLawyerDetailScreen({
    super.key,
    required this.bookingContext,
  });

  final UserBookingContext bookingContext;

  @override
  State<UserLawyerDetailScreen> createState() => _UserLawyerDetailScreenState();
}

class _UserLawyerDetailScreenState extends State<UserLawyerDetailScreen> {
  UserLawyerSummary? _lawyer;
  double? _amount;
  bool _loading = true;
  String? _loadError;
  DateTime? _meetingDate;
  TimeOfDay? _meetingTime;
  final _notesController = TextEditingController();

  bool get _isPhysical => widget.bookingContext.isPhysical;

  @override
  void initState() {
    super.initState();
    _loadLawyer();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadLawyer() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final lawyer =
          await UserRepository.instance.getLawyer(widget.bookingContext.lawyerId);
      if (!mounted) {
        return;
      }
      setState(() {
        _lawyer = lawyer;
        _amount = lawyer.feeAmountFor(widget.bookingContext.consultationType) ??
            widget.bookingContext.amount;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadError = e.message;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadError = 'Could not load lawyer details';
        });
      }
    }
  }

  Future<void> _toggleFavourite() async {
    if (_lawyer == null) {
      return;
    }
    try {
      final isFavourite =
          await UserRepository.instance.toggleFavourite(_lawyer!.id);
      if (mounted) {
        setState(() {
          _lawyer = UserLawyerSummary(
            id: _lawyer!.id,
            fullName: _lawyer!.fullName,
            practiceAreas: _lawyer!.practiceAreas,
            experienceYears: _lawyer!.experienceYears,
            location: _lawyer!.location,
            bio: _lawyer!.bio,
            isFavourite: isFavourite,
            fees: _lawyer!.fees,
          );
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  Future<void> _pickMeetingDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _meetingDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() => _meetingDate = picked);
    }
  }

  Future<void> _pickMeetingTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _meetingTime ?? const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked != null && mounted) {
      setState(() => _meetingTime = picked);
    }
  }

  String? _buildScheduledAtIso() {
    if (_meetingDate == null || _meetingTime == null) {
      return null;
    }
    final local = DateTime(
      _meetingDate!.year,
      _meetingDate!.month,
      _meetingDate!.day,
      _meetingTime!.hour,
      _meetingTime!.minute,
    );
    return local.toUtc().toIso8601String();
  }

  void _onContinue() {
    final amount = _amount ?? 0;
    if (_loadError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_loadError!)),
      );
      return;
    }
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Consultation fee is not available for this lawyer.'),
        ),
      );
      return;
    }
    if (_isPhysical && (_meetingDate == null || _meetingTime == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select meeting date and time')),
      );
      return;
    }

    Navigator.of(context).pushNamed(
      UserRoutes.bookingConfirm,
      arguments: widget.bookingContext.copyWith(
        amount: amount,
        scheduledAt: _isPhysical ? _buildScheduledAtIso() : null,
        notes: _isPhysical ? _notesController.text.trim() : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canContinue =
        !_loading && _loadError == null && (_amount ?? 0) > 0;

    return UserBookingScaffold(
      title: 'Lawyer details',
      subtitle: widget.bookingContext.lawyerName,
      bottomBar: UserBookingPrimaryButton(
        label: 'Continue to payment',
        enabled: canContinue,
        onPressed: _onContinue,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: UserDesignTokens.gold),
            )
          : _loadError != null
              ? UserEmptyState(
                  icon: Icons.error_outline,
                  title: 'Could not load lawyer',
                  subtitle: _loadError!,
                  actionLabel: 'Retry',
                  onAction: _loadLawyer,
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    _LawyerHeader(
                      lawyer: _lawyer!,
                      onFavourite: _toggleFavourite,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: UserDesignTokens.premiumCard(),
                      child: Column(
                        children: [
                          UserBookingSummaryRow(
                            label: 'Consultation',
                            value: consultationTypeLabel(
                              widget.bookingContext.consultationType,
                            ),
                          ),
                          const Divider(color: UserDesignTokens.cardBorder),
                          UserBookingSummaryRow(
                            label: 'Mode',
                            value: modeLabel(widget.bookingContext.mode),
                          ),
                          const Divider(color: UserDesignTokens.cardBorder),
                          UserBookingSummaryRow(
                            label: _isPhysical ? 'Fee' : 'Rate',
                            value: _isPhysical
                                ? '₹${(_amount ?? 0).toStringAsFixed(0)}'
                                : '₹${(_amount ?? 0).toStringAsFixed(0)} / min',
                            highlight: true,
                          ),
                        ],
                      ),
                    ),
                    if (_lawyer!.bio?.isNotEmpty == true) ...[
                      const SizedBox(height: 16),
                      UserSectionHeader(title: 'About'),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: UserDesignTokens.premiumCard(),
                        child: Text(
                          _lawyer!.bio!,
                          style: AppTypography.inter(
                            fontSize: 14,
                            height: 1.5,
                            color: UserDesignTokens.textSecondary,
                          ),
                        ),
                      ),
                    ],
                    if (_isPhysical) ...[
                      const SizedBox(height: 16),
                      UserSectionHeader(title: 'Meeting schedule'),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: UserDesignTokens.premiumCard(),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _pickMeetingDate,
                                    icon: const Icon(Icons.calendar_today_outlined,
                                        size: 18),
                                    label: Text(
                                      _meetingDate == null
                                          ? 'Select date'
                                          : '${_meetingDate!.day}/${_meetingDate!.month}/${_meetingDate!.year}',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _pickMeetingTime,
                                    icon: const Icon(Icons.access_time, size: 18),
                                    label: Text(
                                      _meetingTime == null
                                          ? 'Select time'
                                          : _meetingTime!.format(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _notesController,
                              maxLines: 3,
                              style: AppTypography.inter(
                                color: UserDesignTokens.textPrimary,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Notes (optional)',
                                labelStyle: AppTypography.inter(
                                  color: UserDesignTokens.textMuted,
                                ),
                                filled: true,
                                fillColor: UserDesignTokens.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
    );
  }
}

class _LawyerHeader extends StatelessWidget {
  const _LawyerHeader({
    required this.lawyer,
    required this.onFavourite,
  });

  final UserLawyerSummary lawyer;
  final VoidCallback onFavourite;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: UserDesignTokens.goldAccentCard(),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: UserDesignTokens.goldGradient,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(
                lawyer.fullName.isNotEmpty ? lawyer.fullName[0].toUpperCase() : 'L',
                style: AppTypography.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lawyer.fullName,
                  style: AppTypography.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: UserDesignTokens.textPrimary,
                  ),
                ),
                if (lawyer.practiceAreas?.isNotEmpty == true)
                  Text(
                    lawyer.practiceAreas!,
                    style: AppTypography.inter(
                      fontSize: 13,
                      color: UserDesignTokens.gold,
                    ),
                  ),
                if (lawyer.location?.isNotEmpty == true)
                  Text(
                    lawyer.location!,
                    style: AppTypography.inter(
                      fontSize: 12,
                      color: UserDesignTokens.textMuted,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: onFavourite,
            icon: Icon(
              lawyer.isFavourite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: lawyer.isFavourite
                  ? UserDesignTokens.gold
                  : UserDesignTokens.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
