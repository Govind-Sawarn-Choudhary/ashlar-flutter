import 'package:ashlar_lawyer_hub/core/theme/app_typography.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/widgets/user_design_tokens.dart';
import 'package:ashlar_lawyer_hub/features/user/presentation/widgets/user_premium_widgets.dart';
import 'package:flutter/material.dart';

String consultationTypeLabel(String type) {
  return switch (type) {
    'audio' => 'Phone Call',
    'video' => 'Video Call',
    'chat' => 'Chat',
    'physical' => 'In-Person Meeting',
    _ => type,
  };
}

String modeLabel(String mode) => mode == 'offline' ? 'In-Person' : 'Online';

class UserBookingScaffold extends StatelessWidget {
  const UserBookingScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.body,
    this.bottomBar,
    this.onBack,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final Widget? bottomBar;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return UserPremiumScaffold(
      appBar: UserPremiumAppBar(
        title: title,
        subtitle: subtitle,
        leading: IconButton(
          onPressed: onBack ?? () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: UserDesignTokens.textPrimary, size: 20),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: body),
          if (bottomBar != null) bottomBar!,
        ],
      ),
    );
  }
}

class UserBookingOptionCard extends StatelessWidget {
  const UserBookingOptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UserDesignTokens.radiusMd),
        child: Ink(
          decoration: selected
              ? UserDesignTokens.goldAccentCard()
              : UserDesignTokens.premiumCard(),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: UserDesignTokens.goldSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: UserDesignTokens.gold, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: UserDesignTokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTypography.inter(
                        fontSize: 12,
                        height: 1.35,
                        color: UserDesignTokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: selected ? UserDesignTokens.gold : UserDesignTokens.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserBookingSummaryRow extends StatelessWidget {
  const UserBookingSummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTypography.inter(
                fontSize: 13,
                color: UserDesignTokens.textMuted,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTypography.inter(
                fontSize: 14,
                fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
                color: highlight ? UserDesignTokens.gold : UserDesignTokens.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UserBookingPrimaryButton extends StatelessWidget {
  const UserBookingPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: !enabled || loading ? null : onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: UserDesignTokens.gold,
              foregroundColor: Colors.black,
              disabledBackgroundColor: UserDesignTokens.gold.withValues(alpha: 0.35),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                  )
                : Text(
                    label,
                    style: AppTypography.inter(fontWeight: FontWeight.w800, fontSize: 15),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Modal-style full screen with dimmed backdrop for booking step pickers.
class UserBookingPickerScreen extends StatelessWidget {
  const UserBookingPickerScreen({
    super.key,
    required this.title,
    required this.options,
    this.lawyerName,
  });

  final String title;
  final String? lawyerName;
  final List<Widget> options;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                behavior: HitTestBehavior.opaque,
                child: const SizedBox.expand(),
              ),
            ),
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF141418),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: AppTypography.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: UserDesignTokens.textPrimary,
                    ),
                  ),
                  if (lawyerName != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      lawyerName!,
                      style: AppTypography.inter(
                        fontSize: 13,
                        color: UserDesignTokens.gold,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  ...options,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
