import 'package:ashlar_lawyer_hub/core/network/api_exception.dart';
import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/features/user/data/user_repository.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/challan/user_challan_otp_screen.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/home/widgets/user_bottom_nav_bar.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/widgets/user_design_tokens.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/widgets/user_premium_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserChallanScreen extends StatefulWidget {
  const UserChallanScreen({super.key, this.embeddedInShell = false});

  final bool embeddedInShell;

  @override
  State<UserChallanScreen> createState() => _UserChallanScreenState();
}

class _UserChallanScreenState extends State<UserChallanScreen> {
  final _vehicleController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _vehicleController.dispose();
    super.dispose();
  }

  Future<void> _onConfirm() async {
    FocusScope.of(context).unfocus();
    final vehicle = _vehicleController.text.trim().toUpperCase();
    if (vehicle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your vehicle number')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await UserRepository.instance.lookupChallan(vehicle);
      if (!mounted) {
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => UserChallanOtpScreen(vehicleNumber: vehicle),
        ),
      );
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = widget.embeddedInShell
        ? UserBottomNavBar.reservedBottomPadding(context)
        : 16.0;

    return UserPremiumScaffold(
      bottomPadding: bottomPad,
      appBar: const UserPremiumAppBar(
        title: 'Challan status',
        subtitle: 'Check and pay traffic fines',
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: UserDesignTokens.premiumCard(
              tint: UserDesignTokens.goldSoft.withValues(alpha: 0.15),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.science_outlined,
                    color: UserDesignTokens.gold, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Demo mode: sample challan data for testing. Live Parivahan integration will ship in a future update.',
                    style: AppTypography.inter(
                      fontSize: 12,
                      height: 1.4,
                      color: UserDesignTokens.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: UserDesignTokens.goldAccentCard(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.directions_car_filled,
                        color: UserDesignTokens.gold, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Enter vehicle number',
                        style: AppTypography.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: UserDesignTokens.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'We will verify your vehicle and show pending challans.',
                  style: AppTypography.inter(
                    fontSize: 13,
                    height: 1.4,
                    color: UserDesignTokens.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _vehicleController,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9\- ]')),
            ],
            style: AppTypography.inter(
              color: UserDesignTokens.textPrimary,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
            decoration: InputDecoration(
              labelText: 'Vehicle number',
              hintText: 'e.g. DL01AB1234',
              labelStyle: AppTypography.inter(color: UserDesignTokens.textMuted),
              filled: true,
              fillColor: UserDesignTokens.surfaceElevated,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.confirmation_number_outlined,
                  color: UserDesignTokens.gold),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _submitting ? null : _onConfirm,
              style: FilledButton.styleFrom(
                backgroundColor: UserDesignTokens.gold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : Text(
                      'Check challan status',
                      style: AppTypography.inter(fontWeight: FontWeight.w700),
                    ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: UserDesignTokens.premiumCard(),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: UserDesignTokens.gold, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Demo mode: use OTP 1234 after vehicle lookup for testing.',
                    style: AppTypography.inter(
                      fontSize: 12,
                      height: 1.4,
                      color: UserDesignTokens.textMuted,
                    ),
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
