import 'package:ashlar_lawyer_hub/core/auth/auth_session.dart';
import 'package:ashlar_lawyer_hub/core/config/api_config.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_marketplace_repository.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_profile_helpers.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_profile_repository.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/models/lawyer_auth_response.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/lawyer_routes.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/auth/widgets/lawyer_login_glow_background.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/dashboard/widgets/lawyer_bottom_nav_bar.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/dashboard/widgets/lawyer_bottom_nav_hit_zones.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/dashboard/widgets/lawyer_dashboard_premium_panel.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/dashboard/widgets/lawyer_shell_scope.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/lawyer_fee_and_charges_screen.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/lawyer_select_availability_screen.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/models/lawyer_consultation_fee_type.dart';
import 'package:flutter/material.dart';

/// Lawyer home dashboard with live stats, availability insights, and quick actions.
class LawyerDashboardScreen extends StatefulWidget {
  const LawyerDashboardScreen({super.key, this.embeddedInShell = false});

  final bool embeddedInShell;

  @override
  State<LawyerDashboardScreen> createState() => _LawyerDashboardScreenState();
}

class _LawyerDashboardScreenState extends State<LawyerDashboardScreen>
    with SingleTickerProviderStateMixin {
  LawyerAuthResponse? _profile;
  bool _loading = true;
  bool _refreshing = false;
  bool _navigating = false;
  double _earningsThisMonth = 0;
  int _callsThisMonth = 0;
  int _overallCalls = 0;
  int _missedLeads = 0;
  double _walletBalance = 0;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
    _loadDashboard();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
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
        _fadeController.forward(from: 0);
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

  void _openAppointments(BuildContext context) {
    if (widget.embeddedInShell) {
      LawyerShellScope.switchTo(context, LawyerBottomNavTab.appointments);
      return;
    }
    _openRoute(context, LawyerRoutes.manageAppointments);
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

  String get _firstName {
    final parts = _displayName.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? 'Counsel' : parts.first;
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: false,
      background: const LawyerLoginGlowBackground(),
      body: FigmaScreenCanvas(
        builder: (context, s) {
          final navHeight = widget.embeddedInShell
              ? LawyerBottomNavBar.reservedBottomPadding(context, scale: s)
              : s.s(16);

          return RefreshIndicator(
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
                child: _loading
                    ? LawyerDashboardLoadingSkeleton(scale: s)
                    : FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            LawyerDashboardTopBar(
                              scale: s,
                              onNotifications: () => _openRoute(
                                context,
                                LawyerRoutes.notifications,
                              ),
                              onWallet: () => _openRoute(
                                context,
                                LawyerRoutes.wallet,
                              ),
                            ),
                            SizedBox(height: s.s(16)),
                            if (_profile != null)
                              LawyerDashboardProfileCard(
                                scale: s,
                                greeting: _greeting,
                                displayName: _firstName,
                                location: _location,
                                avatarUrl: _avatarUrl,
                                statusLabel: _verificationLabel,
                                statusColor: _verificationColor,
                              ),
                            if (_missingSetupItems.isNotEmpty) ...[
                              SizedBox(height: s.s(16)),
                              LawyerDashboardSetupBanner(
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
                            LawyerDashboardEarningsHero(
                              scale: s,
                              earningsThisMonth: _earningsThisMonth,
                              walletBalance: _walletBalance,
                              onTap: () => _openRoute(
                                context,
                                LawyerRoutes.wallet,
                              ),
                            ),
                            SizedBox(height: s.s(16)),
                            LawyerDashboardOverviewPanel(
                              scale: s,
                              callsThisMonth: _callsThisMonth,
                              overallCalls: _overallCalls,
                              missedLeads: _missedLeads,
                              availabilityPercent: _availabilityPercent,
                              availabilityLabel: _availabilitySubtitle,
                              weeklyHours: _weeklyAvailableHours.round(),
                              hoursProgress:
                                  (_weeklyAvailableHours / 40).clamp(0.0, 1.0),
                            ),
                            SizedBox(height: s.s(16)),
                            if (_profile != null)
                              LawyerDashboardRatesPanel(
                                scale: s,
                                fees: _profile!.fees,
                                onTap: () => _openScreen(
                                  const LawyerFeeAndChargesScreen(
                                    mode: LawyerFeeAndChargesMode.update,
                                  ),
                                ),
                                onAddFees: () => _openScreen(
                                  const LawyerFeeAndChargesScreen(
                                    mode: LawyerFeeAndChargesMode.update,
                                  ),
                                ),
                              ),
                            SizedBox(height: s.s(16)),
                            LawyerDashboardActionsPanel(
                              scale: s,
                              onAppointments: () => _openAppointments(context),
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
                                padding: EdgeInsets.only(top: s.s(16)),
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
          );
        },
      ),
    );
  }
}
