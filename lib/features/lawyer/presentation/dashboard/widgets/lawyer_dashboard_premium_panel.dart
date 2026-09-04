import 'package:ashlar_lawyer_hub/core/constants/app_assets.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/models/lawyer_auth_response.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/dashboard/widgets/lawyer_dashboard_design_tokens.dart';
import 'package:flutter/material.dart';

class LawyerDashboardTopBar extends StatelessWidget {
  const LawyerDashboardTopBar({
    super.key,
    required this.scale,
    required this.onNotifications,
    required this.onWallet,
  });

  final FigmaScale scale;
  final VoidCallback onNotifications;
  final VoidCallback onWallet;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Row(
      children: [
        Image.asset(
          AppAssets.dashboardHeaderLogo,
          width: s.s(34),
          height: s.s(30),
          fit: BoxFit.contain,
        ),
        SizedBox(width: s.s(8)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ashlar Lawyer Hub',
                style: AppTypography.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: s.fs(15),
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                'Practice dashboard',
                style: AppTypography.inter(
                  color: Colors.white54,
                  fontSize: s.fs(10),
                ),
              ),
            ],
          ),
        ),
        _IconCircleButton(
          scale: s,
          icon: Icons.notifications_none_rounded,
          onTap: onNotifications,
        ),
        SizedBox(width: s.s(8)),
        _IconCircleButton(
          scale: s,
          icon: Icons.account_balance_wallet_outlined,
          onTap: onWallet,
        ),
      ],
    );
  }
}

class LawyerDashboardProfileCard extends StatelessWidget {
  const LawyerDashboardProfileCard({
    super.key,
    required this.scale,
    required this.greeting,
    required this.displayName,
    required this.location,
    required this.avatarUrl,
    required this.statusLabel,
    required this.statusColor,
  });

