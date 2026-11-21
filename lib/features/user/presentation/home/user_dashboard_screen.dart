import 'package:ashlar_lawyer_hub/core/consultation/consultation_models.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/features/user/data/models/user_booking_context.dart';
import 'package:ashlar_lawyer_hub/features/user/data/models/user_marketplace_models.dart';
import 'package:ashlar_lawyer_hub/features/user/data/user_premium_repository.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/home/widgets/user_bottom_nav_bar.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/home/widgets/user_bottom_nav_hit_zones.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/widgets/user_design_tokens.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/widgets/user_premium_widgets.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/widgets/user_shell_scope.dart';
import 'package:ashlar_lawyer_hub/features/user/user_routes.dart';
import 'package:flutter/material.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key, this.embeddedInShell = false});

  final bool embeddedInShell;

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  UserDashboardData? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await loadUserDashboard();
      if (mounted) {
        setState(() {
          _data = data;
          _loading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.message;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Could not load dashboard';
        });
      }
    }
  }

  void _switchTab(UserBottomNavTab tab) {
    UserShellScope.maybeOf(context)?.switchTab(tab);
  }

  void _openLawyerBooking(UserLawyerSummary lawyer) {
    Navigator.of(context).pushNamed(
      UserRoutes.appointmentPreference,
      arguments: UserBookingContext(
        lawyerId: lawyer.id,
        lawyerName: lawyer.fullName,
        mode: 'online',
        consultationType: 'chat',
      ),
    );
  }

  void _openConsultation(ConsultationAppointment appt) {
    Navigator.of(context).pushNamed(
      UserRoutes.consultation,
      arguments: ConsultationScreenArgs(
        appointmentId: appt.id,
        isLawyer: false,
        peerName: appt.lawyerName,
      ),
    );
  }

  bool _canJoin(ConsultationAppointment item) {
    if (item.mode == 'offline' || item.consultationType == 'physical') {
      return false;
    }
    return item.status == 'confirmed' || item.status == 'completed';
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = widget.embeddedInShell
        ? UserBottomNavBar.reservedBottomPadding(context)
        : 16.0;

    return UserPremiumScaffold(
      bottomPadding: bottomPad,
      body: RefreshIndicator(
        color: UserDesignTokens.gold,
        onRefresh: _load,
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: UserDesignTokens.gold),
              )
            : _error != null
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.55,
                        child: UserEmptyState(
                          icon: Icons.cloud_off_outlined,
                          title: 'Could not load home',
                          subtitle: _error!,
                          actionLabel: 'Retry',
                          onAction: _load,
                        ),
                      ),
                    ],
                  )
                : ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 20),
                      _buildQuickActions(),
                      const SizedBox(height: 24),
                      if (_data!.featuredLawyers.isNotEmpty) ...[
                        UserSectionHeader(
                          title: 'Top lawyers for you',
                          actionLabel: 'See all',
                          onAction: () => _switchTab(UserBottomNavTab.lawyers),
                        ),
                        ..._data!.featuredLawyers.map(
                          (lawyer) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: UserLawyerCard(
                              lawyer: lawyer,
                              compact: true,
                              onTap: () => _openLawyerBooking(lawyer),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      UserSectionHeader(
                        title: 'Recent appointments',
                        actionLabel: 'View all',
                        onAction: () => Navigator.of(context)
                            .pushNamed(UserRoutes.myAppointments),
                      ),
                      if (_data!.recentAppointments.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: UserDesignTokens.premiumCard(),
                          child: Text(
                            'No appointments yet. Book a lawyer to get started.',
                            style: AppTypography.inter(
                              color: UserDesignTokens.textMuted,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        )
                      else
                        ..._data!.recentAppointments.map(_appointmentTile),
                      const SizedBox(height: 16),
                      UserSectionHeader(title: 'Legal services'),
                      Row(
                        children: [
                          Expanded(
                            child: _ServiceTile(
                              icon: Icons.description_outlined,
                              label: 'Documents',
                              onTap: () =>
                                  _switchTab(UserBottomNavTab.documents),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ServiceTile(
                              icon: Icons.directions_car_outlined,
                              label: 'Challan pay',
                              onTap: () => _switchTab(UserBottomNavTab.challan),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildHeader() {
    final name = _data?.userName?.trim();
    final greeting = name?.isNotEmpty == true ? 'Hello, $name' : 'Welcome back';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: AppTypography.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: UserDesignTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your legal help, one tap away',
                style: AppTypography.inter(
                  fontSize: 14,
                  color: UserDesignTokens.textMuted,
                ),
              ),
            ],
          ),
        ),
        UserWalletChip(
          balance: _data?.walletBalance ?? 0,
          onTap: () => Navigator.of(context).pushNamed(UserRoutes.wallet),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () =>
              Navigator.of(context).pushNamed(UserRoutes.notifications),
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_outlined,
                  color: UserDesignTokens.textPrimary),
              if ((_data?.unreadNotifications ?? 0) > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: UserDesignTokens.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.82,
      children: [
        UserQuickAction(
          icon: Icons.gavel_rounded,
          label: 'Find lawyer',
          onTap: () => _switchTab(UserBottomNavTab.lawyers),
        ),
        UserQuickAction(
          icon: Icons.calendar_month_outlined,
          label: 'Appointments',
          onTap: () => Navigator.of(context).pushNamed(UserRoutes.myAppointments),
        ),
        UserQuickAction(
          icon: Icons.account_balance_wallet_outlined,
          label: 'Wallet',
          onTap: () => Navigator.of(context).pushNamed(UserRoutes.wallet),
        ),
        UserQuickAction(
          icon: Icons.notifications_active_outlined,
          label: 'Alerts',
          badge: (_data?.unreadNotifications ?? 0) > 0
              ? '${_data!.unreadNotifications}'
              : null,
          onTap: () =>
              Navigator.of(context).pushNamed(UserRoutes.notifications),
        ),
      ],
    );
  }

  Widget _appointmentTile(ConsultationAppointment appt) {
    final canJoin = _canJoin(appt);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canJoin ? () => _openConsultation(appt) : null,
          borderRadius: BorderRadius.circular(UserDesignTokens.radiusMd),
          child: Ink(
            decoration: UserDesignTokens.premiumCard(),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${appt.lawyerName ?? 'Lawyer'} · ${appt.typeLabel}',
                        style: AppTypography.inter(
                          fontWeight: FontWeight.w600,
                          color: UserDesignTokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${appt.amount.toStringAsFixed(0)} · ${appt.status}',
                        style: AppTypography.inter(
                          fontSize: 12,
                          color: UserDesignTokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (canJoin)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: UserDesignTokens.goldSoft,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Join',
                      style: AppTypography.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: UserDesignTokens.gold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UserDesignTokens.radiusMd),
        child: Ink(
          decoration: UserDesignTokens.goldAccentCard(),
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 88,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: UserDesignTokens.gold, size: 28),
                Text(
                  label,
                  style: AppTypography.inter(
                    fontWeight: FontWeight.w700,
                    color: UserDesignTokens.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
