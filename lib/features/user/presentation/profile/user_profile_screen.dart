import 'package:ashlar_lawyer_hub/core/auth/auth_session.dart';
import 'package:ashlar_lawyer_hub/core/widgets/app_messenger.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/features/user/data/user_repository.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/home/widgets/user_bottom_nav_bar.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/profile/user_manage_profile_screen.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/widgets/user_design_tokens.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/widgets/user_premium_widgets.dart';
import 'package:ashlar_lawyer_hub/features/user/user_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key, this.embeddedInShell = false});

  final bool embeddedInShell;

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String _displayName = '';
  String? _email;
  String? _location;
  String _supportPhone = '';
  Map<String, String> _socialLinks = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final me = await UserRepository.instance.getMe();
      final support = await UserRepository.instance.getSupportInfo();
      if (mounted) {
        setState(() {
          _displayName = me.profile.fullName ?? 'User';
          _email = me.profile.email;
          _location = me.profile.location;
          _supportPhone = support.supportPhone;
          _socialLinks = support.socialLinks;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Could not load profile';
        });
      }
    }
  }

  Future<void> _signOut() async {
    await AuthSession.instance.clear();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushNamedAndRemoveUntil('/role-select', (_) => false);
  }

  Future<void> _openManageProfile() async {
    final updated = await Navigator.of(context, rootNavigator: true).push<bool>(
      MaterialPageRoute<bool>(
        fullscreenDialog: false,
        builder: (_) => const UserManageProfileScreen(),
      ),
    );
    if (updated == true) {
      await _loadProfile();
    }
  }

  void _copySupport() {
    Clipboard.setData(ClipboardData(text: _supportPhone));
    AppMessenger.show(context, 'Support number copied', type: AppMessageType.success);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = widget.embeddedInShell
        ? UserBottomNavBar.reservedBottomPadding(context)
        : 16.0;

    return UserPremiumScaffold(
      bottomPadding: bottomPad,
      appBar: const UserPremiumAppBar(
        title: 'My profile',
        subtitle: 'Account & preferences',
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: UserDesignTokens.gold),
            )
          : _error != null
              ? UserEmptyState(
                  icon: Icons.person_outline,
                  title: 'Profile unavailable',
                  subtitle: _error!,
                  actionLabel: 'Retry',
                  onAction: _loadProfile,
                )
              : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                Container(
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
                            _displayName.isNotEmpty
                                ? _displayName[0].toUpperCase()
                                : 'U',
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
                              _displayName,
                              style: AppTypography.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: UserDesignTokens.textPrimary,
                              ),
                            ),
                            if (_email?.isNotEmpty == true)
                              Text(
                                _email!,
                                style: AppTypography.inter(
                                  fontSize: 13,
                                  color: UserDesignTokens.textMuted,
                                ),
                              ),
                            if (_location?.isNotEmpty == true)
                              Text(
                                _location!,
                                style: AppTypography.inter(
                                  fontSize: 12,
                                  color: UserDesignTokens.gold,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _MenuTile(
                  icon: Icons.manage_accounts_outlined,
                  title: 'Manage profile',
                  subtitle: 'View & edit your personal details',
                  onTap: _openManageProfile,
                ),
                _MenuTile(
                  icon: Icons.calendar_today_outlined,
                  title: 'My appointments',
                  subtitle: 'View and join consultations',
                  onTap: () =>
                      Navigator.of(context).pushNamed(UserRoutes.myAppointments),
                ),
                _MenuTile(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'My wallet',
                  subtitle: 'Balance, top-up & payments',
                  onTap: () =>
                      Navigator.of(context).pushNamed(UserRoutes.wallet),
                ),
                _MenuTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Booking updates & alerts',
                  onTap: () =>
                      Navigator.of(context).pushNamed(UserRoutes.notifications),
                ),
                const SizedBox(height: 16),
                UserSectionHeader(title: 'Support'),
                _MenuTile(
                  icon: Icons.support_agent_outlined,
                  title: 'Call support',
                  subtitle: _supportPhone.isNotEmpty
                      ? _supportPhone
                      : 'Tap to copy support number',
                  onTap: _copySupport,
                ),
                if (_socialLinks.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _socialLinks.entries.map((entry) {
                      return ActionChip(
                        label: Text(entry.key),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: entry.value));
                          AppMessenger.show(
                            context,
                            '${entry.key} link copied',
                            type: AppMessageType.success,
                          );
                        },
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: _signOut,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: UserDesignTokens.error,
                    side: const BorderSide(color: UserDesignTokens.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Sign out'),
                ),
              ],
            ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(UserDesignTokens.radiusMd),
          child: Ink(
            decoration: UserDesignTokens.premiumCard(),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: UserDesignTokens.gold),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.inter(
                          fontWeight: FontWeight.w600,
                          color: UserDesignTokens.textPrimary,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: AppTypography.inter(
                          fontSize: 12,
                          color: UserDesignTokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: UserDesignTokens.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
