import 'package:ashlar_lawyer_hub/core/auth/auth_session.dart';
import 'package:ashlar_lawyer_hub/core/config/api_config.dart';
import 'package:ashlar_lawyer_hub/core/layout/figma_scale.dart';
import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_colors.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_dark_scaffold.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_profile_helpers.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/lawyer_profile_repository.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/data/models/lawyer_auth_response.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/lawyer_routes.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/auth/widgets/lawyer_login_glow_background.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/dashboard/widgets/lawyer_bottom_nav_bar.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/dashboard/widgets/lawyer_bottom_nav_hit_zones.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/dashboard/widgets/lawyer_dashboard_design_tokens.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/dashboard/widgets/lawyer_shell_scope.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/lawyer_fee_and_charges_screen.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/lawyer_my_documents_screen.dart';
import 'package:ashlar_lawyer_hub/features/lawyer/presentation/profile/lawyer_select_availability_screen.dart';
import 'package:flutter/material.dart';

class LawyerMyProfileScreen extends StatefulWidget {
  const LawyerMyProfileScreen({super.key, this.embeddedInShell = false});

  final bool embeddedInShell;

  @override
  State<LawyerMyProfileScreen> createState() => _LawyerMyProfileScreenState();
}

class _LawyerMyProfileScreenState extends State<LawyerMyProfileScreen> {
  LawyerAuthResponse? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    try {
      final response = await LawyerProfileRepository.instance.getMe();
      if (mounted) {
        setState(() {
          _profile = response;
          _loading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _signOut() async {
    await AuthSession.instance.clear();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushNamedAndRemoveUntil('/role-select', (route) => false);
  }

  String get _displayName {
    final lawyer = _profile?.lawyer;
    return lawyer?.fullName ?? lawyer?.barVerifiedName ?? 'Lawyer';
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

  String get _phone =>
      _profile?.userPhone ?? _profile?.lawyer.barEnrollmentNumber ?? '';

  Color get _verificationColor {
    final profile = _profile?.lawyer;
    if (profile == null) {
      return AppColors.gold;
    }
    if (profile.isApproved || profile.verificationStatus == 'approved') {
      return const Color(0xFF2E7D32);
    }
    if (profile.verificationStatus == 'rejected') {
      return const Color(0xFFE53935);
    }
    return AppColors.gold;
  }

  void _openAppointments() {
    if (widget.embeddedInShell) {
      LawyerShellScope.switchTo(context, LawyerBottomNavTab.appointments);
      return;
    }
    Navigator.of(context).pushNamed(LawyerRoutes.manageAppointments);
  }

  void _openChatHistory() {
    if (widget.embeddedInShell) {
      LawyerShellScope.switchTo(context, LawyerBottomNavTab.chatHistory);
      return;
    }
    Navigator.of(context).pushNamed(LawyerRoutes.consultationHistory);
  }

  Future<void> _openFeeEditor() async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => const LawyerFeeAndChargesScreen(
          mode: LawyerFeeAndChargesMode.update,
        ),
      ),
    );
    if (updated == true && mounted) {
      await _loadProfile();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Charges updated')),
      );
    }
  }

  Future<void> _openAvailability() async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => const LawyerSelectAvailabilityScreen(
          mode: LawyerSelectAvailabilityMode.update,
        ),
      ),
    );
    if (updated == true && mounted) {
      await _loadProfile();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Availability updated')),
      );
    }
  }

  Future<void> _openDocuments() async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => const LawyerMyDocumentsScreen(),
      ),
    );
    if (updated == true && mounted) {
      await _loadProfile();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Documents updated')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppDarkScaffold(
      showGlow: false,
      useSafeArea: false,
      background: const LawyerLoginGlowBackground(),
      body: FigmaScreenCanvas(
        builder: (context, s) {
          final safeBottom = MediaQuery.paddingOf(context).bottom;
          final bottomPadding = widget.embeddedInShell
              ? LawyerBottomNavBar.reservedBottomPadding(context, scale: s)
              : safeBottom + s.s(24);

          return RefreshIndicator(
            color: AppColors.gold,
            onRefresh: _loadProfile,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(s.s(16), 0, s.s(16), bottomPadding),
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ProfileHeader(
                      scale: s,
                      showBack: !widget.embeddedInShell,
                      onBack: () => Navigator.of(context).maybePop(),
                    ),
                    SizedBox(height: s.s(16)),
                    if (_loading)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: s.s(48)),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.gold.withValues(alpha: 0.9),
                          ),
                        ),
                      )
                    else ...[
                      _ProfileHeroCard(
                        scale: s,
                        displayName: _displayName,
                        phone: _phone,
                        avatarUrl: _avatarUrl,
                        statusLabel: _profile != null
                            ? LawyerProfileHelpers.verificationLabel(
                                _profile!.lawyer,
                              )
                            : 'Profile',
                        statusColor: _verificationColor,
                      ),
                      SizedBox(height: s.s(16)),
                      _SettingsPanel(
                        scale: s,
                        items: [
                          _ProfileMenuItem(
                            icon: Icons.person_outline_rounded,
                            label: 'Manage profile',
                            subtitle: 'Practice area, experience & bio',
                            color: const Color(0xFF1976D2),
                            onTap: () => Navigator.of(context)
                                .pushNamed(LawyerRoutes.manageProfile)
                                .then((_) => _loadProfile()),
                          ),
                          _ProfileMenuItem(
                            icon: Icons.event_available_rounded,
                            label: 'Manage appointments',
                            subtitle: 'Confirm and track bookings',
                            color: const Color(0xFF7B1FA2),
                            onTap: _openAppointments,
                          ),
                          _ProfileMenuItem(
                            icon: Icons.payments_outlined,
                            label: 'Consultation charges',
                            subtitle: 'Chat, audio, video and in-person fees',
                            color: AppColors.gold,
                            onTap: _openFeeEditor,
                          ),
                          _ProfileMenuItem(
                            icon: Icons.schedule_rounded,
                            label: 'Availability',
                            subtitle: 'Working days and hours',
                            color: const Color(0xFF00897B),
                            onTap: _openAvailability,
                          ),
                          _ProfileMenuItem(
                            icon: Icons.folder_outlined,
                            label: 'Documents',
                            subtitle: 'Profile photo, identity proof & degree',
                            color: const Color(0xFFD84315),
                            onTap: _openDocuments,
                          ),
                          _ProfileMenuItem(
                            icon: Icons.chat_bubble_outline_rounded,
                            label: 'Chat & call history',
                            subtitle: 'Past online consultations',
                            color: const Color(0xFF5E35B1),
                            onTap: _openChatHistory,
                            showDivider: false,
                          ),
                        ],
                      ),
                      SizedBox(height: s.s(16)),
                      _SignOutButton(onTap: _signOut),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.scale,
    required this.showBack,
    required this.onBack,
  });

  final FigmaScale scale;
  final bool showBack;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Row(
      children: [
        if (showBack)
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onBack,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: s.s(40),
                height: s.s(40),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: LawyerDashboardTokens.textPrimary,
                  size: s.s(20),
                ),
              ),
            ),
          )
        else
          SizedBox(width: s.s(40)),
        SizedBox(width: s.s(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Profile',
                style: AppTypography.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: s.fs(20),
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'Manage your practice settings',
                style: AppTypography.inter(
                  color: Colors.white54,
                  fontSize: s.fs(11),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({
    required this.scale,
    required this.displayName,
    required this.phone,
    required this.avatarUrl,
    required this.statusLabel,
    required this.statusColor,
  });

  final FigmaScale scale;
  final String displayName;
  final String phone;
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
            AppColors.gold.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(s.s(LawyerDashboardTokens.radiusLg)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          _AvatarRing(scale: s, url: avatarUrl),
          SizedBox(width: s.s(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Adv. $displayName',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: s.fs(18),
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                ),
                if (phone.isNotEmpty) ...[
                  SizedBox(height: s.s(4)),
                  Text(
                    phone,
                    style: AppTypography.inter(
                      color: Colors.white60,
                      fontSize: s.fs(12),
                    ),
                  ),
                ],
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

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({required this.scale, required this.items});

  final FigmaScale scale;
  final List<_ProfileMenuItem> items;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Container(
      decoration: LawyerDashboardTokens.surfaceDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(s.s(16), s.s(16), s.s(16), s.s(8)),
            child: Row(
              children: [
                Container(
                  width: s.s(36),
                  height: s.s(36),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(s.s(10)),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    color: AppColors.gold,
                    size: s.s(18),
                  ),
                ),
                SizedBox(width: s.s(10)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account & practice',
                        style: AppTypography.inter(
                          color: LawyerDashboardTokens.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: s.fs(14),
                        ),
                      ),
                      Text(
                        'Everything clients see about you',
                        style: AppTypography.inter(
                          color: LawyerDashboardTokens.textSecondary,
                          fontSize: s.fs(10),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          for (final item in items) item,
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
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
                            color: LawyerDashboardTokens.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: AppTypography.inter(
                            color: LawyerDashboardTokens.textSecondary,
                            fontSize: 11,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: color.withValues(alpha: 0.8),
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            indent: 68,
            color: LawyerDashboardTokens.surfaceBorder,
          ),
      ],
    );
  }
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE53935).withValues(alpha: 0.35)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout_rounded,
                color: const Color(0xFFE53935).withValues(alpha: 0.9),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Sign out',
                style: AppTypography.inter(
                  color: const Color(0xFFE53935),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
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
    final size = s.s(64);

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