  final FigmaScale scale;
  final String greeting;
  final String displayName;
  final String location;
  final String? avatarUrl;
  final String statusLabel;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Container(
      padding: EdgeInsets.all(s.s(16)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.12),
            AppColors.gold.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(s.s(LawyerDashboardTokens.radiusLg)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AvatarRing(scale: s, url: avatarUrl),
          SizedBox(width: s.s(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: AppTypography.inter(
                    color: Colors.white60,
                    fontSize: s.fs(11),
                  ),
                ),
                SizedBox(height: s.s(2)),
                Text(
                  'Adv. $displayName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: s.fs(18),
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: s.s(6)),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: s.s(12),
                      color: AppColors.gold.withValues(alpha: 0.9),
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
                SizedBox(height: s.s(8)),
                _StatusPill(label: statusLabel, color: statusColor),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LawyerDashboardEarningsHero extends StatelessWidget {
  const LawyerDashboardEarningsHero({
    super.key,
    required this.scale,
    required this.earningsThisMonth,
    required this.walletBalance,
    required this.onTap,
  });

  final FigmaScale scale;
  final double earningsThisMonth;
  final double walletBalance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final isEmpty = earningsThisMonth <= 0 && walletBalance <= 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(s.s(LawyerDashboardTokens.radiusLg)),
        child: Ink(
          padding: EdgeInsets.all(s.s(20)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(s.s(LawyerDashboardTokens.radiusLg)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFD4AF37),
                AppColors.gold,
                const Color(0xFF8B5E14),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EARNINGS THIS MONTH',
                      style: AppTypography.inter(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w700,
                        fontSize: s.fs(9),
                        letterSpacing: 1.1,
                      ),
                    ),
                    SizedBox(height: s.s(8)),
                    Text(
                      isEmpty ? '₹0' : '₹${earningsThisMonth.toStringAsFixed(0)}',
                      style: AppTypography.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: s.fs(34),
                        letterSpacing: -0.8,
                        height: 1,
                      ),
                    ),
                    SizedBox(height: s.s(8)),
                    Text(
                      isEmpty
                          ? 'Complete your profile to start earning'
                          : 'Wallet balance · ₹${walletBalance.toStringAsFixed(0)}',
                      style: AppTypography.inter(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: s.fs(12),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(s.s(12)),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(s.s(14)),
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: s.s(22),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LawyerDashboardOverviewPanel extends StatelessWidget {
  const LawyerDashboardOverviewPanel({
    super.key,
    required this.scale,
    required this.callsThisMonth,
    required this.overallCalls,
    required this.missedLeads,
    required this.availabilityPercent,
    required this.availabilityLabel,
    required this.weeklyHours,
    required this.hoursProgress,
  });

  final FigmaScale scale;
  final int callsThisMonth;
  final int overallCalls;
  final int missedLeads;
  final int availabilityPercent;
  final String availabilityLabel;
  final int weeklyHours;
  final double hoursProgress;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Container(
      decoration: LawyerDashboardTokens.surfaceDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PanelHeader(
            scale: s,
            icon: Icons.insights_rounded,
            title: 'Practice at a glance',
            subtitle: 'Live booking and availability metrics',
          ),
          _MetricGrid(
            scale: s,
            callsThisMonth: callsThisMonth,
            overallCalls: overallCalls,
            missedLeads: missedLeads,
            availabilityPercent: availabilityPercent,
          ),
          const Divider(height: 1, color: LawyerDashboardTokens.surfaceBorder),
          Padding(
            padding: EdgeInsets.all(s.s(16)),
            child: Row(
              children: [
                _RingMetric(
                  scale: s,
                  progress: hoursProgress.clamp(0.05, 1.0),
                  color: const Color(0xFF00897B),
                  icon: Icons.schedule_rounded,
                  value: '$weeklyHours hrs',
                  label: 'Weekly capacity',
                ),
                SizedBox(width: s.s(16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        availabilityLabel,
                        style: AppTypography.inter(
                          color: LawyerDashboardTokens.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: s.fs(13),
                        ),
                      ),
                      SizedBox(height: s.s(4)),
                      Text(
                        '$availabilityPercent% of week covered',
                        style: AppTypography.inter(
                          color: LawyerDashboardTokens.textSecondary,
                          fontSize: s.fs(11),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LawyerDashboardRatesPanel extends StatelessWidget {
  const LawyerDashboardRatesPanel({
    super.key,
    required this.scale,
    required this.fees,
    required this.onTap,
    required this.onAddFees,
  });

  final FigmaScale scale;
  final List<LawyerFeeSnapshot> fees;
  final VoidCallback onTap;
  final VoidCallback onAddFees;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final configured =
        fees.where((f) => f.amount.trim().isNotEmpty).toList();

    return Container(
      decoration: LawyerDashboardTokens.surfaceDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PanelHeader(
            scale: s,
            icon: Icons.payments_outlined,
            title: 'Consultation rates',
            subtitle: configured.isEmpty
                ? 'Set fees so clients can book you'
                : 'What clients see when booking',
            trailing: IconButton(
              onPressed: onTap,
              icon: Icon(Icons.chevron_right_rounded, color: AppColors.gold),
            ),
          ),
          if (configured.isEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(s.s(16), 0, s.s(16), s.s(16)),
              child: _EmptyRatesCta(scale: s, onTap: onAddFees),
            )
          else
            SizedBox(
              height: s.s(96),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.fromLTRB(s.s(16), 0, s.s(16), s.s(16)),
                itemCount: configured.length,
                separatorBuilder: (_, __) => SizedBox(width: s.s(8)),
                itemBuilder: (context, index) {
                  final fee = configured[index];
                  return _RateChip(scale: s, fee: fee);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class LawyerDashboardActionsPanel extends StatelessWidget {
  const LawyerDashboardActionsPanel({
    super.key,
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

    return Container(
      decoration: LawyerDashboardTokens.surfaceDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PanelHeader(
            scale: s,
            icon: Icons.bolt_rounded,
            title: 'Quick actions',
            subtitle: 'Manage your practice in one tap',
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(s.s(12), 0, s.s(12), s.s(12)),
            child: Row(
              children: [
                Expanded(
                  child: _ActionTile(
                    icon: Icons.event_available_rounded,
                    label: 'Bookings',
                    color: const Color(0xFF1976D2),
                    onTap: onAppointments,
                  ),
                ),
                SizedBox(width: s.s(8)),
                Expanded(
                  child: _ActionTile(
                    icon: Icons.schedule_rounded,
                    label: 'Hours',
                    color: const Color(0xFF7B1FA2),
                    onTap: onAvailability,
                  ),
                ),
                SizedBox(width: s.s(8)),
                Expanded(
                  child: _ActionTile(
                    icon: Icons.payments_outlined,
                    label: 'Fees',
                    color: AppColors.gold,
                    onTap: onCharges,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LawyerDashboardSetupBanner extends StatelessWidget {
  const LawyerDashboardSetupBanner({
    super.key,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(LawyerDashboardTokens.radiusMd),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.rocket_launch_rounded,
                  color: AppColors.gold, size: 18),
              const SizedBox(width: 8),
              Text(
                'Almost ready for clients',
                style: AppTypography.inter(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Complete ${missingItems.join(' and ')} to appear in client search.',
            style: AppTypography.inter(
              color: Colors.white70,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              if (needsAvailability)
                _BannerChip(label: 'Set availability', onTap: onAvailability),
              if (needsFees)
                _BannerChip(label: 'Add fees', onTap: onFees),
            ],
          ),
        ],
      ),
    );
  }
}

class LawyerDashboardLoadingSkeleton extends StatefulWidget {
  const LawyerDashboardLoadingSkeleton({super.key, required this.scale});

  final FigmaScale scale;

  @override
  State<LawyerDashboardLoadingSkeleton> createState() =>
      _LawyerDashboardLoadingSkeletonState();
}

class _LawyerDashboardLoadingSkeletonState
    extends State<LawyerDashboardLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: 0.35 + _controller.value * 0.25,
          child: child,
        );
      },
      child: Column(
        children: [
          _SkBlock(s, height: 44),
          SizedBox(height: s.s(16)),
          _SkBlock(s, height: 100),
          SizedBox(height: s.s(16)),
          _SkBlock(s, height: 120),
          SizedBox(height: s.s(16)),
          _SkBlock(s, height: 220),
        ],
      ),
    );
  }
}

class _SkBlock extends StatelessWidget {
  const _SkBlock(this.scale, {required this.height});

  final FigmaScale scale;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class _IconCircleButton extends StatelessWidget {
  const _IconCircleButton({
    required this.scale,
    required this.icon,
    required this.onTap,
  });

  final FigmaScale scale;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = scale.s(40);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: LawyerDashboardTokens.textPrimary,
            size: scale.s(20),
          ),
        ),
      ),
    );
  }
}

class _AvatarRing extends StatelessWidget {
  const _AvatarRing({required this.scale, required this.url});

  final FigmaScale scale;
  final String? url;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final size = s.s(58);

    return Container(
      padding: EdgeInsets.all(s.s(2.5)),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.gold, AppColors.goldLight.withValues(alpha: 0.8)],
        ),
      ),
      child: ClipOval(
        child: url != null
            ? Image.network(
                url!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _AvatarFallback(size: size),
              )
            : _AvatarFallback(size: size),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: const Color(0xFF1A1A2E),
      child: Icon(Icons.person_rounded, color: AppColors.gold, size: size * 0.5),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.inter(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({
    required this.scale,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final FigmaScale scale;
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Padding(
      padding: EdgeInsets.fromLTRB(s.s(16), s.s(16), s.s(8), s.s(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: s.s(36),
            height: s.s(36),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(s.s(10)),
            ),
            child: Icon(icon, color: AppColors.gold, size: s.s(18)),
          ),
          SizedBox(width: s.s(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.inter(
                    color: LawyerDashboardTokens.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: s.fs(14),
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.inter(
                    color: LawyerDashboardTokens.textSecondary,
                    fontSize: s.fs(10),
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({
    required this.scale,
    required this.callsThisMonth,
    required this.overallCalls,
    required this.missedLeads,
    required this.availabilityPercent,
  });

  final FigmaScale scale;
  final int callsThisMonth;
  final int overallCalls;
  final int missedLeads;
  final int availabilityPercent;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: _MetricCell(
                  scale: s,
                  icon: Icons.phone_in_talk_outlined,
                  color: const Color(0xFF1976D2),
                  value: '$callsThisMonth',
                  label: 'Calls\nthis month',
                  emptyHint: callsThisMonth == 0 ? 'No bookings yet' : null,
                ),
              ),
              const _GridDivider(),
              Expanded(
                child: _MetricCell(
                  scale: s,
                  icon: Icons.history_rounded,
                  color: const Color(0xFF7B1FA2),
                  value: '$overallCalls',
                  label: 'Overall\ncalls',
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: LawyerDashboardTokens.surfaceBorder),
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: _MetricCell(
                  scale: s,
                  icon: Icons.call_missed_outgoing_rounded,
                  color: const Color(0xFFE53935),
                  value: '$missedLeads',
                  label: 'Missed\nleads',
                ),
              ),
              const _GridDivider(),
              Expanded(
                child: _MetricCell(
                  scale: s,
                  icon: Icons.track_changes_rounded,
                  color: const Color(0xFF00897B),
                  value: '$availabilityPercent%',
                  label: 'Week\navailability',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GridDivider extends StatelessWidget {
  const _GridDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(vertical: 12),
      color: LawyerDashboardTokens.surfaceBorder,
    );
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({
    required this.scale,
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    this.emptyHint,
  });

  final FigmaScale scale;
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final String? emptyHint;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Padding(
      padding: EdgeInsets.fromLTRB(s.s(16), s.s(4), s.s(12), s.s(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: s.s(28),
            height: s.s(28),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: s.s(15)),
          ),
          SizedBox(height: s.s(10)),
          Text(
            value,
            style: AppTypography.inter(
              color: LawyerDashboardTokens.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: s.fs(22),
              letterSpacing: -0.4,
            ),
          ),
          SizedBox(height: s.s(2)),
          Text(
            label,
            style: AppTypography.inter(
              color: LawyerDashboardTokens.textSecondary,
              fontSize: s.fs(10),
              height: 1.25,
            ),
          ),
          if (emptyHint != null) ...[
            SizedBox(height: s.s(4)),
            Text(
              emptyHint!,
              style: AppTypography.inter(
                color: color.withValues(alpha: 0.85),
                fontSize: s.fs(9),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RingMetric extends StatelessWidget {
  const _RingMetric({
    required this.scale,
    required this.progress,
    required this.color,
    required this.icon,
    required this.value,
    required this.label,
  });

  final FigmaScale scale;
  final double progress;
  final Color color;
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final size = s.s(48);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: s.s(4),
            strokeCap: StrokeCap.round,
            backgroundColor: color.withValues(alpha: 0.12),
            color: color,
          ),
          Icon(icon, color: color, size: s.s(18)),
        ],
      ),
    );
  }
}

class _RateChip extends StatelessWidget {
  const _RateChip({required this.scale, required this.fee});

  final FigmaScale scale;
  final LawyerFeeSnapshot fee;

  static String _label(String type) => switch (type) {
        'chat' => 'Chat',
        'audio' => 'Audio',
        'video' => 'Video',
        'physical' => 'In-person',
        _ => type,
      };

  static Color _color(String type) => switch (type) {
        'chat' => const Color(0xFF1976D2),
        'audio' => const Color(0xFF7B1FA2),
        'video' => const Color(0xFFD84315),
        'physical' => const Color(0xFF388E3C),
        _ => AppColors.gold,
      };

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final color = _color(fee.feeType);

    return Container(
      width: s.s(112),
      padding: EdgeInsets.all(s.s(12)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(s.s(14)),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _label(fee.feeType),
            style: AppTypography.inter(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: s.fs(10),
            ),
          ),
          SizedBox(height: s.s(4)),
          Text(
            '₹${fee.amount}',
            style: AppTypography.inter(
              color: LawyerDashboardTokens.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: s.fs(17),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyRatesCta extends StatelessWidget {
  const _EmptyRatesCta({required this.scale, required this.onTap});

  final FigmaScale scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Material(
      color: AppColors.gold.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(s.s(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(s.s(14)),
        child: Padding(
          padding: EdgeInsets.all(s.s(14)),
          child: Row(
            children: [
              Icon(Icons.add_circle_outline_rounded,
                  color: AppColors.gold, size: s.s(22)),
              SizedBox(width: s.s(10)),
              Expanded(
                child: Text(
                  'Add consultation fees to start receiving bookings',
                  style: AppTypography.inter(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                    fontSize: s.fs(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTypography.inter(
                  color: LawyerDashboardTokens.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BannerChip extends StatelessWidget {
  const _BannerChip({required this.label, required this.onTap});

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
