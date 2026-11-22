import 'package:ashlar_lawyer_hub/core/config/challan_portal_config.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/widgets/user_design_tokens.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/widgets/user_premium_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// After vehicle entry, routes the user to the official eChallan portal.
class UserChallanPortalScreen extends StatefulWidget {
  const UserChallanPortalScreen({super.key, required this.vehicleNumber});

  final String vehicleNumber;

  @override
  State<UserChallanPortalScreen> createState() => _UserChallanPortalScreenState();
}

class _UserChallanPortalScreenState extends State<UserChallanPortalScreen> {
  bool _opening = false;
  bool _copied = false;

  Future<void> _openPortal() async {
    final uri = Uri.parse(ChallanPortalConfig.accusedChallanUrl);
    setState(() => _opening = true);
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!mounted) {
        return;
      }
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open browser. Please open eChallan manually.'),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to open official challan portal')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _opening = false);
      }
    }
  }

  Future<void> _copyVehicle() async {
    await Clipboard.setData(ClipboardData(text: widget.vehicleNumber));
    if (mounted) {
      setState(() => _copied = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle number copied')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _copyVehicle();
      await _openPortal();
    });
  }

  @override
  Widget build(BuildContext context) {
    return UserPremiumScaffold(
      appBar: const UserPremiumAppBar(
        title: 'Official challan check',
        subtitle: ChallanPortalConfig.portalName,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: UserDesignTokens.goldAccentCard(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified_user_outlined,
                        color: UserDesignTokens.gold, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        ChallanPortalConfig.portalAuthority,
                        style: AppTypography.inter(
                          fontSize: 13,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                          color: UserDesignTokens.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Ashlar does not store challan payment data on this step. '
                  'View and pay fines only on the government ${ChallanPortalConfig.portalName} website.',
                  style: AppTypography.inter(
                    fontSize: 12,
                    height: 1.45,
                    color: UserDesignTokens.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Your vehicle',
            style: AppTypography.inter(
              fontSize: 13,
              color: UserDesignTokens.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: UserDesignTokens.premiumCard(),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.vehicleNumber,
                    style: AppTypography.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: UserDesignTokens.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _copyVehicle,
                  icon: Icon(
                    _copied ? Icons.check_rounded : Icons.copy_rounded,
                    color: UserDesignTokens.gold,
                  ),
                  tooltip: 'Copy',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'On the eChallan page, paste your vehicle number when asked, then '
            'complete OTP verification on the government site to see challan details.',
            style: AppTypography.inter(
              fontSize: 13,
              height: 1.45,
              color: UserDesignTokens.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _opening ? null : _openPortal,
              icon: _opening
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Icon(Icons.open_in_browser_rounded),
              label: Text(
                _opening ? 'Opening…' : 'Open eChallan website',
                style: AppTypography.inter(fontWeight: FontWeight.w700),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: UserDesignTokens.gold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            ChallanPortalConfig.accusedChallanUrl,
            textAlign: TextAlign.center,
            style: AppTypography.inter(
              fontSize: 11,
              color: UserDesignTokens.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}