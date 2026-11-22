import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/challan/user_challan_portal_screen.dart';
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

  static final _vehiclePattern = RegExp(r'^[A-Z]{2}[0-9]{1,2}[A-Z]{1,3}[0-9]{1,4}$');

  @override
  void dispose() {
    _vehicleController.dispose();
    super.dispose();
  }

  bool _isValidVehicle(String raw) {
    final normalized = raw.replaceAll(RegExp(r'[\s\-]'), '').toUpperCase();
    if (normalized.length < 6 || normalized.length > 11) {
      return false;
    }
    return _vehiclePattern.hasMatch(normalized) || normalized.length >= 6;
  }

  String _normalizeVehicle(String raw) {
    return raw.replaceAll(RegExp(r'[\s\-]'), '').toUpperCase();
  }

  void _onConfirm() {
    FocusScope.of(context).unfocus();
    final vehicle = _normalizeVehicle(_vehicleController.text);
    if (vehicle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your vehicle number')),
      );
      return;
    }
    if (!_isValidVehicle(vehicle)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid Indian vehicle number (e.g. DL01AB1234)'),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => UserChallanPortalScreen(vehicleNumber: vehicle),
      ),
    );
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
        subtitle: 'Official government eChallan portal',
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
                const Icon(Icons.verified_outlined,
                    color: UserDesignTokens.gold, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'You will be redirected to the official MoRTH eChallan website '
                    'to view challan details and pay securely on the government portal.',
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
                  'We copy your number for quick paste on eChallan, then open the trusted site in your browser.',
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
              onPressed: _onConfirm,
              style: FilledButton.styleFrom(
                backgroundColor: UserDesignTokens.gold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Continue to eChallan',
                style: AppTypography.inter(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}