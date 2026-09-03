import 'dart:math' as math;

import 'package:ashlar_lawyer_hub/core/auth/auth_session.dart';
import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_marketplace_repository.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_profile_repository.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/models/lawyer_auth_response.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/lawyer_routes.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/dashboard/widgets/lawyer_bottom_nav_bar.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/dashboard/widgets/lawyer_bottom_nav_hit_zones.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/dashboard/widgets/lawyer_dashboard_stat_card.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/dashboard/widgets/lawyer_hit_rate_card.dart';
import 'package:flutter/material.dart';

/// Lawyer dashboard — Figma [`7125:6669`](https://www.figma.com/design/lOlDO1Q7rirgmwIPUf9VMP/ashlarlawyerhub-To-Share?node-id=7125-6669) (360×800).
///
/// Built from positioned Flutter widgets (not full-screen PNG).
class LawyerDashboardScreen extends StatefulWidget {
  const LawyerDashboardScreen({super.key});

  @override
  State<LawyerDashboardScreen> createState() => _LawyerDashboardScreenState();
}

class _LawyerDashboardScreenState extends State<LawyerDashboardScreen> {
  LawyerAuthResponse? _profile;
  bool _navigating = false;
  double _earningsThisMonth = 0;
  int _callsThisMonth = 0;
  int _overallCalls = 0;
  int _missedLeads = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final response = await LawyerProfileRepository.instance.getMe();
      if (!mounted) {
        return;
      }

      final stats =
          await LawyerMarketplaceRepository.instance.getDashboardStats();
      if (mounted) {
        setState(() {
          _profile = response;
          _earningsThisMonth = stats.earningsThisMonth;
          _callsThisMonth = stats.callsThisMonth;
          _overallCalls = stats.overallCalls;
          _missedLeads = stats.missedLeads;
        });
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
            onPressed: _loadProfile,
          ),
        ),
      );
    }
  }

  Future<void> _maybeShowUnverifiedPopup(LawyerAuthResponse response) async {
    if (response.lawyer.barEnrollmentVerified) {
      return;
    }
    if (response.lawyer.onboardingStep != 'complete') {
      return;
    }

    final userKey = response.userPhone ?? response.lawyer.barEnrollmentNumber ?? 'lawyer';
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
        content: const Text(
          'Profile not verified. Please contact admin.',
        ),
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
        await _loadProfile();
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
          .firstWhere((value) => value?.trim().isNotEmpty == true, orElse: () => null),
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

  @override
  Widget build(BuildContext context) {
    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: false,
      background: const ColoredBox(color: Colors.black),
      body: FigmaScreenCanvas(
        builder: (context, s) {
          final canvasHeight = math.max(
            s.artboardHeight,
            MediaQuery.sizeOf(context).height - s.artboardTop,
          );

          return SizedBox(
            width: s.viewportWidth,
            height: canvasHeight,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                _DashboardHeader(
                  scale: s,
                  displayName: _displayName,
                  location: _location,
                  onNotifications: () =>
                      Navigator.of(context).pushNamed(LawyerRoutes.notifications),
                  onWallet: () =>
                      Navigator.of(context).pushNamed(LawyerRoutes.wallet),
                ),
                Positioned(
                  left: s.s(16),
                  top: s.s(108),
                  child: LawyerDashboardStatCard(
                    scale: s,
                    title: 'Earnings This Month',
                    amount: '₹${_earningsThisMonth.toStringAsFixed(0)}',
                    subtitle: 'Live from wallet credits',
                  ),
                ),
                Positioned(
                  left: s.s(199),
                  top: s.s(108),
                  child: LawyerDashboardStatCard(
                    scale: s,
                    title: 'Calls This Month',
                    amount: '$_callsThisMonth',
                    subtitle: 'Confirmed appointments',
                  ),
                ),
                Positioned(
                  left: s.s(16),
                  top: s.s(247),
                  child: LawyerDashboardStatCard(
                    scale: s,
                    title: 'Overall Calls',
                    amount: '$_overallCalls',
                    subtitle: 'All-time bookings',
                  ),
                ),
                Positioned(
                  left: s.s(199),
                  top: s.s(247),
                  child: LawyerDashboardStatCard(
                    scale: s,
                    title: 'Missed leads',
                    amount: '$_missedLeads',
                    amountColor: Color(0xFFE53935),
                    subtitle: 'Cancelled appointments',
                  ),
                ),
                Positioned(
                  left: s.s(31),
                  top: s.s(405),
                  child: LawyerHitRateCard(scale: s),
                ),
                LawyerBottomNavBar(
                  scale: s,
                  onTap: (tab) => _onNavTap(context, tab),
                ),
              ],
            ),
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
    required this.onNotifications,
    required this.onWallet,
  });

  final FigmaScale scale;
  final String displayName;
  final String location;
  final VoidCallback onNotifications;
  final VoidCallback onWallet;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: s.s(11),
          top: s.s(59),
          width: s.s(38),
          height: s.s(34),
          child: Image.asset(
            AppAssets.dashboardHeaderLogo,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
        Positioned(
          left: s.s(58),
          top: s.s(59),
          right: s.s(85),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hey, $displayName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: s.fs(16),
                  height: 1.2,
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
                        color: const Color(0xFF92929D),
                        fontWeight: FontWeight.w400,
                        fontSize: s.fs(11),
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          left: s.s(275),
          top: s.s(65),
          width: s.s(32),
          height: s.s(32),
          child: GestureDetector(
            onTap: onNotifications,
            behavior: HitTestBehavior.opaque,
            child: Center(
              child: Image.asset(
                AppAssets.dashboardNotificationIcon,
                width: s.s(19),
                height: s.s(18),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        Positioned(
          left: s.s(312),
          top: s.s(65),
          width: s.s(32),
          height: s.s(32),
          child: GestureDetector(
            onTap: onWallet,
            behavior: HitTestBehavior.opaque,
            child: Center(
              child: Image.asset(
                AppAssets.dashboardWalletIcon,
                width: s.s(18),
                height: s.s(19),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
