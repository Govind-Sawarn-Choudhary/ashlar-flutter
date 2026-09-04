import 'package:ashlar_lawyer_hub/core/auth/auth_session.dart';
import 'package:ashlar_lawyer_hub/core/config/api_config.dart';
import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_marketplace_repository.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_profile_helpers.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_profile_repository.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/models/lawyer_auth_response.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/lawyer_routes.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/auth/widgets/lawyer_login_glow_background.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/dashboard/widgets/lawyer_bottom_nav_bar.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/dashboard/widgets/lawyer_bottom_nav_hit_zones.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/dashboard/widgets/lawyer_dashboard_stat_card.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/dashboard/widgets/lawyer_hit_rate_card.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/lawyer_fee_and_charges_screen.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/lawyer_select_availability_screen.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/models/lawyer_consultation_fee_type.dart';
import 'package:flutter/material.dart';

/// Lawyer home dashboard with live stats, availability insights, and quick actions.
class LawyerDashboardScreen extends StatefulWidget {
  const LawyerDashboardScreen({super.key});

  @override
  State<LawyerDashboardScreen> createState() => _LawyerDashboardScreenState();
}

class _LawyerDashboardScreenState extends State<LawyerDashboardScreen> {
  LawyerAuthResponse? _profile;
  bool _loading = true;
  bool _refreshing = false;
  bool _navigating = false;
  double _earningsThisMonth = 0;
  int _callsThisMonth = 0;
  int _overallCalls = 0;
  int _missedLeads = 0;
  double _walletBalance = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() => _refreshing = true);
    } else {
      setState(() => _loading = true);
    }

    try {
      final response = await LawyerProfileRepository.instance.getMe();
      final stats =
          await LawyerMarketplaceRepository.instance.getDashboardStats();

      if (!mounted) {
        return;
      }

      setState(() {
        _profile = response;
        _earningsThisMonth = stats.earningsThisMonth;
        _callsThisMonth = stats.callsThisMonth;
        _overallCalls = stats.overallCalls;
        _missedLeads = stats.missedLeads;
        _walletBalance = stats.walletBalance;
      });

      if (!isRefresh) {
        await _maybeShowUnverifiedPopup(response);
      }
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _loadDashboard,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _refreshing = false;
        });
      }
    }
  }

  Future<void> _maybeShowUnverifiedPopup(LawyerAuthResponse response) async {
    if (response.lawyer.barEnrollmentVerified) {
      return;
    }
    if (response.lawyer.onboardingStep != 'complete') {
      return;
    }

    final userKey =
        response.userPhone ?? response.lawyer.barEnrollmentNumber ?? 'lawyer';
    if (!await AuthSession.instance.shouldShowLawyerUnverifiedPopup(userKey)) {
      return;
    }

    await AuthSession.instance.markLawyerUnverifiedPopupShown(userKey);

    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Profile not verified'),
        content: const Text('Profile not verified. Please contact admin.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _openRoute(
    BuildContext context,
    String route, {
    Object? arguments,
  }) async {
    if (_navigating) {
      return;
    }

    _navigating = true;
    try {
      await Navigator.of(context).pushNamed(route, arguments: arguments);
      if (mounted) {
        await _loadDashboard(isRefresh: true);
      }
    } finally {
      if (mounted) {
        setState(() => _navigating = false);
      }
    }
  }

  Future<void> _openScreen(Widget screen) async {
    if (_navigating || !mounted) {
      return;
    }

    _navigating = true;
    try {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => screen),
      );
      if (mounted) {
        await _loadDashboard(isRefresh: true);
      }
    } finally {
      if (mounted) {
        setState(() => _navigating = false);
      }
    }
  }

  void _onNavTap(BuildContext context, LawyerBottomNavTab tab) {
    switch (tab) {
      case LawyerBottomNavTab.home:
        break;
      case LawyerBottomNavTab.appointments:
        _openRoute(context, LawyerRoutes.manageAppointments);
      case LawyerBottomNavTab.chatHistory:
        _openRoute(context, LawyerRoutes.consultationHistory);
      case LawyerBottomNavTab.profile:
        _openRoute(context, LawyerRoutes.profile);
    }
  }

  String get _displayName {
    final lawyer = _profile?.lawyer;
    return lawyer?.fullName ?? lawyer?.barVerifiedName ?? 'Lawyer';
  }

  String get _location {
    final lawyer = _profile?.lawyer;
    if (lawyer == null) {
      return 'Location not set';
    }

    final candidates = [
      lawyer.location,
      lawyer.barVerifiedAddress,
      lawyer.barState,
      _profile?.fees
          .where((fee) => fee.feeType == 'physical')
          .map((fee) => fee.location)
          .firstWhere((value) => value?.trim().isNotEmpty == true,
              orElse: () => null),
    ];

    for (final candidate in candidates) {
      if (candidate?.trim().isNotEmpty == true) {
        final value = candidate!.trim().replaceAll(RegExp(r'\s+'), ' ');
        if (value.length <= 48) {
          return value;
        }
        return '${value.substring(0, 45)}...';
      }
    }

    return 'Location not set';
  }

  String? get _avatarUrl {
    final photo = _profile?.documents.firstWhere(
      (doc) => doc.docType == 'passport_photo',
      orElse: () => const LawyerDocumentSnapshot(
        docType: '',
        fileName: '',
        filePath: '',
      ),
    );
    if (photo == null || photo.filePath.trim().isEmpty) {
      return null;
    }
    if (photo.filePath.startsWith('http')) {
      return photo.filePath;
    }
    return '${ApiConfig.baseUrl}${photo.filePath}';
  }

  int get _availabilityPercent {
    final availability = _profile?.availability;
    if (availability == null) {
      return 0;
    }
    if (availability.isCustomSchedule) {
      return ((availability.daySchedules.length / 7) * 100).round().clamp(0, 100);
    }
    return ((availability.selectedDays.length / 7) * 100).round().clamp(0, 100);
  }

  String get _availabilitySubtitle {
    final availability = _profile?.availability;
    if (availability == null) {
      return 'Availability not set';
    }
    return LawyerProfileHelpers.formatSelectedDaysLabel(
      availability.selectedDays.toSet(),
    );
  }

  double get _weeklyAvailableHours {
    final availability = _profile?.availability;
    if (availability == null) {
      return 0;
    }

    if (availability.isCustomSchedule) {
      var total = 0.0;
      for (final schedule in availability.daySchedules) {
        final from = LawyerProfileHelpers.parseTimeLabel(schedule.fromTime);
        final to = LawyerProfileHelpers.parseTimeLabel(schedule.toTime);
        if (from != null && to != null) {
          total += (LawyerProfileHelpers.minutesFromMidnight(to) -
                  LawyerProfileHelpers.minutesFromMidnight(from)) /
              60;
        }
      }
      return total;
    }

    final from = LawyerProfileHelpers.parseTimeLabel(availability.fromTime);
    final to = LawyerProfileHelpers.parseTimeLabel(availability.toTime);
    if (from == null || to == null) {
      return 0;
    }

    final hoursPerDay = (LawyerProfileHelpers.minutesFromMidnight(to) -
            LawyerProfileHelpers.minutesFromMidnight(from)) /
        60;
    return hoursPerDay * availability.selectedDays.length;
  }

  List<String> get _missingSetupItems {
    final items = <String>[];
    final availability = _profile?.availability;
    final hasAvailability = availability != null &&
        ((availability.fromTime?.trim().isNotEmpty == true &&
                availability.toTime?.trim().isNotEmpty == true) ||
            availability.daySchedules.isNotEmpty);

    if (!hasAvailability) {
      items.add('Availability');
    }

    final feeTypes = _profile?.fees.map((fee) => fee.feeType).toSet() ?? {};
    for (final type in LawyerConsultationFeeType.all) {
      if (!feeTypes.contains(type.id)) {
        items.add('Consultation fees');
        break;
      }
    }

    return items;
  }

  String get _verificationLabel =>
      LawyerProfileHelpers.verificationLabel(_profile!.lawyer);

  Color get _verificationColor {
    final profile = _profile!.lawyer;
    if (profile.isApproved || profile.verificationStatus == 'approved') {
      return const Color(0xFF2E7D32);
    }
    if (profile.verificationStatus == 'rejected') {
      return const Color(0xFFE53935);
    }
    return AppColors.gold;
  }

  @override
  Widget build(BuildContext context) {
    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: false,
      background: const LawyerLoginGlowBackground(),
      body: FigmaScreenCanvas(
        builder: (context, s) {
          final bottomInset = MediaQuery.paddingOf(context).bottom;
          final navHeight = s.s(64) + bottomInset + s.s(24);

          if (_loading) {
            return SafeArea(
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.gold.withValues(alpha: 0.9),
                ),
              ),
            );
          }

          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned.fill(
                child: RefreshIndicator(
                  color: AppColors.gold,
                  onRefresh: () => _loadDashboard(isRefresh: true),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      s.s(16),
                      0,
                      s.s(16),
                      navHeight,
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _DashboardHeader(
                            scale: s,
                            displayName: _displayName,
                            location: _location,
                            avatarUrl: _avatarUrl,
                            walletBalance: _walletBalance,
                            onNotifications: () => _openRoute(
                              context,
                              LawyerRoutes.notifications,
                            ),
                            onWallet: () => _openRoute(
                              context,
                              LawyerRoutes.wallet,
                            ),
                          ),
                          if (_profile != null) ...[
                            SizedBox(height: s.s(12)),
                            _StatusChip(
                              label: _verificationLabel,
                              color: _verificationColor,
                            ),
                          ],
                          if (_missingSetupItems.isNotEmpty) ...[
                            SizedBox(height: s.s(12)),
                            _SetupBanner(
                              missingItems: _missingSetupItems,
                              onAvailability: () => _openScreen(
                                const LawyerSelectAvailabilityScreen(
                                  mode: LawyerSelectAvailabilityMode.update,
                                ),
                              ),
                              onFees: () => _openScreen(
                                const LawyerFeeAndChargesScreen(
                                  mode: LawyerFeeAndChargesMode.update,
                                ),
                              ),
                            ),
                          ],
                          SizedBox(height: s.s(16)),
                          Text(
                            'Overview',
                            style: AppTypography.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: s.fs(16),
                            ),
                          ),
                          SizedBox(height: s.s(10)),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: s.s(132),
                                  child: LawyerDashboardStatCard(
                                    scale: s,
                                    title: 'Earnings This Month',
                                    amount:
                                        '₹${_earningsThisMonth.toStringAsFixed(0)}',
                                    subtitle: 'Live wallet credits',
                                    accentColor: AppColors.gold,
                                    icon: Icons.account_balance_wallet_outlined,
                                  ),
                                ),
                              ),
                              SizedBox(width: s.s(10)),
                              Expanded(
                                child: SizedBox(
                                  height: s.s(132),
                                  child: LawyerDashboardStatCard(
                                    scale: s,
                                    title: 'Calls This Month',
                                    amount: '$_callsThisMonth',
                                    subtitle: 'Confirmed appointments',
                                    accentColor: const Color(0xFF1976D2),
                                    icon: Icons.phone_in_talk_outlined,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: s.s(10)),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: s.s(132),
                                  child: LawyerDashboardStatCard(
                                    scale: s,
                                    title: 'Overall Calls',
                                    amount: '$_overallCalls',
                                    subtitle: 'All-time bookings',
                                    accentColor: const Color(0xFF7B1FA2),
                                    icon: Icons.history_rounded,
                                  ),
                                ),
                              ),
                              SizedBox(width: s.s(10)),
                              Expanded(
                                child: SizedBox(
                                  height: s.s(132),
                                  child: LawyerDashboardStatCard(
                                    scale: s,
                                    title: 'Missed Leads',
                                    amount: '$_missedLeads',
                                    subtitle: 'Cancelled appointments',
                                    amountColor: const Color(0xFFE53935),
                                    accentColor: const Color(0xFFE53935),
                                    icon: Icons.call_missed_outgoing_rounded,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: s.s(16)),
                          Align(
                            alignment: Alignment.center,
                            child: LawyerHitRateCard(
                              scale: s,
                              availabilityPercent: _availabilityPercent,
                              availabilitySubtitle: _availabilitySubtitle,
                              activityValue:
                                  '${_weeklyAvailableHours.round()} Hrs',
                              activitySubtitle: 'Available hours/week',
                              activityProgress:
                                  (_weeklyAvailableHours / 40).clamp(0.0, 1.0),
                            ),
                          ),
                          SizedBox(height: s.s(16)),
                          _QuickActions(
                            scale: s,
                            onAppointments: () => _openRoute(
                              context,
                              LawyerRoutes.manageAppointments,
                            ),
                            onAvailability: () => _openScreen(
                              const LawyerSelectAvailabilityScreen(
                                mode: LawyerSelectAvailabilityMode.update,
                              ),
                            ),
                            onCharges: () => _openScreen(
                              const LawyerFeeAndChargesScreen(
                                mode: LawyerFeeAndChargesMode.update,
                              ),
                            ),
                          ),
                          if (_refreshing)
                            Padding(
                              padding: EdgeInsets.only(top: s.s(12)),
                              child: Center(
                                child: SizedBox(
                                  width: s.s(20),
                                  height: s.s(20),
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.gold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              LawyerBottomNavBar(
                scale: s,
                onTap: (tab) => _onNavTap(context, tab),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.scale,
    required this.displayName,
    required this.location,
    required this.avatarUrl,
    required this.walletBalance,
    required this.onNotifications,
    required this.onWallet,
  });

  final FigmaScale scale;
  final String displayName;
  final String location;
  final String? avatarUrl;
  final double walletBalance;
  final VoidCallback onNotifications;
  final VoidCallback onWallet;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Container(
      padding: EdgeInsets.all(s.s(14)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.gold.withValues(alpha: 0.18),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(s.s(16)),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(s.s(14)),
            child: avatarUrl != null
                ? Image.network(
                    avatarUrl!,
                    width: s.s(52),
                    height: s.s(52),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _AvatarFallback(scale: s),
                  )
                : _AvatarFallback(scale: s),
          ),
          SizedBox(width: s.s(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hey, $displayName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: s.fs(16),
                  ),
                ),
                SizedBox(height: s.s(4)),
                Row(
                  children: [
                    Image.asset(
                      AppAssets.dashboardLocationPin,
                      width: s.s(8),
                      height: s.s(10),
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: s.s(4)),
                    Expanded(
                      child: Text(
                        location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.inter(
                          color: Colors.white60,
                          fontSize: s.fs(11),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: s.s(6)),
                Text(
                  'Wallet · ₹${walletBalance.toStringAsFixed(0)}',
                  style: AppTypography.inter(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                    fontSize: s.fs(11),
                  ),
                ),
              ],
            ),
          ),
          _HeaderIconButton(
            scale: s,
            asset: AppAssets.dashboardNotificationIcon,
            onTap: onNotifications,
          ),
          SizedBox(width: s.s(6)),
          _HeaderIconButton(
            scale: s,
            asset: AppAssets.dashboardWalletIcon,
            onTap: onWallet,
          ),
        ],
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.scale});

  final FigmaScale scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: scale.s(52),
      height: scale.s(52),
      color: Colors.white.withValues(alpha: 0.08),
      child: Icon(
        Icons.person_rounded,
        color: AppColors.gold,
        size: scale.s(28),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.scale,
    required this.asset,
    required this.onTap,
  });

  final FigmaScale scale;
  final String asset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Material(
      color: Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(s.s(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(s.s(12)),
        child: SizedBox(
          width: s.s(36),
          height: s.s(36),
          child: Center(
            child: Image.asset(
              asset,
              width: s.s(18),
              height: s.s(18),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Text(
          label,
          style: AppTypography.inter(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

class _SetupBanner extends StatelessWidget {
  const _SetupBanner({
    required this.missingItems,
    required this.onAvailability,
    required this.onFees,
  });

  final List<String> missingItems;
  final VoidCallback onAvailability;
  final VoidCallback onFees;

  @override
  Widget build(BuildContext context) {
    final needsAvailability = missingItems.contains('Availability');
    final needsFees = missingItems.contains('Consultation fees');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_fix_high_rounded,
                  color: AppColors.gold, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Complete your profile',
                  style: AppTypography.inter(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Finish ${missingItems.join(' and ')} so clients can book you.',
            style: AppTypography.inter(
              color: Colors.white70,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (needsAvailability)
                _SetupActionChip(
                  label: 'Set availability',
                  onTap: onAvailability,
                ),
              if (needsFees)
                _SetupActionChip(
                  label: 'Add fees',
                  onTap: onFees,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SetupActionChip extends StatelessWidget {
  const _SetupActionChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.gold.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Text(
            label,
            style: AppTypography.inter(
              color: AppColors.gold,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.scale,
    required this.onAppointments,
    required this.onAvailability,
    required this.onCharges,
  });

  final FigmaScale scale;
  final VoidCallback onAppointments;
  final VoidCallback onAvailability;
  final VoidCallback onCharges;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick actions',
          style: AppTypography.inter(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: s.fs(16),
          ),
        ),
        SizedBox(height: s.s(10)),
        _QuickActionTile(
          icon: Icons.event_available_rounded,
          label: 'Manage appointments',
          subtitle: 'View and update bookings',
          color: const Color(0xFF1976D2),
          onTap: onAppointments,
        ),
        SizedBox(height: s.s(8)),
        _QuickActionTile(
          icon: Icons.schedule_rounded,
          label: 'Update availability',
          subtitle: 'Working days and consultation hours',
          color: const Color(0xFF7B1FA2),
          onTap: onAvailability,
        ),
        SizedBox(height: s.s(8)),
        _QuickActionTile(
          icon: Icons.payments_outlined,
          label: 'Update charges',
          subtitle: 'Chat, audio, video and in-person fees',
          color: AppColors.gold,
          onTap: onCharges,
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTypography.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTypography.inter(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
